## 	© 2019,2020,2023 Hewlett Packard Enterprise Development LP
## 	See LICENSE.txt included in this package
##
##	Description: 	AO configuration information cmdlets 
##		

$Info = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Function Get-AOConfiguration_WSAPI 
{
<#   
.SYNOPSIS	
	Get all or single WSAPI AO configuration information.
.DESCRIPTION
	Get all or single WSAPI AO configuration information.
.EXAMPLE
	Get-AOConfiguration_WSAPI
	Get all WSAPI AO configuration information.
.EXAMPLE
	Get-AOConfiguration_WSAPI -AOconfigName XYZ
	Get single WSAPI AO configuration information.
.PARAMETER AOconfigName
	AO configuration name.
.PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
#>
[CmdletBinding()]
Param(	[Parameter(Position=0, ValueFromPipeline=$true)][System.String]		$AOconfigName,
		[Parameter(Position=1, ValueFromPipeline=$true)]					$WsapiConnection = $global:WsapiConnection
	)
Begin 
{	#Test if connection exist
	Test-WSAPIConnection -WsapiConnection $WsapiConnection
}
Process 
{	$Result = $null
	$dataPS = $null	
	if($AOconfigName)
		{	#Request
			$uri = '/aoconfigurations/'+$AOconfigName
			$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
			if($Result.StatusCode -eq 200)
				{	$dataPS = $Result.content | ConvertFrom-Json
				}
		}	
	else
		{	#Request
			$Result = Invoke-WSAPI -uri '/aoconfigurations' -type 'GET' -WsapiConnection $WsapiConnection
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}	
		}
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -eq 0)
				{	return "No data Fount."
				}
			write-host ""
			write-host "Cmdlet executed successfully" -foreground green
			write-host ""
			Write-DebugLog "SUCCESS: Command Get-AOConfiguration_WSAPI Successfully Executed" $Info
			return $dataPS		
		}
	else
		{	write-host ""
			write-host "FAILURE : While Executing Get-AOConfiguration_WSAPI." -foreground red
			write-host ""
			Write-DebugLog "FAILURE : While Executing Get-AOConfiguration_WSAPI." $Info
			return $Result.StatusDescription
		}
}	
}

Export-ModuleMember Get-AOConfiguration_WSAPI
