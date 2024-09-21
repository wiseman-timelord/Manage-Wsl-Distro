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
    # Clear-Host
    Write-Host ("=" * 120)
    Write-Host "   Manage-Wsl-Distro"
    Write-Host ("=" * 120)
    Write-Host "" # Extra line for spacing
}

# Main menu function
function Show-MainMenu {
    Show-Banner
    Write-Host "`n`n`n`n`n`n`n"
    Write-Host "    1. List Installed Ubuntus`n"
    Write-Host "    2. Install Ubuntu Distro`n"
    Write-Host "    3. Remove Ubuntu Distro"
    Write-Host "`n`n`n`n`n`n`n`n"
    Write-Host ("=" * 120)
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
    write-host ("Listing and Displaying, Distros...`n")
	
	Write-Host "    Installed WSL Distros:"
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
    Read-Host "Press Enter to return to Main Menu..."
}

function Install-UbuntuDistro {
    Show-Banner
    Write-Host "Install Distro Started..."
    
    # Prompt user for the folder containing ISO files
    $isoFolderPath = Read-Host "Please Input Full-Path Ubuntu ISOs Folder"

    if (-not (Test-Path $isoFolderPath)) {
        Wait-WithMessage "Invalid folder path. Please make sure the folder exists." 3
        return
    }

    # Find ISO files in the provided folder
    $isoFiles = Get-ChildItem $isoFolderPath -Filter "ubuntu*.iso" -ErrorAction SilentlyContinue
    if ($isoFiles.Count -eq 0) {
        Wait-WithMessage "No ISO files found matching 'ubuntu*.iso' in the specified folder." 3
        return
    }

    # List available ISO files
    Write-Host "`nAvailable ISO files:`n"
    for ($i = 0; $i -lt $isoFiles.Count; $i++) {
        Write-Host "    $($i + 1). $($isoFiles[$i].Name)"
    }

    # Prompt user to select the ISO
    do {
        $selectedIndex = Read-Host "`nSelection; ISO Options (1-$($isoFiles.Count)), Back to Menu = B"
        if ($selectedIndex -match '^[Bb]$') {
            return
        }
    } while (-not ($selectedIndex -match '^[0-9]+$' -and [int]$selectedIndex -ge 1 -and [int]$selectedIndex -le $isoFiles.Count))

    $selectedIso = $isoFiles[[int]$selectedIndex - 1]

    # Extract distro name from the ISO file name
    $isoNameParts = $selectedIso.BaseName.Split("-")
    if ($isoNameParts.Count -ge 3) {
        $wslDistroName = "$($isoNameParts[0])-$($isoNameParts[1]).$($isoNameParts[2])"
    } else {
        $wslDistroName = $selectedIso.BaseName
    }

    Write-Host "`nInstalling WSL Distro as '$wslDistroName' using $($selectedIso.Name)..."

    # Prepare extraction directory
    try {
        if (-not (Test-Path $Config.ExtractDir)) {
            [Directory]::CreateDirectory($Config.ExtractDir)
        } else {
            Get-ChildItem $Config.ExtractDir | Remove-Item -Force -Recurse
        }
        Write-Log "Extraction directory prepared: $($Config.ExtractDir)" -Level "INFO"
    }
    catch {
        Write-Log "Error preparing extraction directory: $_" -Level "ERROR"
        return
    }

    # Extract ISO and SquashFS
    $extractDir = Join-Path $Config.ExtractDir $selectedIso.BaseName
    [Directory]::CreateDirectory($extractDir)

    # Extract ISO
    $extractIsoArgs = "x `"$($selectedIso.FullName)`" -o`"$extractDir`" -mmt=$($Config.NumThreads) -aoa"
    try {
        # Create tar archive in chunks
        $chunkSize = 1000  # Number of files per chunk
        $tarFile = Join-Path $tempDir "rootfs.tar"
        $allFiles = Get-ChildItem $extractDir -Recurse -File
        $totalFiles = $allFiles.Count
        $chunks = [Math]::Ceiling($totalFiles / $chunkSize)

        for ($i = 0; $i -lt $chunks; $i++) {
            $start = $i * $chunkSize
            $end = [Math]::Min(($i + 1) * $chunkSize, $totalFiles) - 1
            $currentChunk = $allFiles[$start..$end]

            $chunkList = Join-Path $tempDir "chunk_$i.txt"
            $currentChunk | ForEach-Object { $_.FullName } | Out-File $chunkList -Encoding utf8

            $tarArgs = "a -ttar `"$tarFile`" @`"$chunkList`" -mmt=$($Config.NumThreads) -aoa"
            Write-Log "Creating tar chunk $($i+1) of $chunks`: $tarArgs" -Level "INFO"
            $process = Start-Process -Wait -NoNewWindow -PassThru $Config.SevenZipPath -ArgumentList $tarArgs
            if ($process.ExitCode -ne 0) {
                throw "Creating tar chunk $($i+1) failed with exit code $($process.ExitCode)"
            }
            Remove-Item $chunkList -Force
        }
        Write-Host "Tar archive created successfully."

        # Compress the tar file to gzip
        $gzipArgs = "a -tgzip `"$rootfsTarGz`" `"$tarFile`" -mmt=$($Config.NumThreads) -aoa"
        Write-Log "Compressing tar to gzip: $gzipArgs" -Level "INFO"
        $process = Start-Process -Wait -NoNewWindow -PassThru $Config.SevenZipPath -ArgumentList $gzipArgs
        if ($process.ExitCode -ne 0) {
            throw "Compressing tar to gzip failed with exit code $($process.ExitCode)"
        }
        Write-Host "Root filesystem compressed successfully."
    }
    catch {
        Write-Log "Error compressing root filesystem: $_" -Level "ERROR"
        return
    }
    finally {
        # Clean up temp directory
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Temp directory cleaned up" -Level "INFO"
    }turn
    }

    # Compress root filesystem
    $rootfsTarGz = Join-Path $extractDir "rootfs.tar.gz"
    $tempDir = Join-Path $env:TEMP "WSLInstall_$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    Write-Log "Created temp directory: $tempDir" -Level "INFO"

    try {
        # Create tar archive in chunks
        $chunkSize = 1000  # Number of files per chunk
        $tarFile = Join-Path $tempDir "rootfs.tar"
        $allFiles = Get-ChildItem $extractDir -Recurse -File
        $totalFiles = $allFiles.Count
        $chunks = [Math]::Ceiling($totalFiles / $chunkSize)

        for ($i = 0; $i -lt $chunks; $i++) {
            $start = $i * $chunkSize
            $end = [Math]::Min(($i + 1) * $chunkSize, $totalFiles) - 1
            $currentChunk = $allFiles[$start..$end]

            $chunkList = Join-Path $tempDir "chunk_$i.txt"
            $currentChunk | ForEach-Object { $_.FullName } | Out-File $chunkList -Encoding utf8

            $tarArgs = "a -ttar `"$tarFile`" @`"$chunkList`" -mmt=$($Config.NumThreads) -aoa"
            Write-Log "Creating tar chunk $($i+1) of $chunks: $tarArgs" -Level "INFO"
            $process = Start-Process -Wait -NoNewWindow -PassThru $Config.SevenZipPath -ArgumentList $tarArgs
            if ($process.ExitCode -ne 0) {
                throw "Creating tar chunk $($i+1) failed with exit code $($process.ExitCode)"
            }
            Remove-Item $chunkList -Force
        }
        Write-Host "Tar archive created successfully."

        # Compress the tar file to gzip
        $gzipArgs = "a -tgzip `"$rootfsTarGz`" `"$tarFile`" -mmt=$($Config.NumThreads) -aoa"
        Write-Log "Compressing tar to gzip: $gzipArgs" -Level "INFO"
        $process = Start-Process -Wait -NoNewWindow -PassThru $Config.SevenZipPath -ArgumentList $gzipArgs
        if ($process.ExitCode -ne 0) {
            throw "Compressing tar to gzip failed with exit code $($process.ExitCode)"
        }
        Write-Host "Root filesystem compressed successfully."
    }
    catch {
        Write-Log "Error compressing root filesystem: $_" -Level "ERROR"
        return
    }
    finally {
        # Clean up temp directory
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Temp directory cleaned up" -Level "INFO"
    }

    # Import into WSL
    Write-Host "`nInstalling WSL2..."
    $WSLVersion = (wsl --list --verbose | Select-String "Default Version").ToString().Split(":")[-1].Trim()
    $wslImportArgs = "--import `"$wslDistroName`" `"$extractDir`" `"$rootfsTarGz`" --version $WSLVersion"
    try {
        Write-Log "Importing WSL distro: $wslImportArgs" -Level "INFO"
        $process = Start-Process -Wait -NoNewWindow -PassThru "wsl" -ArgumentList $wslImportArgs
        if ($process.ExitCode -ne 0) {
            throw "WSL import failed with exit code $($process.ExitCode)"
        }
        Write-Host "WSL2 install complete."
    }
    catch {
        Write-Log "Error importing WSL distro: $_" -Level "ERROR"
        return
    }

    # Cleanup
    Remove-Item $rootfsTarGz, $extractDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "Cleanup completed" -Level "INFO"
    Write-Host "`nInstallation complete. Use 'wsl -d $wslDistroName' to start your new distro."
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
