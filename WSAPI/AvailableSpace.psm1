####################################################################################
## 	© 2019,2020,2023 Hewlett Packard Enterprise Development LP
##
## 	See LICENSE.txt included in this package
##
##	Description: 	Available space cmdlets 
##		
##	Created:		February 2020
##	Last Modified:	February 2020
##	History:		v3.0 - Created	
#####################################################################################

$Info   = "INFO:"
$Debug  = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Function Get-CapacityInfo_WSAPI 
{
<#
.SYNOPSIS
	Overall system capacity.
.DESCRIPTION
	Overall system capacity.
.PARAMETER WsapiConnection 
  WSAPI Connection object created with Connection command
.EXAMPLE
  Get-CapacityInfo_WSAPI
	Display Overall system capacity.
.Notes
  NAME    : Get-CapacityInfo_WSAPI   
  LASTEDIT: February 2020
  KEYWORDS: Get-CapacityInfo_WSAPI
.Link
  http://www.hpe.com
  Requires PS -Version 3.0
#>
[CmdletBinding()]
Param(  [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]
        $WsapiConnection = $global:WsapiConnection
    )
Process
{ # Test if connection exist    
  Test-WSAPIConnection -WsapiConnection $WsapiConnection
  #Request 
  $Result = Invoke-WSAPI -uri '/capacity' -type 'GET' -WsapiConnection $WsapiConnection
  if($Result.StatusCode -eq 200)
    { # Results
      $dataPS = ($Result.content | ConvertFrom-Json)
    }
  else
    { return $Result.StatusDescription
    }
  # Add custom type to the resulting oject for formating purpose
  Write-DebugLog "Running: Add custom type to the resulting object for formatting purpose" $Debug
  #$AlldataPS = Format-Result -dataPS $dataPS -TypeName '3PAR.Capacity'
  Write-Verbose "Return result(s) without any filter"
  Write-DebugLog "End: Get-CapacityInfo_WSAPI(WSAPI)" $Debug
  return $dataPS
}
}

Export-ModuleMember Get-CapacityInfo_WSAPI
