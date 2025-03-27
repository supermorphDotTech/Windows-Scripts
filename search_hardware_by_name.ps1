<#
.SYNOPSIS
	Searches for user friendly names of hardware devices (i.e. gpu or amd).
.DESCRIPTION
	This PowerShell script searches for the user friendly names of hardware devices. So if
	you search for either the class a device is associated with or if the hardware ID is
	needed, this script will help.

	The search uses likeness, which means you can also just search for a snippet of the
	device name (i.e. gpu or amd).

.EXAMPLE
	Investigating an arbitray hardware Error, you may want to list all devices associated
	with a string (wild card search).
	1) Run this script.
	2) Enter the Device Class or the name of the device.
		- The search term could look like gpu or amd
.INPUTS
	Search term, hardware related.
.OUTPUTS
	All matching user friendly names in the likeness of the search term.
.NOTES
	Visit supermorph.tech on
		https://github.com/supermorphDotTech
	for more modules and other cool stuff check out the homepage
		https://www.supermorph.tech/
		
	For debugging, see the transcript created in $sTranscript
	(default is C:\Windows\Temp\USERNAME\SCRIPTNAME.log).
	
	Author:			Bastian Neuwirth
	Creation Date:	29.03.2024
	Modified Date:	01.05.2024
	Version:		v1.2
	
	Changelog
		v1.2
			Corrected the Write-Output and script version.
		v1.1
			Added transcription of the actually running script version.
		v1.0
			Updated syntax and overall form in line with the template.
		v0.1
			Initial creation.
.COMPONENT
	None.
.ROLE
	Display friendly names of hardware devices.
.FUNCTIONALITY
	This cmdlet runs a query of the search term entered by the user.
	
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
$sScriptVersion = "v1.2"

#Script name
$sScriptName = "search_hardware_by_name.ps1"

#Transcription (Log)
$bTranscriptEnable = $true
$sLogName = "$sScriptName.log"

#---------------------------------------------------
#....................[Functions]....................
#---------------------------------------------------

function fctSearchHardware{
	PARAM()
  
	BEGIN {
		$bErrors = $false
	}

	PROCESS {
		try{
			Write-Output "`n******************************************"
			Write-Output "    SEARCH FOR HARDWARE DEVICE BY NAME"
			Write-Output "******************************************"

			# Request user input for PCI ID
			Write-Output "Insert Device Name as shown in the Devices Manager..."
			$nameSnippet = Read-Host "Device Name: "

			# Initialize evaluation
			$deviceDetected = $false
			$enum = 0

			# Define device search
			$deviceList = Get-PnpDevice | Select-Object -Property Status, Class, FriendlyName, DeviceID

			# Loop through the registry entries.
			foreach($device in $deviceList) {
				
				$deviceName = $device.FriendlyName
				$searchTerm = "*$($nameSnippet)*"
				
				if ($deviceName -eq $null) { continue }
				
				# Filter for devices matching the device name.
				if ($deviceName.Replace(" ","") -like $searchTerm.Replace(" ","")) {
					
					$enum++
					
					if ($enum -eq 1) {
					Write-Output "`n[NR]..[STATUS]..[CLASS]..[NAME]..[ID]`n"
					}
					
					$deviceDetected = $true
					$deviceID = $device.DeviceID
					$deviceStatus = $device.Status
					$deviceClass = $device.Class
					Write-Output "[$($enum)] [$($deviceStatus)] $($deviceClass) | $($deviceName) | $($deviceID)"
				}
			}
		}
		catch{
			$bErrors = $true
			Write-Output "ERROR: $_.Exception"
		}
	}

	END {
		if($bErrors){
			#Stop the Script on Error
			Write-Output "ERROR: Execution stopped."
			if ($bTranscriptEnable) {
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

#---------------------------------------------------
#....................[Execution]....................
#---------------------------------------------------

fctSearchHardware

# Report, if no matching device was found.
if($deviceDetected -eq $false) {
	
	Write-Output "No device is matching $($nameSnippet)"
	
	# Offer a grid view of hardware devices to be displayed.
	# $displayGridResponse = Read-Host "Do you want to display device grid view? [(y)es / (n)o]"
	
	# if($displayGridResponse -eq "y" -or $displayGridResponse -eq "yes") {
		# Get-PnPDevice | Out-GridView -Title 'Select a device' -OutputMode Single | Select-Object -Property *
	# }
}

Write-Output ""

# Wait for user to exit script.
# Read-Host -Prompt "Press Enter to exit"

#---------------------------------------------------
#..................[Transcription]...END............
#---------------------------------------------------

if ($bTranscriptEnable) {
	Stop-Transcript
}