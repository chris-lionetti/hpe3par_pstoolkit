## 	© 2019,2020,2023 Hewlett Packard Enterprise Development LP
##		

Function Get-Port_WSAPI 
{
<#
.SYNOPSIS	
	Get a single or List ports in the storage system.
.DESCRIPTION
	Get a single or List ports in the storage system.
.EXAMPLE
	Get-Port_WSAPI
	Get list all ports in the storage system.
.EXAMPLE
	Get-Port_WSAPI -NSP 1:1:1
	Single port or given port in the storage system.
.EXAMPLE
	Get-Port_WSAPI -Type HOST
	Single port or given port in the storage system.
.EXAMPLE	
	Get-Port_WSAPI -Type "HOST,DISK"
.PARAMETER NSP
	Get a single or List ports in the storage system depanding upon the given type.
.PARAMETER Type	
	Port connection type.
	HOST FC port connected to hosts or fabric.	
	DISK FC port connected to disks.	
	FREE Port is not connected to hosts or disks.	
	IPORT Port is in iport mode.
	RCFC FC port used for Remote Copy.	
	PEER FC port used for data migration.	
	RCIP IP (Ethernet) port used for Remote Copy.	
	ISCSI iSCSI (Ethernet) port connected to hosts.	
	CNA CNA port, which can be FCoE or iSCSI.	
	FS Ethernet File Persona ports.
#>
[CmdletBinding()]
Param(	[Parameter(ParameterSet='NSPD', ValueFromPipeline=$true)]
		[String]	$NSP,
		[Parameter(ParameterSet='TypeD', ValueFromPipeline=$true)]
		[String]	$Type
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null
	$dataPS = $null	
	$Query="?query=""  """
	if($NSP)
	{	$uri = '/ports/'+$NSP
		$Result = Invoke-WSAPI -uri $uri -type 'GET'
		if($Result.StatusCode -eq 200)
		{	$dataPS = $Result.content | ConvertFrom-Json
			write-host "`nCmdlet executed successfully.`n" -foreground green
			Write-DebugLog "SUCCESS: Get-Port_WSAPI successfully Executed." $Info
			return $dataPS		
		}
		else
		{	write-error "`nFAILURE : While Executing Get-Port_WSAPI.`n" 
			Write-DebugLog "FAILURE : While Executing Get-Port_WSAPI. " $Info
			return $Result.StatusDescription
		}
	}
	if($Type)
	{	$dict = @{}
		$dict.Add('HOST','1')
		$dict.Add('DISK','2')
		$dict.Add('FREE','3')
		$dict.Add('IPORT','4')
		$dict.Add('RCFC','5')
		$dict.Add('PEER','6')
		$dict.Add('RCIP','7')
		$dict.Add('ISCSI','8')
		$dict.Add('CNA','9')
		$dict.Add('FS','10')
		$count = 1
		$subEnum = 0
		$lista = $Type.split(",")
		foreach($sub in $lista)
		{	$subEnum = $dict.Get_Item("$sub")
			if($subEnum)
			{	$Query = $Query.Insert($Query.Length-3," type EQ $subEnum")			
				if($lista.Count -gt 1)
				{	if($lista.Count -ne $count)
					{	$Query = $Query.Insert($Query.Length-3," OR ")
						$count = $count + 1
					}				
				}
			}
		}
		$uri = '/ports/'+$Query
		$Result = Invoke-WSAPI -uri $uri -type 'GET' 
		If($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}
		if($dataPS.Count -gt 0)
		{	write-host "`nCmdlet executed successfully.`n" -foreground green
			Write-DebugLog "SUCCESS: Get-Port_WSAPI successfully Executed." $Info
			return $dataPS
		}
		else
		{	write-host "`n FAILURE : While Executing Get-Port_WSAPI. `n"
			Write-DebugLog "FAILURE : While Executing Get-Port_WSAPI." $Info
			return 
		}
	}
	else
	{	$Result = Invoke-WSAPI -uri '/ports' -type 'GET' 
		if($Result.StatusCode -eq 200) {	$dataPS = ($Result.content | ConvertFrom-Json).members	}	
		if($Result.StatusCode -eq 200)
		{	write-host "`n Cmdlet executed successfully.`n" -foreground green
			Write-DebugLog "SUCCESS: Get-Port_WSAPI successfully Executed." $Info
			return $dataPS		
		}
		else
		{	write-host "`n FAILURE : While Executing Get-Port_WSAPI.`n" 
			Write-DebugLog "FAILURE : While Executing Get-Port_WSAPI. " $Info
			return $Result.StatusDescription
		} 
	}
}	
}
Function Get-IscsivLans_WSAPI 
{
<#
.SYNOPSIS	
	Querying iSCSI VLANs for an iSCSI port
.DESCRIPTION
	Querying iSCSI VLANs for an iSCSI port
.EXAMPLE
	Get-IscsivLans_WSAPI
	Get the status of all tasks
.EXAMPLE
	Get-IscsivLans_WSAPI -Type FS
.EXAMPLE
	Get-IscsivLans_WSAPI -NSP 1:0:1
.EXAMPLE	
	Get-IscsivLans_WSAPI -VLANtag xyz -NSP 1:0:1
.PARAMETER Type
	Port connection type.
.PARAMETER NSP
	The <n:s:p> variable identifies the node, slot, and port of the device.
.PARAMETER VLANtag
	VLAN ID.
#>
[CmdletBinding(DefaultParameterSetName='Default')]
Param(	[Parameter(ParameterSetName='TypeA',Mandatory=$true)]	[String]	$Type,
		[Parameter(ParameterSetName='VTag',Mandatory=$true)]
		[Parameter(ParameterSetName='NSP',Mandatory=$true)]		[String]	$NSP,
		[Parameter(ParameterSetName='VTag',Mandatory=$true)]	[String]	$VLANtag
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null
	$dataPS = $null	
	$Query="?query=""  """
	if($Type)
	{	$count = 1
		$lista = $Type.split(",")
		foreach($sub in $lista)
		{	$Query = $Query.Insert($Query.Length-3," type EQ $sub")			
			if($lista.Count -gt 1)
			{	if($lista.Count -ne $count)
				{	$Query = $Query.Insert($Query.Length-3," OR ")
					$count = $count + 1
				}				
			}
		}			
		$uri = '/ports/'+$Query
	}
	if($PSCmdlet.ParameterSetName -eq 'Vtag')	{	$uri = '/ports/'+$NSP+'/iSCSIVlans/'+$VLANtag	}
	if($PSCmdlet.ParameterSetName -eq 'NSP')		{	$uri = '/ports/'+$NSP+'/iSCSIVlans/'	}
	$Result = Invoke-WSAPI -uri $uri -type 'GET'
	if($Result.StatusCode -eq 200)	
	{	$dataPS = ($Result.content | ConvertFrom-Json).members	
		write-host "`nCmdlet executed successfully.`n" -foreground green
		Write-DebugLog "SUCCESS: Command Get-IscsivLans_WSAPI Successfully Executed" $Info
		return $dataPS
	}
	else
	{	write-error "`n FAILURE : While Executing Get-IscsivLans_WSAPI." 
		Write-DebugLog "FAILURE : While Executing Get-IscsivLans_WSAPI." $Info		
		return $Result.StatusDescription
	}
}	
}


Function Get-PortDevices_WSAPI 
{
<#
.SYNOPSIS	
	Get single or list of port devices in the storage system.
.DESCRIPTION
	Get single or list of port devices in the storage system.
.EXAMPLE
	Get-PortDevices_WSAPI -NSP 1:1:1
	Get a list of port devices in the storage system.
.EXAMPLE
	Get-PortDevices_WSAPI -NSP "1:1:1,0:0:0"
	Multiple Port option Get a list of port devices in the storage system.
.PARAMETER NSP
	The <n:s:p> variable identifies the node, slot, and port of the device.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
		[String]	$NSP
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null
	$dataPS = $null	
	$Query="?query=""  """	
	if($NSP)
	{	$lista = $NSP.split(",")
		if($lista.Count -gt 1)
		{	$count = 1
			foreach($sub in $lista)
			{	$Query = $Query.Insert($Query.Length-3," portPos EQ $sub")			
				if($lista.Count -gt 1)
				{	if($lista.Count -ne $count)
					{	$Query = $Query.Insert($Query.Length-3," OR ")
						$count = $count + 1
					}				
				}				
			}
			$uri = '/portdevices'+$Query
			$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
			If($Result.StatusCode -eq 200) {	$dataPS = ($Result.content | ConvertFrom-Json).members	}
			if($dataPS.Count -gt 0)
			{	write-host "`n Cmdlet executed successfully. `n" -foreground green
				Write-DebugLog "SUCCESS: Get-PortDevices_WSAPI successfully Executed." $Info
				return $dataPS
			}
			else
			{	write-host "`n FAILURE : While Executing Get-PortDevices_WSAPI.`n "
				Write-DebugLog "FAILURE : While Executing Get-PortDevices_WSAPI." $Info
				return 
			}
		}
		else
		{	$uri = '/portdevices/all/'+$NSP
			$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
			If($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}	
			if($dataPS.Count -gt 0)
			{	write-host "`n Cmdlet executed successfully.`n" -foreground green
				Write-DebugLog "SUCCESS: Get-PortDevices_WSAPI successfully Executed." $Info
				return $dataPS
			}
			else
			{	write-host "`n FAILURE : While Executing Get-PortDevices_WSAPI. `n"
				Write-DebugLog "FAILURE : While Executing Get-PortDevices_WSAPI." $Info
				return 
			}
		}
	}	
}	
}

Function Get-PortDeviceTDZ_WSAPI 
{
<#
.SYNOPSIS
	Get Single or list of port device target-driven zones.
.DESCRIPTION
	Get Single or list of port device target-driven zones.
.EXAMPLE
	Get-PortDeviceTDZ_WSAPI
	Display a list of port device target-driven zones.
.EXAMPLE
	Get-PortDeviceTDZ_WSAPI -NSP 0:0:0
	Get the information of given port device target-driven zones.
.PARAMETER NSP
	The <n:s:p> variable identifies the node, slot, and port of the device.
#>
[CmdletBinding()]
Param(	[String]	$NSP
	)
Begin 
{	Test-WSAPIConnection 
}
Process 
{	Write-DebugLog "Request: Request to Get-PortDeviceTDZ_WSAPI NSP : $NSP (Invoke-WSAPI)." $Debug
    $Result = $null
	$dataPS = $null		
	if($NSP)
	{	$uri = '/portdevices/targetdrivenzones/'+$NSP
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
		If($Result.StatusCode -eq 200)	{	$dataPS = $Result.content | ConvertFrom-Json	}	
	}	
	else
	{	$Result = Invoke-WSAPI -uri '/portdevices/targetdrivenzones/' -type 'GET' -WsapiConnection $WsapiConnection
		If($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}		
	}

	If($Result.StatusCode -eq 200)
	{	if($dataPS.Count -gt 0)
			{	write-host "`nCmdlet executed successfully.`n" -foreground green
				Write-DebugLog "SUCCESS: Get-PortDeviceTDZ_WSAPI successfully Executed." $Info
				return $dataPS
			}
			else
			{	write-error "`nFAILURE : While Executing Get-PortDeviceTDZ_WSAPI. `n"
				Write-DebugLog "FAILURE : While Executing Get-PortDeviceTDZ_WSAPI." $Info
				return 
			}
	}
	else
	{	write-error "`n FAILURE : While Executing Get-PortDeviceTDZ_WSAPI.`n"
		Write-DebugLog "FAILURE : While Executing Get-PortDeviceTDZ_WSAPI. " $Info
		return $Result.StatusDescription
	}
}
}

Function Get-FcSwitches_WSAPI 
{
<#
.SYNOPSIS
	Get a list of all FC switches connected to a specified port.
.DESCRIPTION
	Get a list of all FC switches connected to a specified port.
.EXAMPLE
	Get-FcSwitches_WSAPI -NSP 0:0:0
	Get a list of all FC switches connected to a specified port.
.PARAMETER NSP
	The <n:s:p> variable identifies the node, slot, and port of the device.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$NSP
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	Write-DebugLog "Request: Request to Get-FcSwitches_WSAPI NSP : $NSP (Invoke-WSAPI)." $Debug
    $Result = $null
	$dataPS = $null		
	if($NSP)
	{	$uri = '/portdevices/fcswitch/'+$NSP
		$Result = Invoke-WSAPI -uri $uri -type 'GET'	
	}
	If($Result.StatusCode -eq 200)
	{	if($dataPS.Count -gt 0)
		{	write-host "`nCmdlet executed successfully.`n" -foreground green
			Write-DebugLog "SUCCESS: Get-FcSwitches_WSAPI successfully Executed." $Info
			return $dataPS
		}
		else
		{	write-error "`nFAILURE : While Executing Get-FcSwitches_WSAPI. `n"
			Write-DebugLog "FAILURE : While Executing Get-FcSwitches_WSAPI." $Info
			return 
		}
	}
	else
	{	write-error "`nFAILURE : While Executing Get-FcSwitches_WSAPI.`n" 
		Write-DebugLog "FAILURE : While Executing Get-FcSwitches_WSAPI. " $Info
		return $Result.StatusDescription
	}
}
}

Function Set-ISCSIPort_WSAPI 
{
<#
.SYNOPSIS
	Configure iSCSI ports
.DESCRIPTION
	Configure iSCSI ports
.EXAMPLE    
	Set-ISCSIPort_WSAPI -NSP 1:2:3 -IPAdr 1.1.1.1 -Netmask xxx -Gateway xxx -MTU xx -ISNSPort xxx -ISNSAddr xxx
	Configure iSCSI ports for given NSP
.PARAMETER NSP 
	The <n:s:p> parameter identifies the port you want to configure.
.PARAMETER IPAdr
	Port IP address
.PARAMETER Netmask
	Netmask for Ethernet
.PARAMETER Gateway
	Gateway IP address
.PARAMETER MTU
	MTU size in bytes
.PARAMETER ISNSPort
	TCP port number for the iSNS server
.PARAMETER ISNSAddr
	iSNS server IP address
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[String]	$NSP,
		[String]	$IPAdr,
		[String]	$Netmask,
		[String]	$Gateway,
		[Int]		$MTU,
		[Int]		$ISNSPort,
		[String]	$ISNSAddr
)
Begin 
{	Test-WSAPIConnection 
}
Process 
{	$body = @{}
	$iSCSIPortInfobody = @{}
	If ($IPAdr) 	{ 	$iSCSIPortInfobody["ipAddr"] ="$($IPAdr)" 	}  
	If ($Netmask) 	{ 	$iSCSIPortInfobody["netmask"] ="$($Netmask)" 	}
	If ($Gateway) 	{ 	$iSCSIPortInfobody["gateway"] ="$($Gateway)" 	}
	If ($MTU) 		{ 	$iSCSIPortInfobody["mtu"] = $MTU	}
	If ($ISNSPort) 	{ 	$iSCSIPortInfobody["iSNSPort"] =$ISNSPort	}
	If ($ISNSAddr) 	{ 	$iSCSIPortInfobody["iSNSAddr"] ="$($ISNSAddr)" 	}
	if($iSCSIPortInfobody.Count -gt 0)	{	$body["iSCSIPortInfo"] = $iSCSIPortInfobody }
    $Result = $null	
	$uri = '/ports/'+$NSP 
	Write-DebugLog "Request: Request to Set-ISCSIPort_WSAPI : $NSP (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	if($Result.StatusCode -eq 200)
	{	write-host "`n Cmdlet executed successfully.`n" -foreground green
		Write-DebugLog "SUCCESS: iSCSI ports : $NSP successfully configure." $Info
		return $Result		
		Write-DebugLog "End: Set-ISCSIPort_WSAPI" $Debug
	}
	else
	{	write-error "`nFAILURE : While Configuring iSCSI ports: $NSP `n "
		Write-DebugLog "FAILURE : While Configuring iSCSI ports: $NSP " $Info
		return $Result.StatusDescription
	}
}
}

Function New-IscsivLan_WSAPI 
{
<#
.SYNOPSIS
	Creates a VLAN on an iSCSI port.
.DESCRIPTION
	Creates a VLAN on an iSCSI port.
.EXAMPLE
	New-IscsivLan_WSAPI -NSP 1:1:1 -IPAddress x.x.x.x -Netmask xx -VlanTag xx
	a VLAN on an iSCSI port
.PARAMETER NSP
	The <n:s:p> parameter identifies the port you want to configure.
.PARAMETER IPAddress
	iSCSI port IPaddress
.PARAMETER Netmask
	Netmask for Ethernet
.PARAMETER VlanTag
	VLAN tag
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[String]	$NSP,

		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[String]	$IPAddress,	 
		
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[String]	$Netmask,	

		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[int]	$VlanTag
)
Begin 
{	Test-WSAPIConnection 
}
Process 
{	Write-DebugLog "Running: Creation of the body hash" $Debug
    $body = @{}    
    $body["ipAddr"] = "$($IPAddress)"
	$body["netmask"] = "$($Netmask)"
	$body["vlanTag"] = $VlanTag   
    $Result = $null
	$uri = "/ports/"+$NSP+"/iSCSIVlans/"
	$Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body
	$status = $Result.StatusCode	
	if($status -eq 201)
	{	write-host "`nCmdlet executed successfully.`n" -foreground green
		Write-DebugLog "SUCCESS: VLAN on an iSCSI port :$NSP created successfully" $Info		
		Write-DebugLog "End: New-IscsivLan_WSAPI" $Debug
		return $Result
	}
	else
	{	write-host "`nFAILURE : While creating VLAN on an iSCSI port : $NSP `n" 
		Write-DebugLog "FAILURE : While VLAN on an iSCSI port : $NSP" $Info
		Write-DebugLog "End: New-IscsivLan_WSAPI" $Debug
		return $Result.StatusDescription
	}	
}
}

Function New-IscsivLun_WSAPI 
{
<#
.SYNOPSIS
	Creates a VLAN on an iSCSI port.
.DESCRIPTION    
	Creates a VLAN on an iSCSI port.
.EXAMPLE
	New-IscsivLun_WSAPI -NSP 1:1:1 -IPAddress x.x.x.x -Netmask xx -VlanTag xx
	a VLAN on an iSCSI port
.PARAMETER NSP
	The <n:s:p> parameter identifies the port you want to configure.
.PARAMETER IPAddress
	iSCSI port IPaddress
.PARAMETER Netmask
	Netmask for Ethernet
.PARAMETER VlanTag
	VLAN tag
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$NSP,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$IPAddress,	  
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$Netmask,	
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[int]		$VlanTag
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	Write-DebugLog "Running: Creation of the body hash" $Debug
    $body = @{}    
    $body["ipAddr"] = "$($IPAddress)"
	$body["netmask"] = "$($Netmask)"
	$body["vlanTag"] = $VlanTag   
    $Result = $null
	$uri = "/ports/"+$NSP+"/iSCSIVlans/"
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body 
	$status = $Result.StatusCode	
	if($status -eq 201)
	{	write-host "`n Cmdlet executed successfully.`n" -foreground green
		Write-DebugLog "SUCCESS: VLAN on an iSCSI port :$NSP created successfully" $Info		
		Write-DebugLog "End: New-IscsivLun_WSAPI" $Debug
		return $Result
	}
	else
	{	write-error "`nFAILURE : While creating VLAN on an iSCSI port : $NSP `n" 
		Write-DebugLog "FAILURE : While VLAN on an iSCSI port : $NSP" $Info
		Write-DebugLog "End: New-IscsivLun_WSAPI" $Debug
		return $Result.StatusDescription
	}	
}
}

Function Set-IscsivLan_WSAPI 
{
<#
.SYNOPSIS
	Configure VLAN on an iSCSI port
.DESCRIPTION
	Configure VLAN on an iSCSI port
.EXAMPLE    
	Set-IscsivLan_WSAPI -NSP 1:2:3 -IPAdr 1.1.1.1 -Netmask xxx -Gateway xxx -MTU xx -STGT xx -ISNSPort xxx -ISNSAddr xxx
	Configure VLAN on an iSCSI port
.PARAMETER NSP 
	The <n:s:p> parameter identifies the port you want to configure.
.PARAMETER VlanTag 
	VLAN tag.
.PARAMETER IPAdr
	Port IP address
.PARAMETER Netmask
	Netmask for Ethernet
.PARAMETER Gateway
	Gateway IP address
.PARAMETER MTU
	MTU size in bytes
.PARAMETER STGT
	Send targets group tag of the iSCSI target.
.PARAMETER ISNSPort
	TCP port number for the iSNS server
.PARAMETER ISNSAddr
	iSNS server IP address
#>
[CmdletBinding()]
Param(	[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
		[String]	$NSP,
		[int]		$VlanTag,	  
		[String]	$IPAdr,
		[String]	$Netmask,
		[String]	$Gateway,
		[Int]		$MTU,
		[Int]		$STGT,
		[Int]		$ISNSPort,
		[String]	$ISNSAddr
)
Begin 
{	Test-WSAPIConnection -WsapiConnection $WsapiConnection
}
Process 
{	$body = @{}		
	If ($IPAdr) 	{ 	$body["ipAddr"] ="$($IPAdr)" 	}  
	If ($Netmask) 	{ 	$body["netmask"] ="$($Netmask)" 	}
	If ($Gateway) 	{ 	$body["gateway"] ="$($Gateway)" 	}
	If ($MTU) 		{ 	$body["mtu"] = $MTU	}
	If ($MTU) 		{ 	$body["stgt"] = $STGT}
	If ($ISNSPort) 	{ 	$body["iSNSPort"] =$ISNSPort}
	If ($ISNSAddr) 	{ 	$body["iSNSAddr"] ="$($ISNSAddr)" 	}
    $Result = $null	
	$uri = "/ports/" + $NSP + "/iSCSIVlans/" + $VlanTag 
	Write-DebugLog "Request: Request to Set-IscsivLan_WSAPI : $NSP (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body -WsapiConnection $WsapiConnection
	if($Result.StatusCode -eq 200)
	{	write-host "`n Cmdlet executed successfully.`n" -foreground green
		Write-DebugLog "SUCCESS: Successfully configure VLAN on an iSCSI port : $NSP ." $Info
		return $Result		
		Write-DebugLog "End: Set-IscsivLan_WSAPI" $Debug
	}
	else
	{	write-host "`n FAILURE : While Configuring VLAN on an iSCSI port : $NSP `n" 
		Write-DebugLog "FAILURE : While Configuring VLAN on an iSCSI port : $NSP " $Info
		return $Result.StatusDescription
	}
}
}

Function Reset-IscsiPort_WSAPI 
{
<#
.SYNOPSIS
	Resetting an iSCSI port configuration
.DESCRIPTION
	Resetting an iSCSI port configuration
.EXAMPLE
	Reset-IscsiPort_WSAPI -NSP 1:1:1 
.PARAMETER NSP
	The <n:s:p> parameter identifies the port you want to configure.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[String]	$NSP
)
Begin 
{	Test-WSAPIConnection 
}
Process 
{	Write-DebugLog "Running: Creation of the body hash" $Debug
    $body = @{}    
    $body["action"] = 2
    $Result = $null
	$uri = '/ports/'+$NSP 
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode	
	if($status -eq 200)
	{	write-host "`nCmdlet executed successfully.`n" -foreground green
		Write-DebugLog "SUCCESS: Successfully Reset an iSCSI port configuration $NSP" $Info		
		Write-DebugLog "End: Reset-IscsiPort_WSAPI" $Debug
		return $Result
	}
	else
	{	write-error "`nFAILURE : While Resetting an iSCSI port configuration : $NSP `n" 
		Write-DebugLog "FAILURE : While Resetting an iSCSI port configuration : $NSP" $Info
		Write-DebugLog "End: Reset-IscsiPort_WSAPI" $Debug		
		return $Result.StatusDescription
	}	
}
}

Function Remove-IscsivLan_WSAPI
{
<#
.SYNOPSIS
	Removing an iSCSI port VLAN.
.DESCRIPTION
	Remove a File Provisioning Group.
.EXAMPLE    
	Remove-IscsivLan_WSAPI -NSP 1:1:1 -VlanTag 1 
	Removing an iSCSI port VLAN
.PARAMETER NSP 
	The <n:s:p> parameter identifies the port you want to configure.
.PARAMETER VlanTag 
	VLAN tag.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[String]	$NSP,

		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[int]		$VlanTag
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{   Write-DebugLog "Running: Building uri to Remove-IscsivLan_WSAPI." $Debug
	$uri = "/ports/"+$NSP+"/iSCSIVlans/"+$VlanTag 
	$Result = $null
	Write-DebugLog "Request: Request to Remove-IscsivLan_WSAPI : $NSP (Invoke-WSAPI)." $Debug
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE'
	$status = $Result.StatusCode
	if($status -eq 202)
	{	write-host "`nCmdlet executed successfully.`n" -foreground green
		Write-DebugLog "SUCCESS: Successfully remove an iSCSI port VLAN : $NSP" $Info
		Write-DebugLog "End: Remove-IscsivLan_WSAPI" $Debug
		return 
	}
	else
	{	write-error "`nFAILURE : While Removing an iSCSI port VLAN : $NSP `n" 
		Write-DebugLog "FAILURE : While Removing an iSCSI port VLAN : $NSP " $Info
		Write-DebugLog "End: Remove-IscsivLan_WSAPI" $Debug
		return $Result.StatusDescription
	}    	
}
}

Export-ModuleMember Get-Port_WSAPI , Get-IscsivLans_WSAPI , Get-PortDevices_WSAPI , Get-PortDeviceTDZ_WSAPI , 
Get-FcSwitches_WSAPI , Get-IscsivLans_WSAPI , Set-ISCSIPort_WSAPI, Set-IscsivLan_WSAPI , New-IscsivLun_WSAPI , Reset-IscsiPort_WSAPI , Remove-IscsivLan_WSAPI
