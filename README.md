# Windows-Scripts
A collection of miscellaneous scripts for use with Microsoft Windows systems.

## dgtrayicon_cleanup.ps1

This PowerShell script needs to be run with elevated privileges. It searches for
remnants in of dgtrayicon.exe leftover in the registry and temp-files. This script
is intendet to be run at user login, but may be executed at any time, since it
spares the running app instance from deletion. The script has been tested with
Windows 11 Pro 23H2 and should in theory be fully compatible with all Windows 10
or Windows 11 Distributions.

###### What it does:
1) Identify the running AMD XConnect instance key
2) Search for registry entries referring to dgtrayicon.exe
3) Delete the regarding icons of the registry remnants in [USERPROFILE]\AppData\Local\Temp

## powershell_script.ps1

This PowerShell script serves as a template for all existing and future powershell scripts.
It will create a transcript in
C:\Windows\Temp\USERNAME\SCRIPTNAME.log
Errors will be caught and called modules of the same template will create their own
transcript (log file).

###### Be aware:
Every script/module being executed from this template as the main process needs to
have it's own unique filename disregarding of it's actual file path. Otherwise
these scripts/modules will try to write the very same file.

Due to how transcripts work in powershell, running multiple instances and multiple
transcripts at the same time may lead to errors. The command Stop-Transcript will
only stop the last transcript started. In case of multiple instances it may lead
to loss of data or even file I/O collisions.

## search_hardware_by_id.ps1

This PowerShell script searches for the user friendly names of hardware devices. So if
for instance the event viewer references a device error, it is usually not clear which
device that would refer to. This script however, will make it clear.

The search uses likeness, which means you can also just search for a snippet of the
hardware ID (i.e. PCI\VEN_1022).

## search_hardware_by_name.ps1

This PowerShell script searches for the user friendly names of hardware devices. So if
you search for either the class a device is associated with or if the hardware ID is
needed, this script will help.

The search uses likeness, which means you can also just search for a snippet of the
device name (i.e. amd).
