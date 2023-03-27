####################################################################################
## 	© 2020,2021,2023 Hewlett Packard Enterprise Development LP
##	Description: 	CIM Management cmdlets 
##		

Function Show-CIM 
{
<#
.SYNOPSIS
    Show the CIM server information
.DESCRIPTION
    The Show-CIM cmdlet displays the CIM server service state being configured,
    either enabled or disabled. It also displays the server current running
    status, either active or inactive. It displays the current status of the
    HTTP and HTTPS ports and their port numbers. In addition, it shows the
    current status of the SLP port, that is either enabled or disabled.
.PARAMETER Policy
    Show CIM server policy information
.EXAMPLE
    PS:> show-cim

    CIMVer    : 4.5.7
    SLPPort   : 427
    Service   : Enabled
    HTTPPort  : 5988
    PGVer     : 2.14.1
    HTTP      : Enabled
    HTTPS     : Enabled
    SLP       : Enabled
    HTTPSPort : 5989
    State     : Active

    PS:> show-cim -Policy

    Policy
    ------
    replica_entity,one_hwid_per_view,use_pegasus_interop_namespace,no_tls_strict
#>
[CmdletBinding()]
param(  [Switch]    $Policy
    )
Begin
{   Test-CLIConnectionB
}	
Process
{   $cmd = "showcim "
    if ($Policy) {    $cmd += " -pol " }
    $Result = Invoke-CLICommand -Connection $SANConnection -cmds $cmd
    $R1 = ($Result[0].Split(" ",[System.StringSplitOptions]::RemoveEmptyEntries))
    $R3 = $R1 -replace '-',''
    $R2 = ( $Result[1].Split(" ",[System.StringSplitOptions]::RemoveEmptyEntries) ) 
    $MyObj = @{}
    $Count= 0
    foreach ( $RI in $R3 )
        {   $MyObj["$RI"] =  $R2[$Count] 
            $Count += 1
        }
    return ( $MyObj | convertto-json | convertFrom-json ) 	
}
}

Function Start-CIM 
{
    <#
.SYNOPSIS
    Start the CIM server to service CIM requests
.DESCRIPTION
    The Start-CIM cmdlet starts the CIM server to service CIM requests. By default, the CIM server is not started until this command is issued.
.EXAMPLE
    The following example starts the CIM server:

    PS:> Start-CIM
    CIM server will start shortly.
#>
[CmdletBinding()]
param(
    )	
Begin
{   Test-CLIConnectionB
}
Process
{   $cmd = "startcim "
    $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
    return 	$Result	
}
}

Function Set-CIM 
{
<#
.SYNOPSIS
    Set the CIM server properties.
.DESCRIPTION
    The Set-CIM cmdlet sets properties of the CIM server, including options to enable/disable the HTTP and HTTPS ports for the CIM server. setcim allows
    a user to enable/disable the SLP port. The command also sets the CIM server policy.
.PARAMETER Slp
    Enables or disables the SLP port 427.
.PARAMETER Http
    Enables or disables the HTTP port 5988
.PARAMETER Https
    Enables or disables the HTTPS port 5989
.PARAMETER Pol
    Sets the cim server policy:
            replica_entity   - complies with SMI-S standard for usage of Replication Entity objects in associations. This is the default policy setting.
            no_replica_entity- does not comply with SMI-S standard for Replication Entity usage. Use only as directed by HPE support personnel or Release Notes.
            one_hwid_per_view - calling exposePaths with multiple initiatorPortIDs to create new view will result in the creation of multiple SCSCIProtocolControllers (SPC), one
                                StorageHardwareID per SPC. Multiple hosts will be created each containing one FC WWN or iscsiname. This is the default policy setting. This is the default policy setting.
            no_one_hwid_per_view - calling exposePaths with multiple initiatorPortIDs to create new view will result in the creation of only one SCSCIProtocolController (SPC) that contains all
                                the StorageHardwareIDs. One host will be created that contains all the FC WWNs or iscsinames.
            use_pegasus_interop_namespace - use the pegasus defined interop namespace root/PG_interop.  This is the default policy setting.
            no_use_pegasus_interop_namespace - use the SMI-S conformant interop namespace root/interop.
            tls_strict       - Only TLS connections using TLS 1.2 with secure ciphers will be accepted if HTTPS is enabled.
            no_tls_strict    - TLS connections using TLS 1.0 - 1.2 will be accepted if HTTPS is enabled. This is the default policy setting.
.EXAMPLE
    To disable the HTTPS ports:
        Set-CIM -Https Disable
.EXAMPLE
    To enable the HTTPS port:
        Set-CIM -Https Enable
.EXAMPLE
    To disable the HTTP port and enable the HTTPS port:
        Set-CIM -Http Disable -Https Enable
.EXAMPLE
    To set the no_use_pegasus_interop_namespace policy:
        Set-CIM -Pol no_use_pegasus_interop_namespace
.EXAMPLE
    To set the replica_entity policy:

        Set-CIM  -Pol replica_entity
.NOTES
    Access to all domains is required to run this command.
    You cannot disable both of the HTTP and HTTPS ports.
    When the CIM server is active, a warning message will be prompted to inform
    you of the current status of the CIM server and asks for the confirmation to
    continue or not. The -F option forces the action without a warning message.
#>
[CmdletBinding()]
param(  [ValidateSet("enable", "disable")]
        [String]    $Slp,

        [ValidateSet("enable", "disable")]
        [String]    $Http,

        [ValidateSet("enable", "disable")]
        [String]    $Https,

        [ValidateSet("replica_entity", "no_replica_entity", "one_hwid_per_view", "no_one_hwid_per_view", "use_pegasus_interop_namespace", "no_use_pegasus_interop_namespace", "tls_strict", "no_tls_strict")]
        [String]    $Pol
    )	
Begin
{   Test-CLIConnectionB
}
Process
{   $cmd = "setcim "
    $cmd += " -f " 
	if (($Slp) -or ($Http) -or ($Https) -or ($Pol)) 
    {   if ($Slp)   {    $cmd += " -slp $Slp"    }
        if ($Http)  {    $cmd += " -http $Http"  }
        if ($Https) {    $cmd += " -https $Https"}
        if ($Pol)   {    $cmd += " -pol $Pol"    }
    }
    else 
    {   Write-warning "At least one of the options -Slp, -Http, -Https, or -Pol are required."
        return
    }
    $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
    return 	$Result	
}
}

Function Stop-CIM {
    <#
.SYNOPSIS
    Stop the CIM server. Future CIM requests will be not supported.
.DESCRIPTION
    The Stop-CIM cmdlet stops the CIM server from servicing CIM requests.
.PARAMETER Immediate
    Specifies that the operation terminates the server immediately
    without graceful shutdown notice.
.EXAMPLE
    The following example stops the CIM server without confirmation

        Stop-CIM        

.EXAMPLE
    The following example stops the CIM server immediately without graceful
    shutdown notice and confirmation:

        Stop-CIM -Immediate        
#>
[CmdletBinding()]
param(  [Switch]    $Immediate
    )	
Process
{   $cmd = "setcim "	
    $cmd += " -f "
    if ($Immediate) {   $cmd += " -x "  }
    $Result = Invoke-CLICommand -cmds  $cmd
    return 	$Result	
}
}

Export-ModuleMember Show-CIM , Start-CIM , Set-CIM , Stop-CIM