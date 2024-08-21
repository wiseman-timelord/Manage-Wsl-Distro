# WinAllUrBunsToo (Windows Install Ubuntu WSL2).
A tool for offline installing Ubuntu to Windows Subsystem Linux 2.

### PLANNER:
1. Current Error...
```
F:\System\O.S\Linux\install_wel2_ubuntu.ps1 : No squashfs image found.
    + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
    + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,install_wel2_ubuntu.ps1

```

### DESCRIPTION:
Its early works, but the idea is, its possible to install isos offline without using the Ms Store, I'd rather do that with the ISOs I already downloaded. You would think this would be as simple as installing other microsoft packages offline with a little command, but NOOOOOOOOOOOOOOO. The purpose of the project, is to be then able to use wsl2 for non-ROCM AMD torch compatibility, as I have done before but used the store to install, that doesnt seem to work, after you strip down the Windows 10 OS to a less, bloated and confused, state.

### OUTPUT:
- Early Version demonstration...
```
Admin rights confirmed.
Working Dir: "F:\System\O.S\Linux"
Executing PowerShell 7 Script...
7-Zip found at 'C:\Program Files\7-Zip\7z.exe'.
Working directory: F:\System\O.S\Linux
Found 5 ISO file(s).

==========================================================================================================
                                             Ubuntu Models
----------------------------------------------------------------------------------------------------------
1. ubuntu-21.04-cinnamon-desktop-amd64 (unable to configure panels correctly on cinnamon).iso
2. ubuntu-21.10-desktop-amd64.iso
3. ubuntu-22.04.3-desktop-amd64.iso
4. ubuntu-24.04-desktop-amd64.iso
5. ubuntu-mate-21.04-desktop-amd64.iso
----------------------------------------------------------------------------------------------------------
Select Model Options = 1-5, Rescan Folder = R, Exit Program = X: 4

Selected ISO: F:\System\O.S\Linux\ubuntu-24.04-desktop-amd64.iso
Extraction directory created at 'F:\System\O.S\Linux\ubuntu-24.04-desktop-amd64'
Extracting ISO contents...

7-Zip 24.06 (x64) : Copyright (c) 1999-2024 Igor Pavlov : 2024-05-26

Scanning the drive for archives:
1 file, 6114656256 bytes (5832 MiB)

Extracting archive: F:\System\O.S\Linux\ubuntu-24.04-desktop-amd64.iso
--
Path = F:\System\O.S\Linux\ubuntu-24.04-desktop-amd64.iso
Type = Iso
Physical Size = 6114656256
Comment =
{
VolumeSpaceSize: 6109124608
VolumeSetSize: 1
VolumeSequenceNumber: 1
}
Created = 2024-04-24 12:29:09.00
Modified = 2024-04-24 12:29:09.00


Would you like to replace the existing file:
  Path:     F:\System\O.S\Linux\ubuntu-24.04-desktop-amd64\acpi.mod
  Size:     10604 bytes (11 KiB)
  Modified: 2024-02-13 21:35:34
with the file from archive:
  Path:     boot\grub\x86_64-efi\acpi.mod
  Size:     16080 bytes (16 KiB)
  Modified: 2024-02-13 21:35:34
? (Y)es / (N)o / (A)lways / (S)kip all / A(u)to rename all / (Q)uit? s

Everything is Ok

Folders: 182
Files: 761
Size:       6108607813
Compressed: 6114656256
ISO contents extracted.
```
