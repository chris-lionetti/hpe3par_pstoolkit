####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##	Description: 	Adaptive Optimization(AO) cmdlets 
##		


Function New-AOConfiguration()
{
<#
.SYNOPSIS
	New-AOConfiguration - Create an Adaptive Optimization configuration.
.DESCRIPTION
	The New-AOConfiguration command creates an Adaptive Optimization configuration.
.PARAMETER T0cpg
	Specifies the Tier 0 CPG for this AO config.
.PARAMETER T1cpg
	Specifies the Tier 1 CPG for this AO config.
.PARAMETER T2cpg
	Specifies the Tier 2 CPG for this AO config.
.PARAMETER Mode
	Specifies the optimization bias for the AO config and can be one of the following:
		Performance: Move more regions towards higher performance tier.
		Balanced:    Balanced between higher performance and lower cost.
		Cost:        Move more regions towards lower cost tier.
	The default is Balanced.
.PARAMETER T0min
	Specifies the minimum space utilization of the tier CPG for AO to maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T). Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.
.PARAMETER T1min
	Specifies the minimum space utilization of the tier CPG for AO to maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T). Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.
.PARAMETER T2min
	Specifies the minimum space utilization of the tier CPG for AO to maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T). Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.
.PARAMETER T0max
	Specifies the maximum space utilization of the tier CPG. AO will move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG. The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.
.PARAMETER T1max
	Specifies the maximum space utilization of the tier CPG. AO will move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG. The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.
.PARAMETER T2max
	Specifies the maximum space utilization of the tier CPG. AO will move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG. The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.
.PARAMETER AOConfigurationName
	Specifies an AO configuration name up to 31 characters in length.
#>
[CmdletBinding()]
 param(	[String]	$T0cpg,
		[String]	$T1cpg,
		[String]	$T2cpg,
		[ValidateSet('Performance','Cost','Balanced')]
		[String]	$Mode,
		[String]	$T0min,
		[String]	$T1min,
		[String]	$T2min,
		[String]	$T0max,
		[String]	$T1max,
		[String]	$T2max,
	[Parameter(Mandatory=$True)]
		[String]	$AOConfigurationName
 )
begin
{	Test-CLIConnectionB
}
Process
{	$Cmd = " createaocfg "
	if($T0cpg)	{	$Cmd += " -t0cpg $T0cpg " }
	if($T1cpg) 	{	$Cmd += " -t1cpg $T1cpg " }
	if($T2cpg) 	{	$Cmd += " -t2cpg $T2cpg " }
	if($Mode) 	{  	$Cmd += " -mode $Mode "   }
	if($T0min) 	{	$Cmd += " -t0min $T0min " }
	if($T1min) 	{	$Cmd += " -t1min $T1min " }
	if($T2min) 	{	$Cmd += " -t2min $T2min " }
	if($T0max) 	{	$Cmd += " -t0max $T0max " }
	if($T1max) 	{	$Cmd += " -t1max $T1max " }
	if($T2max) 	{	$Cmd += " -t2max $T2max " }
	if($AOConfigurationName) {	$Cmd += " $AOConfigurationName " }
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
	Return $Result
}
}

Function Remove-AOConfiguration()
{
<#
.SYNOPSIS
	Remove-AOConfiguration - Remove an Adaptive Optimization configuration.
.DESCRIPTION
	The Remove-AOConfiguration command removes specified Adaptive Optimization configurations from the system.
.PARAMETER Pattern
	Specifies that specified patterns are treated as glob-style patterns and that all AO configurations matching the specified pattern are removed.
.PARAMETER AOConfigurationName
	Specifies the name of the AO configuration to be removed
#>
[CmdletBinding()]
param(	[Parameter(ParameterSetName='Pattern',Mandatory)]	[String]	$Pattern,
		[Parameter(ParameterSetName='Config',Mandatory)]	[String]	$AOConfigurationName
)
Begin
{	Test-CLIConnectionB
}
Process
{	$Cmd = " removeaocfg -f "
	if($Pattern)				{	$Cmd += " -pat $Pattern "	}
	if($AOConfigurationName)	{	$Cmd += " $AOConfigurationName "	}
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
	Return $Result
}
}

Function Start-AO()
{
<#
.SYNOPSIS
	Start-AO - Start execution of an Adaptive Optimization configuration.
.DESCRIPTION
	The Start-AO command starts execution of an Adaptive Optimization (AO) configuration using data 
	region level performance data collected for the specified number of hours.
.EXAMPLE
	Start-AO -Btsecs 3h -AocfgName prodaocfg
	Start execution of AO config prodaocfg using data for the past 3 hours:
.EXAMPLE	
	Start-AO -Btsecs 12h -Etsecs 3h -Maxrunh 6 -AocfgName prodaocfg
	Start execution of AO config prodaocfg using data from 12 hours ago until
	3 hours ago, allowing up to 6 hours to complete:
.EXAMPLE
	Start-AO -Btsecs 3h -Vv "set:dbvvset" -AocfgName prodaocfg
	Start execution of AO for the vvset dbvvset in AOCFG prodaocfg using
    data for the past 3 hours:	
.PARAMETER Btsecs
    Select the begin time in seconds for the analysis period. The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the analysis begins 12 hours ago.
.PARAMETER Etsecs
	Select the end time in seconds for the analysis period.	The value can be specified as either
	- The absolute epoch time (for example 1351263600).
	- The absolute time as a text string in one of the following formats:
		- Full time string including time zone: "2012-10-26 11:00:00 PDT"
		- Full time string excluding time zone: "2012-10-26 11:00:00"
		- Date string: "2012-10-26" or 2012-10-26
		- Time string: "11:00:00" or 11:00:00
	- A negative number indicating the number of seconds before the current time. Instead of a number representing seconds, <secs> can
		be specified with a suffix of m, h or d to represent time in minutes (e.g. -30m), hours (e.g. -1.5h) or days (e.g. -7d).
	If it is not specified then the analysis ends with the most recent
	sample.
.PARAMETER Compact
	Specify if and how CPGs should be compacted. Choices for <mode> are 
	auto 	Automatically select the compactcpg mode (default).
	This will free up the most space but can potentially take longer because it may cause additional region moves to
	increase consolidation.  This is the default mode. In this mode, trimonly is run first to trim LDs without performing
	region moves, and then the full compactcpg is run if space is still needed.
	trimonly 	Only run compactcpg with the -trimonly option. This will to perform any region moves during compactcpg. 
	no       	Do not run compactcpg.  This option may be used if compactcpg is run or scheduled separately.
.PARAMETER Dryrun
	Do not execute the region moves, only show which moves would be done.
.PARAMETER Maxrunh
	Select the approximate maximum run time in hours (default is 6 hours). The number should be between 1 and 24 hours.
	The command will attempt to limit the amount of data to be moved so	the command can complete by the specified number of hours.  If the
	time runs beyond the specified hours, the command will abort at an appropriate time.
.PARAMETER Min_iops
	Do not execute the region moves if the average IOPS during the measurement interval is less than <min_iops>.  If the -vv option is not
	specified, the IOPS are for all the LDs in the AOCFG. If the -vv option is specified, the IOPS are for all the VLUNs that
	include matching VVs. If min_iops is not specified, the default value is 50.
.PARAMETER Mode
	Override the optimization bias of the AO config, for instance to control AO differently for different VVs. Can be one of the following:
	Performance: Move more regions towards higher performance tier.
	Balanced:    Balanced between higher performance and lower cost.
	Cost:        Move more regions towards lower cost tier.
.PARAMETER Vv
	Limit the analysis and data movement to VVs with names that match one or more of the specified names or glob-style patterns. VV set names
	must be prefixed by "set:".  Note that snapshot VVs will not be considered since only base VVs have region space. Each VV's
	user CPG must be part of the specified AOCFG in order to be optimized. Snapshots in a VV's tree will not be optimized.
.PARAMETER T0min
	Specifies the minimum space utilization of the tier CPG for AO to maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T). Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.   
.PARAMETER T1min
	Specifies the minimum space utilization of the tier CPG for AO to maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T). Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.   
.PARAMETER T2min
	Specifies the minimum space utilization of the tier CPG for AO to maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T). Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.
.PARAMETER T0max
	Specifies the maximum space utilization of the tier CPG. AO will move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG. The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.   
.PARAMETER T1max
	Specifies the maximum space utilization of the tier CPG. AO will move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG. The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.   
.PARAMETER T2max
	Specifies the maximum space utilization of the tier CPG. AO will move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG. The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.
.PARAMETER AocfgName
	The AO configuration name, using up to 31 characters.
#>
[CmdletBinding()]
param(
	[String]	$Btsecs,
	[String]	$Etsecs,
	[String]	$Compact,
	[switch]	$Dryrun,
	[String]	$Maxrunh,
	[String]	$Min_iops,
	[String]	$Mode,
	[String]	$Vv,
	[String]	$T0min,
	[String]	$T1min,
	[String]	$T2min,
	[String]	$T0max,
	[String]	$T1max,
	[String]	$T2max,
	[String]	$AocfgName
)
begin
{	Test-CLIConnectionB
}
Process
{	$Cmd = " startao "
	if($Btsecs) 	{	$Cmd += " -btsecs $Btsecs " }
	if($Etsecs)		{	$Cmd += " -etsecs $Etsecs " }
	if($Compact)	{	$Cmd += " -compact $Compact " }
	if($Dryrun)		{	$Cmd += " -dryrun " }
	if($Maxrunh) 	{	$Cmd += " -maxrunh $Maxrunh " }
	if($Min_iops) 	{	$Cmd += " -min_iops $Min_iops " }
	if($Mode)		{	$Cmd += " -mode $Mode "}
	if($Vv)			{	$Cmd += " -vv $Vv "}
	if($T0min)		{	$Cmd += " -t0min $T0min "}
	if($T1min)		{	$Cmd += " -t1min $T1min " }
	if($T2min)		{	$Cmd += " -t2min $T2min "}
	if($T0max)		{	$Cmd += " -t0max $T0max " }
	if($T1max) 		{	$Cmd += " -t1max $T1max " }
	if($T2max)		{	$Cmd += " -t2max $T2max " }
	if($AocfgName)	{	$Cmd += " $AocfgName " }
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
	Return $Result
}
}

Function Update-AOConfiguration()
{
<#
.SYNOPSIS
	Update-AOConfiguration - Update an Adaptive Optimization configuration.
.DESCRIPTION
	Update-AOConfiguration - Update an Adaptive Optimization configuration.
.PARAMETER T0cpg
	Specifies the Tier 0 CPG for this AO config.
.PARAMETER T1cpg
	Specifies the Tier 1 CPG for this AO config.
.PARAMETER T2cpg
	Specifies the Tier 2 CPG for this AO config.
.PARAMETER Mode
	Specifies the optimization bias for the AO config and can
	be one of the following:
		Performance: Move more regions towards higher performance tier.
		Balanced:    Balanced between higher performance and lower cost.
		Cost:        Move more regions towards lower cost tier.
.PARAMETER T0min
	Specifies the minimum space utilization of the tier CPG for AO to maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T). Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.
.PARAMETER T1min
	Specifies the minimum space utilization of the tier CPG for AO to maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T). Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.
.PARAMETER T2min
	Specifies the minimum space utilization of the tier CPG for AO to maintain when optimizing regions between tiers. The size can be
	specified in MB (default) or GB (using g or G) or TB (using t or T). Setting a minimum to 0 (default) indicates that no minimum space
	utilization will be enforced.
.PARAMETER T0max
	Specifies the maximum space utilization of the tier CPG. AO will move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG. The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.
.PARAMETER T1max
	Specifies the maximum space utilization of the tier CPG. AO will move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG. The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.
.PARAMETER T2max
	Specifies the maximum space utilization of the tier CPG. AO will move regions into and out of the CPG based on their relative access
	rate history, but will not exceed this maximum size in the CPG. The size can be specified in MB (default) or GB (using g or G) or
	TB (using t or T). Setting a max to 0 (default) indicates that AO will use other indicators to decide the maximum CPG space utilization:
	either the CPG sdgl, sdgw, or maximum possible growth size.
.PARAMETER NewName
	Specifies a new name for the AO configuration of up to 31 characters in length.
.PARAMETER AOConfigurationName
#>
[CmdletBinding()]
param(
		[String]	$T0cpg,
		[String]	$T1cpg,
		[String]	$T2cpg,
		[ValidateSet('Performance','Balanced','Cost')]
		[String]	$Mode,
		[String]	$T0min,
		[String]	$T1min,
		[String]	$T2min,
		[String]	$T0max,
		[String]	$T1max,
		[String]	$T2max,
		[String]	$NewName,
		[Parameter(Mandatory)]
		[String]	$AOConfigurationName
)
begin
{	Test-CLIConnectionB
}
Process
{	$Cmd = " setaocfg "
	if($T0cpg)	{	$Cmd += " -t0cpg $T0cpg "}
	if($T1cpg)	{	$Cmd += " -t1cpg $T1cpg " }
	if($T2cpg)	{	$Cmd += " -t2cpg $T2cpg " }
	if($Mode) 	{	$Cmd += " -mode $Mode " }
	if($T0min)	{	$Cmd += " -t0min $T0min " }
	if($T1min) 	{	$Cmd += " -t1min $T1min " }
	if($T2min) 	{	$Cmd += " -t2min $T2min " }
	if($T0max) 	{	$Cmd += " -t0max $T0max " }
	if($T1max)	{	$Cmd += " -t1max $T1max " }
	if($T2max)	{	$Cmd += " -t2max $T2max " }
	if($NewName){	$Cmd += " -name $NewName " }
	if($AOConfigurationName){	$Cmd += " $AOConfigurationName " }
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
	Return $Result
}
}
Export-ModuleMember New-AOConfiguration , Remove-AOConfiguration , Start-AO , Update-AOConfiguration