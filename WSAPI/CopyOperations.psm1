﻿## 	© 2019,2020,2023 Hewlett Packard Enterprise Development LP
##

Function New-VvSnapshot_WSAPI 
{
<#      
.SYNOPSIS	
	Creating a volume snapshot
.DESCRIPTION	
	Creating a volume snapshot
.EXAMPLE    
	New-VvSnapshot_WSAPI -VolumeName $val -snpVVName snpvv1        
.EXAMPLE	
	New-VvSnapshot_WSAPI -VolumeName $val -snpVVName snpvv1 -ID 11        
.EXAMPLE	
	New-VvSnapshot_WSAPI -VolumeName $val -snpVVName snpvv1 -ID 11 -Comment hello        
.EXAMPLE	
	New-VvSnapshot_WSAPI -VolumeName $val -snpVVName snpvv1 -ID 11 -Comment hello -ReadOnly $true        
.EXAMPLE	
	New-VvSnapshot_WSAPI -VolumeName $val -snpVVName snpvv1 -ID 11 -Comment hello -ReadOnly $true -ExpirationHours 10        
.EXAMPLE	
	New-VvSnapshot_WSAPI -VolumeName $val -snpVVName snpvv1 -ID 11 -Comment hello -ReadOnly $true -ExpirationHours 10 -RetentionHours 10        
.EXAMPLE	
	New-VvSnapshot_WSAPI -VolumeName $val -snpVVName snpvv1 -AddToSet asvvset	
.PARAMETER VolumeName
	The <VolumeName> parameter specifies the name of the volume from which you want to copy.
.PARAMETER snpVVName
	Specifies a snapshot volume name up to 31 characters in length.	For a snapshot of a volume set, use	name patterns that are used to form	the snapshot volume name. 
	See, VV	Name Patterns in the HPE 3PAR Command Line Interface Reference,available from the HPE Storage Information Library.
.PARAMETER ID
	Specifies the ID of the snapshot. If not specified, the system chooses the next available ID.
	Not applicable for VV-set snapshot creation.	
.PARAMETER Comment
	Specifies any additional information up to 511 characters for the volume.
.PARAMETER ReadOnly
	true—Specifies that the copied volume is read-only.
	false—(default) The volume is read/write.
.PARAMETER ExpirationHours
	Specifies the relative time from the current time that the volume expires. Value is a positive integer and in the range of 1–43,800 hours, or 1825 days.
.PARAMETER RetentionHours
	Specifies the relative time from the current time that the volume will expire. Value is a positive integer and in the range of 1–43,800 hours, or 1825 days.
.PARAMETER AddToSet
	The name of the volume set to which the system adds your created snapshots. If the volume set does not exist, it will be created.
.PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)][String]	$VolumeName,
		[Parameter(ValueFromPipeline=$true)][String]	$snpVVName,
		[Parameter(ValueFromPipeline=$true)][int]		$ID,
		[Parameter(ValueFromPipeline=$true)][String]	$Comment,
		[Parameter(ValueFromPipeline=$true)][boolean]	$ReadOnly,
		[Parameter(ValueFromPipeline=$true)][int]		$ExpirationHours,
		[Parameter(ValueFromPipeline=$true)][int]		$RetentionHours,
		[Parameter(ValueFromPipeline=$true)][String]	$AddToSet
	)
Begin 
{	Test-WSAPIConnection 
}
Process 
{   Write-DebugLog "Running: Creation of the body hash" $Debug
    # Creation of the body hash
    $body = @{}	
	$ParameterBody = @{}
    $body["action"] = "createSnapshot"
    If($snpVVName) 		{	$ParameterBody["name"] 			= "$($snpVVName)"	}
    If($ID) 			{	$ParameterBody["id"] 			= $ID				}
	If($Comment) 		{	$ParameterBody["comment"] 		= "$($Comment)"		}
    If($ReadOnly) 		{	$ParameterBody["readOnly"] 		= $ReadOnly			}
	If($ExpirationHours){	$ParameterBody["expirationHours"] = $ExpirationHours}
	If($RetentionHours)	{	$ParameterBody["retentionHours"]= $RetentionHours	}
	If($AddToSet) 		{	$ParameterBody["addToSet"] 		= "$($AddToSet)"	}
	if($ParameterBody.Count -gt 0) { $body["parameters"] 	= $ParameterBody 	}
    $Result = $null
    #Request
	Write-DebugLog "Request: Request to New-VvSnapshot_WSAPI : $snpVVName (Invoke-WSAPI)." $Debug	
	$uri = '/volumes/'+$VolumeName
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body
	$status = $Result.StatusCode
	if($status -eq 201)
		{ 	write-host "`n SUCCESS: volume snapshot:$snpVVName created successfully. `n" -foreground green
			return $Result
		}
	else
		{	write-Error "`n FAILURE : While creating volume snapshot: $snpVVName `n"
			return $Result.StatusDescription
		}
}
}

Function New-VvListGroupSnapshot_WSAPI 
{
<#      
.SYNOPSIS	
	Creating group snapshots of a virtual volumes list
.DESCRIPTION
	Creating group snapshots of a virtual volumes list
.EXAMPLE    
	New-VvListGroupSnapshot_WSAPI -VolumeName xyz -SnapshotName asSnpvv -SnapshotId 10 -SnapshotWWN 60002AC0000000000101142300018F8D -ReadWrite $true -Comment Hello -ReadOnly $true -Match $true -ExpirationHours 10 -RetentionHours 10 -SkipBlock $true
.PARAMETER VolumeName 
	Name of the volume being copied. Required.
.PARAMETER SnapshotName
	If not specified, the system generates the snapshot name.
.PARAMETER SnapshotId
	ID of the snapShot volume. If not specified, the system chooses an ID.
.PARAMETER SnapshotWWN
	WWN of the snapshot Virtual Volume. With no snapshotWWNspecified, a WWN is chosen automatically.
.PARAMETER ReadWrite
	Optional.
	A True setting applies read-write status to the snapshot.
	A False setting applies read-only status to the snapshot.
	Overrides the readOnly and match settings for the snapshot.
.PARAMETER Comment
	Specifies any additional information for the volume.
.PARAMETER ReadOnly
	Specifies that the copied volumes are read-only. Do not combine with the match member.
.PARAMETER Match
	By default, all snapshots are created read-write. Specifies the creation of snapshots that match the read-only or read-write setting of parent. Do not combine the readOnly and match options.
.PARAMETER ExpirationHours
	Specifies the time relative to the current time that the copied volumes expire. Value is a positive integer with a range of 1–43,800 hours (1825 days).
.PARAMETER RetentionHours
	Specifies the time relative to the current time that the copied volumes are retained. Value is a positive integer with a range of 1–43,800 hours (1825 days).
.PARAMETER SkipBlock
	Occurs if the host IO is blocked while the snapshot is being created.
.PARAMETER AddToSet
	The name of the volume set to which the system adds your created snapshots. If the volume set does not exist, it will be created.
.PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)][String]	$VolumeName,
		[Parameter(ValueFromPipeline=$true)][String]	$SnapshotName,
		[Parameter(ValueFromPipeline=$true)][int]		$SnapshotId,
		[Parameter(ValueFromPipeline=$true)][String]	$SnapshotWWN,
		[Parameter(ValueFromPipeline=$true)][boolean]	$ReadWrite,
		[Parameter(ValueFromPipeline=$true)][String]	$Comment,
		[Parameter(ValueFromPipeline=$true)][boolean]	$ReadOnly,
		[Parameter(ValueFromPipeline=$true)][boolean]	$Match,
		[Parameter(ValueFromPipeline=$true)][int]		$ExpirationHours,
		[Parameter(ValueFromPipeline=$true)][int]		$RetentionHours,
		[Parameter(ValueFromPipeline=$true)][boolean]	$SkipBlock,
		[Parameter(ValueFromPipeline=$true)][String]	$AddToSet
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	$VolumeGroupBody = @()
	$ParameterBody = @{}
    $body["action"] = 8	
    If ($VolumeName) 
		{	$VName=@{}
			$VName["volumeName"] = "$($VolumeName)"	
			$VolumeGroupBody += $VName		
		}
	If ($SnapshotName) 
		{	$snpName=@{}
			$snpName["snapshotName"] = "$($SnapshotName)"	
			$VolumeGroupBody += $snpName
		}
    If ($SnapshotId) 
		{	$snpId=@{}
			$snpId["snapshotId"] = $SnapshotId	
			$VolumeGroupBody += $snpId
		}
	If ($SnapshotWWN) 
		{	$snpwwn=@{}
			$snpwwn["SnapshotWWN"] = "$($SnapshotWWN)"	
			$VolumeGroupBody += $snpwwn
		}
    If ($ReadWrite) 
		{	$rw=@{}
			$rw["readWrite"] = $ReadWrite	
			$VolumeGroupBody += $rw
		}
	if($VolumeGroupBody.Count -gt 0)
		{	$ParameterBody["volumeGroup"] = $VolumeGroupBody 
		}	
	If ($Comment) 		{	$ParameterBody["comment"] = "$($Comment)"	}	
	If ($ReadOnly) 		{	$ParameterBody["readOnly"] = $ReadOnly		}	
	If ($Match) 		{	$ParameterBody["match"] = $Match			}	
	If ($ExpirationHours){	$ParameterBody["expirationHours"] = $ExpirationHours }
	If ($RetentionHours){	$ParameterBody["retentionHours"] = $RetentionHours }
	If ($SkipBlock) 	{	$ParameterBody["skipBlock"] = $SkipBlock	}
	If ($AddToSet) 		{	$ParameterBody["addToSet"] = "$($AddToSet)"	}
	if($ParameterBody.Count -gt 0){	$body["parameters"] = $ParameterBody}	
    $Result = $null
    #Request
	Write-DebugLog "Request: Request to New-VvListGroupSnapshot_WSAPI : $SnapshotName (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri '/volumes' -type 'POST' -body $body 
	$status = $Result.StatusCode
	if($status -eq 300)
		{	write-host "`n SUCCESS: Group snapshots of a virtual volumes list : $SnapshotName created successfully.`n" -foreground green
			# Results
			return $Result
		}
	else
		{	write-Error "`n FAILURE : While creating group snapshots of a virtual volumes list : $SnapshotName `n"
			return $Result.StatusDescription
		}
}
}

Function New-VvPhysicalCopy_WSAPI 
{
<#      
.SYNOPSIS	
	Create a physical copy of a volume.	
.DESCRIPTION
    Create a physical copy of a volume.
.EXAMPLE    
	New-VvPhysicalCopy_WSAPI -VolumeName xyz -DestVolume Test1    
.EXAMPLE
    New-VvPhysicalCopy_WSAPI -VolumeName xyz -DestVolume Test -DestCPG as_cpg    
.EXAMPLE
	New-VvPhysicalCopy_WSAPI -VolumeName xyz -DestVolume Test -Online    
.EXAMPLE
	New-VvPhysicalCopy_WSAPI -VolumeName xyz -DestVolume Test -WWN "60002AC0000000000101142300018F8D"    
.EXAMPLE
	New-VvPhysicalCopy_WSAPI -VolumeName xyz -DestVolume Test -TPVV    
.EXAMPLE
	New-VvPhysicalCopy_WSAPI -VolumeName xyz -DestVolume Test -SnapCPG as_cpg    
.EXAMPLE
	New-VvPhysicalCopy_WSAPI -VolumeName xyz -DestVolume Test -SkipZero
.EXAMPLE
	New-VvPhysicalCopy_WSAPI -VolumeName xyz -DestVolume Test -Compression
.EXAMPLE
	New-VvPhysicalCopy_WSAPI -VolumeName xyz -DestVolume Test -SaveSnapshot
.EXAMPLE
	New-VvPhysicalCopy_WSAPI -VolumeName $val -DestVolume Test -Priority high
.PARAMETER VolumeName
	The <VolumeName> parameter specifies the name of the volume to copy.
.PARAMETER DestVolume
	Specifies the destination volume.
.PARAMETER DestCPG
	Specifies the destination CPG for an online copy.
.PARAMETER Online
	Enables (true) or disables (false) whether to perform the physical copy online. Defaults to false.
.PARAMETER WWN
	Specifies the WWN of the online copy virtual volume.
.PARAMETER TDVV
	Enables (true) or disables (false) whether the online copy is a TDVV. Defaults to false. tpvv and tdvv cannot be set to true at the same time.
.PARAMETER Reduce
	Enables (true) or disables (false) a thinly deduplicated and compressed volume.
.PARAMETER TPVV
	Enables (true) or disables (false) whether the online copy is a TPVV. Defaults to false. tpvv and tdvv cannot be set to true at the same time.
.PARAMETER SnapCPG
	Specifies the snapshot CPG for an online copy.
.PARAMETER SkipZero
	Enables (true) or disables (false) copying only allocated portions of the source VV from a thin provisioned source. Use only on a newly created destination, or if the destination was re-initialized to zero. Does not overwrite preexisting data on the destination VV to match the source VV unless the same offset is allocated in the source.
.PARAMETER Compression
	For online copy only:
	Enables (true) or disables (false) compression of the created volume. Only tpvv or tdvv are compressed. Defaults to false.
.PARAMETER SaveSnapshot
	Enables (true) or disables (false) saving the the snapshot of the source volume after completing the copy of the volume. Defaults to false
.PARAMETER Priority
	Does not apply to online copy.
	HIGH : High priority.
	MED : Medium priority.
	LOW : Low priority.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)][String]		$VolumeName,
		[Parameter(ValueFromPipeline=$true)][String]		$DestVolume,
		[Parameter(ValueFromPipeline=$true)][String]		$DestCPG,
		[Parameter(ValueFromPipeline=$true)][switch]		$Online,
		[Parameter(ValueFromPipeline=$true)][String]		$WWN,
		[Parameter(ValueFromPipeline=$true)][switch]		$TPVV,
		[Parameter(ValueFromPipeline=$true)][switch]		$TDVV,
		[Parameter(ValueFromPipeline=$true)][switch]		$Reduce,
		[Parameter(ValueFromPipeline=$true)][String]		$SnapCPG,
		[Parameter(ValueFromPipeline=$true)][switch]		$SkipZero,
		[Parameter(ValueFromPipeline=$true)][switch]		$Compression,
		[Parameter(ValueFromPipeline=$true)][switch]		$SaveSnapshot,
		[Parameter(ValueFromPipeline=$true)]
		[ValidateSet('HIGH','MED','LOW')] 	[String]		$Priority
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	$ParameterBody = @{}
    $body["action"] = "createPhysicalCopy"
    If ($DestVolume) 			{	$ParameterBody["destVolume"] = "$($DestVolume)"}    
	If ($Online) 
		{	$ParameterBody["online"] = $true
			If ($DestCPG) 
				{	$ParameterBody["destCPG"] = $DestCPG
				}
			else
				{	write-error "Specifies the destination CPG for an online copy." 
					return 				
				}
		}	
    If ($WWN) 					{	$ParameterBody["WWN"] 		= "$($WWN)"	}
	If ($TPVV) 					{	$ParameterBody["tpvv"] 		= $true		}
	If ($TDVV) 					{	$ParameterBody["tdvv"] 		= $true		}
	If ($Reduce)				{	$ParameterBody["reduce"] 	= $true		}		
	If ($SnapCPG)				{	$ParameterBody["snapCPG"] 	= "$($SnapCPG)"}
	If ($SkipZero)				{	$ParameterBody["skipZero"] 	= $true		}
	If ($Compression) 			{	$ParameterBody["compression"] = $true	}
	If ($SaveSnapshot) 			{	$ParameterBody["saveSnapshot"] = $SaveSnapshot}
	if ($Priority -eq "HIGH")	{	$ParameterBody["priority"] 	= 1			}
	if ($Priority -eq "MED")	{	$ParameterBody["priority"] 	= 2			}
	if ($Priority -eq "LOW")	{	$ParameterBody["priority"] 	= 3			}
	if($ParameterBody.Count -gt 0){	$body["parameters"] = $ParameterBody 	}
    $Result = $null
    #Request
	Write-DebugLog "Request: Request to New-VvPhysicalCopy_WSAPI : $VolumeName (Invoke-WSAPI)." $Debug
	$uri = '/volumes/'+$VolumeName
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "`n SUCCESS: Physical copy of a volume: $VolumeName created successfully. `n" -foreground green
			return $Result
		}
	else
		{	write-error "`n FAILURE : While creating Physical copy of a volume : $VolumeName `n"
			return $Result.StatusDescription
		}
}
}

Function Reset-PhysicalCopy_WSAPI 
{
<#
.SYNOPSIS
	Resynchronizing a physical copy to its parent volume
.DESCRIPTION
	Resynchronizing a physical copy to its parent volume
.EXAMPLE    
	Reset-PhysicalCopy_WSAPI -VolumeName xxx
	Resynchronizing a physical copy to its parent volume
.PARAMETER VolumeName 
	The <VolumeName> parameter specifies the name of the destination volume you want to resynchronize.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)][String]		$VolumeName
	)
Begin 
{	Test-WSAPIConnection 
}
Process 
{  	$body = @{}	
	$body["action"] = 2	
    $Result = $null	
	$uri = "/volumes/" + $VolumeName
    #Request
	Write-DebugLog "Request: Request to Reset-PhysicalCopy_WSAPI : $VolumeName (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body
	if($Result.StatusCode -eq 200)
		{	write-host "`n SUCCESS: Successfully Resynchronize a physical copy to its parent volume : $VolumeName . `n" -foreground green
			return $Result		
		}
	else
		{	write-Error "`n FAILURE : While Resynchronizing a physical copy to its parent volume : $VolumeName `n"
			return $Result.StatusDescription
		}
}
}

Function Stop-PhysicalCopy_WSAPI 
{
<#
.SYNOPSIS
	Stop a physical copy of given Volume
.DESCRIPTION
	Stop a physical copy of given Volume
.EXAMPLE    
	Stop-PhysicalCopy_WSAPI -VolumeName xxx
	Stop a physical copy of given Volume 
.PARAMETER VolumeName 
	The <VolumeName> parameter specifies the name of the destination volume you want to resynchronize.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)][String]		$VolumeName
	)
Begin 
{	Test-WSAPIConnection 
}
Process 
{  	$body = @{}	
	$body["action"] = 1	
    $Result = $null	
	$uri = "/volumes/" + $VolumeName
    #Request
	Write-DebugLog "Request: Request to Stop-PhysicalCopy_WSAPI : $VolumeName (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
		{	write-host "`n SUCCESS: Successfully Stop a physical copy of : $VolumeName. `n" -foreground green
			return $Result		
		}
	else
		{	write-Error "`n FAILURE : While stopping a physical copy : $VolumeName `n "
			return $Result.StatusDescription
		}
}
}

Function Move-VirtualCopy_WSAPI 
{
<#
.SYNOPSIS
	To promote the changes from a virtual copy back onto the base volume, thereby overwriting the base volume with the virtual copy.
.DESCRIPTION
	To promote the changes from a virtual copy back onto the base volume, thereby overwriting the base volume with the virtual copy.
.EXAMPLE
	Move-VirtualCopy_WSAPI -VirtualCopyName xyz
.EXAMPLE	
	Move-VirtualCopy_WSAPI -VirtualCopyName xyz -Online
.EXAMPLE	
	Move-VirtualCopy_WSAPI -VirtualCopyName xyz -Priority HIGH
.EXAMPLE	
	Move-VirtualCopy_WSAPI -VirtualCopyName xyz -AllowRemoteCopyParent
.PARAMETER VirtualCopyName 
	The <virtual_copy_name> parameter specifies the name of the virtual copy to be promoted.
.PARAMETER Online	
	Enables (true) or disables (false) executing the promote operation on an online volume. The default setting is false.
.PARAMETER Priority
	Task priority which can be either HIGH, MED, or LOW. 
.PARAMETER AllowRemoteCopyParent
	Allows the promote operation to proceed even if the RW parent volume is currently in a Remote Copy volume group, if that group has not been started. If the Remote Copy group has been started, this command fails.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)][String]	$VirtualCopyName,
		[Parameter(ValueFromPipeline=$true)][Switch]	$Online,
		[Parameter(ValueFromPipeline=$true)]
		[ValidateSet('HIGH','MED','LOW')] 	[String]	$Priority,
		[Parameter(ValueFromPipeline=$true)][Switch]	$AllowRemoteCopyParent
	)
Begin 
{   Test-WSAPIConnection 
}
Process 
{ 	$body = @{}	
	$body["action"] = 4
	if($Online)				{	$body["online"] 	= $true	}	
	if($Priority -eq "HIGH"){	$body["priority"] 	= 1 }
	if($Priority -eq "MED")	{	$body["priority"] 	= 2 }
	if($Priority -eq "MED")	{	$body["priority"] 	= 3 }
	if($AllowRemoteCopyParent)
		{	$body["allowRemoteCopyParent"] = $true	
		}
    $Result = $null	
	$uri = "/volumes/" + $VirtualCopyName
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body
	if($Result.StatusCode -eq 200)
		{	write-host "`n SUCCESS: Successfully Promoted a virtual copy : $VirtualCopyName. `n" -foreground green
			return $Result		
		}
	else
		{	write-Error "`n FAILURE : While Promoting a virtual copy : $VirtualCopyName. `n"
			return $Result.StatusDescription
		}
}
}

Function Move-VvSetVirtualCopy_WSAPI 
{
<#
.SYNOPSIS
	To promote the changes from a vv set virtual copy back onto the base volume, thereby overwriting the base volume with the virtual copy.
.DESCRIPTION
	To promote the changes from a vv set virtual copy back onto the base volume, thereby overwriting the base volume with the virtual copy.
.EXAMPLE
	Move-VvSetVirtualCopy_WSAPI
.EXAMPLE	
	Move-VvSetVirtualCopy_WSAPI -VVSetName xyz
.EXAMPLE	
	Move-VvSetVirtualCopy_WSAPI -VVSetName xyz -Online        
.EXAMPLE	
	Move-VvSetVirtualCopy_WSAPI -VVSetName xyz -Priority HIGH
.EXAMPLE	
	Move-VvSetVirtualCopy_WSAPI -VVSetName xyz -AllowRemoteCopyParent
.PARAMETER VirtualCopyName 
	The <virtual_copy_name> parameter specifies the name of the virtual copy to be promoted.
.PARAMETER Online	
	Enables executing the promote operation on an online volume. The default setting is false.
.PARAMETER Priority
	Task priority which can be set to the values HIGH, MED, or LOW only.
.PARAMETER AllowRemoteCopyParent
	Allows the promote operation to proceed even if the RW parent volume is currently in a Remote Copy volume group, if that group has not been started. If the Remote Copy group has been started, this command fails.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)][String]	$VVSetName,
		[Parameter(ValueFromPipeline=$true)][Switch]	$Online,
		[Parameter(ValueFromPipeline=$true)][String]
		[ValidateSet('HIGH','MED','LOW')]				$Priority,
		[Parameter(ValueFromPipeline=$true)][Switch]	$AllowRemoteCopyParent
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{  	$body = @{}	
	$body["action"] = 4
	if($Online)					{	$body["online"] = $true	}	
	if($Priority -eq "HIGH")	{	$body["priority"] = 1 }
	if($Priority -eq "MED")		{	$body["priority"] = 2 }
	if($Priority -eq "LOW")		{	$body["priority"] = 3 }
	if($AllowRemoteCopyParent)	{	$body["allowRemoteCopyParent"] = $true	} 
    $Result = $null	
	$uri = "/volumesets/" + $VVSetName
    #Request
	Write-DebugLog "Request: Request to Move-VvSetVirtualCopy_WSAPI : $VVSetName (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
		{	write-host "`n SUCCESS: Successfully Promoted a VV-Set virtual copy : $VVSetName. `n" -foreground green
			return $Result		
		}
	else
		{	write-host "`n FAILURE : While Promoting a VV-Set virtual copy : $VVSetName `n"
			return $Result.StatusDescription
		}
}
}

Function New-VvSetSnapshot_WSAPI 
{
<#      
.SYNOPSIS	
	Create a VV-set snapshot.
.DESCRIPTION	
    Create a VV-set snapshot.
	Any user with the Super or Edit role or any role granted sv_create permission (for snapshots) can create a VV-set snapshot.
.EXAMPLE    
	New-VvSetSnapshot_WSAPI -VolumeSetName Test_delete -SnpVVName PERF_AIX38 -ID 110 -Comment Hello -readOnly -ExpirationHours 1 -RetentionHours 1
.PARAMETER VolumeSetName
	The <VolumeSetName> parameter specifies the name of the VV set to copy.
.PARAMETER SnpVVName
	Specifies a snapshot volume name up to 31 characters in length.
	For a snapshot of a volume set, use name patterns that are used to form the snapshot volume name. See, VV Name Patterns in the HPE 3PAR Command Line Interface Reference,available from the HPE Storage Information Library.
.PARAMETER ID
	Specifies the ID of the snapshot. If not specified, the system chooses the next available ID.
	Not applicable for VV-set snapshot creation.
.PARAMETER Comment
	Specifies any additional information up to 511 characters for the volume.
.PARAMETER readOnly
	true—Specifies that the copied volume is read-only. false—(default) The volume is read/write.
.PARAMETER ExpirationHours
	Specifies the relative time from the current time that the volume expires. Value is a positive integer and in the range of 1–43,800 hours, or 1825 days.
.PARAMETER RetentionHours
	Specifies the relative time from the current time that the volume will expire. Value is a positive integer and in the range of 1–43,800 hours, or 1825 days.
.PARAMETER AddToSet 
	The name of the volume set to which the system adds your created snapshots. If the volume set does not exist, it will be created.
#>
[CmdletBinding()]
Param(	[Parameter(Position=0, ValueFromPipeline=$true)][String]	$VolumeSetName,
		[Parameter(Position=1, ValueFromPipeline=$true)][String]	$SnpVVName,
		[Parameter(Position=2, ValueFromPipeline=$true)][int]		$ID,
		[Parameter(Position=3, ValueFromPipeline=$true)][String]	$Comment,
		[Parameter(Position=4, ValueFromPipeline=$true)][switch]	$readOnly,
		[Parameter(Position=5, ValueFromPipeline=$true)][int]		$ExpirationHours,
		[Parameter(Position=6, ValueFromPipeline=$true)][int]		$RetentionHours,
		[Parameter(Position=7, ValueFromPipeline=$true)][String]	$AddToSet
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	$ParameterBody = @{}
    $body["action"] = "createSnapshot"
	If ($SnpVVName) 	{	$ParameterBody["name"] 		= "$($SnpVVName)"	}    
	If ($ID) 			{	$ParameterBody["id"] 		= $ID				}	
    If ($Comment) 		{	$ParameterBody["comment"] 	= "$($Comment)"		}
	If ($ReadOnly) 		{	$ParameterBody["readOnly"] 	= $true				}
	If ($ExpirationHours){	$ParameterBody["expirationHours"] = $ExpirationHours}
	If ($RetentionHours){	$ParameterBody["retentionHours"] = "$($RetentionHours)"}
	If ($AddToSet) 		{	$ParameterBody["addToSet"] 	= "$($AddToSet)"	}
	if($ParameterBody.Count -gt 0){	$body["parameters"] = $ParameterBody 	}
    $Result = $null	
	$uri = '/volumesets/'+$VolumeSetName	
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "`n SUCCESS: VV-set snapshot : $SnpVVName created successfully. `n" -foreground green
			return $Result
		}
	else
		{	write-Error "`n FAILURE : While creating VV-set snapshot : $SnpVVName `n"
			return $Result.StatusDescription
		}
}
}

Function New-VvSetPhysicalCopy_WSAPI 
{
<#      
.SYNOPSIS	
	Create a VV-set snapshot.
.DESCRIPTION	
    Create a VV-set snapshot.
	Any user with the Super or Edit role or any role granted sv_create permission (for snapshots) can create a VV-set snapshot.
.EXAMPLE    
	New-VvSetPhysicalCopy_WSAPI -VolumeSetName Test_delete -DestVolume PERF_AIX38 
.PARAMETER VolumeSetName
	The <VolumeSetName> parameter specifies the name of the VV set to copy.
.PARAMETER DestVolume
	Specifies the destination volume set.
.PARAMETER SaveSnapshot
	Enables (true) or disables (false) whether to save the source volume snapshot after completing VV set copy.
.PARAMETER Priority
	Task priority which can be set to HIGH, MED, or LOW.
#>
[CmdletBinding()]
Param(	[Parameter(Position=0, ValueFromPipeline=$true)][String]	$VolumeSetName,
		[Parameter(Position=1, ValueFromPipeline=$true)][String]	$DestVolume,
		[Parameter(Position=2, ValueFromPipeline=$true)][boolean]	$SaveSnapshot,
		[Parameter(Position=3, ValueFromPipeline=$true)]
		[ValidateSet('HIGH','MED','LOW')]				[String]	$Priority
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	$ParameterBody = @{}
    $body["action"] = "createPhysicalCopy"
	If ($DestVolume) 			{	$ParameterBody["destVolume"] = "$($DestVolume)"}    
	If ($SaveSnapshot) 			{	$ParameterBody["saveSnapshot"] = $SaveSnapshot }
	if($Priority -eq "HIGH")	{	$ParameterBody["priority"] = 1 }
	if($Priority -eq "MED")		{	$ParameterBody["priority"] = 2 }
	if($Priority -eq "LOW")		{	$ParameterBody["priority"] = 3 }
	if($ParameterBody.Count -gt 0){	$body["parameters"] = $ParameterBody }
    $Result = $null	
    $uri = '/volumesets/'+$VolumeSetName
    $Result = Invoke-WSAPI -uri $uri -type 'POST' -body $body
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "`n SUCCESS: Physical copy of a VV set : $VolumeSetName created successfully. `n" -foreground green
			return $Result
		}
	else
		{	write-Error "`n FAILURE : While creating Physical copy of a VV set : $VolumeSetName `n"
			return $Result.StatusDescription
		}
}
}

Function Reset-VvSetPhysicalCopy_WSAPI 
{
<#
.SYNOPSIS
	Resynchronizing a VV set physical copy
.DESCRIPTION
	Resynchronizing a VV set physical copy       
.EXAMPLE
    Reset-VvSetPhysicalCopy_WSAPI -VolumeSetName xyz
.EXAMPLE 
	Reset-VvSetPhysicalCopy_WSAPI -VolumeSetName xxx -Priority HIGH	
.PARAMETER VolumeSetName 
	The <VolumeSetName> specifies the name of the destination VV set to resynchronize.
.PARAMETER Priority
	Task priority which can be either HIGH, MED, or LOW
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)][String]	$VolumeSetName,
		[Parameter(ValueFromPipeline=$true)]
		[ValidateSet('HIGH','MED','LOW')]	[String]	$Priority
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{  	$body = @{}	
	$body["action"] = 3
	if($Priority -eq "HIGH")	{	$body["priority"] = 1	}
	if($Priority -eq "MED")		{	$body["priority"] = 2	}
	if($Priority -eq "LOW")		{	$body["priority"] = 3	}
    $Result = $null	
	$uri = "/volumesets/" + $VolumeSetName
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body	
	if($Result.StatusCode -eq 200)
		{	write-host "`n SUCCESS: Successfully Resynchronize a VV set physical copy : $VolumeSetName. `n" -foreground green
			return $Result		
		}
	else
		{	write-host "`n FAILURE : While Resynchronizing a VV set physical copy : $VolumeSetName `n" -foreground red
			return $Result.StatusDescription
		}
}
}

Function Stop-VvSetPhysicalCopy_WSAPI 
{
<#
.SYNOPSIS
	Stop a VV set physical copy
.DESCRIPTION
	Stop a VV set physical copy
.EXAMPLE
    Stop-VvSetPhysicalCopy_WSAPI -VolumeSetName xxx
.EXAMPLE 
	Stop-VvSetPhysicalCopy_WSAPI -VolumeSetName xxx -Priority HIGH
.PARAMETER VolumeSetName 
	The <VolumeSetName> specifies the name of the destination VV set to resynchronize.
.PARAMETER Priority
	Task priority which can be set to either HIGH, MED, or LOW.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)][String]	$VolumeSetName,
		[Parameter(ValueFromPipeline=$true)][String]	$Priority
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}	
	$body["action"] = 4
	if($Priority -eq "HIGH")	{	$body["priority"] = 1	}
	if($Priority -eq "MED")		{	$body["priority"] = 2	}
	if($Priority -eq "LOW")		{	$body["priority"] = 3	}
    $Result = $null	
	$uri = "/volumesets/" + $VolumeSetName
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body 
	if($Result.StatusCode -eq 200)
		{	write-host "`n SUCCESS: Successfully Stop a VV set physical copy : $VolumeSetName. `n" -foreground green
			return $Result		
		}
	else
		{	write-Error "`nFAILURE : While Stopping a VV set physical copy : $VolumeSetName `n"
			return $Result.StatusDescription
		}
}
}

Function Update-VvOrVvSets_WSAPI 
{
<#      
.SYNOPSIS	
	Update virtual copies or VV-sets	
.DESCRIPTION	
    Update virtual copies or VV-sets
.EXAMPLE
	Update-VvOrVvSets_WSAPI -VolumeSnapshotList "xxx,yyy,zzz" 
	Update virtual copies or VV-sets
.EXAMPLE
	Update-VvOrVvSets_WSAPI -VolumeSnapshotList "xxx,yyy,zzz" -ReadOnly $true/$false
	Update virtual copies or VV-sets
.PARAMETER VolumeSnapshotList
	List one or more volume snapshots to update. If specifying a vvset, use the	following format
	set:vvset_name.
.PARAMETER VolumeSnapshotList
	Specifies that if the virtual copy is read-write, the command updates the read-only parent volume also.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$true)][String[]]	$VolumeSnapshotList,
		[Parameter(ValueFromPipeline=$true)][boolean]	$ReadOnly
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}
	$ParameterBody = @{}
    $body["action"] = 7
    If ($VolumeSnapshotList) 	{	$ParameterBody["volumeSnapshotList"] = $VolumeSnapshotList}
	If ($ReadOnly) 				{	$ParameterBody["readOnly"] = $ReadOnly			}
	if($ParameterBody.Count -gt 0){	$body["parameters"] = $ParameterBody }
    $Result = $null	
	$Result = Invoke-WSAPI -uri '/volumes/' -type 'POST' -body $body
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "`n SUCCESS: Virtual copies or VV-sets : $VolumeSnapshotList successfully Updated. `n" -foreground green
			return $Result
		}
	else
		{	write-Error "`n FAILURE : While Updating virtual copies or VV-sets : $VolumeSnapshotList `n"
			return $Result.StatusDescription
		}
}
}

Export-ModuleMember Move-VirtualCopy_WSAPI , Stop-PhysicalCopy_WSAPI , Reset-PhysicalCopy_WSAPI , New-VvPhysicalCopy_WSAPI ,
New-VvListGroupSnapshot_WSAPI , New-VvSnapshot_WSAPI ,  Update-VvOrVvSets_WSAPI , Stop-VvSetPhysicalCopy_WSAPI , Reset-VvSetPhysicalCopy_WSAPI ,
New-VvSetPhysicalCopy_WSAPI , New-VvSetSnapshot_WSAPI , Move-VvSetVirtualCopy_WSAPI
