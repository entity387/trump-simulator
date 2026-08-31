@echo off
setlocal EnableExtensions
cd /d "%~dp0.."
call "installer\RELEASE_URLS.bat"

if not exist "build\TrumpSimulator.exe" (
    echo [ERROR] build\TrumpSimulator.exe is missing.
    echo Export the Windows Desktop game first.
    pause
    exit /b 1
)

set "ISCC="
if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles%\Inno Setup 6\ISCC.exe"
where ISCC.exe >nul 2>nul && set "ISCC=ISCC.exe"

if not defined ISCC (
    echo [ERROR] Inno Setup 6 was not found.
    pause
    exit /b 1
)

if not exist "release" mkdir "release"
"%ISCC%" "installer\TrumpSimulator.iss"
if errorlevel 1 exit /b 1

for /f "delims=" %%H in ('powershell -NoProfile -Command "(Get-FileHash -Algorithm SHA256 -LiteralPath 'release\TrumpSimulatorSetup.exe').Hash.ToLower()"') do set "SETUP_SHA256=%%H"
if not defined SETUP_SHA256 (
    echo [ERROR] Could not calculate installer SHA-256.
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$notes=(Get-Content -Raw 'installer\UPDATE_NOTES.txt').Trim();" ^
  "$manifest=[ordered]@{version='1.1.0';download_url='%TS_PACKAGE_URL%';installer_filename='TrumpSimulatorSetup.exe';sha256='%SETUP_SHA256%';required=$false;notes=$notes;published_at=(Get-Date).ToUniversalTime().ToString('o')};" ^
  "$manifest | ConvertTo-Json -Depth 4 | Set-Content -Encoding utf8 'release\update.json'"
if errorlevel 1 exit /b 1

if exist "release\%TS_PACKAGE_NAME%" del /q "release\%TS_PACKAGE_NAME%"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Compress-Archive -Force -LiteralPath 'release\TrumpSimulatorSetup.exe','release\update.json' -DestinationPath 'release\%TS_PACKAGE_NAME%'"
if errorlevel 1 exit /b 1

echo.
echo Created:
echo   release\TrumpSimulatorSetup.exe
echo   release\update.json
echo   release\%TS_PACKAGE_NAME%
echo.
echo Upload the ZIP to the R2 bucket and publish update.json on simulatedstudios.com.
echo.
pause
