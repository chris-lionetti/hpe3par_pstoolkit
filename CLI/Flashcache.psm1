﻿####################################################################################
## 	© 2020,2021, 2023 Hewlett Packard Enterprise Development LP
##	Description: 	Flash cache cmdlets 
##		
Function New-FlashCache()
{
<#
.SYNOPSIS
	New-FlashCache - Creates flash cache for the cluster.
.DESCRIPTION
	The New-FlashCache command creates flash cache of <size> for each node pair. The flash cache will be created from SSD drives.
.PARAMETER Sim
	Specifies that the Adaptive Flash Cache will be run in simulator mode. The simulator mode does not require the use of SSD drives.
.PARAMETER RAIDType
	Specifies the RAID type of the logical disks for Flash Cache; r0 for RAID-0 or r1 for RAID-1. If no RAID type is specified, the default is chosen by the storage system.
.PARAMETER Size
	Specifies the size for the flash cache in MiB for each node pair. The flashcache size should be a multiple of 16384 (16GiB), and be an integer. 
	The minimum size of the flash cache is 64GiB. The maximum size of the flash cache is based on the node types, ranging from 768GiB up to 12288GiB (12TiB).
    An optional suffix (with no whitespace before the suffix) will modify the units to GiB (g or G suffix) or TiB (t or T suffix).
#>
[CmdletBinding()]
param(	[switch]	$Sim,
		[String]	$RAIDType,
		[String]	$Size
	)
Begin
{	Test-CLIConnectionB
}
Process
{	$Cmd = " createflashcache "
	if($Sim)		{	$Cmd += " -sim " }
	if($RAIDType)	{	$Cmd += " -t $RAIDType " }
	if($Size) 	{	$Cmd += " $Size " }
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
	Return $Result
}
}

Function Set-FlashCache()
{
<#
.SYNOPSIS
	Set-FlashCache - Sets the flash cache policy for virtual volumes
.DESCRIPTION
	The Set-FlashCache command allows you to set the policy of the flash cache for virtual volumes. The policy is set by using virtual volume sets(vvset). 
	The sys:all is used to enable the policy on all virtual volumes in the system.
.EXAMPLE
	Set-FlashCache
.PARAMETER Enable
	Will turn on the flash cache policy for the target object.
.PARAMETER Disable
	Will turn off flash cache policy for the target object.
.PARAMETER Clear
	Will turn off policy and can only be issued against the sys:all target.
.PARAMETER vvSet
	vvSet refers to the target object name as listed in the showvvset command. Pattern is glob-style (shell-style) patterns (see help on sub,globpat).
	Note(set Name Should de is the same formate Ex:  vvset:vvset1 )
.PARAMETER All
	The policy is applied to all virtual volumes.
#>
[CmdletBinding()]
param(
	[Parameter(ParameterSetName = 'Enable', Mandatory)]
	[switch]	$Enable,

	[Parameter(ParameterSetName = 'Disable', Mandatory)]
	[switch]	$Disable,
	
	[Parameter(ParameterSetName = 'Clear', Mandatory)]
	[switch]	$Clear,

	[Parameter(ParameterSetName = 'Enable', Mandatory)]
	[Parameter(ParameterSetName = 'Disable', Mandatory)]
	[String]	$vvSet,
	
	[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	[switch]	$All
	)
Begin
{	Test-CLIConnectionB
}
Process
{	$Cmd = " setflashcache "
	if($Enable)		{	$Cmd += " enable "	}
	if($Disable)	{	$Cmd += " disable "	}
	if($Clear)		{	$Cmd += " clear "	}
	if($vvSet)		{	$Cmd += " $vvSet " }
	if($All)		{	$Cmd += " sys:all " }
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
	Return $Result
}
}

Function Remove-FlashCache()
{
<#
.SYNOPSIS
	Remove-FlashCache - Removes flash cache from the cluster.
.DESCRIPTION
	The Remove-FlashCache command removes the flash cache from the cluster and will stop use of the extended cache.
.EXAMPLE
	Remove-FlashCache
.PARAMETER F
	Specifies that the command is forced. If this option is not used, the command requires confirmation before proceeding with its operation.
#>
[CmdletBinding()]
param(
	[Parameter(Position=0, Mandatory=$false)]
	[switch]	$F
	)
begin
{	Test-CLIConnectionB
}
Process
{	$Cmd = " removeflashcache "
	if($F)	{	$Cmd += " -f "	}
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
	Return $Result
}
}

Export-ModuleMember New-FlashCache , Set-FlashCache , Remove-FlashCache