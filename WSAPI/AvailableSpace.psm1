## 	© 2019,2020,2023 Hewlett Packard Enterprise Development LP
##

Function Get-CapacityInfo_WSAPI 
{
<#
.SYNOPSIS
	Returns the Overall system capacity information.
.DESCRIPTION
	Returns the Overall system capacity information. More details can be gathered by using the given examples to get detailed
  information either for the Volumes or the System alone, or just the command alone will return the overall capacity.
.EXAMPLE
  PS:> Get-CapacityInfo_WSAPI

  totalMiB                      : 13959168
  allocated                     : @{totalAllocatedMiB=7674880; volumes=; system=}
  freeMiB                       : 6284288
  freeInitializedMiB            : 6284288
  freeUninitializedMiB          : 0
  unavailableCapacityMiB        : 0 
  failedCapacityMiB             : 0
  overProvisionedVirtualSizeMiB : 1755978
  overProvisionedUsedMiB        : 1410372
  overProvisionedAllocatedMiB   : 4109260
  overProvisionedFreeMiB        : 6284288

	Display Overall system capacity.
.EXAMPLE
  # The following is a common command to get Capacity Usage for the Volumes
  PS:> ((Get-CapacityInfo_WSAPI).allocated).volumes

  totalVolumesMiB                   : 4669440
  nonCPGsMiB                        : 0
  nonCPGUserMiB                     : 0
  nonCPGSnapshotMiB                 : 0
  nonCPGAdminMiB                    : 0
  CPGsMiB                           : 4669440
  CPGUserMiB                        : 551859
  CPGUserUsedMiB                    : 551859
  CPGUserUsedBulkVVMiB              : 0
  CPGUserUnusedMiB                  : 0
  CPGSnapshotMiB                    : 4117581
  CPGSnapshotUsedMiB                : 6148
  CPGSnapshotUsedBulkVVMiB          : 0
  CPGSnapshotUnusedMiB              : 4111433
  CPGAdminMiB                       : 448512
  CPGAdminUsedMiB                   : 217344
  CPGAdminUsedBulkVVMiB             : 0
  CPGAdminUnusedMiB                 : 231168
  CPGSharedMiB                      : 1228
  CPGPrivateMiB                     : 556779
  CPGBasePrivateMiB                 : 550631
  CPGBasePrivateReservedMiB         : 550631
  CPGBasePrivatevSphereVVolsMiB     : 0
  CPGSnapshotPrivateMiB             : 6148
  CPGSnapshotPrivateReservedMiB     : 6148
  CPGSnapshotPrivatevSphereVVolsMiB : 0
  CPGFreeMiB                        : 4111433
  unmappedMiB                       : 0
  capacityEfficiency                : @{compaction=30.36; deduplication=1; compression=1.12; dataReduction=1.12; overProvisioning=0.15}
.EXAMPLE
  # The following is a common command to get Capacity Usage for the System not including volume usage
  PS:>> ((Get-CapacityInfo_WSAPI).allocated).system

  totalSystemMiB : 3005440
  internalMiB    : 1164288
  spareMiB       : 1392640
  spareUsedMiB   : 0
  spareUnusedMiB : 1392640
  adminMiB       : 448512
#>
[CmdletBinding()]
Param()
Begin
{ Test-WSAPIConnection
}
Process
{ #Request 
  $Result = Invoke-WSAPI -uri '/capacity' -type 'GET'
  if($Result.StatusCode -eq 200)
    { $IntermediateResult = $Result.content | ConvertFrom-Json
      if ( ($IntermediateResult).AllCapacity )  { $IntermediateResult = ($IntermediateResult).AllCapacity }
      $dataPS = $IntermediateResult
    }
  else  { return $Result.StatusDescription  }
  $AlldataPS = Format-Result -dataPS $dataPS -TypeName ($ArrayType + '.Capacity')
  return $AlldataPS
}
}

Export-ModuleMember Get-CapacityInfo_WSAPI
