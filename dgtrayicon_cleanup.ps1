<#
.SYNOPSIS
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
	for more modules and other cool stuff check out the homepage
		https://www.supermorph.tech/
		
	For debugging, see the transcript created in $sTranscript
	(default is C:\Windows\Temp\USERNAME\SCRIPTNAME.log).
	
	Author:			Bastian Neuwirth
	Creation Date:	29.03.2024
	Modified Date:	30.10.2024
	Version:		v1.3
	
	Changelog
		v1.3
			Added fctTestIsElevated() to exit prematurely with a warning if the script is not
			run with elevated privileges.
			Improved error handling.
		v1.2
			Changed variable names to fit the smph standard nomenclature
		v1.1
			Added transcription of the actually running script version.
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
$sScriptVersion = "v1.3"

#Script name
$sScriptName = "dgtrayicon_cleanup.ps1"

#Transcription (Log)
$bTranscriptEnable = $true
$sLogName = "$sScriptName.log"

#Check, if running with elevated privileges
$bCeckIfElevated = $true

#---------------------------------------------------
#....................[Functions]....................
#---------------------------------------------------

Function fctTestIsElevated {
	Param()
  
	BEGIN {
		$bErrors = $false
	}

	PROCESS {
		Try{
			$oCurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
			$oPrincipal = New-Object Security.Principal.WindowsPrincipal($oCurrentIdentity)
			$bScriptRunsElevated = $oPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
			
			if (-not ($bScriptRunsElevated)) {
				Write-Host  -ForegroundColor red "ERROR: This script is not running with elevated privileges. Please run as Administrator."
				exit
			}
		}
		Catch{
			$bErrors = $true
			$sErr = $_.Exception
			$sErrLine = $_.InvocationInfo.ScriptLineNumber
			$sErrMsg = $sErr.Message
			Write-Host -ForegroundColor red "ERROR at line ${sErrLine}:"
			Write-Host -ForegroundColor red "$sErrMsg"
		}
	}

	END {
		If($bErrors){
			#Stop the Script on Error
			Write-Host ""
			Write-Host -ForegroundColor red "Execution aborted."
			Read-Host "Press Enter to exit."
			if ($bTranscriptEnable) {
				Write-Host -ForegroundColor red "Review transcript $sTranscript"
				Stop-Transcript
			}
			exit
		} else {
			#MY CODE IF NO ERRORS
		}
	}
}

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
			$sRegPath = "Registry::HKEY_CURRENT_USER\Software\Classes\AppUserModelId"

			# Get all Keys in ..\NotifyIconSettings and convert it to only the PSChildName.
			$sRegItems_NotifyIconSettings = (Get-ChildItem -Path $sRegPath -Recurse | Select PSChildName).PSChildName

			# Initialize evaluation
			$bRunningAppDetected = $false

			# Loop through the registry entries.
			foreach($sRegItem in $sRegItems_NotifyIconSettings) {
				
				# Filter for NotifyIconGeneratedAumid
				if ($sRegItem -Like 'NotifyIconGeneratedAumid*') {
					
					# Check if app is dgtrayicon.exe
					$sRegItemApp = Get-ItemPropertyValue -Path "$sRegPath\$sRegItem" -Name "DisplayName"
					
					if ($sRegItemApp -eq "dgtrayicon.exe") {
						$bRunningAppDetected = $true
						$sRunningAppKey = $sRegItem.Split("_")[1]
						Write-Output "`nAMD XConnect current Key: $($sRunningAppKey) ($sRegItemApp)"
					}
				}
			}

			# Report, if no matching item was found.
			if($bRunningAppDetected -eq $false) {
				Write-Output "`nNo running instance of AMD XConnect detected."
			}

		}
		Catch{
			$bErrors = $true
			$sErr = $_.Exception
			$sErrLine = $_.InvocationInfo.ScriptLineNumber
			$sErrMsg = $sErr.Message
			Write-Host -ForegroundColor red "ERROR at line ${sErrLine}:"
			Write-Host -ForegroundColor red "$sErrMsg"
		}
	}

	END {
		If($bErrors){
			#Stop the Script on Error
			Write-Host ""
			Write-Host -ForegroundColor red "Execution aborted."
			Read-Host "Press Enter to exit."
			if ($bTranscriptEnable) {
				Write-Host -ForegroundColor red "Review transcript $sTranscript"
				Stop-Transcript
			}
			exit
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
			$sRegPath = "Registry::HKEY_CURRENT_USER\Control Panel\NotifyIconSettings"

			# Get all Keys in ..\NotifyIconSettings and convert it to only the PSChildName.
			$sRegItems_NotifyIconSettings = (Get-ChildItem -Path $sRegPath -Recurse | Select PSChildName).PSChildName

			# Initialize evaluation
			$bRemnantDetected = $false

			# Loop through the registry entries.
			foreach($sRegItem in $sRegItems_NotifyIconSettings) {
				
				# Skip deletion of registry key if belonging to running AMD XConnect instance
				if ($sRegItem -Like $sRunningAppKey) {
					Write-Output "`nRunning instance of AMD XConnect skipped: $($sRegItem)"
					continue
				}
				
				# Build the registry path.
				$sCurrentRegItemPath = $sRegPath + "\" + $sRegItem
				
				# Get the App-Name.
				$sCurrentRegItemExecutablePath = Get-ItemPropertyValue -Path $sCurrentRegItemPath -Name "ExecutablePath"
				
				# Filter for dgtrayicon and delete the entry. Also delete an associated
				# temp file, if found.
				if ($sCurrentRegItemExecutablePath -Like '*dgtrayicon*') {
					
					$bRemnantDetected = $true
					Write-Output "`nKey property detected: $($sCurrentRegItemExecutablePath)"
					
					Remove-Item -Path $sCurrentRegItemPath
					Write-Output "Registry entry deleted: $($sCurrentRegItemPath)"
					
					$sTempFile = "$($env:LOCALAPPDATA)\Temp\NotifyIconGeneratedAumid_$($sRegItem).png"
					if (Test-Path $sTempFile) {
						Remove-Item -Path $sTempFile
						Write-Output "Temp file deleted: $($sTempFile)"
					} else {
						Write-Output "Associated temp file not found."
					}
				}
			}
	}
		Catch{
			$bErrors = $true
			$sErr = $_.Exception
			$sErrLine = $_.InvocationInfo.ScriptLineNumber
			$sErrMsg = $sErr.Message
			Write-Host -ForegroundColor red "ERROR at line ${sErrLine}:"
			Write-Host -ForegroundColor red "$sErrMsg"
		}
	}

	END {
		If($bErrors){
			#Stop the Script on Error
			Write-Host ""
			Write-Host -ForegroundColor red "Execution aborted."
			Read-Host "Press Enter to exit."
			if ($bTranscriptEnable) {
				Write-Host -ForegroundColor red "Review transcript $sTranscript"
				Stop-Transcript
			}
			exit
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
			$sRegPath = "Registry::HKEY_USERS"
			$RegUsers = (Get-ChildItem -Path $sRegPath)

			# Loop through user entries to identify registry remnants
			foreach($user in $RegUsers) {
				
				$sIconSubPath = "Control Panel\NotifyIconSettings"
				$sUserNotifyRegPath = "Registry::$($user)\$($sIconSubPath)"
				
				# Search for \Control Panel\NotifyIconSettings, otherwise skip
				if (Test-Path $sUserNotifyRegPath) {
					Write-Output "Icon Path found: $($sUserNotifyRegPath)"
				} else {
					continue
				}
				
				# Get all Keys in ..\NotifyIconSettings and convert it to only the PSChildName.
				$sRegItems_NotifyIconSettings = (Get-ChildItem -Path $sUserNotifyRegPath -Recurse | Select PSChildName).PSChildName

				# Loop through the registry entries.
				foreach($sRegItem in $sRegItems_NotifyIconSettings) {
					
					# Skip deletion of registry key if belonging to running AMD XConnect instance
					if ($sRegItem -Like $sRunningAppKey) {
						Write-Output "`nRunning instance of AMD XConnect skipped: $($sRegItem)"
						continue
					}
					
					# Build the registry path.
					$sCurrentRegItemPath = $sUserNotifyRegPath + "\" + $sRegItem
					
					# Get the App-Name.
					$sCurrentRegItemExecutablePath = Get-ItemPropertyValue -Path $sCurrentRegItemPath -Name "ExecutablePath"
					
					# Filter for dgtrayicon and delete the entry. Also delete an associated
					# temp file, if found.
					if ($sCurrentRegItemExecutablePath -Like '*dgtrayicon*') {
						
						$bRemnantDetected = $true
						Write-Output "`nKey property detected: $($sCurrentRegItemExecutablePath)"
						
						Remove-Item -Path $sCurrentRegItemPath
						Write-Output "Registry entry deleted: $($sCurrentRegItemPath)"
						
						$sTempFile = "$($env:LOCALAPPDATA)\Temp\NotifyIconGeneratedAumid_$($sRegItem).png"
						if (Test-Path $sTempFile) {
							Remove-Item -Path $sTempFile
							Write-Output "Temp file deleted: $($sTempFile)"
						} else {
							Write-Output "Associated temp file not found."
						}
					}
				}
			}
		}
		Catch{
			$bErrors = $true
			$sErr = $_.Exception
			$sErrLine = $_.InvocationInfo.ScriptLineNumber
			$sErrMsg = $sErr.Message
			Write-Host -ForegroundColor red "ERROR at line ${sErrLine}:"
			Write-Host -ForegroundColor red "$sErrMsg"
		}
	}

	END {
		If($bErrors){
			#Stop the Script on Error
			Write-Host ""
			Write-Host -ForegroundColor red "Execution aborted."
			Read-Host "Press Enter to exit."
			if ($bTranscriptEnable) {
				Write-Host -ForegroundColor red "Review transcript $sTranscript"
				Stop-Transcript
			}
			exit
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
			if($bRemnantDetected -eq $false) {
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
			Write-Host ""
			Write-Host -ForegroundColor red "Execution aborted."
			Read-Host "Press Enter to exit."
			if ($bTranscriptEnable) {
				Write-Host -ForegroundColor red "Review transcript $sTranscript"
				Stop-Transcript
			}
			exit
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

Write-Output "`n******************************************"
Write-Output "   $sScriptName"
Write-Output "   $sScriptVersion"
Write-Output "******************************************"

# Check, if running script as admin. If not, exit with error.
if ($bCeckIfElevated) {
	fctTestIsElevated
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