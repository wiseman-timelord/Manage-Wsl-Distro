# Manage-WSL-Distro
Status: Alpha; it has already worked, but the overall usefulness of the program is being reviewed and logical supporting features added, while thats going on things are broken. Its tedious, I am stuck in trying to get GPT and claude to correctly split output from "wsl --list", through entire sessions, and getting in the way of other projects, this project is on hold, as I figured out how to install ubuntu, and must now attend to more important matters. Its all there below, just needs finishing.

### PLANNER:
1. Issue: Instead of option 1, we should "List-WSLDistros" and display the current distro installs above the options on the menu, like...
```
========================================================================================================================
                                                    WSL Distro Manager
------------------------------------------------------------------------------------------------------------------------

                                          NAME                STATE           VERSION
                                       1) Ubuntu-24.04-LTS    Stopped         2

------------------------------------------------------------------------------------------------------------------------

                                                1. Install Ubuntu Distro
                                                2. Remove Ubuntu Distro

========================================================================================================================
Select; Menu Options = 1-2, Exit Program = X:
```
...where...
- the text for the menu items and distros and title has been centered through padding, remember there are 120 characters width.
- Option 2 on the menu, would then have the effect of asking the user which distribution to uninstall, without a re-draw, because it has already listed the distros with their relating numbers. It would of course need to capture the text "Ubuntu-24.04-LTS" somehow. I think this "wsl --list --verbose" command would be better, because you know the name of the model would be the first chunk of text in each line after the first line, and it doesnt have the text (default).
2. Its possible to download any model we want without the store messing things up...
```
Example for Ubuntu 24.04...
Invoke-WebRequest -Uri https://wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2404-240425.AppxBundle -OutFile Ubuntu2404.appx -UseBasicParsing

Distribution options we should include:
Ubuntu Latest - https://aka.ms/wslubuntu
Ubuntu 24.04 - https://wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2404-240425.AppxBundle
Ubuntu 22.04 - https://aka.ms/wslubuntu2204
Ubuntu 20.04 - https://aka.ms/wslubuntu2004
```
...these should be the pre-set options,  but we should also not include options in the list, that are already installed. They will need to remove it first before they are allowed to install again. Either way, after downloading the appx then use the command, for example...
```
Add-AppxPackage .\app_name.appx
```
...hence, we would be somewhat replacing "1. Install Ubuntu Distro" on the menu, as need to list the iso files and present them as options, and do complicated 7z tasks. The appx files should be, downloaded/collected in ".\Cache", and, be checked before the web-request and re-used if present, if the user were to select to install them again. The Appx for 2404 is 600MB while the iso is 6GB, its clearly the better option to use the Appx.
3. The safest method is to rename the appx to a zip, then extract the files to .\extracted, then run ".\extracted\ubuntu.exe" 
4. Fix any remaining issues.
5. Install a distro, remove a distro.
6. Test an installed distro.
7. Test any remaining features.
8. Go back to other PROJECTS.

### DESCRIPTION:
A tool for offline, listing, installing, removing, Ubuntu installs in WSL. Its early works, but the idea is, its possible to manage installs of Ubuntu ISOs for WSL, while, being offline and without using the Ms Store. You would think this would be as simple as installing other microsoft packages offline with a little command, but NO. This can be extremely useful..
1. if you modify your Windoows os, to not have un-necessary M$ code, such as telemetry and windows update and built-in spyware, then this breaks the store, and fixing the store would otherwise require reinstall of OS.
2. If you have low bandwidth, as the isos are now ~6GB.
3. If you have privacy concerns, with, M$ store or ubuntu distros on the M$ store.
4. If you just want to use the ISOs you already downloaded, such as versions unavailable on the store.

### OUTPUT:
- The current main menu, you get the idea...
```
========================================================================================================================
WSL Distro Manager
------------------------------------------------------------------------------------------------------------------------

1. List Installed Ubuntus
2. Install Ubuntu Distro
3. Remove Ubuntu Distro

------------------------------------------------------------------------------------------------------------------------
Select option (1-3), X=Exit:

```

## INSALL AND USAGE:
- TBA.

### NOTATION:
- It could potentially do all of this `https://learn.microsoft.com/en-us/windows/wsl/basic-commands`.
- It Could have some description of GUI, or interface improvement such as arrow controls.
- Delays could be improved, but keeping things slow and simple is probably a good idea, to save on human error and characters used during development.

## DISCLAIMER
This software is subject to the terms in License.Txt, covering usage, distribution, and modifications. For full details on your rights and obligations, refer to License.Txt.
