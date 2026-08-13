@echo off
setlocal EnableExtensions
echo ===============================================
echo Trump Simulator - Godot Launch Test
echo ===============================================
echo.

set "GODOT=C:\Users\Rhys.doughty\Downloads\Godot_v4.7.1-stable_win64.exe"

echo Testing:
echo   %GODOT%
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$p=$env:GODOT; if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { Write-Host '[FAIL] File does not exist.'; exit 2 }; $f=Get-Item -LiteralPath $p; Write-Host ('File size: ' + [math]::Round($f.Length/1MB,2) + ' MB'); Write-Host 'Launching Godot --version...'; & $p --version; exit $LASTEXITCODE"

if errorlevel 1 (
    echo.
    echo [FAIL] Windows could not launch that Godot executable.
    echo Double-click the Godot file in Downloads.
    echo If it will not open normally, download Godot again.
) else (
    echo.
    echo [PASS] Godot launches correctly.
    echo Now run BUILD_OFFICIAL_INSTALLER.bat.
)
echo.
pause
