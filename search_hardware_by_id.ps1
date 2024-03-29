# **************************************** #
### DESCRIPTION
# **************************************** #

# This PowerShell script searches for the user friendly names of hardware devices. So if
# for instance the event viewer references a device error, it is usually not clear which
# device that would refer to. This script however, will make it clear.

### KNOWN BUGS
# Please take not that for reasons unknown to me, sometimes the CimInstance will not fetch
# the friendly names. If you know why, please let me know so I can fix that.

# **************************************** #
### EXECUTION
# **************************************** #

Write-Output "`n******************************************"
Write-Output "    SEARCH FOR HARDWARE DEVICE BY ID"
Write-Output "******************************************"

# Request user input for PCI ID
Write-Output "Insert Device ID as shown in the Event Manager..."
$pciId = Read-Host "Device ID: "

# Initialize evaluation
$deviceDetected = $false
$enum = 0

# Define device search
$deviceList = Get-CimInstance -ClassName Win32_PNPEntity | Select-Object -Property FriendlyName, DeviceID

# Loop through the registry entries.
foreach($device in $deviceList) {
	
	$checkID = $device.DeviceID
	
	# Filter for devices matching the device ID.
	if ($checkID -like "*$($pciId)*") {
		
		$enum++
		$deviceDetected = $true
		$deviceName = $device.FriendlyName
		Write-Output "[$($enum)] $($deviceName) - $($checkID)"
	}
}

# Report, if no matching device was found.
if($deviceDetected -eq $false) {
	
	Write-Output "No device is matching $($pciId)"
	
	# Offer a grid view of hardware devices to be displayed.
	$displayGridResponse = Read-Host "Do you want to display device grid view? [(y)es / (n)o]"
	
	if($displayGridResponse -eq "y" -or $displayGridResponse -eq "yes") {
		Get-PnPDevice | Out-GridView -Title 'Select a device' -OutputMode Single | Select-Object -Property *
	}
}

# Wait for user to exit script.
Read-Host -Prompt "Press Enter to exit"