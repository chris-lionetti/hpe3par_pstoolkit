## 	© 2019,2020,2023 Hewlett Packard Enterprise Development LP
##		

Function Get-FileServices_WSAPI 
{
<#
.SYNOPSIS
	Get the File Services information.
.DESCRIPTION
	Get the File Services information.
.PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
.EXAMPLE
    Get-FileServices_WSAPI
	display File Services Information
#>
[CmdletBinding()]
Param()
Begin
{	Test-WSAPIConnection 
}
Process
{	$Result = Invoke-WSAPI -uri '/fileservices' -type 'GET' -WsapiConnection $WsapiConnection
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json)
			write-host "`n SUCCESS: Get-FileServices_WSAPI successfully Executed. `n" -foreground green
			return $dataPS
		}
	else
		{	write-Error "`n FAILURE : While Executing Get-FileServices_WSAPI.`n" 
			return $Result.StatusDescription
		}  
}
}

Function New-FPG_WSAPI 
{
<#
.SYNOPSIS
	Creates a new File Provisioning Group(FPG).
.DESCRIPTION
	Creates a new File Provisioning Group(FPG).
.EXAMPLE
	New-FPG_WSAPI -PFGName "MyFPG" -CPGName "MyCPG"	-SizeTiB 12
	Creates a new File Provisioning Group(FPG), size must be in Terabytes
.EXAMPLE	
	New-FPG_WSAPI -FPGName asFPG -CPGName cpg_test -SizeTiB 1 -FPVV $true
.EXAMPLE	
	New-FPG_WSAPI -FPGName asFPG -CPGName cpg_test -SizeTiB 1 -TDVV $true
.EXAMPLE	
	New-FPG_WSAPI -FPGName asFPG -CPGName cpg_test -SizeTiB 1 -NodeId 1
.PARAMETER FPGName
	Name of the FPG, maximum 22 chars.
.PARAMETER CPGName
	Name of the CPG on which to create the FPG.
.PARAMETER SizeTiB
	Size of the FPG in terabytes.
.PARAMETER FPVV
	Enables (true) or disables (false) FPG volume creation with the FPVV volume. Defaults to false, creating the FPG with the TPVV volume.
.PARAMETER TDVV
	Enables (true) or disables (false) FPG volume creation with the TDVV volume. Defaults to false, creating the FPG with the TPVV volume.
.PARAMETER NodeId
	Bind the created FPG to the specified node.
.PARAMETER Comment
	Specifies any additional information up to 511 characters for the FPG.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)][String]		$FPGName,	  
		[Parameter(ValueFromPipeline=$true)][String]		$CPGName,	
		[Parameter(ValueFromPipeline=$true)][int]			$SizeTiB, 
		[Parameter(ValueFromPipeline=$true)][Boolean]		$FPVV,
		[Parameter(ValueFromPipeline=$true)][Boolean]		$TDVV,
		[Parameter(ValueFromPipeline=$true)][int]			$NodeId,
		[Parameter(ValueFromPipeline=$true)][String]		$Comment
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body 			= @{}    
    $body["name"] 	= "$($FPGName)"
	$body["cpg"] 	= "$($CPGName)"
	$body["sizeTiB"]= $SizeTiB
    If ($FPVV) 	{	$body["fpvv"] = $FPVV	}  
	If ($TDVV) 	{	$body["tdvv"] = $TDVV	} 
	If ($NodeId) {	$body["nodeId"] = $NodeId	}
	If ($Comment){	$body["comment"] = "$($Comment)"}
    $Result = $null
    $Result = Invoke-WSAPI -uri '/fpgs' -type 'POST' -body $body -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode	
	if($status -eq 202)
		{	write-host "`n SUCCESS: File Provisioning Groups:$FPGName created successfully. `n" -foreground green
			Get-FPG_WSAPI -FPG $FPGName
	}
	else
		{	write-host "`n FAILURE : While creating File Provisioning Groups:$FPGName `n"
			return $Result.StatusDescription
		}	
}
}

Function Remove-FPG_WSAPI
{
<#
.SYNOPSIS
	Remove a File Provisioning Group.
.DESCRIPTION
	Remove a File Provisioning Group.
.EXAMPLE    
	Remove-FPG_WSAPI -FPGId 123 
.PARAMETER FPGId 
	Specify the File Provisioning Group uuid to be removed.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Specify the File Provisioning Group uuid to be removed.')]
		[String]$FPGId
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{   $uri = '/fpgs/'+$FPGId
	$Result = $null
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE' -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode
	if($status -eq 202)
		{	write-host "`n SUCCESS: File Provisioning Group:$FPGId successfully remove. `n" -foreground green
			return 
		}
	else
		{	write-error "`n FAILURE : While Removing File Provisioning Group : $FPGId `n"
			return $Result.StatusDescription
		}    	
}
}

Function Get-FPG_WSAPI 
{
<#
.SYNOPSIS
	Get Single or list of File Provisioning Group.
.DESCRIPTION
	Get Single or list of File Provisioning Group.
.EXAMPLE
	Get-FPG_WSAPI
	Display a list of File Provisioning Group.
.EXAMPLE
	Get-FPG_WSAPI -FPG MyFPG
	Display a Given File Provisioning Group.
.EXAMPLE
	Get-FPG_WSAPI -FPG "MyFPG,MyFPG1,MyFPG2,MyFPG3"
	Display Multiple File Provisioning Group.
.PARAMETER FPG
	Name of File Provisioning Group.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)]
		[String]	$FPG
	)
Begin 
{	Test-WSAPIConnection	 
}
Process 
{	$Result = $null
	$dataPS = $null		
	$Query="?query=""  """
	if($FPG)
		{	$count = 1
			$lista = $FPG.split(",")
			if($lista.Count -gt 1)
				{	foreach($sub in $lista)
						{	$Query = $Query.Insert($Query.Length-3," name EQ $sub")			
							if($lista.Count -gt 1)
								{	if($lista.Count -ne $count)
										{	$Query = $Query.Insert($Query.Length-3," OR ")
											$count = $count + 1
										}				
								}
						}
					$uri = '/fpgs/'+$Query
					$Result = Invoke-WSAPI -uri $uri -type 'GET'	
					If($Result.StatusCode -eq 200)
						{	$dataPS = ($Result.content | ConvertFrom-Json).members				
						}
				}
			else
				{	$uri = '/fpgs/'+$FPG
					$Result = Invoke-WSAPI -uri $uri -type 'GET'	
					If($Result.StatusCode -eq 200)
						{	$dataPS = $Result.content | ConvertFrom-Json				
						}		
				}
		}
	else
		{	$Result = Invoke-WSAPI -uri '/fpgs' -type 'GET' 
			If($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members			
				}		
		}
	If($Result.StatusCode -eq 200)
		{	if($dataPS.Count -gt 0)
				{	write-host "`n SUCCESS: Get-FPG_WSAPI successfully Executed.`n " -foreground green
					return $dataPS
				}
			else
				{	write-error "`n FAILURE : While Executing Get-FPG_WSAPI. Expected Result Not Found with Given Filter Option .`n"
					return 
				}
		}
	else
		{	write-error "`n FAILURE : While Executing Get-FPG_WSAPI.`n "
			return $Result.StatusDescription
		}
}
}

Function Get-FPGReclamationTasks_WSAPI 
{
<#
.SYNOPSIS
	Get the reclamation tasks for the FPG.
.DESCRIPTION
	Get the reclamation tasks for the FPG.
.EXAMPLE
    Get-FPGReclamationTasks_WSAPI
	Get the reclamation tasks for the FPG.
#>
[CmdletBinding()]
Param()
Begin
{	Test-WSAPIConnection
}
Process
{	$Result = Invoke-WSAPI -uri '/fpgs/reclaimtasks' -type 'GET'
	if($Result.StatusCode -eq 200)
		{	$dataPS = ($Result.content | ConvertFrom-Json).members
			if($dataPS.Count -gt 0)
				{	write-host "`n SUCCESS: Get-FPGReclamationTasks_WSAPI successfully Executed. `n" -foreground green
					return $dataPS
				}
			else
				{	write-error "`n FAILURE : While Executing Get-FPGReclamationTasks_WSAPI. `n" 
					return 
				}
		}
	else
		{	write-error "`n FAILURE : While Executing Get-FPGReclamationTasks_WSAPI.`n "
			return $Result.StatusDescription
		}  
}
}

Function New-VFS_WSAPI 
{
<#      
.SYNOPSIS	
	Create Virtual File Servers.
.DESCRIPTION	
    Create Virtual File Servers.
.EXAMPLE	
	New-VFS_WSAPI
.PARAMETER VFSName
	Name of the VFS to be created.
.PARAMETER PolicyId
	Policy ID associated with the network configuration.
.PARAMETER FPG_IPInfo
	FPG to which VFS belongs.
.PARAMETER VFS
	VFS where the network is configured.
.PARAMETER IPAddr
	IP address.
.PARAMETER Netmask
	Subnet mask.
.PARAMETER NetworkName
	Network configuration name.
.PARAMETER VlanTag
	VFS network configuration VLAN ID.
.PARAMETER CPG
	CPG in which to create the FPG.
.PARAMETER FPG
	Name of an existing FPG in which to create the VFS.
.PARAMETER SizeTiB
	Specifies the size of the FPG you want to create. Required when using the cpg option.
.PARAMETER TDVV
	Enables (true) or disables false creation of the FPG with tdvv volumes. Defaults to false which creates the FPG with the default volume type (tpvv).
.PARAMETER FPVV
	Enables (true) or disables false creation of the FPG with fpvv volumes. Defaults to false which creates the FPG with the default volume type (tpvv).
.PARAMETER NodeId
	Node ID to which to assign the FPG. Always use with cpg member.
.PARAMETER Comment
	Specifies any additional comments while creating the VFS.
.PARAMETER BlockGraceTimeSec
	Block grace time in seconds for quotas within the VFS.
.PARAMETER InodeGraceTimeSec
	The inode grace time in seconds for quotas within the VFS.
.PARAMETER NoCertificate
	true – Does not create a selfsigned certificate associated with the VFS. false – (default) Creates a selfsigned certificate associated with the VFS.
.PARAMETER SnapshotQuotaEnabled
	Enables (true) or disables (false) the quota accounting flag for snapshots at VFS level.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]	$VFSName,
		[Parameter(ValueFromPipeline=$true)][String]		$PolicyId,
		[Parameter(ValueFromPipeline=$true)][String]		$FPG_IPInfo,
		[Parameter(ValueFromPipeline=$true)][String]		$VFS,
		[Parameter(ValueFromPipeline=$true)][String]		$IPAddr,
		[Parameter(ValueFromPipeline=$true)][String]		$Netmask,
		[Parameter(ValueFromPipeline=$true)][String]		$NetworkName,
		[Parameter(ValueFromPipeline=$true)][int]			$VlanTag,
		[Parameter(ValueFromPipeline=$true)][String]		$CPG,
		[Parameter(ValueFromPipeline=$true)][String]		$FPG,
		[Parameter(ValueFromPipeline=$true)][int]			$SizeTiB,
		[Parameter(ValueFromPipeline=$true)][Switch]		$TDVV,
		[Parameter(ValueFromPipeline=$true)][Switch]		$FPVV,
		[Parameter(ValueFromPipeline=$true)][int]			$NodeId, 
		[Parameter(ValueFromPipeline=$true)][String]		$Comment,
		[Parameter(ValueFromPipeline=$true)][int]			$BlockGraceTimeSec,
		[Parameter(ValueFromPipeline=$true)][int]			$InodeGraceTimeSec,
		[Parameter(ValueFromPipeline=$true)][Switch]		$NoCertificate,
		[Parameter(ValueFromPipeline=$true)][Switch]		$SnapshotQuotaEnabled
	)
Begin 
{	Test-WSAPIConnection 
}
Process 
{	$body = @{}
	$IPInfoBody=@{}
	If($VFSName) 		{	$body["name"] 			= "$($VFSName)"		}
	If($PolicyId) 		{	$IPInfoBody["policyId"] = "$($PolicyId)"	}
	If($FPG_IPInfo) 	{	$IPInfoBody["fpg"] 		= "$($FPG_IPInfo)"	}
	If($VFS) 			{	$IPInfoBody["vfs"] 		= "$($VFS)"			}
	If($IPAddr) 		{	$IPInfoBody["IPAddr"] 	= "$($IPAddr)"		}
	If($Netmask) 		{	$IPInfoBody["netmask"] 	= $Netmask			}
	If($NetworkName)	{	$IPInfoBody["networkName"] = "$($NetworkName)"}
	If($VlanTag) 		{	$IPInfoBody["vlanTag"] 	= $VlanTag			}
	If($CPG) 			{	$body["cpg"] 			= "$($CPG)" 		}
	If($FPG) 			{	$body["fpg"] 			= "$($FPG)" 		}
	If($SizeTiB) 		{	$body["sizeTiB"] 		= $SizeTiB			}
	If($TDVV) 			{	$body["tdvv"] 			= $true				}
	If($FPVV) 			{	$body["fpvv"] 			= $true				}
	If($NodeId) 		{	$body["nodeId"] 		= $NodeId			}
	If($Comment) 		{	$body["comment"] 		= "$($Comment)"		}
	If($BlockGraceTimeSec){	$body["blockGraceTimeSec"] = $BlockGraceTimeSec}
	If($InodeGraceTimeSec){	$body["inodeGraceTimeSec"] = $InodeGraceTimeSec}
	If($NoCertificate) 	{	$body["noCertificate"] 	= $true				}
	If($SnapshotQuotaEnabled){$body["snapshotQuotaEnabled"] = $true		}
	if($IPInfoBody.Count -gt 0){$body["IPInfo"] 	= $IPInfoBody		}
    $Result = $null		
    $Result = Invoke-WSAPI -uri '/virtualfileservers/' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 202)
		{	write-host "`n SUCCESS: Successfully Created Virtual File Servers VFS Name : $VFSName. `n" -foreground green
			return $Result
		}
	else
		{	write-host "`n FAILURE : While Creating Virtual File Servers VFS Name : $VFSName." `n 
			return $Result.StatusDescription
		}
}
}

Function Remove-VFS_WSAPI 
{
<#      
.SYNOPSIS	
	Removing a Virtual File Servers.
.DESCRIPTION	
    Removing a Virtual File Servers.
.EXAMPLE	
	Remove-VFS_WSAPI -VFSID 1
.PARAMETER VFSID
	Virtual File Servers id.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[int]	$VFSID
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null
	$uri = "/virtualfileservers/"+$VFSID
    $Result = Invoke-WSAPI -uri $uri -type 'DELETE' -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "`n SUCCESS: Virtual File Servers : $VFSID successfully Removed. `n" -foreground green
			return $Result
		}
	else
		{	write-host "`n FAILURE : While Dismissing a Virtual File Servers : $VFSID `n"
			return $Result.StatusDescription
		}
}
}

Function Get-VFS_WSAPI 
{
<#
.SYNOPSIS	
	Get all or single Virtual File Servers
.DESCRIPTION
	Get all or single Virtual File Servers
.EXAMPLE
	Get-VFS_WSAPI
	Get List Virtual File Servers
.EXAMPLE
	Get-VFS_WSAPI -VFSID xxx
	Get Single Virtual File Servers
.PARAMETER VFSID	
    Virtual File Servers id.
.PARAMETER VFSName	
    Virtual File Servers Name.
.PARAMETER FPGName	
    File Provisioning Groups Name.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)][int]			$VFSID,
		[Parameter(ValueFromPipeline=$true)][String]		$VFSName,
		[Parameter(ValueFromPipeline=$true)][String]		$FPGName
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null
	$dataPS = $null	
	$flg = "Yes"	
	$Query="?query=""  """
	if($VFSID)
		{	if($VFSName -Or $FPGName)
				{	write-error "we cannot use VFSName and FPGName with VFSID as VFSName and FPGName is use for filtering."
					Return 
				}
			$uri = '/virtualfileservers/'+$VFSID
			$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
			if($Result.StatusCode -eq 200)
				{	$dataPS = $Result.content | ConvertFrom-Json
				}
		}	
	elseif($VFSName)
		{	$Query = $Query.Insert($Query.Length-3," name EQ $VFSName")			
			if($FPGName)
				{	$Query = $Query.Insert($Query.Length-3," AND fpg EQ $FPGName")
					$flg = "No"
				}
			$uri = '/virtualfileservers/'+$Query
			$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}
		}
	elseif($FPGName)
		{	if($flg -eq "Yes")
				{	$Query = $Query.Insert($Query.Length-3," fpg EQ $FPGName")
				}
			$uri = '/virtualfileservers/'+$Query
			$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}		
		}
	else
		{	$Result = Invoke-WSAPI -uri '/virtualfileservers' -type 'GET' -WsapiConnection $WsapiConnection
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}		
		}	
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -eq 0)
				{	return "No data Fount."
				}
			write-host "`n SUCCESS: Command Get-VFS_WSAPI Successfully Executed. `n" -foreground green
			return $dataPS		
		}
	else
		{	write-host "`n FAILURE : While Executing Get-VFS_WSAPI.`n "
			return $Result.StatusDescription
		}
}	
}

Function New-FileStore_WSAPI 
{
<#      
.SYNOPSIS	
	Create File Store.
.DESCRIPTION	
    Create Create File Store.
.EXAMPLE	
	New-FileStore_WSAPI
.PARAMETER FSName
	Name of the File Store you want to create (max 255 characters).
.PARAMETER VFS
	Name of the VFS under which to create the File Store. If it does not exist, the system creates it.
.PARAMETER FPG
	Name of the FPG in which to create the File Store.
.PARAMETER SecurityMode
	File Store security mode is NTFS or legacy.
.PARAMETER SupressSecOpErr 
	Enables or disables the security operations error suppression for File Stores in NTFS security mode. Defaults to false. Cannot be used in LEGACY security mode.
.PARAMETER Comment
	Specifies any additional information about the File Store.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]					[String]	$FSName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]					[String]	$VFS,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]					[String]	$FPG,
		[Parameter(ValueFromPipeline=$true)][ValidateSet('NTFS','Legacy')]		[string]	$SecurityMode,
		[Parameter(ValueFromPipeline=$true)]									[Switch]	$SupressSecOpErr,
		[Parameter(ValueFromPipeline=$true)]									[String]	$Comment
	)
Begin 
{	Test-WSAPIConnection 
}
Process 
{	$body = @{}	
	If($FSName) 					{	$body["name"] 			= "$($FSName)"	}
	If($VFS) 						{	$body["vfs"] 			= "$($VFS)"		}
	If($FPG) 						{	$body["fpg"] 			= "$($FPG)" 	}
	If($SecurityMode -eq 'Legacy') 	{	$body["securityMode"] 	= 1				}
	If($SecurityMode -eq 'NTFS')	{	$body["securityMode"] 	= 2				}
	If($SupressSecOpErr)			{	$body["supressSecOpErr"]= $true 		}
	If($Comment) 					{	$body["comment"] 		= "$($Comment)"	}
    $Result = $null		
    $Result = Invoke-WSAPI -uri '/filestores/' -type 'POST' -body $body
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "`n SUCCESS: Successfully Created File Store, Name: $FSName." -foreground green
			return $Result
		}
	else
		{	write-error "`n FAILURE : While Creating File Store, Name: $FSName. `n "
			return $Result.StatusDescription
		}
}
}

Function Update-FileStore_WSAPI 
{
<#      
.SYNOPSIS	
	Update File Store.
.DESCRIPTION	
    Updating File Store.
.EXAMPLE	
	Update-FileStore_WSAPI
.PARAMETER FStoreID
	File Stores ID.
.PARAMETER SecurityMode
	File Store security mode is set to either NTFS or LEGACY.
.PARAMETER SupressSecOpErr 
	Enables or disables the security operations error suppression for File Stores in NTFS security mode. Defaults to false. Cannot be used in LEGACY security mode.
.PARAMETER Comment
	Specifies any additional information about the File Store.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]		$FStoreID,
		[Parameter(ValueFromPipeline=$true)][String]						$Comment,
		[Parameter(ValueFromPipeline=$true)][ValidateSet('NTFS','LEGACY')]	$SecurityMode,
		[Parameter(ValueFromPipeline=$true)][Switch]						$SupressSecOpErr
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}		
	If($Comment) 	{	$body["comment"] = "$($Comment)"	}
	If($SecurityMode -eq 'NTFS')	{	$body["securityMode"] = 2	}
	If($SecurityMode -eq 'LEGACY')	{	$body["securityMode"] = 1	}
	If($SupressSecOpErr) 
		{	$body["supressSecOpErr"] = $true 
		}	
    $Result = $null
	$uri = '/filestores/'+$FStoreID
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "`n SUCCESS: Successfully Updated File Store, File Store ID: $FStoreID.`n" -foreground green
			return $Result
		}
	else
		{	write-host "`nFAILURE : While Updating File Store, File Store ID: $FStoreID.`n" 
			return $Result.StatusDescription
		}
}
End 
{ 
}
}

Function Remove-FileStore_WSAPI 
{
<#      
.SYNOPSIS	
	Remove File Store.
.DESCRIPTION	
    Remove File Store.
.EXAMPLE	
	Remove-FileStore_WSAPI
.PARAMETER FStoreID
	File Stores ID.
#>
[CmdletBinding()]
Param(	[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)][String]$FStoreID
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$uri = '/filestores/'+$FStoreID
    $Result = Invoke-WSAPI -uri $uri -type 'DELETE'
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "`n SUCCESS: Successfully Removed File Store, File Store ID: $FStoreID.`n" -foreground green
			return $Result
		}
	else
		{	write-host "`nFAILURE : While Removing File Store, File Store ID: $FStoreID.`n" 
			return $Result.StatusDescription
	}
}
End 
{
}
}

Function Get-FileStore_WSAPI 
{
<#
.SYNOPSIS	
	Get all or single File Stores.
.DESCRIPTION
	Get all or single File Stores.
.EXAMPLE
	Get-FileStore_WSAPI
	Get List of File Stores.
.EXAMPLE
	Get-FileStore_WSAPI -FStoreID xxx
	Get Single File Stores.
.PARAMETER FStoreID
	File Stores ID.
.PARAMETER FileStoreName
	File Store Name.
.PARAMETER VFSName
	Virtual File Servers Name.
.PARAMETER FPGName
    File Provisioning Groups Name.	
#>
[CmdletBinding(DefaultParameterSetName='Default')]
Param(	[Parameter(ParameterSetName='FStore',ValueFromPipeline=$true)][int]		$FStoreID,
		[Parameter(ParameterSetName='Filter',ValueFromPipeline=$true)][String]	$FileStoreName,	  
		[Parameter(ParameterSetName='Filter',ValueFromPipeline=$true)][String]	$VFSName,
		[Parameter(ParameterSetName='Filter',ValueFromPipeline=$true)][String]	$FPGName
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null
	$dataPS = $null	
	$flgVFS = "Yes"
	$flgFPG = "Yes"
	$Query="?query=""  """
	if($FStoreID)
		{	$uri = '/filestores/'+$FStoreID
			$Result = Invoke-WSAPI -uri $uri -type 'GET'
			if($Result.StatusCode -eq 200)
				{	$dataPS = $Result.content | ConvertFrom-Json
				}
		}
	if($FileStoreName)
		{	$Query = $Query.Insert($Query.Length-3," name EQ $FileStoreName")			
			if($VFSName)
				{	$Query = $Query.Insert($Query.Length-3," AND vfs EQ $VFSName")
					$flgVFS = "No"
				}
			if($FPGName)
				{	$Query = $Query.Insert($Query.Length-3," AND fpg EQ $FPGName")
					$flgFPG = "No"
				}
			$uri = '/filestores/'+$Query
			$Result = Invoke-WSAPI -uri $uri -type 'GET'
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}
		}	
	elseif($VFSName)
		{	if($flgVFS -eq "Yes")
				{	$Query = $Query.Insert($Query.Length-3," vfs EQ $VFSName")
				}
			if($FPGName)
				{	if($flgFPG -eq "Yes")
						{	$Query = $Query.Insert($Query.Length-3," AND fpg EQ $FPGName")
							$flgFPG = "No"
						}
				}
			$uri = '/filestores/'+$Query
			$Result = Invoke-WSAPI -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}
		}
	elseif($FPGName)
		{	if($flgFPG -eq "Yes")
				{	$Query = $Query.Insert($Query.Length-3," fpg EQ $FPGName")
					$flgFPG = "No"
				}
			$uri = '/filestores/'+$Query
			$Result = Invoke-WSAPI -uri $uri -type 'GET'
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}		
		}
	else
		{	$Result = Invoke-WSAPI -uri '/filestores' -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}	
		}	
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -eq 0)
				{	Write-Warning "No data Found."
					Return
				}
			write-host "`n SUCCESS: Command Get-FileStore_WSAPI Successfully Executed.`n" -foreground green
			return $dataPS		
		}
	else
		{	write-Error "`nFAILURE : While Executing Get-FileStore_WSAPI." 
			return $Result.StatusDescription
		}
}	
}

Function New-FileStoreSnapshot_WSAPI 
{
<#      
.SYNOPSIS	
	Create File Store snapshot.
.DESCRIPTION	
    Create Create File Store snapshot.
.EXAMPLE	
	New-FileStoreSnapshot_WSAPI
.PARAMETER TAG
	The suffix appended to the timestamp of a snapshot creation to form the snapshot name (<timestamp>_< tag>), using ISO8601 date and time format. Truncates tags in excess of 255 characters.
.PARAMETER FStore
	The name of the File Store for which you are creating a snapshot.
.PARAMETER VFS
	The name of the VFS to which the File Store belongs.
.PARAMETER RetainCount
	In the range of 1 to 1024, specifies the number of snapshots to retain for the File Store.
	Snapshots in excess of the count are deleted beginning with the oldest snapshot.
	If the tag for the specified retainCount exceeds the count value, the oldest snapshot is deleted before the new snapshot is created. 
	If the creation of the new snapshot fails, the deleted snapshot will not be restored.
.PARAMETER FPG
	The name of the FPG to which the VFS belongs.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]	$TAG,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]	$FStore,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]	$VFS,
		[Parameter(ValueFromPipeline=$true)][int]						$RetainCount,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]	$FPG	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	If($TAG) 		{	$body["tag"] 			= "$($TAG)"		}
	If($FStore) 	{	$body["fstore"] 		= "$($FStore)"	}
	If($VFS) 		{	$body["vfs"] 			= "$($VFS)"		}
	If($RetainCount){	$body["retainCount"] 	= $RetainCount	}
	If($FPG) 		{	$body["fpg"] 			= "$($FPG)" 	}
    $Result = $null		
	$Result = Invoke-WSAPI -uri '/filestoresnapshots/' -type 'POST' -body $body
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "`n SUCCESS: Successfully Created File Store snapshot. `n" -foreground green
			return $Result
		}
	else
		{	write-error "`n FAILURE : While Creating File Store snapshot.`n "
			return $Result.StatusDescription
		}
}
}

Function Remove-FileStoreSnapshot_WSAPI 
{
<#      
.SYNOPSIS	
	Remove File Store snapshot.
.DESCRIPTION	
    Remove File Store snapshot.
.EXAMPLE	
	Remove-FileStoreSnapshot_WSAPI
.PARAMETER ID
	File Store snapshot ID.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]	$ID	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$uri = '/filestoresnapshots/'+$ID
    $Result = Invoke-WSAPI -uri $uri -type 'DELETE'	
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "`n SUCCESS: Successfully Removed File Store snapshot, File Store snapshot ID: $ID.`n" -foreground green
			return $Result
		}
	else
		{	write-error "`nFAILURE : While Removing File Store snapshot, File Store snapshot ID: $ID.`n"
			return $Result.StatusDescription
		}
}
}

Function Get-FileStoreSnapshot_WSAPI 
{
<#
.SYNOPSIS	
	Get all or single File Stores snapshot.
.DESCRIPTION
	Get all or single File Stores snapshot.
.EXAMPLE
	Get-FileStoreSnapshot_WSAPI
	Get List of File Stores snapshot.
.EXAMPLE
	Get-FileStoreSnapshot_WSAPI -ID xxx
	Get Single File Stores snapshot.	
.PARAMETER ID	
    File Store snapshot ID.
.PARAMETER FileStoreSnapshotName
	File Store snapshot name — exact match and pattern match.
.PARAMETER FileStoreName
	File Store name.
.PARAMETER VFSName
	The name of the VFS to which the File Store snapshot belongs.
.PARAMETER FPGName
	The name of the FPG to which the VFS belongs.
#>
[CmdletBinding(DefaultParameterSetName='Default')]
Param(	[Parameter(ParameterSetName='ById')]	[String]	$ID,
		[Parameter(ParameterSetName='ByFilter')][String]	$FileStoreSnapshotName,
		[Parameter(ParameterSetName='ByFilter')][String]	$FileStoreName,	  
		[Parameter(ParameterSetName='ByFilter')][String]	$VFSName,
		[Parameter(ParameterSetName='ByFilter')][String]	$FPGName	
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null
	$dataPS = $null
	$flgFSN = "Yes"	
	$flgVFS = "Yes"
	$flgFPG = "Yes"
	$Query  = "?query=""  """
	if($ID)
		{	$uri = '/filestoresnapshots/'+$ID
			$Result = Invoke-WSAPI -uri $uri -type 'GET'
			if($Result.StatusCode -eq 200)
				{	$dataPS = $Result.content | ConvertFrom-Json
				}
		}
	if($FileStoreSnapshotName)
		{	$Query = $Query.Insert($Query.Length-3," name EQ $FileStoreSnapshotName")			
			if($FileStoreName)
				{	$Query = $Query.Insert($Query.Length-3," AND fstore EQ $FileStoreName")
					$flgFSN = "No"
				}
			if($VFSName)
				{	$Query = $Query.Insert($Query.Length-3," AND vfs EQ $VFSName")
					$flgVFS = "No"
				}
			if($FPGName)
				{	$Query = $Query.Insert($Query.Length-3," AND fpg EQ $FPGName")
					$flgFPG = "No"
				}
			$uri = '/filestoresnapshots/'+$Query
			$Result = Invoke-WSAPI -uri $uri -type 'GET'
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}
		}	
	elseif($FileStoreName)
		{	if($flgFSN -eq "Yes")
				{	$Query = $Query.Insert($Query.Length-3," fstore EQ $FileStoreName")	
				}		
			if($VFSName)
				{	if($flgVFS -eq "Yes")
						{	$Query = $Query.Insert($Query.Length-3," AND vfs EQ $VFSName")
							$flgVFS = "No"
						}
				}
			if($FPGName)
				{	if($flgFPG -eq "Yes")
						{	$Query = $Query.Insert($Query.Length-3," AND fpg EQ $FPGName")
							$flgFPG = "No"
						}
				}
			$uri = '/filestoresnapshots/'+$Query
			$Result = Invoke-WSAPI -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}
		}	
	elseif($VFSName)
		{	if($flgVFS -eq "Yes")
				{	$Query = $Query.Insert($Query.Length-3," vfs EQ $VFSName")
				}
			if($FPGName)
				{	if($flgFPG -eq "Yes")
						{	$Query = $Query.Insert($Query.Length-3," AND fpg EQ $FPGName")
							$flgFPG = "No"
						}
				}
			$uri = '/filestoresnapshots/'+$Query
			$Result = Invoke-WSAPI -uri $uri -type 'GET'
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}
		}
	elseif($FPGName)
		{	if($flgFPG -eq "Yes")
				{	$Query = $Query.Insert($Query.Length-3," fpg EQ $FPGName")
					$flgFPG = "No"
				}
			$uri = '/filestoresnapshots/'+$Query
			$Result = Invoke-WSAPI -uri $uri -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}		
		}	
	else
		{	$Result = Invoke-WSAPI -uri '/filestoresnapshots' -type 'GET' 
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}	
		}		
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -eq 0)
				{	write-warning "No data Fount." 
					return 
				}
			write-host "`n SUCCESS: Command Get-FileStoreSnapshot_WSAPI Successfully Executed.`n" -foreground green
			return $dataPS		
		}
	else
		{	write-error "`n FAILURE : While Executing Get-FileStoreSnapshot_WSAPI.`n"
			return $Result.StatusDescription
		}
}	
}

Function New-FileShare_WSAPI 
{
<#      
.SYNOPSIS	
	Create File Share.
.DESCRIPTION	
    Create Create File Share.
.EXAMPLE	
	New-FileShare_WSAPI
.PARAMETER FSName	
	Name of the File Share you want to create.
.PARAMETER Protocol
	May be set to either NFS or SMB
.PARAMETER VFS
	Name of the VFS under which to create the File Share. If it does not exist, the system creates it.
.PARAMETER ShareDirectory
	Directory path to the File Share. Requires fstore.
.PARAMETER FStore
	Name of the File Store in which to create the File Share.
.PARAMETER FPG
	Name of FPG in which to create the File Share.
.PARAMETER Comment
	Specifies any additional information about the File Share.
.PARAMETER Enables_SSL
	Enables (true) SSL. Valid for OBJ and FTP File Share types only.
.PARAMETER Disables_SSL
	Disables (false) SSL. Valid for OBJ and FTP File Share types only.
.PARAMETER ObjurlPath
	URL that clients will use to access the share. Valid for OBJ File Share type only.
.PARAMETER NFSOptions
	Valid for NFS File Share type only. Specifies options to use when creating the share. Supports standard NFS export options except no_subtree_check.
	With no options specified, automatically sets the default options.
.PARAMETER NFSClientlist
	Valid for NFS File Share type only. Specifies the clients that can access the share.
	Specify the NFS client using any of the following:
	• Full name (sys1.hpe.com)
	• Name with a wildcard (*.hpe.com)
	• IP address (usea comma to separate IPaddresses)
	With no list specified, defaults to match everything.
.PARAMETER SmbABE
	Valid for SMB File Share only.
	Enables (true) or disables (false) Access Based Enumeration (ABE). ABE specifies that users can see only the files and directories to which they have been allowed access on the shares. 
	Defaults to false.
.PARAMETER SmbAllowedIPs
	List of client IP addresses that are allowed access to the share. Valid for SMB File Share type only.
.PARAMETER SmbDeniedIPs
	List of client IP addresses that are not allowed access to the share. Valid for SMB File Share type only.
.PARAMETER SmbContinuosAvailability
	Enables (true) or disables (false) SMB3 continuous availability features for the share. Defaults to true. Valid for SMB File Share type only. 
.PARAMETER SmbCache
	Specifies clientside caching for offline files.Valid for SMB File Share type only.
.PARAMETER FtpShareIPs
	Lists the IP addresses assigned to the FTP share. Valid only for FTP File Share type.
.PARAMETER FtpOptions
	Specifies the configuration options for the FTP share. Use the format:
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]	$FSName,
		[Parameter(Mandatory=$true)][ValidateSet('NFS','SMB')]			$Protcol,
		[String]		$VFS,
		[String]		$ShareDirectory,
		[String]		$FStore,
		[String]		$FPG,
		[String]		$Comment,
		[Switch]		$Enables_SSL,
		[Switch]		$Disables_SSL,
		[String]		$ObjurlPath,
		[String]		$NFSOptions,
		[String[]]		$NFSClientlist,
		[Switch]		$SmbABE,
		[String[]]		$SmbAllowedIPs,
		[String[]]		$SmbDeniedIPs,
		[Switch]		$SmbContinuosAvailability,
		[ValidateSet('OFF','MANUAL','OPTIMIZED','AUTO')]
		[String]		$SmbCache,
		[String[]]		$FtpShareIPs,
		[String]		$FtpOptions	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	If ($FSName) 			{	$body["name"] 				= "$($FSName)"	}
	If ($Protocol -eq 'NFS'){	$body["type"] 				= 1				}
	If ($Protocol -eq 'SMB'){	$body["type"] 				= 2				}
	If ($VFS) 				{	$body["vfs"] 				= "$($VFS)"		}	
	If ($ShareDirectory) 	{	$body["shareDirectory"] 	= "$($ShareDirectory)" 	}
	If ($FStore) 			{	$body["fstore"] 			= "$($FStore)" 	}
	If ($FPG) 				{	$body["fpg"] 				= "$($FPG)" 	}
	If ($Comment) 			{	$body["comment"] 			= "$($Comment)"	}
	If ($Enables_SSL) 		{	$body["ssl"] 				= $true			}	
	If ($Disables_SSL) 		{	$body["ssl"] 				= $false		}
	If ($ObjurlPath) 		{	$body["objurlPath"] 		= "$($ObjurlPath)"		}
	If ($NFSOptions) 		{	$body["nfsOptions"] 		= "$($NFSOptions)"		}
	If ($NFSClientlist) 	{	$body["nfsClientlist"] 		= "$($NFSClientlist)"	}
	If ($SmbABE) 			{	$body["smbABE"] 			= $true			}
	If ($SmbAllowedIPs) 	{	$body["smbAllowedIPs"] 		= "$($SmbAllowedIPs)"	}
	If ($SmbDeniedIPs) 		{	$body["smbDeniedIPs"] 		= "$($SmbDeniedIPs)" 	}
	If ($SmbContinuosAvailability) {	$body["smbContinuosAvailability"] = $true		}
	if ($SmbCache -Eq "OFF"){	$body["smbCache"] = 1	}
	if ($SmbCache -Eq "MANUAL"){$body["smbCache"] = 2	}
	if ($SmbCache -Eq "OPTIMIZED"){	$body["smbCache"] = 3	}
	if ($SmbCache -Eq "AUTO"){	$body["smbCache"] = 4	}
	If ($FtpShareIPs) 		{	$body["ftpShareIPs"] 		= "$($FtpShareIPs)"	}
	If ($FtpOptions) 		{	$body["ftpOptions"] 		= "$($FtpOptions)"	}
    $Result = $null
	Write-DebugLog "Request: Request to New-FileShare_WSAPI(Invoke-WSAPI)." $Debug	
    $Result = Invoke-WSAPI -uri '/fileshares/' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "`n SUCCESS: Successfully Created File Share, Name: $FSName.`n" -foreground green
			return $Result
		}
	else
		{	write-error "`nFAILURE : While Creating File Share, Name: $FSName.`n" 
			return $Result.StatusDescription
		}
}
}

Function Remove-FileShare_WSAPI 
{
<#      
.SYNOPSIS	
	Remove File Share.
.DESCRIPTION	
    Remove File Share.
.EXAMPLE	
	Remove-FileShare_WSAPI
.PARAMETER ID
	File Share ID contains the unique identifier of the File Share you want to remove.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]	$ID
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$uri = '/fileshares/'+$ID
    $Result = Invoke-WSAPI -uri $uri -type 'DELETE'
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "`n SUCCESS: Successfully Removed File Share, File Share ID: $ID.`n" -foreground green
			return $Result
		}
	else
		{	write-error "`n FAILURE : While Removing File Share, File Share ID: $ID.`n" 
			return $Result.StatusDescription
		}
}
}

Function Get-FileShare_WSAPI 
{
<#
.SYNOPSIS	
	Get all or single File Shares.
.DESCRIPTION
	Get all or single File Shares.
.EXAMPLE
	Get-FileShare_WSAPI
	Get List of File Shares.
.EXAMPLE
	Get-FileShare_WSAPI -ID xxx
	Get Single File Shares.
.PARAMETER ID
    File Share ID contains the unique identifier of the File Share you want to Query.
.PARAMETER FSName
	File Share name.
.PARAMETER FSType
	File Share type, ie, smb/nfs/obj
.PARAMETER VFS
	Name of the Virtual File Servers.
.PARAMETER FPG
	Name of the File Provisioning Groups.
.PARAMETER FStore
	Name of the File Stores.
#>
[CmdletBinding(DefaultParameterSetName='None')]
Param(	[Parameter(ValueFromPipeline=$true,ParameterSetName='ById')]	[int]		$ID,
		[Parameter(ValueFromPipeline=$true,ParameterSetName='ByOther')]	[String]	$FSName,
		[Parameter(ValueFromPipeline=$true,ParameterSetName='ByOther')]	[String]	$FSType,
		[Parameter(ValueFromPipeline=$true,ParameterSetName='ByOther')]	[String]	$VFS,
		[Parameter(ValueFromPipeline=$true,ParameterSetName='ByOther')]	[String]	$FPG,
		[Parameter(ValueFromPipeline=$true,ParameterSetName='ByOther')]	[String]	$FStore
	)
Begin 
{	Test-WSAPIConnection 
}
Process 
{	$Result = $null
	$dataPS = $null	
	$Query="?query=""  """
	if ($PSCmdlet.ParameterSetName -eq 'None')
		{	$Result = Invoke-WSAPI -uri '/fileshares' -type 'GET'
			if($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}
		}
	if	($ID)
		{	$uri = '/fileshares/'+$ID
			$Result = Invoke-WSAPI -uri $uri -type 'GET'
			if($Result.StatusCode -eq 200)	{	$dataPS = $Result.content | ConvertFrom-Json	}
		}
	if	($PSCmdlet.ParameterSetName -eq 'ByOther')	
		{	$flg = "NO"
			if($FSName)
				{ 	$Query = $Query.Insert($Query.Length-3," name EQ $FSName")			
				}
			if($FSType)
				{	if($flg -eq "NO")	{	$Query = $Query.Insert($Query.Length-3," type EQ $FSType")	}
					else				{	$Query = $Query.Insert($Query.Length-3," AND type EQ $FSType")	}
					$flg = "YES"
				}
			if($VFS)
				{	if ($flg -eq "NO")	{	$Query = $Query.Insert($Query.Length-3," vfs EQ $VFS")		}
					else				{	$Query = $Query.Insert($Query.Length-3," AND vfs EQ $VFS")	}
					$flg = "YES"
				}
			if($FPG)
				{	if($flg -eq "NO")	{	$Query = $Query.Insert($Query.Length-3," fpg EQ $FPG")	}
					else				{	$Query = $Query.Insert($Query.Length-3," AND fpg EQ $FPG")	}
					$flg = "YES"
				}
			if($FStore)
				{	if($flg -eq "NO")	{	$Query = $Query.Insert($Query.Length-3," fstore EQ $FStore")	}
					else				{	$Query = $Query.Insert($Query.Length-3," AND fstore EQ $FStore")	}
					$flg = "YES"
				}
			$uri = '/fileshares/'+$Query
			$Result = Invoke-WSAPI -uri $uri -type 'GET'
			if($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}
		}
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -eq 0)	{	write-warning "No data Found."
										return
									}
			write-host "`n SUCCESS: Command Get-FileShare_WSAPI Successfully Executed.`n" -foreground green
			return $dataPS		
		}
	else
		{	write-error "`nFAILURE : While Executing Get-FileShare_WSAPI.`n"
			return $Result.StatusDescription
		}
}	
}

Function Get-DirPermission_WSAPI 
{
<#
.SYNOPSIS	
	Get directory permission properties.
.DESCRIPTION
	Get directory permission properties.
.EXAMPLE
	Get-DirPermission_WSAPI -ID 12
.PARAMETER ID	
    File Share ID contains the unique identifier of the File Share you want to Query.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)][int]	$ID
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null
	$dataPS = $null	
	$uri = '/fileshares/'+$ID+'/dirperms'
	$Result = Invoke-WSAPI -uri $uri -type 'GET'
	if($Result.StatusCode -eq 200)	{	$dataPS = $Result.content | ConvertFrom-Json	}	
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -eq 0)
				{	write-warning "No data Found."
					return
				}
			write-host "`n SUCCESS: Command Get-DirPermission_WSAPI Successfully Executed.`n" -foreground green
			return $dataPS		
		}
	else
		{	write-error "`n FAILURE : While Executing Get-DirPermission_WSAPI.`n "
			return $Result.StatusDescription
	}
}	
}

Function New-FilePersonaQuota_WSAPI 
{
<#      
.SYNOPSIS	
	Create File Persona quota.
.DESCRIPTION	
    Create File Persona quota.
.EXAMPLE	
	New-FilePersonaQuota_WSAPI
.PARAMETER Name
	The name of the object that the File Persona quotas to be created for.
.PARAMETER Type
	The type of File Persona quota to be created. can be either; user :user quota type, or group :group quota type, or fstore :fstore quota type.
.PARAMETER VFS
	VFS name associated with the File Persona quota.
.PARAMETER FPG
	Name of the FPG hosting the VFS.
.PARAMETER SoftBlockMiB
	Soft capacity storage quota.
.PARAMETER HardBlockMiB
	Hard capacity storage quota.
.PARAMETER SoftFileLimit
	Specifies the soft limit for the number of stored files.
.PARAMETER HardFileLimit
	Specifies the hard limit for the number of stored files.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]		$Name,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[ValidateSet('user','group','fstore')]				[String]		$Type,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]		$VFS,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]		$FPG,
		[Parameter(ValueFromPipeline=$true)]				[int]			$SoftBlockMiB,	
		[Parameter(ValueFromPipeline=$true)]				[int]			$HardBlockMiB,
		[Parameter(ValueFromPipeline=$true)]				[int]			$SoftFileLimit,
		[Parameter(ValueFromPipeline=$true)]				[int]			$HardFileLimit
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	$body["name"] = "$($Name)"
	if($Type -eq "user")	{	$body["type"] = 1	}
	if($Type -eq "group")	{	$body["type"] = 2	}
	if($Type -eq "fstore")	{	$body["type"] = 3	}						
	$body["vfs"] = "$($VFS)"
	$body["fpg"] = "$($FPG)" 
	If($SoftBlockMiB) 		{	$body["softBlockMiB"] = $SoftBlockMiB	}
	If($HardBlockMiB) 		{	$body["hardBlockMiB"] = $HardBlockMiB	}
	If($SoftFileLimit) 		{	$body["softFileLimit"] = $SoftFileLimit	}
	If($HardFileLimit) 		{	$body["hardFileLimit"] = $HardFileLimit	}
    $Result = $null
	$Result = Invoke-WSAPI -uri '/filepersonaquotas/' -type 'POST' -body $body -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "`n SUCCESS: Successfully Created File Persona quota.`n " -foreground green
			return $Result
		}
	else
		{	write-error "`n FAILURE : While Creating File Persona quota.`n"
			return $Result.StatusDescription
		}
}
}

Function Update-FilePersonaQuota_WSAPI 
{
<#      
.SYNOPSIS	
	Update File Persona quota information.
.DESCRIPTION	
    Updating File Persona quota information.	
.EXAMPLE	
	Update-FilePersonaQuota_WSAPI
.PARAMETER ID
	The <id> variable contains the unique ID of the File Persona you want to modify.
.PARAMETER SoftFileLimit
	Specifies the soft limit for the number of stored files.
.PARAMETER RMSoftFileLimit
	Resets softFileLimit:
	• true —resets to 0
	• false — ignored if false and softFileLimit is set to 0. Set to limit if false and softFileLimit is a positive value.	
.PARAMETER HardFileLimit
	Specifies the hard limit for the number of stored files.
.PARAMETER RMHardFileLimit
	Resets hardFileLimit:
	• true —resets to 0 
	• If false , and hardFileLimit is set to 0, ignores. 
	• If false , and hardFileLimit is a positive value, then set to that limit.	
.PARAMETER SoftBlockMiB
	Soft capacity storage quota.	
.PARAMETER RMSoftBlockMiB
	Resets softBlockMiB: 
	• true —resets to 0 
	• If false , and softBlockMiB is set to 0, ignores.
	• If false , and softBlockMiB is a positive value, then set to that limit.
.PARAMETER HardBlockMiB
	Hard capacity storage quota.
.PARAMETER RMHardBlockMiB
	Resets hardBlockMiB: 
	• true —resets to 0 
	• If false , and hardBlockMiB is set to 0, ignores.
	• If false , and hardBlockMiB is a positive value, then set to that limit.	
.PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command	   
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)][String] $ID,
		[Parameter(ValueFromPipeline=$true)][Int]		$SoftFileLimit,
		[Parameter(ValueFromPipeline=$true)][Int]		$RMSoftFileLimit,
		[Parameter(ValueFromPipeline=$true)][Int]		$HardFileLimit,
		[Parameter(ValueFromPipeline=$true)][Int]		$RMHardFileLimit,
		[Parameter(ValueFromPipeline=$true)][Int]		$SoftBlockMiB,
		[Parameter(ValueFromPipeline=$true)][Int]		$RMSoftBlockMiB,
		[Parameter(ValueFromPipeline=$true)][Int]		$HardBlockMiB,
		[Parameter(ValueFromPipeline=$true)][Int]		$RMHardBlockMiB	
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	If($SoftFileLimit) 		{	$body["softFileLimit"] 		= $SoftFileLimit }	
	If($RMSoftFileLimit) 	{	$body["rmSoftFileLimit"] 	= $RMSoftFileLimit 	}
	If($HardFileLimit) 		{	$body["hardFileLimit"] 		= $HardFileLimit }
	If($RMHardFileLimit) 	{	$body["rmHardFileLimit"] 	= $RMHardFileLimit 		}
	If($SoftBlockMiB) 		{	$body["softBlockMiB"] 		= $SoftBlockMiB 		}
	If($RMSoftBlockMiB) 	{	$body["rmSoftBlockMiB"] 	= $RMSoftBlockMiB 		}
	If($HardBlockMiB) 		{	$body["hardBlockMiB"] 		= $HardBlockMiB 		}
	If($RMHardBlockMiB) 	{	$body["rmHardBlockMiB"] 	= $RMHardBlockMiB 		}
    $Result = $null
	$uri = '/filepersonaquotas/'+$ID
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "`n SUCCESS: Successfully Updated File Persona quota information, ID: $ID.`n" -foreground green
			return $Result
		}
	else
		{	write-error "`nFAILURE : While Updating File Persona quota information, ID: $ID.`n" 
			return $Result.StatusDescription
		}
}
}

Function Remove-FilePersonaQuota_WSAPI 
{
<#      
.SYNOPSIS	
	Remove File Persona quota.
.DESCRIPTION	
    Remove File Persona quota.
.EXAMPLE	
	Remove-FilePersonaQuota_WSAPI
.PARAMETER ID
	The <id> variable contains the unique ID of the File Persona you want to Remove.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true)][String]	$ID
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	Write-DebugLog "Request: Request to Remove-FilePersonaQuota_WSAPI(Invoke-WSAPI)." $Debug	
	$uri = '/filepersonaquotas/'+$ID
    $Result = Invoke-WSAPI -uri $uri -type 'DELETE'
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "`n SUCCESS: Successfully Removed File Persona quota, File Persona quota ID: $ID.`n" -foreground green
			return $Result
		}
	else
		{	write-error "`nFAILURE : While Removing File Persona quota, File Persona quota ID: $ID.`n"
			return $Result.StatusDescription
		}
}
}

Function Get-FilePersonaQuota_WSAPI 
{
<#
.SYNOPSIS	
	Get all or single File Persona quota.
.DESCRIPTION
	Get all or single File Persona quota. 
.EXAMPLE
	Get-FilePersonaQuota_WSAPI
	Get List of File Persona quota.	
.EXAMPLE
	Get-FilePersonaQuota_WSAPI -ID xxx
	Get Single File Persona quota.	
.PARAMETER ID	
    The <id> variable contains the unique ID of the File Persona.	
.PARAMETER Name
	user, group, or fstore name.
.PARAMETER Key
	user, group, or fstore id.
.PARAMETER QType
	Quota type.
.PARAMETER VFS
	Virtual File Servers name.
.PARAMETER FPG
	File Provisioning Groups name.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)][int]		$ID,
		[Parameter(ValueFromPipeline=$true)][String]	$Name,
		[Parameter(ValueFromPipeline=$true)][String]	$Key,
		[Parameter(ValueFromPipeline=$true)][String]	$QType,
		[Parameter(ValueFromPipeline=$true)][String]	$VFS,
		[Parameter(ValueFromPipeline=$true)][String]	$FPG
			)
Begin 
{	Test-WSAPIConnection 
}
Process 
{	$Result = $null
	$dataPS = $null
	$Query="?query=""  """
	$flg = "NO"	
	if($ID)
		{	$uri = '/filepersonaquota/'+$ID
			$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
			if($Result.StatusCode -eq 200)	{	$dataPS = $Result.content | ConvertFrom-Json	}
		}
	elseif($Name -Or $Key -Or $QType -Or $VFS -Or $FPG)
		{	if($Name)
				{	$Query = $Query.Insert($Query.Length-3," name EQ $Name")			
					$flg = "YES"
				}
			if($Key)
				{	if($flg -eq "NO")	{	$Query = $Query.Insert($Query.Length-3," key EQ $Key")}
					else				{	$Query = $Query.Insert($Query.Length-3," AND key EQ $Key")	}
					$flg = "YES"
				}
			if($QType)
				{	if($flg -eq "NO")	{	$Query = $Query.Insert($Query.Length-3," type EQ $QType")	}
					else				{	$Query = $Query.Insert($Query.Length-3," AND type EQ $QType")	}
					$flg = "YES"
				}
			if($VFS)
				{	if($flg -eq "NO")	{	$Query = $Query.Insert($Query.Length-3," vfs EQ $VFS")	}
					else				{	$Query = $Query.Insert($Query.Length-3," AND vfs EQ $VFS")		}
					$flg = "YES"
				}
			if($FPG)
				{	if($flg -eq "NO")	{	$Query = $Query.Insert($Query.Length-3," fpg EQ $FPG")	}
					else				{	$Query = $Query.Insert($Query.Length-3," AND fpg EQ $FPG")	}
					$flg = "YES"
				}
			$uri = '/filepersonaquota/'+$Query
			$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection
			if($Result.StatusCode -eq 200)
				{	$dataPS = ($Result.content | ConvertFrom-Json).members
				}
		}	
	else
		{	$Result = Invoke-WSAPI -uri '/filepersonaquota' -type 'GET' -WsapiConnection $WsapiConnection
			if($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}	
		}	
	if($Result.StatusCode -eq 200)
		{	if($dataPS.Count -eq 0)	{	return "No data Found."	}
			write-host "`n SUCCESS: Command Get-FilePersonaQuota_WSAPI Successfully Executed.`n" -foreground green
			return $dataPS		
		}
	else
		{	write-error "`n FAILURE : While Executing Get-FilePersonaQuota_WSAPI.`n"
			return $Result.StatusDescription
		}
}	
}

Function Restore-FilePersonaQuota_WSAPI 
{
<#      
.SYNOPSIS	
	Restore a File Persona quota.
.DESCRIPTION	
    Restore a File Persona quota.
.EXAMPLE	
	Restore-FilePersonaQuota_WSAPI
.PARAMETER VFSUUID
	VFS UUID.
.PARAMETER ArchivedPath
	The path to the archived file from which the file persona quotas are to be restored.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]		$VFSUUID,
		[Parameter(ValueFromPipeline=$true)]    			[String]		$ArchivedPath
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}
	$body["action"] = 2 
	If($VFSUUID) 		{	$body["vfsUUID"] = "$($VFSUUID)"			}
	If($ArchivedPath)	{	$body["archivedPath"] = "$($ArchivedPath)"	}
    $Result = $null
	$Result = Invoke-WSAPI -uri '/filepersonaquotas/' -type 'POST' -body $body -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "`n SUCCESS: Successfully Restore a File Persona quota, VFSUUID: $VFSUUID.`n" -foreground green
			return $Result
		}
	else
		{	write-error "`n FAILURE : While Restoring a File Persona quota, VFSUUID: $VFSUUID.`n"
			return $Result.StatusDescription
		}
}
}

Function Group-FilePersonaQuota_WSAPI 
{
<#      
.SYNOPSIS	
	Archive a File Persona quota.
.DESCRIPTION	
    Archive a File Persona quota.
.EXAMPLE	
	Group-FilePersonaQuota_WSAPI
.PARAMETER QuotaArchiveParameter
	VFS UUID.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]	$QuotaArchiveParameter
	)
Begin 
{	Test-WSAPIConnection 
}
Process 
{	$body = @{}
	$body["action"] = 1 
	If($QuotaArchiveParameter) {	$body["quotaArchiveParameter"] = "$($QuotaArchiveParameter)"	}
    $Result = $null		
	$Result = Invoke-WSAPI -uri '/filepersonaquotas/' -type 'POST' -body $body -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "`n SUCCESS: Successfully Restore a File Persona quota, VFSUUID: $VFSUUID.`n " -foreground green
			return $Result
		}
	else
		{	write-error "`nFAILURE : While Restoring a File Persona quota, VFSUUID: $VFSUUID.`n" 
			return $Result.StatusDescription
		}
}
}

Export-ModuleMember Get-FileServices_WSAPI , New-FPG_WSAPI , Remove-FPG_WSAPI , Get-FPG_WSAPI , Get-FPGReclamationTasks_WSAPI

Export-ModuleMember New-VFS_WSAPI, Remove-VFS_WSAPI , Get-VFS_WSAPI 

Export-ModuleMember New-FileStore_WSAPI , Update-FileStore_WSAPI , Remove-FileStore_WSAPI , Get-FileStore_WSAPI , New-FileStoreSnapshot_WSAPI ,
Remove-FileStoreSnapshot_WSAPI , Get-FileStoreSnapshot_WSAPI 

Export-ModuleMember New-FileShare_WSAPI , Remove-FileShare_WSAPI , Get-FileShare_WSAPI 

Export-ModuleMember Get-DirPermission_WSAPI

Export-ModuleMember New-FilePersonaQuota_WSAPI , Update-FilePersonaQuota_WSAPI , Remove-FilePersonaQuota_WSAPI , Get-FilePersonaQuota_WSAPI , Group-FilePersonaQuota_WSAPI ,
Restore-FilePersonaQuota_WSAPI
