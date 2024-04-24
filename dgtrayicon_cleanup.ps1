<#
.Synopsis
	This script mitigates a bug of AMD XConnect (dgtrayicon.exe) that will lead to
	accumulation of registry entries and Task Bar icons.
.DESCRIPTION
	This PowerShell script needs to be run with elevated privileges. It searches for
	remnants in of dgtrayicon.exe leftover in the registry and temp-files. This script
	is intendet to be run at user login, but may be executed at any time, since it
	spares the running app instance from deletion. The script has been tested with
	Windows 11 Pro 23H2 and should in theory be fully compatible with all Windows 10
	or Windows 11 Distributions.
.EXAMPLE
	Just run the script with elevated privileges.
.INPUTS
	None.
.OUTPUTS
	None.
.NOTES
	Visit supermorph.tech on
		https://github.com/supermorphDotTech
	for more cool stuff or check out the homepage
		https://www.supermorph.tech/
		
	For debugging, see the transcript created in $sTranscript
	(default is C:\Windows\Temp\USERNAME\SCRIPTNAME.log).
	
	Author:			###
	Creation Date:	###
	Modified Date:	###
	Version:		v1.0
	
	Changelog
		v1.0
			Updated syntax and overall form in line with the template.
		v0.1
			Initial creation.
.COMPONENT
	None.
.ROLE
	Bug mitigation and registry cleanup.
.FUNCTIONALITY
	1) Identify the running AMD XConnect instance key
	2) Search for registry entries referring to dgtrayicon.exe
	3) Delete the regarding icons of the registry remnants in [USERPROFILE]\AppData\Local\Temp
	
	!! LIMITATIONS !!
	Every script/module being executed from this template as the main
	process needs to have it's own unique filename disregarding of it's
	actual file path. Otherwise these scripts/modules will try to write
	the very same file.

	Due to how transcripts work in powershell, running multiple instances
	and multiple transcripts at the same time may lead to errors. The
	command Stop-Transcript will only stop the last transcript started. In
	case of multiple instances it may lead to loss of data or even file I/O
	collisions.
#>

#---------------------------------------------------
#.................[Initialisations].................
#---------------------------------------------------

#Client Name
$sClientName = $env:Computername

#User Name
$sUserName = $env:USERNAME

#User Profile
$sUserProfile = $env:USERPROFILE

#Temp folder
$sTemp = "$env:WINDIR\Temp"

#Log folder
$sLogFolder = "$sTemp\$sUserName"
if (-not (Test-Path $sLogFolder)) {
			New-Item -Path $sLogFolder -Force
		}

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#---------------------------------------------------
#..................[Declarations]...................
#---------------------------------------------------

#Script Version
$sScriptVersion = "0.1"

#Script name
$sScriptName = "dgtrayicon_cleanup.ps1"

#Transcription (Log)
$bTranscriptEnable = $true
$sLogName = "$sScriptName.log"

#---------------------------------------------------
#....................[Functions]....................
#---------------------------------------------------

Function fctIdentifyLegitRegistryEntry{
	Param()
  
	BEGIN {
		$bErrors = $false
	}

	PROCESS {
		Try{
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
					
					# Check if app is dgtrayicon.exe
					$regItemApp = Get-ItemPropertyValue -Path "$RegPath\$RegItem" -Name "DisplayName"
					
					if ($regItemApp -eq "dgtrayicon.exe") {
						$RunningAppDetected = $true
						$RunningAppKey = $RegItem.Split("_")[1]
						Write-Output "`nAMD XConnect current Key: $($RunningAppKey) ($regItemApp)"
					}
				}
			}

			# Report, if no matching item was found.
			if($RunningAppDetected -eq $false) {
				Write-Output "'nNo running instance of AMD XConnect detected."
			}

	}
		Catch{
			$bErrors = $true
			Write-Output "ERROR: $_.Exception"
		}
	}

	END {
		If($bErrors){
			#Stop the Script on Error
			Write-Output "ERROR: Execution stopped."
			if ($bTranscriptEnable) {
				Stop-Transcript
			}
			Exit
		} else {
			#MY CODE IF NO ERRORS
		}
	}
}

Function fctRegCleanup_HKEY_CURRENT_USER{
	Param()
  
	BEGIN {
		$bErrors = $false
	}

	PROCESS {
		Try{
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
	}
		Catch{
			$bErrors = $true
			Write-Output "ERROR: $_.Exception"
		}
	}

	END {
		If($bErrors){
			#Stop the Script on Error
			Write-Output "ERROR: Execution stopped."
			if ($bTranscriptEnable) {
				Stop-Transcript
			}
			Exit
		} else {
			#MY CODE IF NO ERRORS
		}
	}
}

Function fctRegCleanup_HKEY_USERS{
	Param()
  
	BEGIN {
		$bErrors = $false
	}

	PROCESS {
		Try{
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
		}
		Catch{
			$bErrors = $true
			Write-Output "ERROR: $_.Exception"
		}
	}

	END {
		If($bErrors){
			#Stop the Script on Error
			Write-Output "ERROR: Execution stopped."
			if ($bTranscriptEnable) {
				Stop-Transcript
			}
			Exit
		} else {
			#MY CODE IF NO ERRORS
		}
	}
}

Function fctFinishUp{
	Param()
  
	BEGIN {
		$bErrors = $false
	}

	PROCESS {
		Try{
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
		}
		Catch{
			$bErrors = $true
			Write-Output "ERROR: $_.Exception"
		}
	}

	END {
		If($bErrors){
			#Stop the Script on Error
			Write-Output "ERROR: Execution stopped."
			if ($bTranscriptEnable) {
				Stop-Transcript
			}
			Exit
		} else {
			#MY CODE IF NO ERRORS
		}
	}
}

#---------------------------------------------------
#..................[Transcription]...START..........
#---------------------------------------------------

if ($bTranscriptEnable) {
	$sTranscript = Join-Path -Path $sLogFolder -ChildPath $sLogName
	Start-Transcript -Path $sTranscript
}

#---------------------------------------------------
#....................[Execution]....................
#---------------------------------------------------

fctIdentifyLegitRegistryEntry
fctRegCleanup_HKEY_CURRENT_USER
fctRegCleanup_HKEY_USERS
fctFinishUp

#---------------------------------------------------
#..................[Transcription]...END............
#---------------------------------------------------

if ($bTranscriptEnable) {
	Stop-Transcript
}
