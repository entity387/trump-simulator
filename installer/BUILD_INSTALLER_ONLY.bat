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

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$notes=(Get-Content -Raw 'installer\UPDATE_NOTES.txt').Trim();" ^
  "$manifest=[ordered]@{version='1.0.0';download_url='%TS_INSTALLER_URL%';sha256='%SETUP_SHA256%';required=$false;notes=$notes;published_at=(Get-Date).ToUniversalTime().ToString('o')};" ^
  "$manifest | ConvertTo-Json -Depth 4 | Set-Content -Encoding utf8 'release\update.json'"

echo.
echo Created:
echo   release\TrumpSimulatorSetup.exe
echo   release\update.json
echo.
pause
