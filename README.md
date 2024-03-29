# Windows-Scripts
A collection of miscellaneous scripts for use with Microsoft Windows systems.

# registry_query_and_delete_dgtrayicon.ps1

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

# search_hardware_by_id.ps1

This PowerShell script searches for the user friendly names of hardware devices. So if
for instance the event viewer references a device error, it is usually not clear which
device that would refer to. This script however, will make it clear.
