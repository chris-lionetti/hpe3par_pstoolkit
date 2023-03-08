## 	© 2019,2020,2023 Hewlett Packard Enterprise Development LP
## 	See LICENSE.txt included in this package
##
##	Description: 	Flash cache operations cmdlets 
##		

$Info  = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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
.PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
#>
[CmdletBinding()]
Param(	[Parameter(Position=0, ValueFromPipeline=$true)][switch]	$Enable,
		[Parameter(Position=1, ValueFromPipeline=$true)][switch]	$Disable,
		[Parameter(Position=2, ValueFromPipeline=$true)]			$WsapiConnection = $global:WsapiConnection
	)
Begin 
{	# Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
}
Process 
{  	$body = @{}	
	If ($Enable) 
		{	$body["flashCachePolicy"] = 1	
		}
	elseIf ($Disable) 
		{	$body["flashCachePolicy"] = 2	
		}
	else
		{	return "Please Select at-list any one from [Enable Or Disable]"
		}
	$Result = $null	
	#Request
	Write-DebugLog "Request: Request to Set-FlashCache_WSAPI (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri '/system' -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	if($Result.StatusCode -eq 200)
		{	write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Successfully Set Flash Cache policy." $Info
			# Results		
			return $Result		
			Write-DebugLog "End: Set-FlashCache_WSAPI." $Debug
		}
	else
		{	write-host ""
			write-host "FAILURE : While Setting Flash Cache policy." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Setting Flash Cache policy." $Info
			return $Result.StatusDescription
		}
}
End 
{ 
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
	New-FlashCache_WSAPI -NoCheckSCMSize "true"
.EXAMPLE	
	New-FlashCache_WSAPI -NoCheckSCMSize "false"
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
Param(	[Parameter(Position=0, ValueFromPipeline=$true)][int]			$SizeGiB,
		[Parameter(Position=1, ValueFromPipeline=$true)][int]			$Mode,
		[Parameter(Position=2, ValueFromPipeline=$true)][System.String]	$RAIDType,
		[Parameter(Position=3, ValueFromPipeline=$true)][System.String]	$NoCheckSCMSize,
		[Parameter(Position=3, ValueFromPipeline=$true)]				$WsapiConnection = $global:WsapiConnection
	)
Begin 
{	# Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
}
Process 
{	Write-DebugLog "Running: Creation of the body hash" $Debug
    # Creation of the body hash
    $body = @{}
	$FlashCacheBody = @{} 
	If($SizeGiB) 	{	$FlashCacheBody["sizeGiB"] = $SizeGiB	}
	If($Mode) 		{	$FlashCacheBody["mode"] = $Mode			}
	if($RAIDType)	
		{	if($RAIDType -eq "R0")
				{	$FlashCacheBody["RAIDType"] = 1
				}
			elseif($RAIDType -eq "R1")
				{	$FlashCacheBody["RAIDType"] = 2
				}		
			else
				{	Write-DebugLog "Stop: Exiting Update-Cpg_WSAPI since RAIDType $RAIDType in incorrect "
					Return "FAILURE : RAIDType :- $RAIDType is an Incorrect Please Use RAIDType R0 or R1 only. "
				}
		}
	If($NoCheckSCMSize) 
		{	$val = $NoCheckSCMSize.ToUpper()
			if($val -eq "TRUE")
				{	$FlashCacheBody["noCheckSCMSize"] = $True
				}
			if($val -eq "FALSE")
				{	$FlashCacheBody["noCheckSCMSize"] = $false
				}		
		}	
	if($FlashCacheBody.Count -gt 0)	{	$body["flashCache"] = $FlashCacheBody }
    $Result = $null		
    #Request
	Write-DebugLog "Request: Request to New-FlashCache_WSAPI(Invoke-WSAPI)." $Debug	
	#Request	
    $Result = Invoke-WSAPI -uri '/' -type 'POST' -body $body -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Successfully Created Flash Cache." $Info
			# Results
			return $Result
			Write-DebugLog "End: New-FlashCache_WSAPI" $Debug
		}
	else
	{	write-host ""
		write-host "FAILURE : While creating a Flash Cache." -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While creating a Flash Cache." $Info
		return $Result.StatusDescription
	}
}
End 
{  
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
.PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
#>
[CmdletBinding()]
Param(	[Parameter(Position=0, ValueFromPipeline=$true)]	$WsapiConnection = $global:WsapiConnection
	)
Begin 
{	# Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
}
Process 
{	#Request
	Write-DebugLog "Request: Request to Remove-FlashCache_WSAPI(Invoke-WSAPI)." $Debug	
	#Request
    $Result = Invoke-WSAPI -uri '/flashcache' -type 'DELETE' -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Successfully Removed Flash CacheD." $Info	
			# Results
			return $Result
			Write-DebugLog "End: Remove-FlashCache_WSAPI" $Debug
		}
	else
		{	write-host ""
			write-host "FAILURE : While Removing Flash Cache." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Removing Flash Cache." $Info
			return $Result.StatusDescription
	}
}
End
{ 
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
.PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
#>
[CmdletBinding()]
Param(	[Parameter(Position=1, ValueFromPipeline=$true)]	$WsapiConnection = $global:WsapiConnection
	)
Begin 
{	#Test if connection exist
	Test-WSAPIConnection -WsapiConnection $WsapiConnection
}
Process 
{	$Result = $null
	$dataPS = $null
	#Request
	$Result = Invoke-WSAPI -uri '/flashcache' -type 'GET' -WsapiConnection $WsapiConnection
	if($Result.StatusCode -eq 200)
		{	$dataPS = $Result.content | ConvertFrom-Json
		}		
	if($Result.StatusCode -eq 200)
		{	write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Command Get-FlashCache_WSAPI Successfully Executed" $Info
			return $dataPS		
		}
	else
		{	write-host ""
			write-host "FAILURE : While Executing Get-FlashCache_WSAPI." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-FlashCache_WSAPI." $Info
			return $Result.StatusDescription
	}
}	
}

Export-ModuleMember Set-FlashCache_WSAPI , New-FlashCache_WSAPI , Remove-FlashCache_WSAPI , Get-FlashCache_WSAPI