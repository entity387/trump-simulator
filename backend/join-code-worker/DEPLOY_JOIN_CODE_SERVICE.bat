@echo off
setlocal
cd /d "%~dp0"

echo ===============================================
echo Trump Simulator - Join Code Service Deployment
echo ===============================================
echo.

where npm >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Node.js / npm was not found.
    echo Install Node.js first, then run this again.
    pause
    exit /b 1
)

if not exist node_modules (
    echo Installing Wrangler...
    call npm install
    if errorlevel 1 exit /b 1
)

echo.
echo Cloudflare may open a browser window for login.
echo.
call npm run deploy

echo.
echo Copy the deployed Worker URL into project.godot:
echo trump_simulator/multiplayer/join_code_api
echo.
pause
