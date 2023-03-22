﻿####################################################################################
## 	© 2020,2021,2023 Hewlett Packard Enterprise Development LP
##	Description: 	CIM Management cmdlets 
##		

Function Show-CIM {
<#
.SYNOPSIS
    Show the CIM server information
.DESCRIPTION
    The Show-CIM cmdlet displays the CIM server service state being configured,
    either enabled or disabled. It also displays the server current running
    status, either active or inactive. It displays the current status of the
    HTTP and HTTPS ports and their port numbers. In addition, it shows the
    current status of the SLP port, that is either enabled or disabled.
.PARAMETER Pol
    Show CIM server policy information
.EXAMPLE
    The following example shows the current CIM status:

        Show-CIM

        -Service- -State-- --SLP-- SLPPort -HTTP-- HTTPPort -HTTPS- HTTPSPort PGVer  CIMVer
        Enabled   Active   Enabled     427 Enabled     5988 Enabled      5989 2.14.1 3.3.1

    The following example shows the current CIM policy:

        Show-CIM -Pol

        --------------Policy---------------
        replica_entity,one_hwid_per_view,use_pegasus_interop_namespace,no_tls_strict
#>
[CmdletBinding()]
param(  [Switch]    $Pol
    )
Begin
{   Test-CLIConnectionB
}	
Process
{   $cmd = "showcim "
    if ($Pol) {    $cmd += " -pol " }
    $Result = Invoke-CLICommand -Connection $SANConnection -cmds $cmd
    return 	$Result	
}
}

Function Start-CIM {
    <#
.SYNOPSIS
    Start the CIM server to service CIM requests
.DESCRIPTION
    The Start-CIM cmdlet starts the CIM server to service CIM requests. By
    default, the CIM server is not started until this command is issued.
.EXAMPLES
    The following example starts the CIM server:

    Start-CIM
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

Function Set-CIM {
    <#
  .SYNOPSIS
    Set the CIM server properties
                                                                                                           .
  .DESCRIPTION
    The Set-CIM cmdlet sets properties of the CIM server, including options to
    enable/disable the HTTP and HTTPS ports for the CIM server. setcim allows
    a user to enable/disable the SLP port. The command also sets the CIM server
    policy.

  .PARAMETER F
    Forces the operation of the setcim command, bypassing the typical
    confirmation message.
   
  .PARAMETER Slp
      Enables or disables the SLP port 427.

  .PARAMETER Http
      Enables or disables the HTTP port 5988

  .PARAMETER Https
      Enables or disables the HTTPS port 5989

  .PARAMETER Pol
      Sets the cim server policy:

            replica_entity   - complies with SMI-S standard for usage of
                               Replication Entity objects in associations.
                               This is the default policy setting.
            no_replica_entity- does not comply with SMI-S standard for
                               Replication Entity usage. Use only as directed
                               by HPE support personnel or Release Notes.
            one_hwid_per_view - calling exposePaths with multiple
                               initiatorPortIDs to create new view will result
                               in the creation of multiple
                               SCSCIProtocolControllers (SPC), one
                               StorageHardwareID per SPC. Multiple hosts will
                               be created each containing one FC WWN or
                               iscsiname. This is the default policy setting.
                               This is the default policy setting.
            no_one_hwid_per_view - calling exposePaths with multiple
                               initiatorPortIDs to create new view will result
                               in the creation of only one
                               SCSCIProtocolController (SPC) that contains all
                               the StorageHardwareIDs. One host will be created
                               that contains all the FC WWNs or iscsinames.
            use_pegasus_interop_namespace - use the pegasus defined interop
                               namespace root/PG_interop.  This is the default
                               policy setting.
            no_use_pegasus_interop_namespace - use the SMI-S conformant
                               interop namespace root/interop.
            tls_strict       - Only TLS connections using TLS 1.2 with
                               secure ciphers will be accepted if HTTPS is
                               enabled.
            no_tls_strict    - TLS connections using TLS 1.0 - 1.2 will be
                               accepted if HTTPS is enabled. This is the
                               default policy setting.

  .EXAMPLES
    To disable the HTTPS ports:

        Set-CIM -F -Https Disable

    To enable the HTTPS port:

        Set-CIM -F -Https Enable

    To disable the HTTP port and enable the HTTPS port:

        Set-CIM -F -Http Disable -Https Enable

    To set the no_use_pegasus_interop_namespace policy:

        Set-CIM -F -Pol no_use_pegasus_interop_namespace

    To set the replica_entity policy:

        Set-CIM -F -Pol replica_entity
  
  .NOTES
    Access to all domains is required to run this command.

    You cannot disable both of the HTTP and HTTPS ports.

    When the CIM server is active, a warning message will be prompted to inform
    you of the current status of the CIM server and asks for the confirmation to
    continue or not. The -F option forces the action without a warning message.

    NAME:  Set-CIM
    LASTEDIT: 25/04/2021
    KEYWORDS: Set-CIM
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $false, HelpMessage = "To forces the operation")]
        [Switch]
        $F,

        [Parameter(Position = 1, Mandatory = $false, HelpMessage = "To enables or disables the SLP port 427")]
        [ValidateSet("enable", "disable")]
        [System.String]
        $Slp,

        [Parameter(Position = 2, Mandatory = $false, HelpMessage = "To enables or disables the HTTP port 5988")]
        [ValidateSet("enable", "disable")]
        [System.String]
        $Http,

        [Parameter(Position = 3, Mandatory = $false, HelpMessage = "To enables or disables the HTTPS port 5989")]
        [ValidateSet("enable", "disable")]
        [System.String]
        $Https,

        [Parameter(Position = 4, Mandatory = $false, HelpMessage = "To sets the cim server policy")]
        [ValidateSet("replica_entity", "no_replica_entity", "one_hwid_per_view", "no_one_hwid_per_view", "use_pegasus_interop_namespace", "no_use_pegasus_interop_namespace", "tls_strict", "no_tls_strict")]
        [System.String]
        $Pol,
		
        [Parameter(Position = 5, Mandatory = $false, ValueFromPipeline = $true)]
        $SANConnection = $global:SANConnection        
    )	
	
    Write-DebugLog "Start: In Set-CIM   - validating input values" $Debug 
    #check if connection object contents are null/empty
    if (!$SANConnection) {
        #check if connection object contents are null/empty
        $Validate1 = Test-CLIConnection $SANConnection
        if ($Validate1 -eq "Failed") {
            #check if global connection object contents are null/empty
            $Validate2 = Test-CLIConnection $global:SANConnection
            if ($Validate2 -eq "Failed") {
                Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
                Write-DebugLog "Stop: Exiting Set-CIM since SAN connection object values are null/empty" $Debug
                return "Unable to execute the cmdlet Set-CIM since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."               
            }
        }
    }
    $plinkresult = Test-PARCli
    if ($plinkresult -match "FAILURE :") {
        write-debuglog "$plinkresult" "ERR:" 
        return $plinkresult
    }

    $cmd = "setcim "

    if ($F) {
        $cmd += " -f "
    }
    else {
        Return "Force set option is only supported with the Set-CIM cmdlet."
    }
	
    if (($Slp) -or ($Http) -or ($Https) -or ($Pol)) {

        if ($Slp) {
            $cmd += " -slp $Slp"
        }

        if ($Http) {
            $cmd += " -http $Http"
        }

        if ($Https) {
            $cmd += " -https $Https"
        }

        if ($Pol) {
            $cmd += " -pol $Pol"
        }
    }
    else {
        Return "At least one of the options -Slp, -Http, -Https, or -Pol are required."
    }
	
    $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd

    write-debuglog " Executed the Set-CIM cmdlet" "INFO:" 

    return 	$Result	

}

Function Stop-CIM {
    <#
.SYNOPSIS
    Stop the CIM server. Future CIM requests will be not supported.
.DESCRIPTION
    The Stop-CIM cmdlet stops the CIM server from servicing CIM requests.
.PARAMETER Force
    Specifies that the operation is forced. If this option is not used,
    the command requires confirmation before proceeding with its
    operation.
.PARAMETER Immediate
    Specifies that the operation terminates the server immediately
    without graceful shutdown notice.
.EXAMPLE
    The following example stops the CIM server without confirmation

        Stop-CIM -F        

    The following example stops the CIM server immediately without graceful
    shutdown notice and confirmation:

        Stop-CIM -F -X        
#>
[CmdletBinding()]
param(  [Switch]    $Force,
        [Switch]    $Immediate
    )	
Process
{   $cmd = "setcim "	
    if ($Force)         {    $cmd += " -f "    }
    if ($Immediate)     {    $cmd += " -x "    }
    $Result = Invoke-CLICommand -cmds  $cmd
    return 	$Result	
}
}

Export-ModuleMember Show-CIM , Start-CIM , Set-CIM , Stop-CIM