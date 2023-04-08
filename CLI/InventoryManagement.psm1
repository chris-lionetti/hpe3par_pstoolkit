####################################################################################
## 	© 2020,2021, 2023 Hewlett Packard Enterprise Development LP
##	Description: 	Inventory Management cmdlets 
##		
Function Get-Inventory
{
<#
.SYNOPSIS
	Get-Inventory - show hardware inventory
.DESCRIPTION
	Shows information about all the hardware components in the system.
.EXAMPLE
.PARAMETER Svc
	Displays inventory information with HPE serial number, spare part number, and so on. It is not supported on HPE 3PAR 10000 systems.
#>
[CmdletBinding()]
param(	[switch]	$Svc
	)
begin
{	Test-CLIConnectionB
}
Process
{	$Cmd = " showinventory "
	if($Svc)	{	$Cmd += " -svc "	}
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
	Return $Result
} 
}

Export-ModuleMember Get-Inventory