## 	© 2020,2021,2023 Hewlett Packard Enterprise Development LP
##		

Function New-Host_WSAPI 
{
<#
.SYNOPSIS
	Creates a new host.
.DESCRIPTION    
	Creates a new host.
    Any user with Super or Edit role, or any role granted host_create permission, can perform this operation. Requires access to all domains.    
.EXAMPLE
	New-Host_WSAPI -HostName MyHost
    Creates a new host.
.EXAMPLE
	New-Host_WSAPI -HostName MyHost -Domain MyDoamin	
	Create the host MyHost in the specified domain MyDoamin.
.EXAMPLE
	New-Host_WSAPI -HostName MyHost -Domain MyDoamin -FCWWN XYZ
	Create the host MyHost in the specified domain MyDoamin with WWN XYZ
.EXAMPLE
	New-Host_WSAPI -HostName MyHost -Domain MyDoamin -FCWWN XYZ -Persona GENERIC_ALUA
.EXAMPLE	
	New-Host_WSAPI -HostName MyHost -Domain MyDoamin -Persona GENERIC
.EXAMPLE	
	New-Host_WSAPI -HostName MyHost -Location 1
.EXAMPLE
	New-Host_WSAPI -HostName MyHost -IPAddr 1.0.1.0
.EXAMPLE	
	New-Host_WSAPI -HostName $hostName -Port 1:0:1
.PARAMETER HostName
	Specifies the host name. Required for creating a host.
.PARAMETER Domain
	Create the host in the specified domain, or in the default domain, if unspecified.
.PARAMETER FCWWN
	Set WWNs for the host.
.PARAMETER ForceTearDown
	If set to true, forces tear down of low-priority VLUN exports.
.PARAMETER ISCSINames
	Set one or more iSCSI names for the host.
.PARAMETER Location
	The host’s location.
.PARAMETER IPAddr
	The host’s IP address.
.PARAMETER OS
	The operating system running on the host.
.PARAMETER Model
	The host’s model.
.PARAMETER Contact
	The host’s owner and contact.
.PARAMETER Comment
	Any additional information for the host.
.PARAMETER Persona
	Uses the default persona "GENERIC_ALUA" unless you specify the host persona. Valid answers are GENERIC, GENERIC_ALUA, GENERIC_LEGACY,
	HPUX_LEGACY, AIX_LEGACY, EGENERA, ONTAP_LEGACY,	VMWARE, OPENVMS, HPUX, WindowsServer, AIX_ALUA
.PARAMETER Port
	Specifies the desired relationship between the array ports and the host for target-driven zoning. Use this option when the Smart SAN license is installed only.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true)]
		[String]	$HostName,
		[String]	$Domain,
		[String[]]	$FCWWN,
		[Boolean]	$ForceTearDown,
		[String[]]	$ISCSINames,
		[String]	$Location,
		[String]	$IPAddr,
		[String]	$OS,
		[String]	$Model,
		[String]	$Contact,
		[String]	$Comment,
		[ValidateSet('GENERIC', 'GENERIC_ALUA', 'GENERIC_LEGACY', 'HPUX_LEGACY', 'AIX_LEGACY', 'EGENERA', 'ONTAP_LEGACY',
		'VMWARE' ,'OPENVMS', 'HPUX', 'WindowsServer', 'AIX_ALUA')]
		[String]	$Persona,
		[String[]]	$Port
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	Write-DebugLog "Running: Creation of the body hash" $Debug
    $body = @{}    
    $body["name"] = "$($HostName)"
    If ($Domain)    				{	$body["domain"] = "$($Domain)" 	}
    If ($FCWWN) 					{	$body["FCWWNs"] = $FCWWN    	} 	
    If ($ForceTearDown) 			{	$body["forceTearDown"] = $ForceTearDown    }
	If ($ISCSINames)				{	$body["iSCSINames"] = $ISCSINames }	
	if($Persona -eq "GENERIC")		{	$body["persona"] = 1	}
	if($Persona -eq "GENERIC_ALUA")	{	$body["persona"] = 2	}
	if($Persona -eq "GENERIC_LEGACY"){	$body["persona"] = 3	}
	if($Persona -eq "HPUX_LEGACY")	{	$body["persona"] = 4	}
	if($Persona -eq "AIX_LEGACY")	{	$body["persona"] = 5	}
	if($Persona -eq "EGENERA")		{	$body["persona"] = 6	}
	if($Persona -eq "ONTAP_LEGACY")	{	$body["persona"] = 7	}
	if($Persona -eq "VMWARE")		{	$body["persona"] = 8	}
	if($Persona -eq "OPENVMS")		{	$body["persona"] = 9	}
	if($Persona -eq "HPUX")			{	$body["persona"] = 10	}
	if($Persona -eq "WindowsServer"){	$body["persona"] = 11	}
	if($Persona -eq "AIX_ALUA")		{	$body["persona"] = 12	}
	If ($Port) 	{	$body["port"] = $Port }
	$DescriptorsBody = @{}   
	If ($Location)	{	$DescriptorsBody["location"] 	= "$($Location)"}	
	If ($IPAddr) 	{	$DescriptorsBody["IPAddr"] 		= "$($IPAddr)"  }
	If ($OS) 	    {	$DescriptorsBody["os"] 			= "$($OS)"		}
	If ($Model) 	{	$DescriptorsBody["model"] 		= "$($Model)"   }
	If ($Contact)   {	$DescriptorsBody["contact"] 	= "$($Contact)" }
	If ($Comment)   {	$DescriptorsBody["Comment"] 	= "$($Comment)" }
	if ($DescriptorsBody.Count -gt 0)	{	$body["descriptors"] = $DescriptorsBody 	}    
    $Result = $null
    $Result = Invoke-WSAPI -uri '/hosts' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 201)
	{	write-host "`nCmdlet executed successfully.`n" -foreground green
		Write-DebugLog "SUCCESS: Host:$HostName successfully created" $Info
		Get-Host_WSAPI -HostName $HostName
		Write-DebugLog "End: New-Host_WSAPI" $Debug
	}
	else
	{	write-host "FAILURE : While creating Host:$HostName " -foreground red
		Write-DebugLog "FAILURE : While creating Host:$HostName " $Info
		return $Result.StatusDescription
	}	
}
}

Function Add-RemoveHostWWN_WSAPI 
{
<#
.SYNOPSIS
	Add or remove a host WWN from target-driven zoning
.DESCRIPTION    
	Add a host WWN from target-driven zoning.
    Any user with Super or Edit role, or any role granted host_create permission, can perform this operation. Requires access to all domains.    
.EXAMPLE
	Add-RemoveHostWWN_WSAPI -HostName MyHost -FCWWNs "$wwn" -AddWwnToHost
.EXAMPLE	
	Add-RemoveHostWWN_WSAPI -HostName MyHost -FCWWNs "$wwn" -RemoveWwnFromHost
.PARAMETER HostName
	Host Name.
.PARAMETER FCWWNs
	WWNs of the host.
.PARAMETER Port
	Specifies the ports for target-driven zoning.
	Use this option when the Smart SAN license is installed only.
	This field is NOT supported for the following actions:ADD_WWN_TO_HOST REMOVE_WWN_FROM_H OST,
	It is a required field for the following actions:ADD_WWN_TO_TZONE REMOVE_WWN_FROM_T ZONE.
.PARAMETER AddWwnToHost
	its a action to be performed.
	Recommended method for adding WWN to host. Operates the same as using a PUT method with the pathOperation specified as ADD.
.PARAMETER RemoveWwnFromHost
	Recommended method for removing WWN from host. Operates the same as using the PUT method with the pathOperation specified as REMOVE.
.PARAMETER AddWwnToTZone   
	Adds WWN to target driven zone. Creates the target driven zone if it does not exist, and adds the WWN to the host if it does not exist.
	
.PARAMETER RemoveWwnFromTZone
	Removes WWN from the targetzone. Removes the target driven zone unless it is the last WWN. Does not remove the last WWN from the host.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true)]
		[String]	$HostName,
		[Parameter(Mandatory=$true)]
		[String[]]	$FCWWNs,
		[String[]]	$Port,
		[Parameter(ParameterSetName = 'Add', Mandatory=$true)]
		[switch]	$AddWwnToHost,
		[Parameter(ParameterSetName = 'Remove',	Mandatory=$true)]
		[switch]	$RemoveWwnFromHost,
		[Parameter(ParameterSetName = 'AddT', Mandatory=$true)]
		[switch]	$AddWwnToTZone,
		[Parameter(ParameterSetName = 'RemoveT', Mandatory=$true)]
		[switch]	$RemoveWwnFromTZone
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	Write-DebugLog "Running: Creation of the body hash" $Debug
    $body = @{}
    If($AddWwnToHost) 			{	$body["action"] = 1 }
	if($RemoveWwnFromHost)		{	$body["action"] = 2	}
	If($AddWwnToTZone) 			{	$body["action"] = 3 }
	if($RemoveWwnFromTZone)		{	$body["action"] = 4	}	
	$ParametersBody = @{} 
    If($FCWWNs) {	$ParametersBody["FCWWNs"] = $FCWWNs    }
	If($Port)     {	$ParametersBody["port"] = $Port}
	if($ParametersBody.Count -gt 0)	{	$body["parameters"] = $ParametersBody 	}
    $Result = $null
	$uri = '/hosts/'+$HostName
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 200)
	{	write-host "`nCmdlet executed successfully.`n" -foreground green
		Write-DebugLog "SUCCESS: Command Executed Successfully with Host : $HostName" $Info
		Get-Host_WSAPI -HostName $HostName
		Write-DebugLog "End: Add-RemoveHostWWN_WSAPI" $Debug
	}
	else
	{	write-host "FAILURE : Cmdlet Execution failed with Host : $HostName." -foreground red
		Write-DebugLog "cmdlet Execution failed with Host : $HostName." $Info
		return $Result.StatusDescription
	}	
}
}

Function Update-Host_WSAPI 
{
<#      
.SYNOPSIS	
	Update Host.
.DESCRIPTION	    
    Update Host.
.EXAMPLE	
	Update-Host_WSAPI -HostName MyHost
.EXAMPLE	
	Update-Host_WSAPI -HostName MyHost -ChapName TestHostAS	
.EXAMPLE	
	Update-Host_WSAPI -HostName MyHost -ChapOperationMode 1 
.PARAMETER HostName
	Neme of the Host to Update.
.PARAMETER ChapName
	The chap name.
.PARAMETER ChapOperationMode
	Initiator or target.
.PARAMETER ChapRemoveTargetOnly
	If true, then remove target chap only.
.PARAMETER ChapSecret
	The chap secret for the host or the target
.PARAMETER ChapSecretHex
	If true, then chapSecret is treated as Hex.
.PARAMETER ChapOperation
	Add or remove.
	1) INITIATOR : Set the initiator CHAP authentication information on the host.
	2) TARGET : Set the target CHAP authentication information on the host.
.PARAMETER Descriptors
	The description of the host.
.PARAMETER FCWWN
	One or more WWN to set for the host.
.PARAMETER ForcePathRemoval
	If true, remove WWN(s) or iSCSI(s) even if there are VLUNs that are exported to the host. 
.PARAMETER iSCSINames
	One or more iSCSI names to set for the host.
.PARAMETER NewName
	New name of the host.
.PARAMETER PathOperation
	If adding, adds the WWN or iSCSI name to the existing host. 
	If removing, removes the WWN or iSCSI names from the existing host.
	1) ADD : Add host chap or path.
	2) REMOVE : Remove host chap or path.
.PARAMETER Persona
	The ID of the persona to modify the host’s persona to. Can be one of the following { GENERIC | GENERIC_ALUA | GENERIC_LEGACY |HPUX_LEGACY
	AIX_LEGACY | EGENERA | ONTAP_LEGACY | VMWARE | OPENVMS | HPUX | WindowsServer | AIX_ALUA }
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[String]	$HostName,
		[String]	$ChapName,
		[int]		$ChapOperationMode,
		[Switch]	$ChapRemoveTargetOnly,
		[String]	$ChapSecret,
		[Switch]	$ChapSecretHex,
		[ValidateSet('INITIATOR','TARGET')]
		[String]	$ChapOperation,
		[String]	$Descriptors,
		[String[]]	$FCWWN,
		[Switch]	$ForcePathRemoval,
		[String[]]	$iSCSINames,
		[String]	$NewName,
		[ValidateSet('ADD','REMOVE')]
		[String]	$PathOperation,
		[ValidateSet('GENERIC','GENERIC_LEGACY','HPUX_LEGACY','AIX_LEGACY','EGENERA','ONTAP_LEGACY','VMWARE','OPENVMS','HPUX')]
		[String]	$Persona
)
Begin 
{	Test-WSAPIConnection 
}
Process 
{	$body = @{}		
	If($ChapName) 					{	$body["chapName"] = "$($ChapName)"    }
	If($ChapOperationMode) 			{	$body["chapOperationMode"] = $ChapOperationMode    }
	If($ChapRemoveTargetOnly) 		{	$body["chapRemoveTargetOnly"] = $true    }
	If($ChapSecret) 				{	$body["chapSecret"] = "$($ChapSecret)"    }
	If($ChapSecretHex) 				{	$body["chapSecretHex"] = $true    }
	if($ChapOperation -eq "INITIATOR"){	$body["chapOperation"] = 1	}
	if($ChapOperation -eq "TARGET")	{	$body["chapOperation"] = 2	}
	If($Descriptors) 				{	$body["descriptors"] = "$($Descriptors)" }
	If($FCWWN) 						{	$body["FCWWNs"] = $FCWWN    }
	If($ForcePathRemoval) 			{	$body["forcePathRemoval"] = $true    }
	If($iSCSINames) 				{	$body["iSCSINames"] = $iSCSINames    }
	If($NewName) 					{	$body["newName"] = "$($NewName)"    }
	if($PathOperation -eq "ADD")	{	$body["pathOperation"] = 1	}
	if($PathOperation -eq "REMOVE")	{	$body["pathOperation"] = 2	}
	if($Persona -eq "GENERIC")		{	$body["persona"] = 1		}
	if($Persona -eq "GENERIC_ALUA")	{	$body["persona"] = 2		}
	if($Persona -eq "GENERIC_LEGACY"){	$body["persona"] = 3		}
	if($Persona -eq "HPUX_LEGACY")	{	$body["persona"] = 4		}
	if($Persona -eq "AIX_LEGACY")	{	$body["persona"] = 5		}
	if($Persona -eq "EGENERA")		{	$body["persona"] = 6		}
	if($Persona -eq "ONTAP_LEGACY")	{	$body["persona"] = 7		}
	if($Persona -eq "VMWARE")		{	$body["persona"] = 8		}
	if($Persona -eq "OPENVMS")		{	$body["persona"] = 9		}
	if($Persona -eq "HPUX")			{	$body["persona"] = 10		}
    $Result = $null
	$uri = '/hosts/'+$HostName
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
	$status = $Result.StatusCode
	if($status -eq 200)
	{	write-host "`n SUCCESS: Successfully Update Host : $HostName.`n" -foreground green
		if($NewName){	Get-Host_WSAPI -HostName $NewName}
		else		{	Get-Host_WSAPI -HostName $HostName	}
	}
	else
	{	write-Error "FAILURE : While Updating Host : $HostName." -foreground red
		return $Result.StatusDescription
	}
}
}

Function Remove-Host_WSAPI
{
<#
.SYNOPSIS
	Remove a Host.
.DESCRIPTION
	Remove a Host.
	Any user with Super or Edit role, or any role granted host_remove permission, can perform this operation. Requires access to all domains.
.EXAMPLE    
	Remove-Host_WSAPI -HostName MyHost
.PARAMETER HostName 
	Specify the name of Host to be removed.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory = $true)]
		[String]$HostName
	)
Begin 
{	Test-WSAPIConnection 
}
Process 
{	$uri = '/hosts/'+$HostName
	$Result = $null
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE' 
	$status = $Result.StatusCode
	if($status -eq 200)
	{	write-host "`n SUCCESS: Host:$HostName successfully removed."
		return 
	}
	else
	{	write-host "FAILURE : While Removing Host:$HostName " -foreground red
		return $Result.StatusDescription
	}    
}
}

Function Get-Host_WSAPI 
{
<#
.SYNOPSIS
	Get Single or list of Hotes.
.DESCRIPTION
	Get Single or list of Hotes.
.EXAMPLE
	Get-Host_WSAPI
	Display a list of host.
.EXAMPLE
	Get-Host_WSAPI -HostName MyHost
	Get the information of given host.
.PARAMETER HostName
	Specify name of the Host.
#>
[CmdletBinding()]
Param (	[String]	$HostName
	)
Begin 
{	Test-WSAPIConnection 	 
}
Process 
{	$Result = $null
	$dataPS = $null		
	if($HostName)
	{	$uri = '/hosts/'+$HostName
		$Result = Invoke-WSAPI -uri $uri -type 'GET' 
		If($Result.StatusCode -eq 200)	{	$dataPS = $Result.content | ConvertFrom-Json }	
	}	
	else
	{	$Result = Invoke-WSAPI -uri '/hosts' -type 'GET' 
		If($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}		
	}
	If($Result.StatusCode -eq 200)
	{	write-host "`n SUCCESS: Get-Host_WSAPI successfully Executed.`n"
		return $dataPS
	}
	else
	{	write-Error "FAILURE : While Executing Get-Host_WSAPI."
		return $Result.StatusDescription
	}
}
}

Function Get-HostWithFilter_WSAPI 
{
<#
.SYNOPSIS
	Get Single or list of Hotes information with WWN filtering.
.DESCRIPTION
	Get Single or list of Hotes information with WWN filtering. specify the FCPaths WWN or the iSCSIPaths name.
.EXAMPLE
	Get-HostWithFilter_WSAPI -WWN 123 
	Get a host detail with single wwn name
.EXAMPLE
	Get-HostWithFilter_WSAPI -WWN "123,ABC,000" 
	Get a host detail with multiple wwn name
.EXAMPLE
	Get-HostWithFilter_WSAPI -ISCSI 123 
	Get a host detail with single ISCSI name
.EXAMPLE
	Get-HostWithFilter_WSAPI -ISCSI "123,ABC,000" 
	Get a host detail with multiple ISCSI name
.EXAMPLE
	Get-HostWithFilter_WSAPI -WWN "xxx,xxx,xxx" -ISCSI "xxx,xxx,xxx" 
.PARAMETER WWN
	Specify WWN of the Host.
.PARAMETER ISCSI
	Specify ISCSI of the Host.
#>
[CmdletBinding()]
Param(	[String]	$WWN,
		[String]	$ISCSI
)
Begin 
{	Test-WSAPIConnection 	 
}
Process 
{	$Result = $null
	$dataPS = $null	
	$Query="?query=""  """	
	if($WWN)
	{	$Query = $Query.Insert($Query.Length-3," FCPaths[ ]")
		$count = 1
		$lista = $WWN.split(",")
		foreach($sub in $lista)
		{	$Query = $Query.Insert($Query.Length-4," wwn EQ $sub")			
			if($lista.Count -gt 1)
			{	if($lista.Count -ne $count)
				{	$Query = $Query.Insert($Query.Length-4," OR ")
					$count = $count + 1
				}				
			}
		}		
	}	
	if($ISCSI)
	{	$Link = $null
		if($WWN)
		{	$Query = $Query.Insert($Query.Length-2," OR iSCSIPaths[ ]")
			$Link = 3
		}
		else
		{	$Query = $Query.Insert($Query.Length-3," iSCSIPaths[ ]")
			$Link = 5
		}		
		$count = 1
		$lista = $ISCSI.split(",")
		foreach($sub in $lista)
		{	$Query = $Query.Insert($Query.Length-$Link," name EQ $sub")			
			if($lista.Count -gt 1)
			{	if($lista.Count -ne $count)
				{	$Query = $Query.Insert($Query.Length-$Link," OR ")
					$count = $count + 1
				}				
			}
		}		
	}
	if($ISCSI -Or $WWN)	{	$uri = '/hosts/'+$Query }
		else	{ 	Write-error "Command Failed, YOu must supply from [ISCSI | WWN]" 
					return
				}
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 
	If($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}
	If($Result.StatusCode -eq 200)
	{	if($dataPS.Count -gt 0)
		{	write-host "`n SUCCESS: Get-HostWithFilter_WSAPI successfully Executed. `n"
			return $dataPS
		}
		else
		{	write-Error "FAILURE : While Executing Get-HostWithFilter_WSAPI. Expected Result Not Found with Given Filter Option : ISCSI/$ISCSI WWN/$WWN."
			return 
		}		
	}
	else
	{	write-host "FAILURE : While Executing Get-HostWithFilter_WSAPI." -foreground red
		return $Result.StatusDescription
	}
}
}

Function Get-HostPersona_WSAPI 
{
<#
.SYNOPSIS
	Get Single or list of host persona,.
.DESCRIPTION  
	Get Single or list of host persona,.
.EXAMPLE
	Get-HostPersona_WSAPI
	Display a list of host persona.
.EXAMPLE
	Get-HostPersona_WSAPI -Id 10
	Display a host persona of given id.
.EXAMPLE
	Get-HostPersona_WSAPI -WsapiAssignedId 100
	Display a host persona of given Wsapi Assigned Id.
.EXAMPLE
	Get-HostPersona_WSAPI -Id 10
	Get the information of given host persona.
.EXAMPLE	
	Get-HostPersona_WSAPI -WsapiAssignedId "1,2,3"
	Multiple Host.
.PARAMETER Id
	Specify host persona id you want to query.
.PARAMETER WsapiAssignedId
	To filter by wsapi Assigned Id.
#>
[CmdletBinding(DefaultParameterSetName='default')]
Param(	[Parameter(ParameterSetName='ById')]			[int]		$Id,
		[Parameter(ParameterSetName='ByAssignedId')]	[String]	$WsapiAssignedId	
	)
Begin 
{	Test-WSAPIConnection 	 
}
Process 
{	$Result = $null
	$dataPS = $null		
	$Query="?query=""  """
	if($Id)	{	$uri = '/hostpersonas/'+$Id	}
	if($WsapiAssignedId)
	{	$count = 1
		$lista = $WsapiAssignedId.split(",")
		foreach($sub in $lista)
		{	$Query = $Query.Insert($Query.Length-3," wsapiAssignedId EQ $sub")			
			if($lista.Count -gt 1)
			{	if($lista.Count -ne $count)
				{	$Query = $Query.Insert($Query.Length-3," OR ")
					$count = $count + 1
				}				
			}
		}
		$uri = '/hostpersonas/'+$Query		
	}
	if ($PSCmdlet.ParameterSetName -eq 'default')
	{	$uri = '/hostpersonas'
	}	
	$Result = Invoke-WSAPI -uri $uri -type 'GET' 
	If($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members	
			write-host "`n SUCCESS: Get-HostPersona_WSAPI successfully Executed." -ForegroundColor Green
			return $dataPS
		}
		else
		{	write-error "`n FAILURE : While Executing Get-HostPersona_WSAPI.`n" 
			return $Result.StatusDescription
		}
}
}

Export-ModuleMember New-Host_WSAPI , Add-RemoveHostWWN_WSAPI , Update-Host_WSAPI , Remove-Host_WSAPI , Get-Host_WSAPI 
Export-ModuleMember Get-HostWithFilter_WSAPI , Get-HostPersona_WSAPI

