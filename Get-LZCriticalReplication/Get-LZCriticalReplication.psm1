function Get-LZCriticalReplication {

<#
.SYNOPSIS
    Returns replicas delayed by N hours
 
.DESCRIPTION
	Get-LZCriticalReplication is a function that returns the list of replicas delayed by N hours.
	The delay time is defined in hours in the "delay" parameter. If no value is provided, all replicas in critical state are displayed.
	 
.PARAMETER Delay
    Sets the delay time in hours

.EXAMPLE
     Get-LZCriticalReplication -Delay 24

.NOTES
    Author:  Luiz Zurobski
#>

	[CmdletBinding()]
	param (
		[Parameter()]
		[int]$delay
	)
	if($PSBoundParameters.ContainsKey("delay"))
	{
		$date = (Get-Date).AddHours(-$delay)
		Get-VMReplication | 
		select Name, Health, PrimaryServer, LastReplicationTime | 
		where LastReplicationTime -lt $date | 
		Sort-Object -Property LastReplicationTime
	}
	else {
		Get-VMReplication | 
		select Name, Health, PrimaryServer, LastReplicationTime | 
		where Health -eq 'critical' | 
		Sort-Object -Property LastReplicationTime
	}
}
