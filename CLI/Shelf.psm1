####################################################################################
## 	© 2020,2021, 2023 Hewlett Packard Enterprise Development LP
##	Description: 	Disk Enclosure Management cmdlets 
##

Function Find-Cage
{
<#
.SYNOPSIS
	The Find-Cage command allows system administrators to locate a drive cage, drive magazine, or port in the system using the devices’ blinking LEDs.
.DESCRIPTION
	The Find-Cage command allows system administrators to locate a drive cage, drive magazine, or port in the system using the devices’ blinking LEDs. 
.EXAMPLE
	PS:> Find-Cage -Time 30 -CageName cage0	
	
	This example causes the Fibre Channel LEDs on the drive CageName cage0 to blink for 30 seconds.
.EXAMPLE  
	PS:> Find-Cage -Time 30 -CageName cage0 -mag 3	
	
	This example causes the Fibre Channel LEDs on the drive CageName cage0 to blink for 30 seconds,Indicates the drive magazine by number 3.
.EXAMPLE  
	PS:> Find-Cage -Time 30 -CageName cage0 -PortName demo1	
	
	This example causes the Fibre Channel LEDs on the drive CageName cage0 to blink for 30 seconds, If a port is specified, the port LED will oscillate between green and off.
.EXAMPLE  	
	PS:> Find-Cage -CageName cage1 -Mag 2	
	
	This example causes the Fibre Channel LEDs on the drive CageName cage1 to blink, Indicates the drive magazine by number 2.	
.PARAMETER Time 
	Specifies the number of seconds, from 0 through 255 seconds, to blink the LED. 
	If the argument is not specified, the option defaults to 60 seconds.
.PARAMETER CageName 
	Specifies the drive cage name as shown in the Name column of Get-Cage command output.
.PARAMETER ModuleName
	Indicates the module name to locate. Accepted values are
	pcm|iom|drive. The iom specifier is not supported for node enclosures.
.PARAMETER ModuleNumber
	Indicates the module number to locate. The cage and module number can be found
	by issuing showcage -d <cage_name>.
.PARAMETER Mag 
	Indicates the drive magazine by number.
	• For DC1 drive cages, accepted values are 0 through 4.
	• For DC2 and DC4 drive cages, accepted values are 0 through 9.
	• For DC3 drive cages, accepted values are 0 through 15.
.PARAMETER PortName  
	Indicates the port specifiers. Accepted values are A0|B0|A1|B1|A2|B2|A3|B3. If a port is specified, the port LED will oscillate between green and off.
#>
[CmdletBinding(DefaultParameterSetName='default')]
param(	[ValidateRange(0,255)]									[int]		$Time = 60,
		[Parameter(Mandatory)]									[String]	$CageName,
																[String]	$ModuleName,
		[ValidateSet('pcm','iom','drive')]						[String]	$ModuleNumber,
		[Parameter(ParameterSetName='MAG',Mandatory)]
		[ValidateRange(0,15)]									[int]		$Mag,
		[Parameter(ParameterSetName='PORT',Mandatory)]
		[ValidateSet('A0','A1','A2','A3','B0','B1','B2','B3')]	[String]	$PortName
	)		
Begin	
{	Test-CLIConnection
}
Process
{	$cmd= "locatecage "	
	$cmd+=" -t $time"
	$Result2 = Invoke-CLICommand -Connection $SANConnection -cmds 'showcage'
	if($Result2 -match $CageName)				{	$cmd+=" $CageName"	}
	else 	{	throw "FAILURE : -CageName $CageName  is Unavailable `n Try using [Get-Cage] Command "	}
	if ($ModuleName)							{	$cmd+=" $ModuleName"	}	
	if ($ModuleNumber)							{	$cmd+=" $ModuleNumber"	}
	if ($PSCmdlet.ParameterSetName -eq 'PORT')	{	$cmd +=" $Mag"	}	
	if ($PSCmdlet.ParameterSetName -eq 'PORT')	{	$cmd +=" $PortName"	}	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd	
	if([string]::IsNullOrEmpty($Result))
		{	write-host "Success : Find-Cage Command Executed Successfully $Result" -ForegroundColor Green
			return  
		}
	else
		{	throw  "FAILURE : While Executing Find-Cage `n $Result"
		} 		
}
}

Function Get-Cage
{
<#
.SYNOPSIS
	The Get-Cage command displays information about drive cages.
.DESCRIPTION
	The Get-Cage command displays information about drive cages. The command returns all data for all drive cages.
	The CLI option allows for a large number of filters to minimize the amount of the data being returned, however since 
	powershell has built in filtering, these options are simply not exposed. Use the Pipeline filters to extract only subsets of data. 
.EXAMPLE
	PS:> Get-Cage
	
	This examples display information for a single system’s drive cages.
.EXAMPLE  
	PS:> Get-Cage
.EXAMPLE
	PS:> ( Get-Cage ).Connector | format-table

	This is how you can recover all of the connection details.
.PARAMETER WhatIf
	When the Whatif switch is used, instead of runnig the command, the SSH CLI command is shown that retrieves the given data.
.PARAMETER ReturnRawResponse
	This switch is used when you wish to see the raw text that is returned from the command instead of 
	allowing the object to be parsed and converted into a powershell object.
#>
[CmdletBinding(DefaultParameterSetName='NoArgs')]
param(	[String]	$cageName,
		[switch]	$WhatIf,
		[switch]	$ReturnRawRespons
	)
Begin
{	Test-CLIConnectionB
}
Process
{	$cmd= "showcage -all "
	if ( $cageName ) 		{ 	$cmd+=" $cageName "	}
	if ( $WhatIf ) 			{ 	return $cmd}
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
	if ( $ReturnRawResponse) { 	return $Result }
	if( $Result.Count -gt 1)
		{	$ReturnObject = New-PWSHObjectFromCLIOutput -InterimResults $Result -verbose
			Return  $ReturnObject
		}
	else
		{	throw " FAILURE : While Executing Get-Cage `n $Result"		
		}		
} 
}

Function Set-Cage
{
<#
.SYNOPSIS	
	The Set-Cage command enables service personnel to set or modify parameters for a drive cage.
.DESCRIPTION
	The Set-Cage command enables service personnel to set or modify parameters for a drive cage.
.EXAMPLE
	Set-Cage -Position left -CageName cage1
	This example demonstrates how to assign cage1 a position description of Side Left.
.EXAMPLE
	Set-Cage -Position left -PSModel 1 -CageName cage1
    This  example demonstrates how to assign model names to the power supplies in cage1. Inthisexample, cage1 hastwopowersupplies(0 and 1).
.PARAMETER Position  
	Sets a description for the position of the cage in the cabinet, where <position> is a description to be assigned by service personnel (for example, left-top)
.PARAMETER PSModel	  
	Sets the model of a cage power supply, where <model> is a model name to be assigned to the power supply by service personnel.
	get information regarding PSModel try using  [ Get-Cage -option d ]
.PARAMETER CageName	 
	Indicates the name of the drive cage that is the object of the setcage operation.	
#>
[CmdletBinding()]
param(	[String]	$Position,
		[String]	$PSModel,
		[String]	$CageName
	)
Begin
{	Test-CLIConnectionB
}
Process
{	$cmd= "setcage "
	if ($Position )	{	$cmd+="position $Position "	}		
	if ($PSModel)	{	$cmd2="showcage -d"
						$Result2 = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd2
						if($Result2 -match $PSModel)
							{	$cmd+=" ps $PSModel "
							}	
						else
							{	return "Failure: -PSModel $PSModel is Not available. To Find Available Model `n Try  [Get-Cage -option d ] Command"
							}
					}		
	if ($CageName)	{	$cmd1="showcage"
						$Result1 = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd1
						if($Result1 -match $CageName)
							{	$cmd +="$CageName "
							}
						else
							{	return "Failure:  -CageName $CageName is Not available `n Try using [ Get-Cage ] Command to get list of Cage Name "
							}		
					}			
	else			{	return "ERROR: -CageName is a required parameter"
					}
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $cmd
	if([string]::IsNullOrEmpty($Result))
		{	return  "Success : Executing Set-Cage Command $Result "
		}
	else
		{	return  "FAILURE : While Executing Set-Cage $Result"
		} 		
}
}

Export-ModuleMember Find-Cage , Get-Cage , Set-Cage