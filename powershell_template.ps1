<#
.SYNOPSIS
	Short description
.DESCRIPTION
	Long description
.EXAMPLE
	Example of how to use this cmdlet
.EXAMPLE
	Another example of how to use this cmdlet
.INPUTS
	Inputs to this cmdlet (if any)
.OUTPUTS
	Output from this cmdlet (if any)
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
	Version:		v0.1
	
	Changelog
		v0.1
			Initial creation.
.COMPONENT
	Component this cmdlet belongs to
.ROLE
	Role this cmdlet takes within the component
.FUNCTIONALITY
	Functionality that best describes this cmdlet
	
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
$sScriptName = "Script Name"

#Transcription (Log)
$bTranscriptEnable = $true
$sLogName = "$sScriptName.log"

#---------------------------------------------------
#....................[Functions]....................
#---------------------------------------------------

Function fctMyFunction{
	Param()
  
	BEGIN {
		$bErrors = $false
	}
  
	PROCESS {
		Try{
			#MY CODE
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

# Script Execution goes here

#---------------------------------------------------
#..................[Transcription]...END............
#---------------------------------------------------

if ($bTranscriptEnable) {
	Stop-Transcript
}
