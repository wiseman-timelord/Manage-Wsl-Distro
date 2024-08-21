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
Its early works, but the idea is, its possible to install ISOs offline without using the Ms Store, I'd rather do that with the ISOs I already downloaded. You would think this would be as simple as installing other microsoft packages offline with a little command, but NOOOOOOOOOOOOOOO. The purpose of the project, is to be then able to use wsl2 for non-ROCM AMD torch compatibility, as I have done before but used the store to install, that doesnt seem to work at some point after you mod Windows 10 OS, when I had a fresh install, through so many customizations that you just dont go back.

### OUTPUT:
- Early Version demonstration...
```
Admin rights confirmed.
Working Dir: "F:\System\O.S\Linux"
Executing PowerShell 7 Script...
7-Zip found at 'C:\Program Files\7-Zip\7z.exe'.
Cleared Extracted directory: F:\System\O.S\Linux\Extracted
Found 5 ISO file(s) in F:\System\O.S\Linux.

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
Extraction directory created at 'F:\System\O.S\Linux\Extracted\ubuntu-24.04-desktop-amd64'
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

Everything is Ok

Folders: 182
Files: 1027
Size:       6111356013
Compressed: 6114656256
ISO contents extracted.
No squashfs image found in the extracted contents. Trying alternate location...
Found squashfs image: F:\System\O.S\Linux\Extracted\ubuntu-24.04-desktop-amd64\minimal.de.squashfs
Extracting root filesystem...

7-Zip 24.06 (x64) : Copyright (c) 1999-2024 Igor Pavlov : 2024-05-26

Scanning the drive for archives:
1 file, 16592896 bytes (16 MiB)

Extracting archive: F:\System\O.S\Linux\Extracted\ubuntu-24.04-desktop-amd64\minimal.de.squashfs
--
Path = F:\System\O.S\Linux\Extracted\ubuntu-24.04-desktop-amd64\minimal.de.squashfs
Type = SquashFS
Physical Size = 16592896
Headers Size = 139321
File System = SquashFS 4.0
Method = XZ
Cluster Size = 131072
Big-endian = -
Created = 2024-04-24 12:12:13
Characteristics = DUPLICATES_REMOVED EXPORTABLE
Code Page = UTF-8

ERROR: Cannot create folder : Cannot create a file when that file already exists. : F:\System\O.S\Linux\Extracted\ubuntu-24.04-desktop-amd64\es
ERROR: Cannot create folder : Cannot create a file when that file already exists. : F:\System\O.S\Linux\Extracted\ubuntu-24.04-desktop-amd64\fr
ERROR: Cannot create folder : Cannot create a file when that file already exists. : F:\System\O.S\Linux\Extracted\ubuntu-24.04-desktop-amd64\it
ERROR: Cannot create folder : Cannot create a file when that file already exists. : F:\System\O.S\Linux\Extracted\ubuntu-24.04-desktop-amd64\pt
ERROR: Cannot create folder : Cannot create a file when that file already exists. : F:\System\O.S\Linux\Extracted\ubuntu-24.04-desktop-amd64\pt_BR
ERROR: Cannot create folder : Cannot create a file when that file already exists. : F:\System\O.S\Linux\Extracted\ubuntu-24.04-desktop-amd64\ru
ERROR: Cannot create folder : Cannot create a file when that file already exists. : F:\System\O.S\Linux\Extracted\ubuntu-24.04-desktop-amd64\zh_CN
ERROR: Cannot create folder : Cannot create a file when that file already exists. : F:\System\O.S\Linux\Extracted\ubuntu-24.04-desktop-amd64\info
ERROR: Dangerous link path was ignored : var\lib\swcatalog\yaml\ftpmaster.internal_ubuntu__dists_noble_main_dep11_Components-amd64.yml.gz : /var/lib/apt/lists/ftpmaster.internal_ubuntu__dists_noble_main_dep11_Components-amd64.yml.gz
ERROR: Dangerous link path was ignored : var\lib\swcatalog\yaml\ftpmaster.internal_ubuntu__dists_noble_multiverse_dep11_Components-amd64.yml.gz : /var/lib/apt/lists/ftpmaster.internal_ubuntu__dists_noble_multiverse_dep11_Components-amd64.yml.gz
ERROR: Dangerous link path was ignored : var\lib\swcatalog\yaml\ftpmaster.internal_ubuntu__dists_noble_universe_dep11_Components-amd64.yml.gz : /var/lib/apt/lists/ftpmaster.internal_ubuntu__dists_noble_universe_dep11_Components-amd64.yml.gz

Sub items Errors: 11

Archives with Errors: 1

Sub items Errors: 11
Root filesystem extracted.
Compressing root filesystem...

7-Zip 24.06 (x64) : Copyright (c) 1999-2024 Igor Pavlov : 2024-05-26

Scanning the drive:
250 folders, 3672 files, 6147781597 bytes (5863 MiB)

Creating archive: F:\System\O.S\Linux\Extracted\ubuntu-24.04-desktop-amd64\rootfs.tar

Add new data to archive: 250 folders, 3672 files, 6147781597 bytes (5863 MiB)


Files read from disk: 3922
Archive size: 6150545408 bytes (5866 MiB)
Everything is Ok

7-Zip 24.06 (x64) : Copyright (c) 1999-2024 Igor Pavlov : 2024-05-26

Scanning the drive:
1 file, 6150545408 bytes (5866 MiB)

Creating archive: F:\System\O.S\Linux\Extracted\ubuntu-24.04-desktop-amd64\rootfs.tar.gz

Add new data to archive: 1 file, 6150545408 bytes (5866 MiB)


Files read from disk: 1
Archive size: 6086816945 bytes (5805 MiB)
Everything is Ok
Root filesystem compressed.
Installing Ubuntu distribution in WSL2...
The system cannot find the path specified.
F:\System\O.S\Linux\install_wel2_ubuntu.ps1 : Failed to install Ubuntu distribution in WSL2.
    + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
    + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,install_wel2_ubuntu.ps1

Please check the WSL2 setup and try again.
```
