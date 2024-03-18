function Get-LZVMsByName {

<#
.SYNOPSIS
    Search for VMs across all Hyper-V servers on the network based on specified parameters.
 
.DESCRIPTION
	Search for VMs across all Hyper-V servers on the network based on specified parameters.
	Save your Hyper-V servers list in a csv file and save it as "C:\Scripts\Servers.csv".
	Type your parameter using the standard 'criteria1|criteria2|criteria3'.
	 
.PARAMETER SearchStrings
    Use this parameter to specify the search criterias. Use the standard 'criteria1|criteria2|criteria3'.

.EXAMPLE
     Get-LZVMsByName -SearchStrings 'sql|oracle|db|database'

.NOTES
    Author:  Luiz Zurobski
#>
	
	[CmdletBinding()]
	param (
		[Parameter()]
		[string[]]$SearchStrings
    )
    # Read computer names from the CSV file
    $computers = Import-Csv -Path "C:\Scripts\Servers.csv" | Select-Object -ExpandProperty ComputerName

    foreach ($computer in $computers) {
        Write-Host "Running script on $computer"

        # Run the script remotely on each computer
        Invoke-Command -ComputerName $computer -ScriptBlock {
            param($SearchStrings)
            Get-VM | Where-Object { $_.Name -match ($SearchStrings -join '|') } | Select-Object VMName, ProcessorCount, @{n='Memory (GB)';e={$_.MemoryStartup/1GB}} `
            | Format-Table -AutoSize
        } -ArgumentList $SearchStrings
        
        Write-Host "-------------------------"
    }
}
