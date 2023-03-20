## 	© 2019,2020,2023 Hewlett Packard Enterprise Development LP
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
	Uses the default persona "GENERIC_ALUA" unless you specify the host persona.
	1	GENERIC
	2	GENERIC_ALUA
	3	GENERIC_LEGACY
	4	HPUX_LEGACY
	5	AIX_LEGACY
	6	EGENERA
	7	ONTAP_LEGACY
	8	VMWARE
	9	OPENVMS
	10	HPUX
	11	WindowsServer
	12	AIX_ALUA
.PARAMETER Port
	Specifies the desired relationship between the array ports and the host for target-driven zoning. Use this option when the Smart SAN license is installed only.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]	$HostName,
		[Parameter(ValueFromPipeline=$true)][String]					$Domain,
		[Parameter(ValueFromPipeline=$true)][String[]]					$FCWWN,
		[Parameter(ValueFromPipeline=$true)][Boolean]					$ForceTearDown,
		[Parameter(ValueFromPipeline=$true)][String[]]					$ISCSINames,
		[Parameter(ValueFromPipeline=$true)][String]					$Location,
		[Parameter(ValueFromPipeline=$true)][String]					$IPAddr,
		[Parameter(ValueFromPipeline=$true)][String]					$OS,
		[Parameter(ValueFromPipeline=$true)][String]					$Model,
		[Parameter(ValueFromPipeline=$true)][String]					$Contact,
		[Parameter(ValueFromPipeline=$true)][String]					$Comment,
		[Parameter(ValueFromPipeline=$true)]
		[ValidateSet=('GENERIC','GENERIC_ALUA','GENERIC_LEGACY','HPUX_LEGACY','AIX_LEGACY','EGENERA','ONTAP_LEGACY','VMWARE','OPENVMS','HPUX','WindowsServer','AIX_ALUA')]
											[String]					$Persona,
		[Parameter(ValueFromPipeline=$true)][String[]]					$Port
)
Begin 
{	Test-WSAPIConnection 
}
Process 
{	$body = @{}    
    $body["name"] = "$($HostName)"
    If ($Domain) 						{	$body["domain"] = "$($Domain)"	}
    If ($FCWWN) 						{	$body["FCWWNs"] = $FCWWN		} 
    If ($ForceTearDown) 				{	$body["forceTearDown"] = $ForceTearDown	}
	If ($ISCSINames) 					{	$body["iSCSINames"] = $ISCSINames	}
	if($Persona -eq "GENERIC")			{	$body["persona"] = 1 	}
	if($Persona -eq "GENERIC_ALUA")		{	$body["persona"] = 2 	}
	if($Persona -eq "GENERIC_LEGACY")	{	$body["persona"] = 3 	}
	if($Persona -eq "HPUX_LEGACY")		{	$body["persona"] = 4	}
	if($Persona -eq "AIX_LEGACY")		{	$body["persona"] = 5	}
	if($Persona -eq "EGENERA")			{	$body["persona"] = 6	}
	if($Persona -eq "ONTAP_LEGACY")		{	$body["persona"] = 7	}
	if($Persona -eq "VMWARE")			{	$body["persona"] = 8	}
	if($Persona -eq "OPENVMS")			{	$body["persona"] = 9	}
	if($Persona -eq "HPUX")				{	$body["persona"] = 10	}
	if($Persona -eq "WindowsServer")	{	$body["persona"] = 11	}
	if($Persona -eq "AIX_ALUA")			{	$body["persona"] = 12	}
	If ($Port) 							{	$body["port"] = $Por	}
	$DescriptorsBody = @{}   
	If ($Location)	{	$DescriptorsBody["location"] 	= "$($Location)" }
	If ($IPAddr)  	{	$DescriptorsBody["IPAddr"] 		= "$($IPAddr)"	}
	If ($OS) 		{	$DescriptorsBody["os"] 			= "$($OS)"	}
	If ($Model)     {	$DescriptorsBody["model"] 		= "$($Model)"}
	If ($Contact) 	{	$DescriptorsBody["contact"] 	= "$($Contact)" }
	If ($Comment) 	{	$DescriptorsBody["Comment"] 	= "$($Comment)"}
	if($DescriptorsBody.Count -gt 0){$body["descriptors"] = $DescriptorsBody }    
    $Result = $null
    $Result = Invoke-WSAPI -uri '/hosts' -type 'POST' -body $body -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "`n SUCCESS: Host:$HostName successfully created.`n" -foreground green
			Get-Host_WSAPI -HostName $HostName
		}
	else
		{	write-error "`nFAILURE : While creating Host:$HostName `n"
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
	Host Name which is required when attempting to add or remove a WWN from a Host, Not a usable field when using the TZONE options.
.PARAMETER FCWWNs
	Required for any of the four options (2 Add options, and 2 Remove options) and represents the WWNs of the host.
.PARAMETER Port
	Specifies the ports for target-driven zoning. Use this option when the Smart SAN license is installed only.
	This field is only valid when using the Add or Remove Target Zoning (TZONE) options
.PARAMETER AddWwnToHost
	Recommended method for adding WWN to host. Operates the same as using a PUT method with the pathOperation specified as ADD.
.PARAMETER RemoveWwnFromHost
	Recommended method for removing WWN from host. Operates the same as using the PUT method with the pathOperation specified as REMOVE.
.PARAMETER AddWwnToTZone   
	Adds WWN to target driven zone. Creates the target driven zone if it does not exist, and adds the WWN to the host if it does not exist.
.PARAMETER RemoveWwnFromTZone
	Removes WWN from the targetzone. Removes the target driven zone unless it is the last WWN. Does not remove the last WWN from the host.
#>
[CmdletBinding()]
Param(	[Parameter(ParameterSetName='AddWWNHost',    Mandatory=$true, ValueFromPipeline=$true)]	
		[Parameter(ParameterSetName='RemoveWWNHost', Mandatory=$true, ValueFromPipeline=$true)]	[String]	$HostName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]									[String[]]	$FCWWNs,
		[Parameter(ParameterSetName='AddWWNTZone',   Mandatory=$true, ValueFromPipeline=$true)]	
		[Parameter(ParameterSetName='RemoveWWNTZone',Mandatory=$true, ValueFromPipeline=$true)]	[String[]]	$Port,
		[Parameter(ParameterSetName='AddWWNHost',    Mandatory=$true, ValueFromPipeline=$true)]	[switch]	$AddWwnToHost,
		[Parameter(ParameterSetName='RemoveWWNHost', Mandatory=$true, ValueFromPipeline=$true)]	[switch]	$RemoveWwnFromHost,
		[Parameter(ParameterSetName='AddWWNTZone',   Mandatory=$true, ValueFromPipeline=$true)]	[switch]	$AddWwnToTZone,
		[Parameter(ParameterSetName='RemoveWWNTZone',Mandatory=$true, ValueFromPipeline=$true)]	[switch]	$RemoveWwnFromTZone
)
Begin 
{	Test-WSAPIConnection 
}
Process 
{	$body = @{}
    If($AddWwnToHost) 			{	$body["action"] = 1	}
	if($RemoveWwnFromHost)		{	$body["action"] = 2	}
	If($AddWwnToTZone) 			{	$body["action"] = 3	}
	if($RemoveWwnFromTZone)		{	$body["action"] = 4	}
	$ParametersBody = @{} 
    If($FCWWNs) 				{	$ParametersBody["FCWWNs"] = $FCWWNs	}
	If($Port) 					{	$ParametersBody["port"] = $Port		}
	if($ParametersBody.Count -gt 0){$body["parameters"] = $ParametersBody }
    $Result = $null
	$uri = '/hosts/'+$HostName
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "`n SUCCESS: Command Executed Successfully with Host : $HostName. `n" -foreground green
			return (Get-Host_WSAPI -HostName $HostName)
		}
	else
		{	write-host "`n FAILURE : Cmdlet Execution failed with Host : $HostName. `n"
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
	The ID of the persona to modify the host’s persona to. It can only be one of the following { GENERIC | GENERIC_ALUA | GENERIC_LEGACY | 
	HPUX_LEGACY | AIX_LEGACY | EGENERA | ONTAP_LEGACY | VMWARE | OPENVMS | HPUX | WindowsServer | AIX_ALUA }
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]	$HostName,
		[Parameter(ValueFromPipeline=$true)][String]					$ChapName,
		[Parameter(ValueFromPipeline=$true)][int]						$ChapOperationMode,
		[Parameter(ValueFromPipeline=$true)][Switch]					$ChapRemoveTargetOnly,
		[Parameter(ValueFromPipeline=$true)][String]					$ChapSecret,
		[Parameter(ValueFromPipeline=$true)][Switch]					$ChapSecretHex,
		[Parameter(ValueFromPipeline=$true)]
		[ValidateSet('INITIATOR','TARGET')][String]						$ChapOperation,
		[Parameter(ValueFromPipeline=$true)][String]					$Descriptors,
		[Parameter(ValueFromPipeline=$true)][String[]]					$FCWWN,
		[Parameter(ValueFromPipeline=$true)][Switch]					$ForcePathRemoval,
		[Parameter(ValueFromPipeline=$true)][String[]]					$iSCSINames,
		[Parameter(ValueFromPipeline=$true)][String]					$NewName,
		[Parameter(ValueFromPipeline=$true)]
		[ValidateSet('ADD','REMOVE')]		[String]					$PathOperation,
		[Parameter(ValueFromPipeline=$true)]
		[ValidateSet('GENERIC','GENERIC_ALUA','GENERIC_LEGACY','HPUX_LEGACY','AIX_LEGACY','EGENERA','ONTAP_LEGACY','VMWARE','OPENVMS','HPUX')]
											[String]					$Persona
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	Write-DebugLog "Running: Creation of the body hash" $Debug
    $body = @{}		
	If($ChapName) 					{	$body["chapName"] 				= "$($ChapName)"		}
	If($ChapOperationMode) 			{	$body["chapOperationMode"] 		= $ChapOperationMode	}
	If($ChapRemoveTargetOnly) 		{	$body["chapRemoveTargetOnly"] 	= $true					}
	If($ChapSecret) 				{	$body["chapSecret"] 			= "$($ChapSecret)"		}
	If($ChapSecretHex) 				{	$body["chapSecretHex"] 			= $true					}
	if($ChapOperation -eq "INITIATOR"){	$body["chapOperation"] 			= 1 					}
	if($ChapOperation -eq "TARGET")	{	$body["chapOperation"] 			= 2 					}
	If($Descriptors) 				{	$body["descriptors"] 			= "$($Descriptors)"		}
	If($FCWWN) 						{	$body["FCWWNs"] 				= $FCWWN				}
	If($ForcePathRemoval) 			{	$body["forcePathRemoval"] 		= $true					}
	If($iSCSINames) 				{	$body["iSCSINames"] 			= $iSCSINames			}
	If($NewName) 					{	$body["newName"] 				= "$($NewName)"			}
	if($PathOperation -eq "ADD")	{	$body["pathOperation"] 			= 1						}
	if($PathOperation -eq "REMOVE")	{	$body["pathOperation"] 			= 2						}
	if ($Persona -eq "GENERIC")	  	{	$body["persona"] = 1 }
	if($Persona -eq "GENERIC_ALUA") {	$body["persona"] = 2 }
	if($Persona -eq "GENERIC_LEGACY"){	$body["persona"] = 3 }
	if($Persona -eq "HPUX_LEGACY")  {	$body["persona"] = 4 }
	if($Persona -eq "AIX_LEGACY")   {	$body["persona"] = 5 }
	if($Persona -eq "EGENERA")      { 	$body["persona"] = 6 }
	if($Persona -eq "ONTAP_LEGACY") {	$body["persona"] = 7 }
	if($Persona -eq "VMWARE")       {	$body["persona"] = 8 }
	if($Persona -eq "OPENVMS")	  	{ 	$body["persona"] = 9 }
	if($Persona -eq "HPUX")		  	{	$body["persona"] = 10}
    $Result = $null
	Write-DebugLog "Request: Request to Update-Host_WSAPI(Invoke-WSAPI)." $Debug	
	$uri = '/hosts/'+$HostName
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "`n Cmdlet executed successfully. `n" -foreground green
			Write-DebugLog "SUCCESS: Successfully Update Host : $HostName." $Info
			if($NewName)	{	Get-Host_WSAPI -HostName $NewName	}
			else			{	Get-Host_WSAPI -HostName $HostName	}
			Write-DebugLog "End: Update-Host_WSAPI" $Debug
		}
	else
		{	write-Error "`n FAILURE : While Updating Host : $HostName.`n"
			Write-DebugLog "FAILURE : Updating Host : $HostName." $Info
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
Param(	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
		[String]$HostName
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{   $uri = '/hosts/'+$HostName
	$Result = $null
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE'
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "`n SUCCESS: Host:$HostName successfully remove.`n" -foreground green
			return ""
		}
	else
		{	write-Error "`n FAILURE : While Removing Host:$HostName `n"
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
Param(	[Parameter(ValueFromPipeline=$true)][String]	$HostName
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
			If($Result.StatusCode -eq 200)	{	$dataPS = $Result.content | ConvertFrom-Json	}	
		}	
	else
		{	$Result = Invoke-WSAPI -uri '/hosts' -type 'GET'
			If($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}		
		}
	If($Result.StatusCode -eq 200)
		{	write-host "`n SUCCESS: Get-Host_WSAPI successfully Executed.`n" -foreground green
			return $dataPS
		}
	else
		{	write-Error "`n FAILURE : While Executing Get-Host_WSAPI.`n "
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
	if( -not ($ISCSI -Or $WWN) )	{	write-error "Please select at list any one from [ISCSI | WWN]"	
										return
									}	
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
		{	$Link
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
	else				{	return "Please select at list any one from [ISCSI | WWN]"	}	
	$Result = Invoke-WSAPI -uri $uri -type 'GET'
	If($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}
	If($Result.StatusCode -eq 200)
		{	if($dataPS.Count -gt 0)
				{	write-host "`n SUCCESS: Get-HostWithFilter_WSAPI successfully Executed.`n" -foreground green
					return $dataPS
				}
			else
				{	write-Error "`n FAILURE : While Executing Get-HostWithFilter_WSAPI. Expected Result Not Found with Given Filter Option : ISCSI/$ISCSI WWN/$WWN. `n" 
					return 
				}		
		}
	else
		{	write-Error "`n FAILURE : While Executing Get-HostWithFilter_WSAPI. `n"
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
#>
[CmdletBinding(DefaultParameterSetName='Default')]
Param(	[Parameter(ParameterSetName='ById',ValueFromPipeline=$true)]	[int]		$Id,
		[Parameter(ParameterSetName='ByWid',ValueFromPipeline=$true)]	[string]	$WsapiAssignedId
	)
Begin 
{	Test-WSAPIConnection	 
}
Process 
{	$Result = $null
	$dataPS = $null		
	$Query="?query=""  """
	if($Id)
		{	$uri = '/hostpersonas/'+$Id
			$Errmsg = write-host "`n FAILURE : While Executing Get-HostPersona_WSAPI with Given filter Option : Id/$id. `n"
		}
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
			$Errmsg = "`n FAILURE : While Executing Get-HostPersona_WSAPI. Expected Result Not Found with Given Filter Option : WsapiAssignedId/$WsapiAssignedId."
		}
	if($PSCmdlet.ParameterSetName -eq 'Default')
		{	$uri = '/hostpersonas'
			$Errmsg = "`n FAILURE : While Executing Get-HostPersona_WSAPI."
		}
	$Result = Invoke-WSAPI -uri $uri -type 'GET'			
	If($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members	
			write-host "`n SUCCESS: Get-HostPersona_WSAPI successfully Executed.`n" -foreground green
			if($dataPS.Count -gt 0)	{	return $dataPS	}
			else					{	write-warning "`n While Executing Get-HostPersona_WSAPI. Command suceeded however zero items were returned."
										return 
									}
		}
	else
		{	write-Error $Errmsg
			return $Result.StatusDescription
		}
}
}

Export-ModuleMember New-Host_WSAPI , Add-RemoveHostWWN_WSAPI , Update-Host_WSAPI , Remove-Host_WSAPI , Get-Host_WSAPI , Get-HostWithFilter_WSAPI , Get-HostPersona_WSAPI
