####################################################################################
## 	© 2020,2021,2023 Hewlett Packard Enterprise Development LP
##
##	Description: 	Module functions to automate management of HPE 3PAR StoreServ Storage System
##		
##	Pre-requisites: WSAPI uses HPE 3PAR CLI commands to start, configure, and modify the WSAPI server.
##					For more information about using the CLI, see:
##					• HPE 3PAR Command Line Interface Administrator Guide
##					• HPE 3PAR Command Line Interface Reference
##
##					Starting the WSAPI server    : The WSAPI server does not start automatically.
##					Using the CLI, enter startwsapi to manually start the WSAPI server.
## 					Configuring the WSAPI server: To configure WSAPI, enter setwsapi in the CLI.
##
##	Created:		May 2018
##	Last Modified:	January 2019
##	
##	History:		v2.2 - WSAPI (v1.6.3) support for the following:
##							CRUD operations on CPG, Volume, host, host sets, VV sets, VLUN, FPG/VFS/File Shares, Remote Copy Group etc.
##							Querying and filtering system events and tasks
##							Configuring and querying ports
##							Querying system capacity
##							Creating physical copy of volume/VV set and re-synchronizing 
##							SR reports - Statistical data reports for CPG, PD, ports, VLUN, QoS & Remote Copy volumes etc.
##							Querying WSAPI users and roles								
##								
#######################################################################################

$Info = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
$global:ArrayT = $null
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

add-type @" 
	public struct WSAPIconObject{	public string Id;
									public string Name;
									public string SystemVersion;
									public string Patches;
									public string IPAddress;
									public string Model;
									public string SerialNumber;
									public string TotalCapacityMiB;
									public string AllocatedCapacityMiB;
									public string FreeCapacityMiB;
									public string Key;
}

"@

Function Add-DiskType
{
<#
.SYNOPSIS
    find and add disk type to temp variable.
.DESCRIPTION
    find and add disk type to temp variable. 
.EXAMPLE
    Add-DiskType -Dt $td
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true)]
		[String]	$DT
	)
Begin 
{	Test-3PARConnection -WsapiConnection $WsapiConnection
}
Process 
{		$lista = $DT.split(",")		
		$count = 1
		[string]$DTyp
		foreach($sub in $lista)
		{	$val_Fix = "FC","NL","SSD","SCM"
			$val_Input =$sub
			if($val_Fix -eq $val_Input)
			{	if($val_Input.ToUpper() -eq "FC")	{	$DTyp = $DTyp + "1"	}
				if($val_Input.ToUpper() -eq "NL")	{	$DTyp = $DTyp + "2"	}
				if($val_Input.ToUpper() -eq "SSD")	{	$DTyp = $DTyp + "3"	}
				if($val_Input.ToUpper() -eq "SCM")	{	$DTyp = $DTyp + "4"	}
				if($lista.Count -gt 1)
				{	if($lista.Count -ne $count)
					{	$DTyp = $DTyp + ","
						$count = $count + 1
					}				
				}
			}
			else
			{ 	Write-DebugLog "Stop: Exiting Since -DiskType $DT in incorrect "
				Return "FAILURE : -DiskType :- $DT is an Incorrect, Please Use [ FC | NL | SSD | SCM] only ."
			}						
		}
		return $DTyp.Trim()		
}
}

Function Add-RedType
{
<#
.SYNOPSIS
    find and add Red type to temp variable.
.DESCRIPTION
    find and add Red type to temp variable. 
.EXAMPLE
    Add-RedType -RT $td
#>
[CmdletBinding()]
param(
		[Parameter(Mandatory=$true)]	[String]	$RT
)
Begin 
{	Test-3PARConnection -WsapiConnection $WsapiConnection
}
Process 
{
		$lista = $RT.split(",")		
		$count = 1
		[string]$RType
		foreach($sub in $lista)
		{
			$val_Fix = "R0","R1","R5","R6"
			$val_Input =$sub
			if($val_Fix -eq $val_Input)
			{
				if($val_Input.ToUpper() -eq "R0")
				{
					$RType = $RType + "1"
				}
				if($val_Input.ToUpper() -eq "R1")
				{
					$RType = $RType + "2"
				}
				if($val_Input.ToUpper() -eq "R5")
				{
					$RType = $RType + "3"
				}
				if($val_Input.ToUpper() -eq "R6")
				{
					$RType = $RType + "4"
				}
				if($lista.Count -gt 1)
				{
					if($lista.Count -ne $count)
					{					
						$RType = $RType + ","
						$count = $count + 1
					}				
				}
			}
			else
			{ 
				Write-DebugLog "Stop: Exiting Since -RedType $RT in incorrect "
				Return "FAILURE : -RedType :- $RT is an Incorrect, Please Use [ R0 | R1 | R5 | R6 ] only ."
			}						
		}
		return $RType.Trim()		
	}
}
