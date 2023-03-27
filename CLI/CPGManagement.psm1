####################################################################################
## 	© 2020,2021,2023 Hewlett Packard Enterprise Development LP
##	Description: 	CPG Management cmdlets 
##

Function Compress-CPG()
{
<#
.SYNOPSIS
	Compress-CPG - Consolidate space in common provisioning groups.
.DESCRIPTION
	The Compress-CPG command consolidates logical disk space in Common
	Provisioning Groups (CPGs) into as few logical disks as possible, allowing
	unused logical disks to be removed and their space reclaimed.
.EXAMPLE
	Compress-CPG -CPG_name xxx 
.EXAMPLE
	Compress-CPG -CPG_name tstCPG
.PARAMETER Pat
	Compacts CPGs that match any of the specified patterns. This option
	must be used if the pattern specifier is used.
.PARAMETER Waittask
	Waits for any created tasks to complete.
.PARAMETER Trimonly
	Removes unused logical disks after consolidating the space. This option will not perform any region moves.
.PARAMETER Nomatch
	Removes only unused logical disks whose characteristics do not match the growth characteristics of the CPG. Must be used with the -trimonly
	option. If all logical disks match the CPG growth characteristics, this option has no effect.
.PARAMETER DryRun
	Specifies that the operation is a dry run, and the tasks are not actually performed.
#>
[CmdletBinding()]
param(	[switch]	$Pat,
		[switch]	$Waittask,
		[switch]	$Trimonly,
		[switch]	$Nomatch,
		[switch]	$DryRun,
		[Parameter(Mandatory=$true)]
		[String]	$CPG_name
)
Begin
{	Test-CLIConnectionB
}
Process
{ 	$Cmd = " compactcpg -f "
	if($Pat)		{	$Cmd += " -pat "  }
	if($Waittask)	{	$Cmd += " -waittask " }
	if($Trimonly)	{	$Cmd += " -trimonly "	}
	if($Nomatch)	{	$Cmd += " -nomatch " }
	if($DryRun) 	{	$Cmd += " -dr " }
	$Cmd += " $CPG_name "
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
	Return $Result
}
}

Export-ModuleMember Compress-CPG