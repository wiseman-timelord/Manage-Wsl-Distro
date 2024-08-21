# Global Variables
$ScriptDir    = Split-Path -Parent $MyInvocation.MyCommand.Path
$ExtractDir   = Join-Path -Path $ScriptDir -ChildPath "Extracted"
$SevenZipPath = "C:\Program Files\7-Zip\7z.exe"
$NumThreads   = 4
$WSLVersion   = 2

# Ensure 7-Zip exists
if (-Not (Test-Path -Path $SevenZipPath)) {
    Write-Error "7-Zip not found at '$SevenZipPath'. Please install 7-Zip or update the script with the correct path."
    exit 1
}
Write-Host "7-Zip found at '$SevenZipPath'." -ForegroundColor Green

# Create or clear the Extracted directory
if (-Not (Test-Path -Path $ExtractDir)) {
    New-Item -Path $ExtractDir -ItemType Directory | Out-Null
    Write-Host "Created Extracted directory: $ExtractDir" -ForegroundColor Green
}
else {
    Get-ChildItem -Path $ExtractDir | Remove-Item -Force -Recurse
    Write-Host "Cleared Extracted directory: $ExtractDir" -ForegroundColor Green
}

# Find ISO files in the script directory
$isoFiles = Get-ChildItem -Path $ScriptDir -Filter "*ubuntu*.iso"
if ($isoFiles.Count -eq 0) {
    Write-Error "No Ubuntu ISO files found in $ScriptDir."
    exit 1
}
Write-Host "Found $($isoFiles.Count) ISO file(s) in $ScriptDir."

# Display Menu
Write-Host "`n=========================================================================================================="
Write-Host "                                             Ubuntu Models"
Write-Host "----------------------------------------------------------------------------------------------------------"
for ($i = 0; $i -lt $isoFiles.Count; $i++) {
    Write-Host "$($i + 1). $($isoFiles[$i].Name)"
}

# User Selection Loop
$selectedIso = $null
while (-Not $selectedIso) {
    Write-Host "----------------------------------------------------------------------------------------------------------"
    $choice = Read-Host "Select Model Options = 1-$($isoFiles.Count), Rescan Folder = R, Exit Program = X"

    if ($choice -match '^[Xx]$') {
        Write-Host "Exiting program..."
        exit 0
    }

    if ($choice -match '^[Rr]$') {
        Write-Host "Rescanning script directory..."
        $isoFiles = Get-ChildItem -Path $ScriptDir -Filter "*ubuntu*.iso"
        if ($isoFiles.Count -eq 0) {
            Write-Error "No Ubuntu ISO files found in $ScriptDir."
            exit 1
        }
        Write-Host "`nFound $($isoFiles.Count) ISO file(s) in $ScriptDir."
        for ($i = 0; $i -lt $isoFiles.Count; $i++) {
            Write-Host "$($i + 1). $($isoFiles[$i].Name)"
        }
        continue
    }

    $choice = [int]$choice
    if ($choice -ge 1 -and $choice -le $isoFiles.Count) {
        $selectedIso = $isoFiles[$choice - 1]
        Write-Host "`nSelected ISO: $($selectedIso.FullName)" -ForegroundColor Green
    } else {
        Write-Host "Invalid choice. Please select a valid option." -ForegroundColor Red
    }
}

# Prepare for extraction
$wslDistroName = $selectedIso.BaseName
$extractDir = Join-Path -Path $ExtractDir -ChildPath $wslDistroName

# Create extraction directory
if (-Not (Test-Path -Path $extractDir)) {
    New-Item -Path $extractDir -ItemType Directory | Out-Null
}
Write-Host "Extraction directory created at '$extractDir'"

# Extract ISO contents
Write-Host "Extracting ISO contents..."
$isoExtractionArgs = "e `"$($selectedIso.FullName)`" -o`"$extractDir`" -mmt=$NumThreads -aoa"
Start-Process -Wait -NoNewWindow -FilePath $SevenZipPath -ArgumentList $isoExtractionArgs
Write-Host "ISO contents extracted."

# Locate squashfs image
$squashfsImage = Get-ChildItem -Path "$extractDir\casper" -Filter "*.squashfs" | Select-Object -First 1
if (-Not $squashfsImage) {
    Write-Host "No squashfs image found in the extracted contents. Trying alternate location..."
    $squashfsImage = Get-ChildItem -Path "$extractDir" -Filter "*.squashfs" | Select-Object -First 1
    if (-Not $squashfsImage) {
        Write-Error "No squashfs image found."
        Write-Host "Please check the contents of the '$ExtractDir\$wslDistroName' directory for the expected squashfs file."
        Get-ChildItem -Path "$ExtractDir\$wslDistroName" -Recurse
        exit 1
    }
}
Write-Host "Found squashfs image: $($squashfsImage.FullName)"

# Extract root filesystem
Write-Host "Extracting root filesystem..."
$squashfsExtractionArgs = "e `"$($squashfsImage.FullName)`" -o`"$extractDir`" -mmt=$NumThreads -aoa"
Start-Process -Wait -NoNewWindow -FilePath $SevenZipPath -ArgumentList $squashfsExtractionArgs
Write-Host "Root filesystem extracted."

# Compress the root filesystem
Write-Host "Compressing root filesystem..."
$rootfsTar = Join-Path -Path $extractDir -ChildPath "rootfs.tar"
$rootfsTarGz = "$rootfsTar.gz"
$compressArgsTar = "a -ttar `"$rootfsTar`" `"$extractDir\*`" -xr!rootfs.tar -mmt=$NumThreads -aoa"
$compressArgsGz = "a -tgzip `"$rootfsTarGz`" `"$rootfsTar`" -mmt=$NumThreads -aoa"
Start-Process -Wait -NoNewWindow -FilePath $SevenZipPath -ArgumentList $compressArgsTar
Start-Process -Wait -NoNewWindow -FilePath $SevenZipPath -ArgumentList $compressArgsGz
Write-Host "Root filesystem compressed."

# Install WSL2 distribution
Write-Host "Installing Ubuntu distribution in WSL2..."
$wslImportArgs = "--import $wslDistroName $extractDir $rootfsTarGz --version $WSLVersion"
wsl $wslImportArgs
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to install Ubuntu distribution in WSL2."
    Write-Host "Please check the WSL2 setup and try again."
    exit 1
}
Write-Host "Ubuntu distribution installed in WSL2."

# Cleanup
Remove-Item -Path $rootfsTar, $rootfsTarGz -Force
Write-Host "Installation complete. Run 'wsl -d $wslDistroName' to start your new Ubuntu distribution."