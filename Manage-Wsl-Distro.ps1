# Global Variables
$ScriptDir    = Split-Path -Parent $MyInvocation.MyCommand.Path  # Script directory path
$ExtractDir   = Join-Path -Path $ScriptDir -ChildPath "Extracted"  # Extraction directory
$SevenZipPath = "C:\Program Files\7-Zip\7z.exe"  # 7-Zip executable path
$NumThreads   = 4  # Number of threads
$WSLVersion   = 2  # WSL version

# Function to list installed WSL distros
function List-WSLDistros {
    Write-Host "`nInstalled WSL distros:"  # Print installed WSL distros
    wsl --list --all
}

# Function to install an Ubuntu distro
function Install-UbuntuDistro {
    $wslDistroName = "CustomUbuntu-24.04-LTS"  # Custom distro name

    # Prepare extraction directory
    if (-Not (Test-Path -Path $ExtractDir)) {
        New-Item -Path $ExtractDir -ItemType Directory | Out-Null  # Create extraction dir
    } else {
        Get-ChildItem -Path $ExtractDir | Remove-Item -Force -Recurse  # Clear extraction dir
    }
    Write-Host "Directory prepared." -ForegroundColor Green  # Directory ready

    # Find ISO files
    $isoFiles = Get-ChildItem -Path $ScriptDir -Filter "*ubuntu*.iso"  # Locate ISO files
    if ($isoFiles.Count -eq 0) {
        Write-Error "No ISO found."  # Error: No ISO
        return
    }
    Write-Host "$($isoFiles.Count) ISO(s) found."  # ISO count

    # Display ISO selection
    for ($i = 0; $i -lt $isoFiles.Count; $i++) {
        Write-Host "$($i + 1). $($isoFiles[$i].Name)"  # List ISO options
    }

    # Select ISO or exit
    $selectedIso = $null
    while (-Not $selectedIso) {
        $choice = Read-Host "Select ISO (1-$($isoFiles.Count)), Rescan = R, Exit = X"  # Prompt for choice

        if ($choice -match '^[Xx]$') { return }  # Exit condition
        if ($choice -match '^[Rr]$') {
            $isoFiles = Get-ChildItem -Path $ScriptDir -Filter "*ubuntu*.iso"  # Rescan for ISOs
            if ($isoFiles.Count -eq 0) { Write-Error "No ISO found."; return }  # Error: No ISO
            for ($i = 0; $i -lt $isoFiles.Count; $i++) { Write-Host "$($i + 1). $($isoFiles[$i].Name)" }  # List ISOs
            continue
        }

        if (($choice -as [int]) -ge 1 -and ($choice -as [int]) -le $isoFiles.Count) {
            $selectedIso = $isoFiles[$choice - 1]  # Select ISO
        } else {
            Write-Host "Invalid selection." -ForegroundColor Red  # Error: Invalid choice
        }
    }

    # Extract ISO contents
    Write-Host "Extracting ISO..."  # Begin ISO extraction
    $extractDir = Join-Path -Path $ExtractDir -ChildPath $selectedIso.BaseName  # Extraction path
    if (-Not (Test-Path -Path $extractDir)) { New-Item -Path $extractDir -ItemType Directory | Out-Null }  # Create directory
    $isoExtractionArgs = "x `"$($selectedIso.FullName)`" -o`"$extractDir`" -mmt=$NumThreads -aoa"  # 7-Zip extraction args
    Start-Process -Wait -NoNewWindow -FilePath $SevenZipPath -ArgumentList $isoExtractionArgs  # Start extraction

    # Locate and extract SquashFS
    $squashfsImage = Get-ChildItem -Path "$extractDir\casper" -Filter "*.squashfs" | Select-Object -First 1  # Locate SquashFS
    if (-Not $squashfsImage) {
        $squashfsImage = Get-ChildItem -Path "$extractDir" -Filter "*.squashfs" | Select-Object -First 1  # Locate SquashFS in root
        if (-Not $squashfsImage) {
            Write-Error "No squashfs found."  # Error: No squashfs
            return
        }
    }
    $squashfsExtractionArgs = "x `"$($squashfsImage.FullName)`" -o`"$extractDir`" -mmt=$NumThreads -aoa"  # 7-Zip squashfs args
    Start-Process -Wait -NoNewWindow -FilePath $SevenZipPath -ArgumentList $squashfsExtractionArgs  # Start extraction

    # Compress root filesystem
    $rootfsTarGz = Join-Path -Path $extractDir -ChildPath "rootfs.tar.gz"  # rootfs path
    $compressArgsGz = "a -tgzip `"$rootfsTarGz`" `"$extractDir\*`" -xr!rootfs.tar -mmt=$NumThreads -aoa"  # Compression args
    Start-Process -Wait -NoNewWindow -FilePath $SevenZipPath -ArgumentList $compressArgsGz  # Compress rootfs

    # Import into WSL
    Write-Host "`nInstalling WSL2..."  # WSL2 installation begins
    $wslImportArgs = "--import `"$wslDistroName`" `"$extractDir`" `"$rootfsTarGz`" --version $WSLVersion"  # WSL import args
    wsl $wslImportArgs  # WSL import
    if ($LASTEXITCODE -ne 0) {
        Write-Error "WSL import failed."  # Error: Import failure
    } else {
        Write-Host "WSL2 install complete."  # Install successful
    }

    # Cleanup
    Remove-Item -Path $rootfsTarGz -Force -ErrorAction SilentlyContinue  # Clean up rootfs archive
    Write-Host "`nInstallation complete. Use 'wsl -d $wslDistroName'."  # Installation finished
}

# Function to remove a specific Ubuntu distro
function Remove-UbuntuDistro {
    $distros = wsl --list --all | Select-String "Ubuntu-"  # Find Ubuntu distros

    if (-Not $distros) {
        Write-Host "No Ubuntu distros found." -ForegroundColor Red  # No distros found
        return
    }

    Write-Host "Ubuntu distros:"  # List found distros
    for ($i = 0; $i -lt $distros.Count; $i++) {
        Write-Host "$($i + 1). $($distros[$i])"  # Display distros
    }

    $choice = Read-Host "Select Ubuntu to remove (1-$($distros.Count)), Exit = X"  # Prompt for removal

    if ($choice -match '^[Xx]$') { return }  # Exit condition

    if (($choice -as [int]) -ge 1 -and ($choice -as [int]) -le $distros.Count) {
        $selectedDistro = $distros[$choice - 1] -replace " \(Default\)", ""  # Clean distro name
        $selectedDistro = $selectedDistro -replace "Windows Subsystem for Linux Distributions:", ""  # Clean distro name
        $selectedDistro = $selectedDistro.Trim()  # Trim whitespace
        wsl --unregister $selectedDistro  # Remove distro
        Write-Host "`nUbuntu distro removed: $selectedDistro"  # Distro removed
    } else {
        Write-Host "Invalid selection." -ForegroundColor Red  # Error: Invalid choice
    }
}

# Main menu loop
while ($true) {
    Write-Host "========================================================="
	Write-Host "Wsl Distro Manager"
    Write-Host "---------------------------------------------------------"
	Write-Host "1. List installed WSL distros"  # Option 1 description
    Write-Host "2. Install Ubuntu distro"  # Option 2 description
    Write-Host "3. Remove Ubuntu distro"  # Option 3 description
    Write-Host "---------------------------------------------------------"

    $menuChoice = Read-Host "Select; Menu Options = 1-3, Exit Program = X"  # Display menu and prompt for input
    switch ($menuChoice) {
        "1" {
            List-WSLDistros  # Call list function
        }
        "2" {
            Install-UbuntuDistro  # Call install function
        }
        "3" {
            Remove-UbuntuDistro  # Call remove function
        }
        "X" {
            Write-Host "Exiting program..."  # Exit program
            exit 0
        }
        default {
            Write-Host "Invalid selection." -ForegroundColor Red  # Error: Invalid choice
        }
    }

    Write-Host "`nPress any key to return to menu..."  # Return to menu
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")  # Wait for key press
    Clear-Host  # Clear screen
}
