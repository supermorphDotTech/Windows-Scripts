<#
.SYNOPSIS
	Save all Wifi Passwords saved in the PC to a file.
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
	Run the script and follow the prompts.
	
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

function fctWifiPasswords {
	<#
	.SYNOPSIS
		Save all Wifi Passwords saved in the PC to a file.
	.EXAMPLE
		fctWifiPasswords $bTranscriptEnable
	#>
	PARAM(
		[bool]$bTranscriptEnable
	)
  
	BEGIN {
		$bErrors = $false
		$bLocVal = $false
		$bFileOutVal = $false
		$arrResults = @()
		$sysConsolePath = Get-Location
		$sDesktop = [System.Environment]::GetFolderPath("Desktop")
		$sLocalization = [System.Globalization.CultureInfo]::InstalledUICulture.Name
		$hLocalizations = @{
			en = @{
				sProfilesPattern = "All User Profile"
				sKeyPattern = "Key Content"
			}
			de = @{
				sProfilesPattern = "Profil f.r alle Benutzer"
				sKeyPattern = "Schl.sselinhalt"
			}
		}
		
	}

	PROCESS {
		try {
			# Check for the localization of the OS and if supported by this script.
			if ($sLocalization | Select-String -Pattern "en-") {
				$sProfilesPattern = $hLocalizations["en"]["sProfilesPattern"]
				$sKeyPattern = $hLocalizations["en"]["sKeyPattern"]
				$bLocVal = $true
			} elseif ($sLocalization | Select-String -Pattern "de-") {
				$sProfilesPattern = $hLocalizations["de"]["sProfilesPattern"]
				$sKeyPattern = $hLocalizations["de"]["sKeyPattern"]
				$bLocVal = $true
			}
			# Run if localization of OS is supported by this script.
			if ($bLocVal) {
				# Prompt user where the output file shall be stored.
				Write-Host "`nWhere to save wifi_passwords.txt to?"
				Write-Host "1) User Desktop ($sDesktop)"
				Write-Host "2) This location ($($sysConsolePath.Path))"
				Write-Host "3) Custom location"
				while (-not $bFileOutVal) {
					$sFileOut = Read-Host -Prompt "`nChoose 1, 2 or 3"
					if ($sFileOut -in 1,2,3) {
						$bFileOutVal = $true
					} else {
						Write-Host -ForegroundColor red "`nSelection invalid. Please repeat."
					}
				}
				# Evaluate user choice.
				if ($sFileOut -eq 1) {
					$sFilePath = $sDesktop
				} elseif ($sFileOut -eq 2) {
					$sFilePath = $sysConsolePath.Path
				} elseif ($sFileOut -eq 3) {
					$sFilePath = Read-Host -Prompt "`nPath of the directory"
				}
				$arrProfiles = netsh wlan show profiles | Select-String -Pattern $sProfilesPattern | ForEach-Object { $_.Line.Split(":")[1].Trim() }
				# Loop through stored Wifi SSIDs
				foreach ($sProfile in $arrProfiles) {
					if($sProfile -ne "") {
						$sProfileInfo = netsh wlan show profile name="$sProfile" key=clear | Select-String -Pattern $sKeyPattern
						if ($sProfileInfo) {
							$sSsid = "SSID: $sProfile"
							$sKeyContent = $sProfileInfo.Line.Split(":")[1].Trim()
							$arrResults += "$sSsid`nKey : $sKeyContent"
							Write-Host "Profile Key stored for $sProfile"
						}
					}
				}

				$arrResults | Out-File -FilePath "$($sFilePath)\wifipasswords.txt" -Encoding utf8
			} else {
				Write-Host -ForegroundColor red "Localization $sLocalization not supported."
			}
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

fctWifiPasswords $bTranscriptEnable

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