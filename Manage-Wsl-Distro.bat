@echo off
setlocal enabledelayedexpansion

:: Ensure the script runs with admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Please run as admin.
    pause
    exit /b 1
)
echo Admin rights confirmed.

:: Initialization
set "working_directory_location=%~dp0"
set "working_directory_location=%working_directory_location:~0,-1%"
pushd "%working_directory_location%"
echo Working Dir: "%working_directory_location%"

:: Call the PowerShell script...
echo Executing PowerShell 7 Script...
powershell -ExecutionPolicy Bypass -NoProfile -File "manage-wsl-distro.ps1"
echo PowerShell 7 Script Exited.

::: End of Script.
echo Exit Sequence Initiated.
pause
exit /b 0
