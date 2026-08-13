@echo off
setlocal EnableExtensions
cd /d "%~dp0.."

echo ===============================================
echo Trump Simulator - Installer Build Diagnostics
echo ===============================================
echo.

echo [Project Folder]
echo %CD%
echo.

echo [Godot on PATH]
where godot.exe 2>nul
where godot4.exe 2>nul
echo.

echo [Inno Setup]
if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" echo %ProgramFiles(x86)%\Inno Setup 6\ISCC.exe
if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" echo %ProgramFiles%\Inno Setup 6\ISCC.exe
where ISCC.exe 2>nul
echo.

echo [Required project files]
if exist "project.godot" (echo OK project.godot) else (echo MISSING project.godot)
if exist "export_presets.cfg" (echo OK export_presets.cfg) else (echo MISSING export_presets.cfg)
if exist "installer\TrumpSimulator.iss" (echo OK TrumpSimulator.iss) else (echo MISSING TrumpSimulator.iss)
if exist "installer\TrumpSimulator.ico" (echo OK TrumpSimulator.ico) else (echo MISSING TrumpSimulator.ico)
echo.

echo If the main builder fails, send me:
echo   release\BUILD_LOG.txt
echo.
pause
