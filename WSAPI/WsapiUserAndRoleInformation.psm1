﻿## 	© 2019,2020,2023 Hewlett Packard Enterprise Development LP
##

Function Get-Users_WSAPI 
{
<#   
.SYNOPSIS	
	Get all or single WSAPI users information.
.DESCRIPTION
	Get all or single WSAPI users information.
.EXAMPLE
	Get-Users_WSAPI
	Get all WSAPI users information.
.EXAMPLE
	Get-Users_WSAPI -UserName XYZ
	Get single WSAPI users information.
.PARAMETER UserName
	Name Of The User.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)][String]	$UserName
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null
	$dataPS = $null	
	if($UserName)
		{	#Request
			$uri = '/users/'+$UserName
			$Result = Invoke-WSAPI -uri $uri -type 'GET'
			if($Result.StatusCode -eq 200)	{	$dataPS = $Result.content | ConvertFrom-Json	}
		}	
	else
		{	#Request
			$Result = Invoke-WSAPI -uri '/users' -type 'GET'
			if($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}	
		}
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -eq 0)	{	return "No data Fount."	}
			write-host "`n Cmdlet executed successfully.`n" -foreground green
			Write-DebugLog "SUCCESS: Command Get-Users_WSAPI Successfully Executed" $Info
			return $dataPS		
		}
	else
		{	write-Error "`n FAILURE : While Executing Get-Users_WSAPI.`n "
			Write-DebugLog "FAILURE : While Executing Get-Users_WSAPI." $Info
			return $Result.StatusDescription
		}
}	
}

Function Get-Roles_WSAPI 
{
<#   
.SYNOPSIS	
	Get all or single WSAPI role information.
.DESCRIPTION
	Get all or single WSAPI role information.
.EXAMPLE
	Get-Roles_WSAPI
	Get all WSAPI role information.
.EXAMPLE
	Get-Roles_WSAPI -RoleName XYZ
	Get single WSAPI role information.
.PARAMETER RoleName
	Name of the Role.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)][String]	$RoleName
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null
	$dataPS = $null		
	if($RoleName)
		{	#Request
			$uri = '/roles/'+$RoleName
			$Result = Invoke-WSAPI -uri $uri -type 'GET'
			if($Result.StatusCode -eq 200)	{	$dataPS = $Result.content | ConvertFrom-Json	}
		}	
	else
		{	#Request
			$Result = Invoke-WSAPI -uri '/roles' -type 'GET'
			if($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}	
		}
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -eq 0)
				{	Write-Warning "No Data Found."
					return
				}
			write-host "`nCmdlet executed successfully.`n" -foreground green
			Write-DebugLog "SUCCESS: Command Get-Roles_WSAPI Successfully Executed" $Info	
			return $dataPS		
		}
	else
		{	write-Error "`nFAILURE : While Executing Get-Roles_WSAPI." -foreground red
			Write-DebugLog "FAILURE : While Executing Get-Roles_WSAPI." $Info
			return $Result.StatusDescription
	}
}	
}

Export-ModuleMember Get-Users_WSAPI , Get-Roles_WSAPI
