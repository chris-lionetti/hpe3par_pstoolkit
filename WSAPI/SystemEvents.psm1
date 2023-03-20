﻿## 	© 2019,2020,2023 Hewlett Packard Enterprise Development LP
##		

Function Open-SSE_WSAPI 
{
<#   
.SYNOPSIS	
	Establishing a communication channel for Server-Sent Event (SSE).
.DESCRIPTION
	Establishing a communication channel for Server-Sent Event (SSE) 
.EXAMPLE
	Open-SSE_WSAPI
#>
[CmdletBinding()]
Param(
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null
	$dataPS = $null	
	$Result = Invoke-WSAPI -uri '/eventstream' -type 'GET'
	if($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}	
	if($Result.StatusCode -eq 200)
		{	write-host "`n SUCCESS: Command Open-SSE_WSAPI Successfully Executed.`n" -foreground green
			return $dataPS		
		}
	else
		{	write-Error "`n FAILURE : While Executing Open-SSE_WSAPI.`n"
			return $Result.StatusDescription
		}
}	
}

Function Get-EventLogs_WSAPI 
{
<#
.SYNOPSIS	
	Get all past events from system event logs or a logged event information for the available resources. 
.DESCRIPTION
	Get all past events from system event logs or a logged event information for the available resources. 
.EXAMPLE
	Get-EventLogs_WSAPI
#>
[CmdletBinding()]
Param()
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null
	$dataPS = $null	
	#Request
	$Result = Invoke-WSAPI -uri '/eventlog' -type 'GET'
	if($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}	
	if($Result.StatusCode -eq 200)
		{	write-host "`n SUCCESS: Command Get-EventLogs_WSAPI Successfully Executed.`n" -foreground green
			return $dataPS		
		}
	else
		{	write-Error "`n FAILURE : While Executing Get-EventLogs_WSAPI. `n"
			return $Result.StatusDescription
		}
}	
}

Export-ModuleMember Open-SSE_WSAPI , Get-EventLogs_WSAPI
