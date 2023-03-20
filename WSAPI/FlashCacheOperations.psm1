## 	© 2019,2020,2023 Hewlett Packard Enterprise Development LP
##	Description: 	Flash cache operations cmdlets 
##		

Function Set-FlashCache_WSAPI 
{
<#
.SYNOPSIS
	Setting Flash Cache policy
.DESCRIPTION
	Setting Flash Cache policy
.EXAMPLE
	Set-FlashCache_WSAPI -Enable
	Enable Flash Cache policy
.EXAMPLE
	Set-FlashCache_WSAPI -Disable
	Disable Flash Cache policy
.PARAMETER Enable
	Enable Flash Cache policy
.PARAMETER Disable
	Disable Flash Cache policy
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ParameterSetName='Enable', ValueFromPipeline=$true)]	[switch]	$Enable,
		[Parameter(Mandatory=$true, ParameterSetName='Disable', ValueFromPipeline=$true)]	[switch]	$Disable
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{  	$body = @{}	
	If ($Enable)	{	$body["flashCachePolicy"] = 1	}
	If ($Disable) 	{	$body["flashCachePolicy"] = 2	}
	$Result = $null	
    $Result = Invoke-WSAPI -uri '/system' -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	if($Result.StatusCode -eq 200)
		{	write-host "`n SUCCESS: Successfully Set Flash Cache policy. `n" -foreground green
			return $Result		
		}
	else
		{	write-error "`nFAILURE : While Setting Flash Cache policy.`n " 
			return $Result.StatusDescription
		}
}
}

Function New-FlashCache_WSAPI 
{
<#      
.SYNOPSIS	
	Creating a Flash Cache.
.DESCRIPTION	
    Creating a Flash Cache.
.EXAMPLE	
	New-FlashCache_WSAPI -SizeGiB 64 -Mode 1 -RAIDType R6
.EXAMPLE	
	New-FlashCache_WSAPI -SizeGiB 64 -Mode 1 -RAIDType R0
.EXAMPLE	
	New-FlashCache_WSAPI -NoCheckSCMSize $true
.EXAMPLE	
	New-FlashCache_WSAPI -NoCheckSCMSize $false
.PARAMETER SizeGiB
	Specifies the node pair size of the Flash Cache on the system.
.PARAMETER Mode
	Simulator: 1 Real: 2 (default)
.PARAMETER RAIDType  
	Raid Type of the logical disks for flash cache. When unspecified, storage system chooses the default(R0 Level0,R1 Level1).
.PARAMETER NoCheckSCMSize
	Overrides the size comparison check to allow Adaptive Flash Cache creation with mismatched SCM device sizes.
.PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]	[int]			$SizeGiB,
		[Parameter(ValueFromPipeline=$true)]	[int]			$Mode,
		[Parameter(ValueFromPipeline=$true)]
		[ValidateSet('R0','R1')]				[String]		$RAIDType,
		[Parameter(ValueFromPipeline=$true)]	[boolean]		$NoCheckSCMSize
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}
	$FlashCacheBody = @{} 
	If($SizeGiB) 			{	$FlashCacheBody["sizeGiB"] = $SizeGiB	}
	If($Mode) 				{	$FlashCacheBody["mode"] = $Mode			}
	if($RAIDType -eq "R0")	{	$FlashCacheBody["RAIDType"] = 1	}
	if($RAIDType -eq "R1")	{	$FlashCacheBody["RAIDType"] = 2}		
	If($NoCheckSCMSize) 	{	$FlashCacheBody["noCheckSCMSize"] = $NoCheckSCMSize }
	if($FlashCacheBody.Count -gt 0)	{	$body["flashCache"] = $FlashCacheBody }
    $Result = $null
	$Result = Invoke-WSAPI -uri '/' -type 'POST' -body $body
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "`n SUCCESS: Successfully Created Flash Cache.`n" -foreground green
			return $Result
		}
	else
	{	write-error "`n FAILURE : While creating a Flash Cache.`n" 
		return $Result.StatusDescription
	}
}
}
Function Remove-FlashCache_WSAPI 
{
<#      
.SYNOPSIS	
	Removing a Flash Cache.
.DESCRIPTION	
    Removing a Flash Cache.
.EXAMPLE	
	Remove-FlashCache_WSAPI
#>
[CmdletBinding()]
Param()
Begin 
{	Test-WSAPIConnection
}
Process 
{	Write-DebugLog "Request: Request to Remove-FlashCache_WSAPI(Invoke-WSAPI)." $Debug	
	$Result = Invoke-WSAPI -uri '/flashcache' -type 'DELETE'
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "`n SUCCESS: Successfully Removed Flash Cache.`n" -foreground green
			Write-DebugLog "" $Info	
			return $Result
		}
	else
		{	write-error "`n FAILURE : While Removing Flash Cache.`n"
			return $Result.StatusDescription
	}
}
}

Function Get-FlashCache_WSAPI 
{
<#
.SYNOPSIS	
	Get Flash Cache information.
.DESCRIPTION
	Get Flash Cache information.
.EXAMPLE
	Get-FlashCache_WSAPI
	Get Flash Cache information.
#>
[CmdletBinding()]
Param()
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null
	$dataPS = $null
	$Result = Invoke-WSAPI -uri '/flashcache' -type 'GET'
	if($Result.StatusCode -eq 200)	{	$dataPS = $Result.content | ConvertFrom-Json	}		
	if($Result.StatusCode -eq 200)
		{	write-host "`n SUCCESS: Command Get-FlashCache_WSAPI Successfully Executed.`n" -foreground green
			return $dataPS		
		}
	else
		{	write-error "`n FAILURE : While Executing Get-FlashCache_WSAPI.`n"
			return $Result.StatusDescription
	}
}	
}

Export-ModuleMember Set-FlashCache_WSAPI , New-FlashCache_WSAPI , Remove-FlashCache_WSAPI , Get-FlashCache_WSAPI