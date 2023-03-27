####################################################################################
## 	© 2020,2021,2023 Hewlett Packard Enterprise Development LP
##
##	Description: 	Configure Web Services API cmdlets 

Function Get-Wsapi
{
<#
.SYNOPSIS
  Get-Wsapi - Show the Web Services API server information.
.DESCRIPTION
  The Get-Wsapi command displays the WSAPI server service configuration state as either Enabled or Disabled. It displays the server current running
  status as Active, Inactive or Error. It also displays the current status of the HTTP and HTTPS ports and their port numbers. WSAPI server URL is
  also displayed.
.EXAMPLE
  PS:> Get-Wsapi -d

  service State                       : Enabled
  HPE Primera UI State                : Active
  server State                        : Active
  HTTPS Port                          : 443
  Number of Sessions Created          : 1
  System Resource Usage               : 96
  Number of Sessions Active           : 0
  Version                             : 1.10.0
  Event Stream State                  : Enabled
  Max Number of SSE Sessions Allowed  : 5
  Number of SSE Sessions Created      : 0
  Number of SSE Sessions Active       : 0
  Session Timeout                     : 15 Minutes
  Policy                              : tls_strict,no_per_user_limit
  API URL                             : https://192.168.1.81/api/v1

.EXAMPLE
  PS:> Get-Wsapi

  Service    : Enabled
  State      : Active
  HTTPS_Port : 443
  Version    : 1.10.0
  API_URL    : https://192.168.1.81/api/v1

.PARAMETER Detailed
  Shows detailed WSAPI information.
#>
[CmdletBinding()]
param( [switch]  $Detailed
  )
Begin
{ Test-CLIConnectionB
}
Process
{   $Cmd = " showwsapi "
    if($Detailed)    {	$Cmd += " -d "  }
    $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
    $range = $Result.count
    if($Result -match "-Service-")
    { $tempFile = [IO.Path]::GetTempFileName()
      foreach ($s in  $Result[0..$range] )
      { $s= [regex]::Replace($s,"^ +","")
        $s= [regex]::Replace($s," +"," ")
        $s= [regex]::Replace($s," ",",")
        $s= $s.Trim() -replace '-Service-,-State-,-HTTP_State-,HTTP_Port,-HTTPS_State-,HTTPS_Port,-Version-,-------------API_URL--------------','Service,State,HTTP_State,HTTP_Port,HTTPS_State,HTTPS_Port,ersion,API_URL'			
        $s = $s.replace('-','')
        Add-Content -Path $tempFile -Value $s
      }
      $ReturnObj = Import-Csv $tempFile
      Remove-Item $tempFile
      return $ReturnObj
    }
    else  
    {	$numc = 0
      $ObjBuild = '{ '
      $tempFile = [IO.Path]::GetTempFileName()
      foreach ($s in $Result[0..$range] )
        { #write-host "Raw Table line = $s"
          $s = $s.Replace(':',',')
          $s = $s.Replace('https,','https:')
          $x = $s.split(', ')
          if ( $x.count -gt 1)
          { if ( $x[1] -ne '') 
            { $numc += 1
              $s =  $x[0].trim() + ', ' + $x[1].trim()
              $z = "`'$($x[0].trim()) `' : `'$($x[1].trim())`'"
              if ($x[0] -contains '-')
              {}
              else
              { if ($range -ne $numc) { $z += ','}
                $ObjBuild += $z
              }
            }
          }
        }
      $ObjBuild += ' }'
      $ReturnObj = ( $ObjBuild | convertFrom-Json )
      return $ReturnObj
    }
}
}

Function Get-WsapiSession
{
<#
.SYNOPSIS
  Get-WsapiSession - Show the Web Services API server sessions information.
.DESCRIPTION
  The Get-WsapiSession command displays the WSAPI server sessions connection information, including the id, node, username, role, hostname,
  and IP Address of the connecting client. It also displays the session creation time and session type.
.EXAMPLE
	Get-WsapiSession
#>
[CmdletBinding()]
param()
begin
{ Test-CLIConnectionB
}
Process  
{ $Cmd = " showwsapisession "
  $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
  Write-DebugLog "Executing Function : Get-WsapiSession Command" INFO: 
	if($Result.Count -gt 2)
	{ $range = $Result.count - 3
		$tempFile = [IO.Path]::GetTempFileName()
		foreach ($s in  $Result[0..$range] )
		{	$s= [regex]::Replace($s,"^ +","")
			$s= [regex]::Replace($s," +"," ")
			$s= [regex]::Replace($s," ",",")
			$s= $s.Trim() -replace 'Id,Node,-Name--,-Role-,-Client_IP_Addr-,----Connected_since----,-State-,-Session_Type-','Id,Node,Name,Role,Client_IP_Addr,Connected_since,State,Session_Type'			
			Add-Content -Path $tempFile -Value $s
		}
		Import-Csv $tempFile
		Remove-Item $tempFile
	}
	else
	{ return $Result
	} 
}
}

Function Remove-WsapiSession
{
<#
.SYNOPSIS
  Remove-WsapiSession - Remove WSAPI user connections.
.DESCRIPTION
  The Remove-WsapiSession command removes the WSAPI user connections from the current system.
.EXAMPLE
	Remove-WsapiSession -Id "1537246327049685" -username 3parxyz -IPAddress "10.10.10.10"
.PARAMETER Patern
  Specifies that the <id>, <user_name> and <IP_address> specifiers are treated as glob-style (shell-style) patterns and all WSAPI user
  connections matching those patterns are removed. By default, confirmation is required to proceed with removing each connection
  unless the -f option is specified.
.PARAMETER DryRun
  Specifies that the operation is a dry run and no connections are removed.
.PARAMETER CloseSse
  Specifies that the Server Sent Event (SSE) connection channel will be
  closed. WSAPI session credential for SSE will not be removed.
.PARAMETER id
  Specifies the Id of the WSAPI session connection to be removed.
.PARAMETER username
  Specifies the name of the WSAPI user to be removed.
.PARAMETER IPAddress
  Specifies the IP address of the WSAPI user to be removed.
#>
[CmdletBinding()]
param(                                [switch]  $Patern,
                                      [switch]  $DryRun,
                                      [switch]  $CloseSse,
        [Parameter(Mandatory=$true)]  [String]  $Id,
        [Parameter(Mandatory=$true)]  [String]  $username,
        [Parameter(Mandatory=$true)]  [String]  $IPAddress
)
begin
{ Test-CLIConnectionB
}
Process
{ $Cmd = " removewsapisession -f"
  if($Patern)     {  $Cmd += " -pat " }
  if($DryRun)     {  $Cmd += " -dr "  }
  if($CloseSse)   {  $Cmd += " $CloseSse " }
  if($Id)         {  $Cmd += " $Id "  }
  if($username)   {  $Cmd += " $username "}
  if($IPAddress)  { $Cmd += " IP_address " }
  $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
  Return $Result
} 
}

Function Set-Wsapi
{
<#
.SYNOPSIS
  Set-Wsapi - Set the Web Services API server properties.
.DESCRIPTION
  The Set-Wsapi command sets properties of the Web Services API server,
  including options to enable or disable the HTTP and HTTPS ports.
.EXAMPLE
	Set-Wsapi -Force -Enable_Http
.PARAMETER Pol
  Sets the WSAPI server policy:
  tls_strict       - only TLS connections using TLS 1.2 with secure ciphers will be accepted if HTTPS is enabled. This is the default policy setting.
  no_tls_strict    - TLS connections using TLS 1.0 - 1.2 will be accepted if HTTPS is enabled.
.PARAMETER Timeout
  Specifies the value that can be set for the idle session timeout for a WSAPI session. <value> is a positive integer and in the range
  of 3-1440 minutes or (3 minutes to 24 hours). Changing the session timeout takes effect immediately and will affect already opened and
  subsequent WSAPI sessions. The default timeout value is 15 minutes.
.PARAMETER Evtstream
  Enables or disables the event stream feature. This supports Server Sent Event (SSE) protocol.
  The default value is enable.
#>
[CmdletBinding()]
param(  [ValidateSet('tls_strict','no_tls_strict')]
        [String]  $Policy,
        [ValidateRange(3,1440)]
        [String]  $Timeout,
        [String]  $Evtstream = 'enable'
  )
begin
{ Test-CLIConnectionB
}
Process
{ $Cmd = " setwsapi "
  $Cmd += " -f "
  if($Policy)   {	$Cmd += " -pol $Policy " }
  if($Timeout)  {	$Cmd += " -timeout $Timeout " }
  if($Evtstream){	$Cmd += " -evtstream $Evtstream " }
  $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
  Return $Result
} 
}

Function Start-Wsapi
{
<#
.SYNOPSIS
  Start-Wsapi - Start the Web Services API server to service HTTP and HTTPS requests.
.DESCRIPTION
  The Start-Wsapi command starts the Web Services API server to service HTTP and HTTPS requests.
  By default, the Web Services API server is not started until this command is issued.
.EXAMPLE
  Start-Wsapi
#>
[CmdletBinding()]
param()
Begin
{ Test-CLIConnectionB
}
Process
{	$cmd= " startwsapi "
  $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd 
	return $Result	
}
}

Function Stop-Wsapi
{
<#
.SYNOPSIS
  Stop-Wsapi - Stop the Web Services API server. Future HTTP and HTTPS requests will be rejected.
.DESCRIPTION
  The Stop-Wsapi command stops the Web Services API server from servicing HTTP and HTTPS requests.
.EXAMPLE
	Stop-Wsapi
#>
[CmdletBinding()]
param()
Begin
{ Test-CLIConnection
}
Process
{ $Cmd = " stopwsapi -f "
  $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
  Return $Result
}
} 

Export-ModuleMember Get-Wsapi , Get-WsapiSession , Remove-WsapiSession , Set-Wsapi , Start-Wsapi , Stop-Wsapi