@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0.."

call "installer\RELEASE_URLS.bat"
set "PROJECT_DIR=%CD%"

set "LOG=%CD%\release\BUILD_LOG.txt"
if not exist "release" mkdir "release"
> "%LOG%" echo Trump Simulator 1.0 - Official Release Build Log
>>"%LOG%" echo Started: %DATE% %TIME%
>>"%LOG%" echo Project: %CD%
>>"%LOG%" echo.

echo =====================================================
echo   TRUMP SIMULATOR 1.0 - OFFICIAL RELEASE BUILDER
echo   Simulated Studios
echo =====================================================
echo.
echo A build log will be saved to:
echo   release\BUILD_LOG.txt
echo.

rem =====================================================
rem FIND GODOT
rem =====================================================
set "GODOT="

rem 1. PATH
for %%G in (godot.exe godot4.exe) do (
    if not defined GODOT (
        for /f "delims=" %%P in ('where %%G 2^>nul') do (
            if not defined GODOT set "GODOT=%%P"
        )
    )
)

rem 2. Common installed locations
if not defined GODOT if exist "%LOCALAPPDATA%\Programs\Godot\Godot.exe" set "GODOT=%LOCALAPPDATA%\Programs\Godot\Godot.exe"
if not defined GODOT if exist "%ProgramFiles%\Godot\Godot.exe" set "GODOT=%ProgramFiles%\Godot\Godot.exe"
if not defined GODOT if exist "%ProgramFiles(x86)%\Godot\Godot.exe" set "GODOT=%ProgramFiles(x86)%\Godot\Godot.exe"

rem 3. Common portable locations - Desktop / Downloads.
if not defined GODOT (
    for /f "delims=" %%P in ('dir /b /s "%USERPROFILE%\Desktop\Godot*.exe" 2^>nul ^| findstr /v /i "_console.exe"') do (
        if not defined GODOT set "GODOT=%%P"
    )
)
if not defined GODOT (
    for /f "delims=" %%P in ('dir /b /s "%USERPROFILE%\Downloads\Godot*.exe" 2^>nul ^| findstr /v /i "_console.exe"') do (
        if not defined GODOT set "GODOT=%%P"
    )
)

rem 4. Ask user.
if not defined GODOT (
    echo [ACTION NEEDED] I could not automatically find Godot.
    echo.
    echo Find your Godot .exe in File Explorer.
    echo You can drag the Godot .exe into this window, then press ENTER.
    echo.
    set /p "GODOT=Godot path: "
    set "GODOT=!GODOT:"=!"
)

if not defined GODOT (
    echo.
    echo [ERROR] No Godot path was supplied.
    >>"%LOG%" echo ERROR: No Godot path was supplied.
    pause
    exit /b 1
)

if not exist "%GODOT%" (
    echo.
    echo [ERROR] Godot was not found at:
    echo   %GODOT%
    >>"%LOG%" echo ERROR: Godot path does not exist: %GODOT%
    pause
    exit /b 1
)

echo Found Godot:
echo   %GODOT%
>>"%LOG%" echo GODOT=%GODOT%

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "if (-not (Test-Path -LiteralPath $env:GODOT -PathType Leaf)) { Write-Error 'Godot executable does not exist'; exit 2 }; & $env:GODOT --version; exit $LASTEXITCODE" >>"%LOG%" 2>&1

if errorlevel 1 (
    echo.
    echo [ERROR] Windows found the Godot file but could not launch it.
    echo.
    echo Try double-clicking this exact file:
    echo   %GODOT%
    echo.
    echo If Godot does not open, download Godot again.
    echo If it DOES open, send me release\BUILD_LOG.txt.
    >>"%LOG%" echo ERROR: Godot executable could not be launched by PowerShell.
    pause
    exit /b 1
)

rem =====================================================
rem EXPORT GAME
rem =====================================================
echo.
echo [1/4] Exporting Trump Simulator 1.0...
echo This can take a little while.
echo.

if exist "build\TrumpSimulator.exe" del /q "build\TrumpSimulator.exe" >nul 2>nul
if exist "build\TrumpSimulator.pck" del /q "build\TrumpSimulator.pck" >nul 2>nul
if not exist "build" mkdir "build"

>>"%LOG%" echo.
>>"%LOG%" echo ===== GODOT EXPORT =====
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "& $env:GODOT --headless --path $env:PROJECT_DIR --export-release 'Windows Desktop' 'build\TrumpSimulator.exe'; exit $LASTEXITCODE" >>"%LOG%" 2>&1

if errorlevel 1 (
    echo.
    echo [ERROR] Godot could not export the game.
    echo.
    echo Most common causes:
    echo   1. Windows export templates are not installed in Godot.
    echo   2. The project has a script/parse error.
    echo   3. The Windows Desktop export preset is missing.
    echo.
    echo Open:
    echo   release\BUILD_LOG.txt
    echo.
    echo The LAST lines of that file will tell us the exact Godot error.
    >>"%LOG%" echo ERROR: Godot export returned a failure code.
    pause
    exit /b 1
)

if not exist "build\TrumpSimulator.exe" (
    echo.
    echo [ERROR] Godot finished but build\TrumpSimulator.exe was not created.
    >>"%LOG%" echo ERROR: build\TrumpSimulator.exe not created.
    pause
    exit /b 1
)

echo [OK] Game exported.
>>"%LOG%" echo OK: Game exported.

rem =====================================================
rem FIND INNO SETUP
rem =====================================================
echo.
echo [2/4] Finding Inno Setup 6...
set "ISCC="

if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if not defined ISCC if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles%\Inno Setup 6\ISCC.exe"

if not defined ISCC (
    for /f "delims=" %%P in ('where ISCC.exe 2^>nul') do (
        if not defined ISCC set "ISCC=%%P"
    )
)

if not defined ISCC (
    echo.
    echo [ACTION NEEDED] Inno Setup 6 was not found.
    echo.
    echo Install Inno Setup 6, then run this builder again.
    echo The Godot game export already succeeded, so you do NOT need
    echo to redo anything else.
    >>"%LOG%" echo ERROR: Inno Setup 6 not found.
    pause
    exit /b 1
)

echo Found Inno Setup:
echo   %ISCC%
>>"%LOG%" echo ISCC=%ISCC%

rem =====================================================
rem BUILD INSTALLER
rem =====================================================
echo.
echo [3/4] Building official installer...
>>"%LOG%" echo.
>>"%LOG%" echo ===== INNO SETUP =====
"%ISCC%" "installer\TrumpSimulator.iss" >>"%LOG%" 2>&1

if errorlevel 1 (
    echo.
    echo [ERROR] Inno Setup could not build the installer.
    echo Open release\BUILD_LOG.txt and send me the last error lines.
    >>"%LOG%" echo ERROR: Inno Setup returned a failure code.
    pause
    exit /b 1
)

if not exist "release\TrumpSimulatorSetup.exe" (
    echo.
    echo [ERROR] Inno Setup completed but the installer was not found.
    >>"%LOG%" echo ERROR: release\TrumpSimulatorSetup.exe not found.
    pause
    exit /b 1
)

echo [OK] Installer created.
>>"%LOG%" echo OK: Installer created.

rem =====================================================
rem CREATE UPDATE.JSON
rem =====================================================
echo.
echo [4/4] Creating website update manifest...

set "SETUP_SHA256="
for /f "delims=" %%H in ('powershell.exe -NoProfile -Command "(Get-FileHash -Algorithm SHA256 -LiteralPath 'release\TrumpSimulatorSetup.exe').Hash.ToLower()"') do set "SETUP_SHA256=%%H"

if not defined SETUP_SHA256 (
    echo.
    echo [ERROR] Windows PowerShell could not calculate the installer SHA-256.
    >>"%LOG%" echo ERROR: SHA-256 generation failed.
    pause
    exit /b 1
)

>>"%LOG%" echo SHA256=%SETUP_SHA256%

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$notes=(Get-Content -Raw 'installer\UPDATE_NOTES.txt').Trim();" ^
  "$manifest=[ordered]@{version='1.1.0';download_url='%TS_INSTALLER_URL%';sha256='%SETUP_SHA256%';required=$false;notes=$notes;published_at=(Get-Date).ToUniversalTime().ToString('o')};" ^
  "$manifest | ConvertTo-Json -Depth 4 | Set-Content -Encoding utf8 'release\update.json'" >>"%LOG%" 2>&1

if errorlevel 1 (
    echo.
    echo [ERROR] Could not generate release\update.json.
    echo Open release\BUILD_LOG.txt for details.
    >>"%LOG%" echo ERROR: update.json generation failed.
    pause
    exit /b 1
)

if not exist "release\update.json" (
    echo.
    echo [ERROR] release\update.json was not created.
    >>"%LOG%" echo ERROR: update.json missing.
    pause
    exit /b 1
)

>>"%LOG%" echo.
>>"%LOG%" echo BUILD SUCCESSFUL: %DATE% %TIME%

echo.
echo =====================================================
echo   SUCCESS - TRUMP SIMULATOR 1.0 IS BUILT
echo =====================================================
echo.
echo Your official installer is:
echo.
echo   release\TrumpSimulatorSetup.exe
echo.
echo Your website updater file is:
echo.
echo   release\update.json
echo.
echo BUILD_LOG.txt has also been saved for troubleshooting.
echo.
pause
