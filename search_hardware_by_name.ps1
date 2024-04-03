# **************************************** #
### DESCRIPTION
# **************************************** #

# This PowerShell script searches for the user friendly names of hardware devices. So if
# you search for either the class a device is associated with or if the hardware ID is
# needed, this script will help.

# The search uses likeness, which means you can also just search for a snippet of the
# device name (i.e. amd).

# **************************************** #
### EXECUTION
# **************************************** #

Write-Output "`n******************************************"
Write-Output "    SEARCH FOR HARDWARE DEVICE BY ID"
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