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
    
        $TotalVMCount = 0  # Initialize total VM count
        
        foreach ($computer in $computers) {
            Write-Host "Running script on $computer" -ForegroundColor Yellow
    
            # Run the script remotely on each computer
            $VMs = Invoke-Command -ComputerName $computer -ScriptBlock {
                param($SearchStrings)
                Get-VM | Where-Object { $_.Name -match ($SearchStrings -join '|') }
            } -ArgumentList $SearchStrings
                      
            # Display VM information if VMs are found
            if ($VMs.Count -gt 0) {
                $VMs | Select-Object VMName, ProcessorCount, @{n='Memory (GB)';e={$_.MemoryStartup/1GB}} `
                    | Format-Table -AutoSize
                # Display the number of VMs returned
                Write-Host "The number of VMs found is" $VMs.Count
            } else {
                Write-Host "No VMs found on $computer"
            }
            
            Write-Host "-------------------------"
        }

    }    
