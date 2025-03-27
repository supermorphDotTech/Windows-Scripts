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
	for more modules and other cool stuff check out the homepage
		https://www.supermorph.tech/
		
	For debugging, see the transcript created in $sTranscript
	(default is C:\Users\USERNAME\SCRIPTNAME.log).
	
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
$sLogFolder = "$sUserProfile\Documents"

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Script Version
$sScriptVersion = "v0.1"

#Script name
$sScriptName = $MyInvocation.MyCommand.Name

#---------------------------------------------------
#..................[Declarations]...................
#---------------------------------------------------

#Transcription (Log)
$bTranscriptEnable = $true
$sTranscript = Join-Path -Path $sLogFolder -ChildPath "$sScriptName.log"

#---------------------------------------------------
#....................[Functions]....................
#---------------------------------------------------

function fctMyFunction() {
	<#
	.SYNOPSIS
		Short description
	.EXAMPLE
		Example of how to use this cmdlet
	#>
	PARAM(
		[bool]$bTranscriptEnable,
		# [string]$sStringVar,
		# [int]$iIntVar
		#...
	)
  
	BEGIN {
		$bErrors = $false
	}

	PROCESS {
		try {
			#MY CODE
		}
		catch {
			$bErrors = $true
			$sErr = $_.Exception
			$sErrLine = $_.InvocationInfo.ScriptLineNumber
			$sErrMsg = $sErr.Message
			Write-Host -ForegroundColor red "ERROR at line ${sErrLine}:"
			Write-Host -ForegroundColor red "$sErrMsg"
		}
	}

	END {
		if($bErrors){
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
			# Write-Host ""
			# Write-Host -ForegroundColor green "Script $sScriptName $sScriptVersion finished without errors."
			# Read-Host "Press Enter to exit."
			# return $sStringVar, $iIntVar
		}
	}
}

#---------------------------------------------------
#..................[Transcription]...START..........
#---------------------------------------------------

if ($bTranscriptEnable) {
	if (-not (Test-Path $sLogFolder)) {
				New-Item -Path $sLogFolder -Force
			}
	Start-Transcript -Path $sTranscript
}

Write-Host -ForegroundColor green "`n******************************************"
Write-Host -ForegroundColor green "   https://www.supermorph.tech/"
Write-Host -ForegroundColor green "   $sScriptName"
Write-Host -ForegroundColor green "   $sScriptVersion"
Write-Host -ForegroundColor green "******************************************"

#---------------------------------------------------
#....................[Execution]....................
#---------------------------------------------------

# Script Execution goes here

#---------------------------------------------------
#..................[Transcription]...END............
#---------------------------------------------------

if ($bTranscriptEnable) {
	Write-Host ''
	Stop-Transcript
	Write-Host ''
}

# Write-Host -ForegroundColor yellow 'Script finished. Press ENTER to exit'
# Read-Host
# Write-Host ''
exit