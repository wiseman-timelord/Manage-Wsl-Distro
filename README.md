# Manage-WSL-Distro
Status: Alpha; it has already worked, but the overall usefulness of the program is being reviewed and logical supporting features added, while thats going on things are broken.

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

2. (Needs re-assessment after above) When Selecting option 3 to remove a distro, it cant find any distros...
```
No Ubuntu distros found.
```
...However, it is able to find distros when I use option 1 to list the currently installed distros. In option 1 I want it to be verbose, but option 3 will should use a simpler command, and expect different response detailing what models are installed, example output...
```
C:\Users\Mastar>wsl --list
Windows Subsystem for Linux Distributions:
Ubuntu-24.04-LTS (Default)
```
...this should then result in script offering these as options to remove, and then when the user selects a distributin to remove, we should firstmake sure its not running... 
```
wsl --terminate <Distribution Name>
```
...and then remove it...
```
To unregister and uninstall a WSL distribution:
PowerShell

wsl --unregister <DistributionName>

Replacing <DistributionName> with the name of your targeted Linux distribution will unregister that distribution from WSL so it can be reinstalled or cleaned up. Caution: Once unregistered, all data, settings, and software associated with that distribution will be permanently lost. Reinstalling from the store will install a clean copy of the distribution. For example, wsl --unregister Ubuntu would remove Ubuntu from the distributions available in WSL. 
```
...and then if success, then run...
```
Running 
wsl --list
 will reveal that it is no longer listed.
```
...to confirm the relevant distribution is removed. Or if it fails with an error, then it should report the error to the user, and then return to main menu.

2. Fix any remaining issues.
3. Install a distro, remove a distro.
4. Test an installed distro.
5. Test any remaining features.
6. Go back to other PROJECTS.

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
