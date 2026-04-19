@echo off
setlocal

set "PORT=%~1"
if "%PORT%"=="" set "PORT=9222"

REM Kill existing TradingView instances
taskkill /F /IM TradingView.exe >nul 2>&1
timeout /t 2 /nobreak >nul

REM >>> Hardcode TradingView MSIX path (from your PowerShell output)
set "TV_EXE=C:\Program Files\WindowsApps\TradingView.Desktop_3.0.0.7652_x64__n534cwy3pjxzj\TradingView.exe"

if not exist "%TV_EXE%" (
  echo Error: TradingView.exe not found at:
  echo   "%TV_EXE%"
  echo Tip: TradingView may have auto-updated. Re-run the PowerShell search to get the new path.
  exit /b 1
)

echo Found TradingView at: "%TV_EXE%"
echo Starting with --remote-debugging-port=%PORT%...
start "" "%TV_EXE%" --remote-debugging-port=%PORT%

echo Waiting for CDP to become available...
timeout /t 5 /nobreak >nul

:check
curl -s http://localhost:%PORT%/json/version >nul 2>&1
if %errorlevel% neq 0 (
  echo Still waiting...
  timeout /t 2 /nobreak >nul
  goto check
)

echo.
echo CDP ready at http://localhost:%PORT%
curl -s http://localhost:%PORT%/json/version
echo.
endlocal