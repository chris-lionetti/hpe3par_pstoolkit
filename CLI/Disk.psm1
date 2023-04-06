####################################################################################
## 	© 2020,2021,2023 Hewlett Packard Enterprise Development LP

Function Set-AdmitsPD
{
<#
.SYNOPSIS
    The Set-AdmitsPD command creates and admits physical disk definitions to enable the use of those disks.
.DESCRIPTION
    The Set-AdmitsPD command creates and admits physical disk definitions to enable the use of those disks.
.EXAMPLE
	PS:> Set-AdmitsPD 

	This example admits physical disks.
.EXAMPLE
	PS:> Set-AdmitsPD -Nold

	Do not use the PD (as identified by the <world_wide_name> specifier) For logical disk allocation.
.EXAMPLE
	PS:> Set-AdmitsPD -NoPatch

	Suppresses the check for drive table update packages for new hardware enablement.
.EXAMPLE  	
	PS:> Set-AdmitsPD -Nold -wwn xyz

	Do not use the PD (as identified by the <world_wide_name> specifier) For logical disk allocation.
.PARAMETER Nold
	Do not use the PD (as identified by the <world_wide_name> specifier) for logical disk allocation.
.PARAMETER Nopatch
	Suppresses the check for drive table update packages for new hardware enablement.
.PARAMETER wwn
	Indicates the World-Wide Name (WWN) of the physical disk to be admitted. If WWNs are specified, only the specified physical disk(s) are admitted.	
#>
[CmdletBinding()]
param(	[switch]	$Nold,
		[switch]	$NoPatch,
		[String]	$wwn
	)	
begin
{	Test-CLIConnection
}	
Process
{	$cmd= "admitpd -f  "
	if ($Nold)		{	$cmd+=" -nold "		}	
	if ($NoPatch)	{	$cmd+=" -nopatch "	}
	if($wwn)		{	$cmd += " $wwn"		}
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
	return 	$Result	
}
}

Function Show-PD
{
<#
.SYNOPSIS
	The Show-PD command displays configuration information about the physical disks (PDs) on a system. 
.DESCRIPTION
	The Show-PD command displays configuration information about the physical disks (PDs) on a system. 
.EXAMPLE  
	Show-PD
	This example displays configuration information about all the physical disks (PDs) on a system. 
.EXAMPLE  
	Show-PD -PD_ID 5
	This example displays configuration information about specific or given physical disks (PDs) on a system. 
.EXAMPLE  
	Show-PD -C 
	This example displays chunklet use information for all disks. 
.EXAMPLE  
	Show-PD -C -PD_ID 5
	This example will display chunklet use information for all disks with the physical disk ID. 
.EXAMPLE  
	Show-PD -Node 0 -PD_ID 5
.EXAMPLE  
	Show-PD -I -Pattern -ND 1 -PD_ID 5
.EXAMPLE
	Show-PD -C -Pattern -Devtype FC  	
.EXAMPLE  
	Show-PD -option p -pattern mg -patternValue 0
	This example will display all the FC disks in magazine 0 of all cages.
.PARAMETER Listcols
	List the columns available to be shown in the -showcols option described below (see 'clihelp -col showpd' for help on each column).
.PARAMETER I
	Show disk inventory (inquiry) data.

	The following columns are shown:
	Id CagePos State Node_WWN MFR Model Serial FW_Rev Protocol MediaType AdmissionTime.
.PARAMETER E
	Show disk environment and error information. Note that reading this information places a significant load on each disk.
	The following columns are shown: Id CagePos Type State Rd_CErr Rd_UErr Wr_CErr Wr_UErr Temp_DegC LifeLeft_PCT.
.PARAMETER C
	Show chunklet usage information. Any chunklet in a failed disk will be shown as "Fail".

	The following columns are shown:
	Id CagePos Type State Total_Chunk Nrm_Used_OK Nrm_Used_Fail Nrm_Unused_Free Nrm_Unused_Uninit Nrm_Unused_Unavail Nrm_Unused_Fail
	Spr_Used_OK Spr_Used_Fail Spr_Unused_Free Spr_Unused_Uninit Spr_Unused_Fail.
.PARAMETER S
	Show detailed state information.
	This option is deprecated and will be removed in a subsequent release.
.PARAMETER State
	Show detailed state information. This is the same as -s.

	The following columns are shown:
	Id CagePos Type State Detailed_State SedState.
.PARAMETER Path
	Show current and saved path information for disks.

	The following columns are shown:
	Id CagePos Type State Path_A0 Path_A1 Path_B0 Path_B1 Order.
.PARAMETER Space
	Show disk capacity usage information (in MB).
	The following columns are shown:
	Id CagePos Type State Size_MB Volume_MB Spare_MB Free_MB Unavail_MB Failed_MB.
.PARAMETER Failed
	Specifies that only failed physical disks are displayed.
.PARAMETER Degraded
	Specifies that only degraded physical disks are displayed. If both -failed and -degraded are specified, 
	the command shows failed disks and degraded disks.
.PARAMETER Pattern
	Physical disks matching the specified pattern are displayed.
.PARAMETER ND
	Specifies one or more nodes. Nodes are identified by one or more integers (item). Multiple nodes are separated with a single comma
	(e.g. 1,2,3). A range of nodes is separated with a hyphen (e.g. 0-7). The primary path of the disks must be on the specified node(s).
.PARAMETER ST
	Specifies one or more PCI slots. Slots are identified by one or more integers (item). Multiple slots are separated with a single comma
	(e.g. 1,2,3). A range of slots is separated with a hyphen (e.g. 0-7). The primary path of the disks must be on the specified PCI slot(s).
.PARAMETER PT
	Specifies one or more ports. Ports are identified by one or more integers (item). Multiple ports are separated with a single comma
	(e.g. 1,2,3). A range of ports is separated with a hyphen (e.g. 0-4). The primary path of the disks must be on the specified port(s).
.PARAMETER CG
	Specifies one or more drive cages. Drive cages are identified by one or more integers (item). Multiple drive cages are separated with a
	single comma (e.g. 1,2,3). A range of drive cages is separated with a hyphen (e.g. 0-3). The specified drive cage(s) must contain disks.
.PARAMETER MG
	Specifies one or more drive magazines. The "1." or "0." displayed in the CagePos column of showpd output indicating the side of the
	cage is omitted when using the -mg option. Drive magazines are identified by one or more integers (item). Multiple drive magazines
	are separated with a single comma (e.g. 1,2,3). A range of drive magazines is separated with a hyphen(e.g. 0-7). The specified drive
	magazine(s) must contain disks.
.PARAMETER PN
	Specifies one or more disk positions within a drive magazine. Disk positions are identified by one or more integers (item). Multiple
	disk positions are separated with a single comma(e.g. 1,2,3). A range of disk positions is separated with a hyphen(e.g. 0-3). The
	specified position(s) must contain disks.
.PARAMETER DK
	Specifies one or more physical disks. Disks are identified by one or more integers(item). Multiple disks are separated with a single
	comma (e.g. 1,2,3). A range of disks is separated with a hyphen(e.g. 0-3).  Disks must match the specified ID(s).
.PARAMETER Devtype
	Specifies that physical disks must have the specified device type (FC for Fast Class, NL for Nearline, SSD for Solid State Drive)
	to be used. Device types can be displayed by issuing the "showpd" command.
.PARAMETER RPM
	Drives must be of the specified relative performance metric, as shown in the "RPM" column of the "showpd" command.
	The number does not represent a rotational speed for the drives without spinning media (SSD). It is meant as a rough estimation of
	the performance difference between the drive and the other drives in the system.  For FC and NL drives, the number corresponds to
	both a performance measure and actual rotational speed. For SSD drives, the number is to be treated as a relative performance
	benchmark that takes into account I/O's per second, bandwidth and access time.
.PARAMETER Node
	Specifies that the display is limited to specified nodes and physical disks connected to those nodes. The node list is specified as a series
	of integers separated by commas (e.g. 1,2,3). The list can also consist of a single integer. If the node list is not specified, all disks on all
	nodes are displayed.
.PARAMETER Slots
	Specifies that the display is limited to specified PCI slots and physical disks connected to those PCI slots. The slot list is specified
	as a series of integers separated by commas (e.g. 1,2,3). The list can also consist of a single integer. If the slot list is not specified, all
	disks on all slots are displayed.
.PARAMETER Ports
	Specifies that the display is limited to specified ports and physical disks connected to those ports. The port list is specified
	as a series of integers separated by commas (e.g. 1,2,3). The list can also consist of a single integer. If the port list is not specified, all
	disks on all ports are displayed.
.PARAMETER WWN
	Specifies the WWN of the physical disk. This option and argument can be specified if the <PD_ID> specifier is not used. This option should be
	the last option in the command line.
#>
[CmdletBinding()]
param(	[switch]	$I,
		[switch]	$E,
		[switch]	$C,
		[switch]	$StateInfo,
		[switch]	$State,
		[switch]	$Path,
		[switch]	$Space,
		[switch]	$Failed,
		[switch]	$Degraded,
		[String]	$Node ,
		[String]	$Slots ,
		[String]	$Ports ,
		[String]	$WWN ,
		[switch]	$Pattern,
		[String]	$ND ,
		[String]	$ST ,
		[String]	$PT ,
		[String]	$CG ,
		[String]	$MG ,
		[String]	$PN ,
		[String]	$DK ,
		[String]	$Devtype ,
		[String]	$RPM ,
		[String]	$PD_ID ,
		[switch]	$Listcols,
		[switch]	$ReturnRawResult
	)
begin
{	Test-CLIConnectionB
}		
Process
{	$cmd= "showpd "	
	if($Listcols)	{	$cmd+=" -listcols "
						$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
						$ReturnObject = New-PWSHObjectFromCLIOutput $Result
						return $ReturnObject
	}
	if($I)		{	$cmd+=" -i "	}
	if($E)		{	$cmd+=" -e "	}
	if($C)		{	$cmd+=" -c "	}
	if($StateInfo){	$cmd+=" -s "	}
	if($State)	{	$cmd+=" -state "	}
	if($Path)	{	$cmd+=" -path "	}
	if($Space)	{	$cmd+=" -space "	}
	if($Failed)	{	$cmd+=" -failed "	}
	if($Degraded){	$cmd+=" -degraded "	}
	if($Node)	{	$cmd+=" -nodes $Node "	}
	if($Slots)	{	$cmd+=" -slots $Slots "	}
	if($Ports)	{	$cmd+=" -ports $Ports "	}
	if($WWN)	{	$cmd+=" -w $WWN "	}
	if($Pattern){
		if($ND)	{	$cmd+=" -p -nd $ND " }
		if($ST)	{	$cmd+=" -p -st $ST " }
		if($PT) {	$cmd+=" -p -pt $PT " }
		if($CG)	{	$cmd+=" -p -cg $CG " }
		if($MG)	{	$cmd+=" -p -mg $MG " }
		if($PN) {	$cmd+=" -p -pn $PN " }
		if($DK)	{	$cmd+=" -p -dk $DK " }
		if($Devtype){	$cmd+=" -p -devtype $Devtype " }
		if($RPM){	$cmd+=" -p -rpm $RPM "	}
				}		
	if ($PD_ID)
		{	$PD=$PD_ID		
			$pdd="showpd $PD"
			$Result1 = Invoke-CLICommand -Connection $SANConnection -cmds  $pdd	
			if($Result1 -match "No PDs listed" )
				{	Write-DebugLog "Stop: Exiting Show-PD  since  -PD_ID $PD_ID is not available "
					return " FAILURE : $PD_ID is not available id pLease try using only [Show-PD] to get the list of PD_ID Available. "			
				}
			else 	
				{	$cmd+=" $PD_ID "
				}
		}
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
	$ReturnObject = New-PWSHObjectFromCLIOutput $Result
	if($Result.Count -gt 1)
	{	if ( $ReturnRawResult )
		{	return $result 
		}
		else
		{ 	write-host "Success : Command Show-PD execute Successfully."
			return $ReturnObject
		}
	}
	else
	{	return $Result		
	} 	
} 
}

Function Remove-PD()
{
<#
  .SYNOPSIS
   Remove-PD - Remove a physical disk (PD) from system use.

  .DESCRIPTION
   The Remove-PD command removes PD definitions from system use.

  .EXAMPLE
	The following example removes a PD with ID 1:
	Remove-PD -PDID 1
   
  .PARAMETER PDID
	Specifies the PD(s), identified by integers, to be removed from system use.

  .Notes
    NAME: Remove-PD
    LASTEDIT 30/10/2019
    KEYWORDS: Remove-PD
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$True)]
	[String]
	$PDID,

	[Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Remove-PD - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" " ERR: "
			Write-DebugLog "Stop: Exiting Remove-PD since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Remove-PD since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
	write-debuglog "$plinkresult"
	Return $plinkresult
 }

	$Cmd = " dismisspd "

 if($PDID)
 {
	$Cmd += " $PDID "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing function : Remove-PD command -->" INFO: 
 
 Return $Result
} 

Function Set-PD
{
<#
  .SYNOPSIS
   The Set-PD command marks a Physical Disk (PD) as allocatable or non allocatable for Logical   Disks (LDs).
   
  .DESCRIPTION
   The Set-PD command marks a Physical Disk (PD) as allocatable or non allocatable for Logical   Disks (LDs).   
	
  .EXAMPLE
	Set-PD -Ldalloc off -PD_ID 20	
	displays PD 20 marked as non allocatable for LDs.
   
  .EXAMPLE  
	Set-PD -Ldalloc on -PD_ID 25	
	displays PD 25 marked as allocatable for LDs.
   		
  .PARAMETER ldalloc 
	Specifies that the PD, as indicated with the PD_ID specifier, is either allocatable (on) or nonallocatable for LDs (off).
  	
  .PARAMETER PD_ID 
	Specifies the PD identification using an integer.	
     
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Set-PD
    LASTEDIT: 30/10/2019
    KEYWORDS: Set-PD
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false)]
		[String]
		$Ldalloc,
		
		[Parameter(Position=1, Mandatory=$true,ValueFromPipeline=$true)]
		[String]
		$PD_ID,
			
		[Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection        
	)		
	
	Write-DebugLog "Start: In Set-PD   - validating input values" $Debug 
	#check if connection object contents are null/empty
	if(!$SANConnection)
	{				
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Set-PD since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Set-PD since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}		
	$cmd= "setpd "	
	if ($Ldalloc)
	{
		$a = "on","off"
		$l=$Ldalloc
		if($a -eq $l)
		{
			$cmd+=" ldalloc $Ldalloc "	
		}
		else
		{ 
			Write-DebugLog "Stop: Exiting Set-PD  since -Ldalloc in incorrect "
			return "FAILURE : -Ldalloc $Ldalloc cannot be used only [on|off] can be used . "
		}
	}
	else
	{
		Write-DebugLog "Stop: Ldalloc is mandatory" $Debug
		return "Error :  -Ldalloc is mandatory. "		
	}		
	if ($PD_ID)
	{
		$PD=$PD_ID
		if($PD -gt 4095)
		{ 
			Write-DebugLog "Stop: Exiting Set-PD  since  -PD_ID $PD_ID Illegal integer argument "
			return "FAILURE : -PD_ID $PD_ID Illegal integer argument . Expected range [0-4095].  "
		}
		$cmd+=" $PD_ID "
	}
	else
	{
		Write-DebugLog "Stop: PD_ID is mandatory" $Debug
		return "Error :  -PD_ID is mandatory. "		
	}		
	if ($cmd -eq "setpd ")
	{
		Write-DebugLog "FAILURE : Set-PD Should be used with Parameters, No parameters passed."
		return get-help  Set-PD 
	}	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
	
	write-debuglog "  Executing Set-PD Physical Disk (PD) as allocatable or non allocatable for Logical Disks (LDs). with the command  " "INFO:" 
	if([string]::IsNullOrEmpty($Result))
	{
		return  "Success : Executing Set-PD  $Result"
	}
	else
	{
		return  "FAILURE : While Executing Set-PD $Result "
	} 	
}

Function Switch-PD()
{
<#
  .SYNOPSIS
   Switch-PD - Spin up or down a physical disk (PD).

  .DESCRIPTION
   The Switch-PD command spins a PD up or down. This command is used when
   replacing a PD in a drive magazine.

  .EXAMPLE
	The following example instigates the spin up of a PD identified by its
	WWN of 2000000087002078:
	Switch-PD -Spinup -WWN 2000000087002078
  
  .PARAMETER Spinup
	Specifies that the PD is to spin up. If this subcommand is not used,
	then the spindown subcommand must be used.
  
  .PARAMETER Spindown
	Specifies that the PD is to spin down. If this subcommand is not used,
	then the spinup subcommand must be used.

  .PARAMETER Ovrd
   Specifies that the operation is forced, even if the PD is in use.

   
  .PARAMETER WWN
	Specifies the World Wide Name of the PD. This specifier can be repeated
	to identify multiple PDs.
   
  .Notes
    NAME: Switch-PD
    LASTEDIT 30/10/2019
    KEYWORDS: Switch-PD
  
  .Link
    http://www.hpe.com

 #Requires PS -Version 3.0
#>
[CmdletBinding()]
 param(
	[Parameter(Position=0, Mandatory=$false)]
	[switch]
	$Spinup,

	[Parameter(Position=1, Mandatory=$false)]
	[switch]
	$Spindown,
 
	[Parameter(Position=2, Mandatory=$false)]
	[switch]
	$Ovrd,	

	[Parameter(Position=3, Mandatory=$True)]
	[String]
	$WWN,

	[Parameter(Position=4, Mandatory=$false, ValueFromPipeline=$true)]
	$SANConnection = $global:SANConnection
 )

 Write-DebugLog "Start: In Switch-PD - validating input values" $Debug 
 #check if connection object contents are null/empty
 if(!$SANConnection)
 {
	#check if connection object contents are null/empty
	$Validate1 = Test-CLIConnection $SANConnection
	if($Validate1 -eq "Failed")
	{
		#check if global connection object contents are null/empty
		$Validate2 = Test-CLIConnection $global:SANConnection
		if($Validate2 -eq "Failed")
		{
			Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" " ERR: "
			Write-DebugLog "Stop: Exiting Switch-PD since SAN connection object values are null/empty" $Debug 
			Return "Unable to execute the cmdlet Switch-PD since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
		}
	}
 }

 $plinkresult = Test-PARCli -SANConnection $SANConnection
 if($plinkresult -match "FAILURE :")
 {
   write-debuglog "$plinkresult"
   Return $plinkresult
 }

 $Cmd = " controlpd "

 if($Spinup)
 {
	$Cmd += " spinup "
 }
 elseif($Spindown)
 {
	$Cmd += " spindown "
 }
 else
 {
	Return "Select at least one from [ Spinup | Spindown ]"
 }

 if($Ovrd)
 {
	$Cmd += " -ovrd "
 }

 if($WWN)
 {
	$Cmd += " $WWN "
 }

 $Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
 Write-DebugLog "Executing function : Switch-PD command -->" INFO: 
 
 Return $Result
}

Function Test-PD
{
<#
  .SYNOPSIS
    The Test-PD command executes surface scans or diagnostics on physical disks.
	
  .DESCRIPTION
    The Test-PD command executes surface scans or diagnostics on physical disks.	
	
  .EXAMPLE
	Test-PD -specifier scrub -ch 500 -pd_ID 1
	This example Test-PD chunklet 500 on physical disk 1 is scanned for media defects.
   
  .EXAMPLE  
	Test-PD -specifier scrub -count 150 -pd_ID 1
	This example scans a number of chunklets starting from -ch 150 on physical disk 1.
   
  .EXAMPLE  
	Test-PD -specifier diag -path a -pd_ID 5
	This example Specifies a physical disk path as a,physical disk 5 is scanned for media defects.
		
  .EXAMPLE  	
	Test-PD -specifier diag -iosize 1s -pd_ID 3
	This example Specifies I/O size 1s, physical disk 3 is scanned for media defects.
	
  .EXAMPLE  	
	Test-PD -specifier diag -range 5m  -pd_ID 3
	This example Limits diagnostic to range 5m [mb] physical disk 3 is scanned for media defects.
		
  .PARAMETER specifier	
	scrub - Scans one or more chunklets for media defects.
	diag - Performs read, write, or verifies test diagnostics.
  
  .PARAMETER ch
	To scan a specific chunklet rather than the entire disk.
  
  .PARAMETER count
	To scan a number of chunklets starting from -ch.
  
  .PARAMETER path
	Specifies a physical disk path as [a|b|both|system].
  
  .PARAMETER test
	Specifies [read|write|verify] test diagnostics. If no type is specified, the default is read .

  .PARAMETER iosize
	Specifies I/O size, valid ranges are from 1s to 1m. If no size is specified, the default is 128k .
	 
  .PARAMETER range
	Limits diagnostic regions to a specified size, from 2m to 2g.
	
  .PARAMETER pd_ID
	The ID of the physical disk to be checked. Only one pd_ID can be specified for the “scrub” test.
	
  .PARAMETER threads
	Specifies number of I/O threads, valid ranges are from 1 to 4. If the number of threads is not specified, the default is 1.
	
  .PARAMETER time
	Indicates the number of seconds to run, from 1 to 36000.
	
  .PARAMETER total
	Indicates total bytes to transfer per disk. If a size is not specified, the default size is 1g.
	
  .PARAMETER retry
	 Specifies the total number of retries on an I/O error.
	
  .PARAMETER SANConnection 
    Specify the SAN Connection object created with New-CLIConnection or New-PoshSshConnection
	
  .Notes
    NAME:  Test-PD
    LASTEDIT: 30/10/2019
    KEYWORDS: Test-PD
   
  .Link
     http://www.hpe.com
 
 #Requires PS -Version 3.0

 #>
[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$false,ValueFromPipeline=$true)]
		[String]
		$specifier,
		
		[Parameter(Position=1, Mandatory=$false,ValueFromPipeline=$true)]
		[String]
		$ch,
		
		[Parameter(Position=2, Mandatory=$false,ValueFromPipeline=$true)]
		[String]
		$count,
		
		[Parameter(Position=3, Mandatory=$false,ValueFromPipeline=$true)]
		[String]
		$path,
		
		[Parameter(Position=4, Mandatory=$false,ValueFromPipeline=$true)]
		[String]
		$test,
		
		[Parameter(Position=5, Mandatory=$false,ValueFromPipeline=$true)]
		[String]
		$iosize,
		
		[Parameter(Position=6, Mandatory=$false,ValueFromPipeline=$true)]
		[String]
		$range,
		
		[Parameter(Position=7, Mandatory=$false,ValueFromPipeline=$true)]
		[String]
		$threads,
		
		[Parameter(Position=8, Mandatory=$false,ValueFromPipeline=$true)]
		[String]
		$time,
		
		[Parameter(Position=9, Mandatory=$false,ValueFromPipeline=$true)]
		[String]
		$total,
		
		[Parameter(Position=10, Mandatory=$false,ValueFromPipeline=$true)]
		[String]
		$retry,
		
		[Parameter(Position=11, Mandatory=$false,ValueFromPipeline=$true)]
		[String]
		$pd_ID,
		
		[Parameter(Position=12, Mandatory=$false, ValueFromPipeline=$true)]
        $SANConnection = $global:SANConnection 
       
	)		
	
	Write-DebugLog "Start: In Test-PD   - validating input values" $Debug 
	#check if connection object contents are null/empty
	if(!$SANConnection)
	{				
		#check if connection object contents are null/empty
		$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{
			#check if global connection object contents are null/empty
			$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{
				Write-DebugLog "Connection object is null/empty or the array address (FQDN/IP Address) or user credentials in the connection object are either null or incorrect.  Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-DebugLog "Stop: Exiting Test-PD since SAN connection object values are null/empty" $Debug
				return "Unable to execute the cmdlet Test-PD since no active storage connection session exists. `nUse New-PoshSSHConnection or New-CLIConnection to start a new storage connection session."
			}
		}
	}
	$plinkresult = Test-PARCli
	if($plinkresult -match "FAILURE :")
	{
		write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}		
	$cmd= "checkpd "	
	if ($specifier)
	{
		$spe = $specifier
		$demo = "scrub" , "diag"
		if($demo -eq $spe)
		{
			$cmd+=" $spe "
		}
		else
		{
			return " FAILURE : $spe is not a Valid specifier please use [scrub | diag] only.  "
		}
	}
	else
	{
		return " FAILURE :  -specifier is mandatory for Test-PD to execute  "
	}		
	if ($ch)
	{
		$a=$ch
		[int]$b=$a
		if($a -eq $b)
		{
			if($cmd -match "scrub")
			{
				$cmd +=" -ch $ch "
			}
			else
			{
				return "FAILURE : -ch $ch cannot be used with -Specification diag "
			}
		}	
		else
		{
			Return "Error :  -ch $ch Only Integers are Accepted "
	
		}
	}	
	if ($count)
	{
		$a=$count
		[int]$b=$a
		if($a -eq $b)
		{	
			if($cmd -match "scrub")
			{
				$cmd +=" -count $count "
			}
			else
			{
				return "FAILURE : -count $count cannot be used with -Specification diag "
			}
		}
		else
		{
			Return "Error :  -count $count Only Integers are Accepted "	
		}
	}		
	if ($path)
	{
		if($cmd -match "diag")
		{
			$a = $path
			$b = "a","b","both","system"
			if($b -match $a)
			{
				$cmd +=" -path $path "
			}
			else
			{
				return "FAILURE : -path $path is invalid use [a | b | both | system ] only  "
			}
		}
		else
		{
			return " FAILURE : -path $path cannot be used with -Specification scrub "
		}
	}		
	if ($test)
	{
		if($cmd -match "diag")
		{
			$a = $test 
			$b = "read","write","verify"
			if($b -eq $a)
			{
				$cmd +=" -test $test "
			}
			else
			{
				return "FAILURE : -test $test is invalid use [ read | write | verify ] only  "
			}
		}
		else
		{
			return " FAILURE : -test $test cannot be used with -Specification scrub "
		}
	}			
	if ($iosize)
	{	
		if($cmd -match "diag")
		{
			$cmd +=" -iosize $iosize "
		}
		else
		{
			return "FAILURE : -test $test cannot be used with -Specification scrub "
		}
	}			 
	if ($range )
	{
		if($cmd -match "diag")
		{
			$cmd +=" -range $range "
		}
		else
		{
			return "FAILURE : -range $range cannot be used with -Specification scrub "
		}
	}	
	if ($threads )
	{
		if($cmd -match "diag")
		{
			$cmd +=" -threads $threads "
		}
		else
		{
			return "FAILURE : -threads $threads cannot be used with -Specification scrub "
		}
	}
	if ($time )
	{
		if($cmd -match "diag")
		{
			$cmd +=" -time $time "
		}
		else
		{
			return "FAILURE : -time $time cannot be used with -Specification scrub "
		}
	}
	if ($total )
	{
		if($cmd -match "diag")
		{
			$cmd +=" -total $total "
		}
		else
		{
			return "FAILURE : -total $total cannot be used with -Specification scrub "
		}
	}
	if ($retry )
	{
		if($cmd -match "diag")
		{
			$cmd +=" -retry $retry "
		}
		else
		{
			return "FAILURE : -retry $retry cannot be used with -Specification scrub "
		}
	}
	if($pd_ID)
	{	
		$cmd += " $pd_ID "
	}
	else
	{
		return " FAILURE :  pd_ID is mandatory for Test-PD to execute  "
	}	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd	
	write-debuglog "  Executing surface scans or diagnostics on physical disks with the command  " "INFO:" 
	return $Result	
}

Export-ModuleMember Set-AdmitsPD , Show-PD , Remove-PD , Set-PD , Switch-PD , Test-PD