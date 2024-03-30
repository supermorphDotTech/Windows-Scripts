# **************************************** #
### DESCRIPTION
# **************************************** #

# This PowerShell script needs to be run with elevated privileges. It searches for
# remnants in of dgtrayicon.exe leftover in the registry and temp-files. This script
# is intendet to be run at user login, but may be executed at any time, since it
# spares the running app instance from deletion. The script has been tested with
# Windows 11 Pro 23H2 and should in theory be fully compatible with all Windows 10
# or Windows 11 Distributions.

# What it does:
# 1) Identify the running AMD XConnect instance key
# 2) Search for registry entries referring to dgtrayicon.exe
# 3) Delete the regarding icons of the registry remnants in [USERPROFILE]\AppData\Local\Temp

# **************************************** #
### IDENTIFY THE CURRENT LEGIT REGISTRY ENTRY
# **************************************** #

Write-Output "`n******************************************"
Write-Output "IDENTIFY THE CURRENT LEGIT REGISTRY ENTRY"
Write-Output "******************************************"

# Define the Registry folder to search through.
$RegPath = "Registry::HKEY_CURRENT_USER\Software\Classes\AppUserModelId"

# Get all Keys in ..\NotifyIconSettings and convert it to only the PSChildName.
$RegItems_NotifyIconSettings = (Get-ChildItem -Path $RegPath -Recurse | Select PSChildName).PSChildName

# Initialize evaluation
$RunningAppDetected = $false

# Loop through the registry entries.
foreach($RegItem in $RegItems_NotifyIconSettings) {
	
	# Filter for NotifyIconGeneratedAumid
	if ($RegItem -Like 'NotifyIconGeneratedAumid*') {
		
		$RunningAppDetected = $true
		$RunningAppKey = $RegItem.Split("_")[1]
		Write-Output "`nAMD XConnect current Key: $($RunningAppKey)"
	}
}

# Report, if no matching item was found.
if($RunningAppDetected -eq $false) {
	Write-Output "'nNo running instance of AMD XConnect detected."
}

# **************************************** #
### SEARCH AND DELETE REGISTRY REMNANTS
### HKEY_CURRENT_USER
# **************************************** #

Write-Output "`n******************************************"
Write-Output "   SEARCH AND DELETE REGISTRY REMNANTS"
Write-Output "   HKEY_CURRENT_USER"
Write-Output "******************************************"

# Define the Registry folder to loop through.
$RegPath = "Registry::HKEY_CURRENT_USER\Control Panel\NotifyIconSettings"

# Get all Keys in ..\NotifyIconSettings and convert it to only the PSChildName.
$RegItems_NotifyIconSettings = (Get-ChildItem -Path $RegPath -Recurse | Select PSChildName).PSChildName

# Initialize evaluation
$RemnantDetected = $false

# Loop through the registry entries.
foreach($RegItem in $RegItems_NotifyIconSettings) {
	
	# Skip deletion of registry key if belonging to running AMD XConnect instance
	if ($RegItem -Like $RunningAppKey) {
		Write-Output "`nRunning instance of AMD XConnect skipped: $($RegItem)"
		continue
	}
	
	# Build the registry path.
	$CurrentRegItemPath = $RegPath + "\" + $RegItem
	
	# Get the App-Name.
	$CurrentRegItemExecutablePath = Get-ItemPropertyValue -Path $CurrentRegItemPath -Name "ExecutablePath"
	
	# Filter for dgtrayicon and delete the entry. Also delete an associated
	# temp file, if found.
	if ($CurrentRegItemExecutablePath -Like '*dgtrayicon*') {
		
		$RemnantDetected = $true
		Write-Output "`nKey property detected: $($CurrentRegItemExecutablePath)"
		
		Remove-Item -Path $CurrentRegItemPath
		Write-Output "Registry entry deleted: $($CurrentRegItemPath)"
		
		$TempFile = "$($env:LOCALAPPDATA)\Temp\NotifyIconGeneratedAumid_$($RegItem).png"
		if (Test-Path $TempFile) {
			Remove-Item -Path $TempFile
			Write-Output "Temp file deleted: $($TempFile)"
		} else {
			Write-Output "Associated temp file not found."
		}
	}
}

# **************************************** #
### SEARCH AND DELETE REGISTRY REMNANTS
### HKEY_USERS
# **************************************** #

Write-Output "`n******************************************"
Write-Output "   SEARCH AND DELETE REGISTRY REMNANTS"
Write-Output "   HKEY_USERS"
Write-Output "******************************************`n"

# Define the Registry folder to loop through.
$RegPath = "Registry::HKEY_USERS"
$RegUsers = (Get-ChildItem -Path $RegPath)

# Loop through user entries to identify registry remnants
foreach($user in $RegUsers) {
	
	$iconSubPath = "Control Panel\NotifyIconSettings"
	$UserNotifyRegPath = "Registry::$($user)\$($iconSubPath)"
	
	# Search for \Control Panel\NotifyIconSettings, otherwise skip
	if (Test-Path $UserNotifyRegPath) {
		Write-Output "Icon Path found: $($UserNotifyRegPath)"
	} else {
		continue
	}
	
	# Get all Keys in ..\NotifyIconSettings and convert it to only the PSChildName.
	$RegItems_NotifyIconSettings = (Get-ChildItem -Path $UserNotifyRegPath -Recurse | Select PSChildName).PSChildName

	# Loop through the registry entries.
	foreach($RegItem in $RegItems_NotifyIconSettings) {
		
		# Skip deletion of registry key if belonging to running AMD XConnect instance
		if ($RegItem -Like $RunningAppKey) {
			Write-Output "`nRunning instance of AMD XConnect skipped: $($RegItem)"
			continue
		}
		
		# Build the registry path.
		$CurrentRegItemPath = $UserNotifyRegPath + "\" + $RegItem
		
		# Get the App-Name.
		$CurrentRegItemExecutablePath = Get-ItemPropertyValue -Path $CurrentRegItemPath -Name "ExecutablePath"
		
		# Filter for dgtrayicon and delete the entry. Also delete an associated
		# temp file, if found.
		if ($CurrentRegItemExecutablePath -Like '*dgtrayicon*') {
			
			$RemnantDetected = $true
			Write-Output "`nKey property detected: $($CurrentRegItemExecutablePath)"
			
			Remove-Item -Path $CurrentRegItemPath
			Write-Output "Registry entry deleted: $($CurrentRegItemPath)"
			
			$TempFile = "$($env:LOCALAPPDATA)\Temp\NotifyIconGeneratedAumid_$($RegItem).png"
			if (Test-Path $TempFile) {
				Remove-Item -Path $TempFile
				Write-Output "Temp file deleted: $($TempFile)"
			} else {
				Write-Output "Associated temp file not found."
			}
		}
	}
}

# Report, if no matching item was found.
if($RemnantDetected -eq $false) {
	Write-Output "`nNo matching keys found."
}

Write-Output "`n******************************************"
Write-Output "   DONE. CONSIDER SUPPORTING MY PROJECTS."
Write-Output "   https://www.supermorph.tech/"
Write-Output "******************************************`n"

# Wait for user to exit script.
# Read-Host -Prompt "Press Enter to exit"

# Trailing linebreak
Write-Output "`n"
