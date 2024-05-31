<#
.SYNOPSIS
	This script mitigates a bug of AMD XConnect (dgtrayicon.exe) that will lead to
	accumulation of registry entries and Task Bar icons. It is developed for
	Windows 11, but should work seamlessly with Windows 10.
.DESCRIPTION
	This script mitigates a bug of AMD XConnect (dgtrayicon.exe) that will lead to
	accumulation of registry entries and Task Bar icons. 
	This PowerShell script needs to be run with elevated privileges. It searches for
	remnants in of dgtrayicon.exe leftover in the registry and temp-files. This script
	is intendet to be run at user login, but may be executed at any time, since it
	spares the running app instance from deletion. The script has been tested with
	Windows 11 Pro 23H2 and should in theory be fully compatible with all Windows 10
	or Windows 11 Distributions.
.EXAMPLE
	Run the script with elevated privileges, preferably by GPO at
	user login.
.INPUTS
	None
.OUTPUTS
	None
.NOTES
	Visit supermorph.tech on
		https://github.com/supermorphDotTech
	for more modules and other cool stuff check out the homepage
		https://www.supermorph.tech/
		
	For debugging, see the transcript created in $sTranscript
	(default is C:\Windows\Temp\USERNAME\SCRIPTNAME.log).
	
	Author:			Bastian Neuwirth
	Creation Date:	01.05.2024
	Modified Date:	-
	Version:		v0.1
	
	Changelog
		v0.1
			Initial creation.
.COMPONENT
	None
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
$sScriptVersion = "v0.1"

#Script name
$sScriptName = "amd_egpu_win11_fixes"

#Transcription (Log)
$bTranscriptEnable = $true
$sLogName = "$sScriptName.log"

#eGPU name by likeness (i.e. 4080)
#> Make sure only a single device is detected.
$sEgpuSearch = "AMD Radeon RX 7800 XT"

#iGPU or dGPU name by likeness (i.e. 4080)
#> Make sure only a single device is detected.
$sIgpuSearch = "AMD Radeon(TM) Graphics"

#---------------------------------------------------
#....................[Functions]....................
#---------------------------------------------------

function fctSearchHardware{
	PARAM(
		[string]$nameSnippet
	)
  
	BEGIN {
		$bErrors = $false
	}

	PROCESS {
		try{
			Write-Output "`nSearching for device `"$nameSnippet`""

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
				
				# Filter for devices matching the search term.
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
					
					# Store temporary device
					$sGpuName = $deviceName
					$sGpuId = $deviceID
					$arrReturn = @($sGpuName, $sGpuId)
				}
			}
			
			# Abort execution, if more than 1 device was found. Search term needs to lead to
			# a single device.
			if ($enum -gt 1) {
				Read-Host "`nERROR - The search term `"$nameSnippet`" is not in one-to-one relation to a device. Please specify it further.`nPress `"Return`" to exit."
				exit
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
			Write-Output "`nDevice `"$sGpuName`" detected. Executing fixes..."
			return $sGpuName, $sGpuId
		}
	}
}

Function fctMyFunction{
	PARAM()
  
	BEGIN {
		$bErrors = $false
	}

	PROCESS {
		try{
			#MY CODE
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

$sEgpuName, $sEgpuId = fctSearchHardware $sEgpuSearch

# $arrEgpu = (fctSearchHardware $sEgpuSearch)[-1]
# $sEgpuName = $arrEgpu[0]
# $sEgpuId = $arrEgpu[1]

# fctSearchHardware $sEgpuSearch
# $sEgpuName = $arrReturn[0]
# $sEgpuId = $arrReturn[1]

# $sEgpuName = $sGpuName
# $sEgpuId = $sGpuId

Write-Output "TEST`n $($sEgpuName)"
Write-Output "TEST`n $($sEgpuId)"
Write-Output "`neGPU detected. Searching for integrated`/dedicated GPU now."

#---------------------------------------------------
#..................[Transcription]...END............
#---------------------------------------------------

if ($bTranscriptEnable) {
	Stop-Transcript
}
