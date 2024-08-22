# Global Variables
$ScriptDir    = Split-Path -Parent $MyInvocation.MyCommand.Path
$ExtractDir   = Join-Path -Path $ScriptDir -ChildPath "Extracted"
$SevenZipPath = "C:\Program Files\7-Zip\7z.exe"
$NumThreads   = 4
$WSLVersion   = 2

# Separator functions
function Show-SeparatorThick {
    Write-Host "Display Clears In 5 Seconds..."
	Start-Sleep -Seconds 5
    Clear-Host
    Write-Host ("=" * 120)	
}

function Show-SeparatorThin {
    Write-Host ("-" * 120)
}

# List WSL distros
function List-WSLDistros {
    Show-SeparatorThick
    Write-Host "Installed WSL Distros"
    Show-SeparatorThin
    
    $wslList = wsl --list --verbose
    if ($wslList) {
        $wslList | ForEach-Object { Write-Host $_ }
    } else {
        Write-Host "No WSL distributions found." -ForegroundColor Yellow
    }
    
    Show-SeparatorThin
}

# Install Ubuntu distro
function Install-UbuntuDistro {
    $wslDistroName = "CustomUbuntu-24.04-LTS"

    # Prepare extraction directory
    if (-Not (Test-Path -Path $ExtractDir)) {
        New-Item -Path $ExtractDir -ItemType Directory | Out-Null
    } else {
        Get-ChildItem -Path $ExtractDir | Remove-Item -Force -Recurse
    }
    Write-Host "Directory prepared." -ForegroundColor Green

    # Find ISO files
    $isoFiles = Get-ChildItem -Path $ScriptDir -Filter "*ubuntu*.iso"
    if ($isoFiles.Count -eq 0) {
        Write-Error "No ISO found."
        return
    }

    # Display ISO selection
    Show-SeparatorThick
    Write-Host "Select Ubuntu ISO to Install"
    Show-SeparatorThin
    Write-Host ""
	for ($i = 0; $i -lt $isoFiles.Count; $i++) {
        Write-Host "$($i + 1). $($isoFiles[$i].Name)"
    }
	Write-Host ""
    Show-SeparatorThin
    $choice = Read-Host "Select ISO (1-$($isoFiles.Count)), R=Rescan, X=Exit"

    # Handle user choice
    switch -Regex ($choice) {
        '^[Xx]$' { return }
        '^[Rr]$' { 
            Install-UbuntuDistro  # Recursive call to rescan
            return
        }
        '^[0-9]+$' {
            if ([int]$choice -ge 1 -and [int]$choice -le $isoFiles.Count) {
                $selectedIso = $isoFiles[[int]$choice - 1]
            } else {
                Write-Host "Invalid selection." -ForegroundColor Red
                return
            }
        }
        default {
            Write-Host "Invalid input." -ForegroundColor Red
            return
        }
    }

    # Extract ISO contents
    Write-Host "Extracting ISO..."
    $extractDir = Join-Path -Path $ExtractDir -ChildPath $selectedIso.BaseName
    if (-Not (Test-Path -Path $extractDir)) { New-Item -Path $extractDir -ItemType Directory | Out-Null }
    $isoExtractionArgs = "x `"$($selectedIso.FullName)`" -o`"$extractDir`" -mmt=$NumThreads -aoa"
    Start-Process -Wait -NoNewWindow -FilePath $SevenZipPath -ArgumentList $isoExtractionArgs

    # Locate and extract SquashFS
    $squashfsImage = Get-ChildItem -Path "$extractDir\casper" -Filter "*.squashfs" | Select-Object -First 1
    if (-Not $squashfsImage) {
        $squashfsImage = Get-ChildItem -Path "$extractDir" -Filter "*.squashfs" | Select-Object -First 1
        if (-Not $squashfsImage) {
            Write-Error "No squashfs found."
            return
        }
    }
    $squashfsExtractionArgs = "x `"$($squashfsImage.FullName)`" -o`"$extractDir`" -mmt=$NumThreads -aoa"
    Start-Process -Wait -NoNewWindow -FilePath $SevenZipPath -ArgumentList $squashfsExtractionArgs

    # Compress root filesystem
    $rootfsTarGz = Join-Path -Path $extractDir -ChildPath "rootfs.tar.gz"
    $compressArgsGz = "a -tgzip `"$rootfsTarGz`" `"$extractDir\*`" -xr!rootfs.tar -mmt=$NumThreads -aoa"
    Start-Process -Wait -NoNewWindow -FilePath $SevenZipPath -ArgumentList $compressArgsGz

    # Import into WSL
    Write-Host "`nInstalling WSL2..."
    $wslImportArgs = "--import `"$wslDistroName`" `"$extractDir`" `"$rootfsTarGz`" --version $WSLVersion"
    wsl $wslImportArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Error "WSL import failed."
    } else {
        Write-Host "WSL2 install complete."
    }

    # Cleanup
    Remove-Item -Path $rootfsTarGz -Force -ErrorAction SilentlyContinue
    Write-Host "`nInstallation complete. Use 'wsl -d $wslDistroName'."
    Write-Host "Press Enter to continue..." -NoNewline
    Read-Host
}

# Remove Ubuntu distro
function Remove-UbuntuDistro {
    $distros = wsl --list --all | Select-String "Ubuntu-"

    if (-Not $distros) {
        Write-Host "No Ubuntu distros found." -ForegroundColor Red
        return
    }

    Show-SeparatorThick
    Write-Host "Select Ubuntu Distro to Remove"
    Show-SeparatorThin
    Write-Host ""
	for ($i = 0; $i -lt $distros.Count; $i++) {
        Write-Host "$($i + 1). $($distros[$i])"
    }
    Write-Host ""
	Show-SeparatorThin
    $choice = Read-Host "Select distro (1-$($distros.Count)), X=Exit"

    switch -Regex ($choice) {
        '^[Xx]$' { return }
        '^[0-9]+$' {
            if ([int]$choice -ge 1 -and [int]$choice -le $distros.Count) {
                $selectedDistro = $distros[[int]$choice - 1] -replace " \(Default\)", ""
                $selectedDistro = $selectedDistro -replace "Windows Subsystem for Linux Distributions:", ""
                $selectedDistro = $selectedDistro.Trim()
                wsl --unregister $selectedDistro
                Write-Host "`nUbuntu distro removed: $selectedDistro"
            } else {
                Write-Host "Invalid selection." -ForegroundColor Red
            }
        }
        default {
            Write-Host "Invalid input." -ForegroundColor Red
        }
    }

    Write-Host "Press Enter to continue..." -NoNewline
    Read-Host
}

# Display main menu
function Show-MainMenu {
    Show-SeparatorThick
    Write-Host "WSL Distro Manager"
    Show-SeparatorThin
    Write-Host ""
	Write-Host "1. List Installed Ubuntus"
    Write-Host "2. Install Ubuntu Distro"
    Write-Host "3. Remove Ubuntu Distro"
	Write-Host ""
    Show-SeparatorThin
    $menuChoice = Read-Host "Select option (1-3), X=Exit"

    switch ($menuChoice) {
        "1" { List-WSLDistros }
        "2" { Install-UbuntuDistro }
        "3" { Remove-UbuntuDistro }
        "X" { return $false }
        default {
            Write-Host "Invalid selection." -ForegroundColor Red
            Write-Host "Press Enter to continue..." -NoNewline
            Read-Host
        }
    }
    return $true
}

# Main execution loop
while (Show-MainMenu) {
    # Main menu is already cleared in Show-SeparatorThick
}

Write-Host "Exiting program..."