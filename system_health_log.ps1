<#
.SYNOPSIS
	Log system health data to a file.
.NOTES
	Visit supermorph.tech on
		https://github.com/supermorphDotTech
	for more modules and other cool stuff check out the homepage
		https://www.supermorph.tech/
		
	For debugging, see the transcript created in $sTranscript
	(default is C:\Windows\Temp\USERNAME\SCRIPTNAME.log).
	
	Author:			Bastian Neuwirth
	Creation Date:	15.08.2024
	Modified Date:	15.08.2024
	Version:		v0.1
	
	Changelog
		v0.1
			Initial creation.
.COMPONENT
	Save Wifi passwords to file.
.FUNCTIONALITY
	Store the script on a USB and run it. The SystemHealthLog.txt
	will be stored on the flash drive. Use it with a batch-file
	to run the script from UI via double left click.
	
	set "scriptDir=%~dp0"
	PowerShell -NoProfile -ExecutionPolicy Bypass -File "%scriptDir%system_health_log.ps1"
	
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

#Script Version
$sScriptVersion = "v0.1"

#Script name
$sScriptName = $MyInvocation.MyCommand.Name

#---------------------------------------------------
#..................[Declarations]...................
#---------------------------------------------------

#Transcription (Log)
$bTranscriptEnable = $false
$sTranscript = Join-Path -Path $sLogFolder -ChildPath "$sScriptName.log"

#---------------------------------------------------
#....................[Functions]....................
#---------------------------------------------------

function fctSystemHealthLog {
	<#
	.SYNOPSIS
		Log system health data to a file.
	.EXAMPLE
		fctSystemHealthLog $bTranscriptEnable
	#>
	PARAM(
		[bool]$bTranscriptEnable
	)
  
	BEGIN {
		$bErrors = $false
	}

	PROCESS {
		try {
			# Collecting basic system information and writing to a log file.
			Get-ComputerInfo | Out-File "$PSScriptRoot\SystemHealthLog.txt"
			Get-Process | Out-File -Append "$PSScriptRoot\SystemHealthLog.txt"
			Get-Service | Out-File -Append "$PSScriptRoot\SystemHealthLog.txt"
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
	Start-Transcript -Path $sTranscript
}

Write-Host -ForegroundColor green "`n******************************************"
Write-Host -ForegroundColor green "   $sScriptName"
Write-Host -ForegroundColor green "   $sScriptVersion"
Write-Host -ForegroundColor green "******************************************"

#---------------------------------------------------
#....................[Execution]....................
#---------------------------------------------------

fctSystemHealthLog $bTranscriptEnable

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