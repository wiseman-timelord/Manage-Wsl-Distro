#!/usr/bin/env pwsh
#Requires -Version 7.4

using namespace System.IO
using namespace System.Management.Automation

# Configuration
$Config = @{
    ScriptDir    = $PSScriptRoot
    ExtractDir   = Join-Path $PSScriptRoot "Extracted"
    SevenZipPath = "C:\Program Files\7-Zip\7z.exe"
    NumThreads   = [Environment]::ProcessorCount
    LogFile      = Join-Path $PSScriptRoot "wsl_manager.log"
}

# Initialize logging
function Write-Log {
    param ([string]$Message, [string]$Level = "INFO")
    "[$([DateTime]::Now.ToString('yyyy-MM-dd HH:mm:ss'))] [$Level] $Message" | Tee-Object -Append $Config.LogFile
}

# Banner function
function Show-Banner {
    Clear-Host
    $banner = "=" * 120
    Write-Host $banner
    Write-Host "WSL Distro Manager"
    Write-Host $banner
    Write-Host "" # Extra line for spacing
}

# Main menu function
function Show-MainMenu {
    Show-Banner
    # Printing menu options individually
    Write-Host "1. List Installed Ubuntus"
    Write-Host "2. Install Ubuntu Distro"
    Write-Host "3. Remove Ubuntu Distro"
    Write-Host "" # Add a blank line before the prompt for better readability

    # Prompt user for input
    $menuChoice = Read-Host "Select option (1-3), X=Exit"

    # Handle user choice
    switch ($menuChoice) {
        "1" { List-WSLDistros }
        "2" { Install-UbuntuDistro }
        "3" { Remove-UbuntuDistro }
        default { return $false }
    }
    return $true
}

# Utility: Wait with message
function Wait-WithMessage([string]$Message, [int]$WaitTime) {
    Write-Host $Message
    Start-Sleep -Seconds $WaitTime
}

# Function to handle user input within menus
function Handle-UserChoice {
    param (
        [array]$Items,
        [string]$PromptMessage,
        [string]$ErrorMessage
    )
    $Items | ForEach-Object { "{0}. {1}" -f ($_ + 1), $Items[$_] }
    $choice = Read-Host $PromptMessage

    switch ($choice) {
        {$_ -match '^[Xx]$'} { return $null }
        {$_ -match '^[0-9]+$' -and [int]$choice -ge 1 -and [int]$choice -le $Items.Count} { return $Items[[int]$choice - 1] }
        default {
            Write-Log $ErrorMessage -Level "ERROR"
            return $null
        }
    }
}

# WSL functions
function List-WSLDistros {
    Show-Banner
    Write-Host "Installed WSL Distros:"
    try {
        $wslList = wsl --list --verbose
        if ($wslList) {
            $wslList | ForEach-Object { Write-Host $_ }
        } else {
            Wait-WithMessage "No WSL distributions found." 1
        }
    }
    catch {
        Write-Log "Error listing WSL distros: $_" -Level "ERROR"
    }
    Read-Host "Press Enter to return to the main menu..."
}

function Install-UbuntuDistro {
    Show-Banner
    $wslDistroName = "CustomUbuntu-24.04-LTS"

    # Prepare extraction directory
    try {
        if (-not (Test-Path $Config.ExtractDir)) {
            [Directory]::CreateDirectory($Config.ExtractDir)
        } else {
            Get-ChildItem $Config.ExtractDir | Remove-Item -Force -Recurse
        }
        Wait-WithMessage "Directory prepared." 1
    }
    catch {
        Write-Log "Error preparing extraction directory: $_" -Level "ERROR"
        return
    }

    # Find and select ISO
    $isoFiles = Get-ChildItem $Config.ScriptDir -Filter "*ubuntu*.iso"
    if ($isoFiles.Count -eq 0) {
        Wait-WithMessage "No ISO found." 3
        return
    }

    # Printing each ISO option
    Write-Host "Available ISO files:"
    for ($i = 0; $i -lt $isoFiles.Count; $i++) {
        Write-Host "$($i + 1). $($isoFiles[$i].Name)"
    }

    # Prompt user for selection
    do {
        $selectedIndex = Read-Host "Select ISO (1-$($isoFiles.Count)), X=Exit"
        if ($selectedIndex -match '^[Xx]$') {
            return
        }
    } while (-not ($selectedIndex -match '^[0-9]+$' -and [int]$selectedIndex -ge 1 -and [int]$selectedIndex -le $isoFiles.Count))

    $selectedIso = $isoFiles[[int]$selectedIndex - 1]

    Write-Host "`nInstalling WSL Distro using $($selectedIso.Name)..."

    # Extract ISO and SquashFS
    $extractDir = Join-Path $Config.ExtractDir $selectedIso.BaseName
    [Directory]::CreateDirectory($extractDir)

    $extractionSteps = @(
        @{ Source = $selectedIso.FullName; Destination = $extractDir; Name = "ISO" },
        @{ Source = (Get-ChildItem "$extractDir\casper" -Filter "*.squashfs" -Recurse | Select-Object -First 1).FullName; Destination = $extractDir; Name = "SquashFS" }
    )

    foreach ($step in $extractionSteps) {
        $extractArgs = "x `"$($step.Source)`" -o`"$($step.Destination)`" -mmt=$($Config.NumThreads) -aoa"
        try {
            $process = Start-Process -Wait -NoNewWindow -PassThru $Config.SevenZipPath -ArgumentList $extractArgs
            if ($process.ExitCode -ne 0) {
                throw "$($step.Name) extraction failed with exit code $($process.ExitCode)"
            }
        }
        catch {
            Write-Log "Error extracting $($step.Name): $_" -Level "ERROR"
            return
        }
    }

    # Compress root filesystem
    $rootfsTarGz = Join-Path $extractDir "rootfs.tar.gz"
    $compressArgs = "a -tgzip `"$rootfsTarGz`" `"$extractDir\*`" -xr!rootfs.tar -mmt=$($Config.NumThreads) -aoa"
    try {
        Start-Process -Wait -NoNewWindow $Config.SevenZipPath -ArgumentList $compressArgs
    }
    catch {
        Write-Log "Error compressing root filesystem: $_" -Level "ERROR"
        return
    }

    # Import into WSL
    Wait-WithMessage "`nInstalling WSL2..." 1
    $WSLVersion = (wsl --list --verbose | Select-String "Default Version").ToString().Split(":")[-1].Trim()
    $wslImportArgs = "--import `"$wslDistroName`" `"$extractDir`" `"$rootfsTarGz`" --version $WSLVersion"
    try {
        wsl $wslImportArgs
        if ($LASTEXITCODE -ne 0) {
            throw "WSL import failed with exit code $LASTEXITCODE"
        }
        Wait-WithMessage "WSL2 install complete." 1
    }
    catch {
        Write-Log "Error importing WSL distro: $_" -Level "ERROR"
        return
    }

    # Cleanup
    Remove-Item $rootfsTarGz, $extractDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "`nInstallation complete. Use 'wsl -d $wslDistroName'."
    Read-Host "Press Enter to return to the main menu..."
}

function Remove-UbuntuDistro {
    Show-Banner
    Write-Host "Removing Ubuntu Distro..."

    try {
        $distros = wsl --list --all | Select-String "Ubuntu-"
        if (-not $distros) {
            Wait-WithMessage "No Ubuntu distros found." 3
            return
        }

        # Print each available distro for removal
        Write-Host "Available Ubuntu distros:"
        for ($i = 0; $i -lt $distros.Count; $i++) {
            Write-Host "$($i + 1). $($distros[$i].ToString().Trim())"
        }

        # Prompt user for selection
        do {
            $selectedIndex = Read-Host "Select distro to remove (1-$($distros.Count)), X=Exit"
            if ($selectedIndex -match '^[Xx]$') {
                return
            }
        } while (-not ($selectedIndex -match '^[0-9]+$' -and [int]$selectedIndex -ge 1 -and [int]$selectedIndex -le $distros.Count))

        $selectedDistro = $distros[[int]$selectedIndex - 1].ToString().Trim()
        Write-Host "`nRemoving WSL Distro: $selectedDistro..."

        # Remove selected distro
        try {
            wsl --unregister $selectedDistro
            Write-Host "`nUbuntu distro removed."
        }
        catch {
            Write-Log "Error removing Ubuntu distro: $_" -Level "ERROR"
        }
    }
    catch {
        Write-Log "Error removing Ubuntu distro: $_" -Level "ERROR"
    }
    Read-Host "Press Enter to return to the main menu..."
}

# Main execution
try {
    if (-not (Test-Path $Config.SevenZipPath)) {
        throw "7-Zip not found at $($Config.SevenZipPath). Please check the path and try again."
    }

    while (Show-MainMenu) { }

    Write-Log "Exiting program..."
    Wait-WithMessage "Goodbye!" 1
}
catch {
    Write-Log "Critical error: $_" -Level "ERROR"
    Write-Host "An error occurred. Please check the log file for details."
    Wait-WithMessage "Exiting due to an error..." 1
    exit 1
}
