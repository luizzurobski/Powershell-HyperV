<#
.SYNOPSIS
    Creates virtual machines by importing configuration from a csv file
 
.DESCRIPTION
    Creates virtual machines by importing configuration from a csv file.
	 
.EXAMPLE
     New-BulkVMCreationLZ -csvFilePath "C:\Scripts\VMConfigurations.csv" -ImagePath "C:\Images"

.NOTES
    Author:  Luiz Zurobski
#>

Function New-BulkVMCreationLZ {

	[CmdletBinding()]
	param (
		[Parameter()]
		[string]$csvFilePath = "C:\Scripts\VMConfigurations.csv",
		[Parameter()]
		[string]$ImagePath = "C:\Images"
	)

    # Import VM configurations from CSV file
    $vmConfigurations = Import-Csv -Path $csvFilePath

	# Default VHD path in Hyper-V
	$VHDPath = (Get-VMHost).VirtualHardDiskPath
	
	# Loop through VM configurations and create virtual machines
	foreach ($vm in $vmConfigurations) {
		$vmName = $vm.Name
		$vmMemoryStartupBytes = 1MB*$vm.MemoryStartupBytes
		$vmSwitchName = $vm.SwitchName
		$vmVLANID = $vm.VLANID
		$vmMACAddress = $vm.MACAddress
		$vmProcessors = $vm.Processors
		$vmImage = $vm.Image

		# Create vhd from image
		Copy-Item $ImagePath\$vmImage.vhdx -Destination $VHDPath\$vmName.vhdx

		# Create virtual machine
		$newVM = New-VM -Name $vmName `
			-MemoryStartupBytes $vmMemoryStartupBytes `
			-SwitchName $vmSwitchName `
			-Generation 2 `
			-VHDPath $VHDPath\$vmName.vhdx `
					
		# Set CPU config
		$newVM | Set-VMProcessor -Count $vmProcessors -CompatibilityForMigrationEnabled $true

		# Set VLAN ID
		$vmNetworkAdapter = $newVM | Get-VMNetworkAdapter
		$vmNetworkAdapter | Set-VMNetworkAdapterVlan -Access -VlanId $vmVLANID

		# Set static MAC address
		$vmNetworkAdapter | Set-VMNetworkAdapter -StaticMacAddress $vmMACAddress
		
		# Disable dynamic memory
		$newVM | Set-VMMemory -DynamicMemoryEnabled $false

		Write-Host "Virtual machine '$vmName' created."
	}
}
