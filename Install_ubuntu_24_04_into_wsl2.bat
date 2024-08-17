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

:: Global Variables
set "scriptDir=%~dp0"
set "wslDistroName=Ubuntu-24.04-LTS"
set "extractDir=%scriptDir%\%wslDistroName%"
set "sevenZipPath=C:\Program Files\7-Zip\7z.exe"

:: Check if 7-Zip is available
if not exist "%sevenZipPath%" (
    echo 7-Zip not found at "%sevenZipPath%".
    echo Please install 7-Zip or update the script with the correct path.
    pause
    exit /b 1
)
echo 7-Zip found at "%sevenZipPath%".

:begin
:: Initialization
title WSL2 Ubuntu Installer
cd /d "%scriptDir%"
echo Working directory: %scriptDir%

:: Scan for ISO files
echo Scanning for ISO files...
set "isoCount=0"
for %%I in ("%scriptDir%*ubuntu*.iso") do (
    set /a isoCount+=1
    set "iso[!isoCount!]=%%I"
)
if %isoCount%==0 (
    echo No Ubuntu ISO files found.
    pause
    exit /b 1
)
echo Found: %installImage%:: Display the menu

:: Display the menu
rem cls
echo ==========================================================================================================
echo                                             Ubuntu Models
echo ----------------------------------------------------------------------------------------------------------
echo.
for /L %%i in (1,1,%isoCount%) do (
    echo %%i. !iso[%%i]!
)

:menu
:: Prompt the user for input
echo.
echo ----------------------------------------------------------------------------------------------------------
set /p "choice=Select; Model Options = 1-%isoCount%, Rescan Folder = R, Exit Program = X: "

:: Handle the user's choice
if /I "%choice%"=="X" (
    echo Exiting program...
    pause
    exit /b 0
)

if /I "%choice%"=="R" (
    goto begin
)

if %choice% geq 1 if %choice% leq %isoCount% (
    set "selectedIso=!iso[%choice%]!"
    echo Selected ISO: !selectedIso!
) else (
    echo Invalid choice.
    goto menu
)

:: Set Global Variables
set "IsoFileFullPath=!selectedIso!"

:: Create extraction directory
echo Creating extraction directory...
if not exist "%extractDir%" mkdir "%extractDir%"

:: Extract ISO using 7-Zip
echo Extracting ISO contents...
"%sevenZipPath%" x "%IsoFileFullPath%" -o"%extractDir%" >nul

:: Debugging: Display extracted files
echo Debugging: Listing contents of %extractDir%\casper
dir "%extractDir%\casper\"

:: Locate the appropriate squashfs image
echo Finding squashfs image...
set "installImage="
if exist "%extractDir%\casper\filesystem.squashfs" (
    set "installImage=%extractDir%\casper\filesystem.squashfs"
) else if exist "%extractDir%\casper\minimal.standard.squashfs" (
    set "installImage=%extractDir%\casper\minimal.standard.squashfs"
) else if exist "%extractDir%\casper\minimal.standard.live.squashfs" (
    set "installImage=%extractDir%\casper\minimal.standard.live.squashfs"
)

:: Exit if no squashfs image found
if "%installImage%"=="" (
    echo No squashfs image found.
    pause
    exit /b 1
)
echo Found: %installImage%

:: Extract the root filesystem from squashfs
echo Extracting root filesystem...
"%sevenZipPath%" x "%installImage%" -o"%extractDir%" >nul

:: Compress the extracted root filesystem
echo Compressing root filesystem...
"%sevenZipPath%" a -ttar "%extractDir%\rootfs.tar" "%extractDir%\*" -xr!rootfs.tar >nul
"%sevenZipPath%" a -tgzip "%extractDir%\rootfs.tar.gz" "%extractDir%\rootfs.tar" >nul

:: Install the Ubuntu distribution in WSL2
echo Installing Ubuntu distribution in WSL2...
wsl --import "%wslDistroName%" "%extractDir%" "%extractDir%\rootfs.tar.gz" --version 2

:: Cleanup
echo Cleaning up...
del "%extractDir%\rootfs.tar"
echo Installation complete.
echo Run 'wsl -d %wslDistroName%' to start your new Ubuntu distribution.
pause
exit /b 0
