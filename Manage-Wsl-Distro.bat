:: Script: `.\Manager-Wsl-Distro.Bat`

:: Initialization
@echo off
setlocal enabledelayedexpansion
title Manager-Wsl-Distro
color 80
echo Initialization Complete.
timeout /t 1 >nul

:: DISPLAY BANNER: START
cls
echo ========================================================================================================================
echo     Manager-Wsl-Distro
echo ========================================================================================================================
echo.
timeout /t 1 >nul
:: DISPLAY BANNER: END

:: CHECK ADMIN BLOCK, DO NOT, MODIFY or MOVE: START
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Error: Admin Required!
    timeout /t 2 >nul
    echo Right Click, Run As Administrator.
    timeout /t 2 >nul
    goto :end_of_script
)
echo Status: Administrator
timeout /t 1 >nul
:: CHECK ADMIN BLOCK, DO NOT, MODIFY or MOVE: END

:: DP0 TO SCRIPT BLOCK, DO NOT, MODIFY or MOVE: START
set "ScriptDirectory=%~dp0"
set "ScriptDirectory=%ScriptDirectory:~0,-1%"
cd /d "%ScriptDirectory%"
echo Dp0'd to Script.
timeout /t 1 >nul
:: DP0 TO SCRIPT BLOCK, DO NOT, MODIFY or MOVE: END

:: EXECUTE_MAIN: START
echo.
echo Executing PowerShell-Core Script...
timeout /t 2 /nobreak >nul
@echo on
pwsh -ExecutionPolicy Bypass -File manage-wsl-distro.ps1
@echo off
echo.
echo Remember to move Completed Files to Intended Destinations!
echo.
timeout /t 2 /nobreak >nul
:: EXECUTE_MAIN: END

:end_of_script
echo Batch Processes Finished.
echo Exiting Batch Script.
timeout /t 3 /nobreak >nul
echo.
set /p input=(Press Enter to Finish...)
