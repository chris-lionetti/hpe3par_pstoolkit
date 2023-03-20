﻿## 	© 2019,2020,2023 Hewlett Packard Enterprise Development LP
##

Function Get-AOConfiguration_WSAPI 
{
<#
.SYNOPSIS	
	Get all or single Adaptive Optimization configuration information.
.DESCRIPTION
	Get all or single Adaptive Optimization configuration information.
.EXAMPLE
	Get-AOConfiguration_WSAPI
	Get all WSAPI AO configuration information.
.EXAMPLE
	Get-AOConfiguration_WSAPI -AOconfigName XYZ
	Get single WSAPI AO configuration information.
.PARAMETER AOconfigName
	AO configuration name.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)][String]		$AOconfigName
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null
	$dataPS = $null	
	if($AOconfigName)
		{	$uri = '/aoconfigurations/'+$AOconfigName
			$Result = Invoke-WSAPI -uri $uri -type 'GET'
			if($Result.StatusCode -eq 200)	{	$dataPS = $Result.content | ConvertFrom-Json	}
		}	
	else
		{	$Result = Invoke-WSAPI -uri '/aoconfigurations' -type 'GET'
			if($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}	
		}
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -eq 0)
				{	write-warning "No Data Found."
					return
				}
			write-host "`n SUCCESS: Command Get-AOConfiguration_WSAPI Successfully Executed. `n" -foreground green
			return $dataPS		
		}
	else
		{	write-Error "`n FAILURE : While Executing Get-AOConfiguration_WSAPI. `n"
			return $Result.StatusDescription
		}
}	
}

Export-ModuleMember Get-AOConfiguration_WSAPI
