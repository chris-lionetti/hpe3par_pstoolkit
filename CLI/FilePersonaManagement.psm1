####################################################################################
## 	© 2020,2021, 2023 Hewlett Packard Enterprise Development LP
##	Description: 	File Persona Management cmdlets 
##		
Function Start-FSNDMP
{
<#
.SYNOPSIS   
	The Start-FSNDMP command is used to start both NDMP service and ISCSI service. 
.DESCRIPTION  
	The Start-FSNDMP command is used to start both NDMP service and ISCSI service.
.EXAMPLE	
	Start-FSNDMP
#>
[CmdletBinding()]
param()
Begin
{	Test-CLIConnectionB
}
Process
{	$cmd= "startfsndmp "	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
	Return $Result
}
}

Function Stop-FSNDMP
{
<#
.SYNOPSIS   
	The Stop-FSNDMP command is used to stop both NDMP service and ISCSI service.
.DESCRIPTION  
	The Stop-FSNDMP command is used to stop both NDMP service and ISCSI service.
.EXAMPLE	
	Stop-FSNDMP	
#>
[CmdletBinding()]
param()
Begin
{	Test-CLIConnectionB
}	
Process 
{	$cmd= "stopfsndmp "
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
	return $Result
}	
} 

Export-ModuleMember Start-FSNDMP , Stop-FSNDMP