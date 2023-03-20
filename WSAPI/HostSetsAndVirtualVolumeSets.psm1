## 	© 2019,2020,2023 Hewlett Packard Enterprise Development LP
##	Description: 	Host sets and virtual volume sets cmdlets 
##		

Function New-HostSet_WSAPI 
{
<#
.SYNOPSIS
	Creates a new host Set.
.DESCRIPTION
	Creates a new host Set.
    Any user with the Super or Edit role can create a host set. Any role granted hostset_set permission can add hosts to a host set.
	You can add hosts to a host set using a glob-style pattern. A glob-style pattern is not supported when removing hosts from sets.
	For additional information about glob-style patterns, see “Glob-Style Patterns” in the HPE 3PAR Command Line Interface Reference.
.PARAMETER HostSetName
	Name of the host set to be created.
.PARAMETER Comment
	Comment for the host set.
.PARAMETER Domain
	The domain in which the host set will be created.
.PARAMETER SetMembers
	The host to be added to the set. The existence of the hist will not be checked.
.PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
.EXAMPLE
	New-HostSet_WSAPI -HostSetName MyHostSet
    Creates a new host Set with name MyHostSet.
.EXAMPLE
	New-HostSet_WSAPI -HostSetName MyHostSet -Comment "this Is Test Set" -Domain MyDomain
    Creates a new host Set with name MyHostSet.
.EXAMPLE
	New-HostSet_WSAPI -HostSetName MyHostSet -Comment "this Is Test Set" -Domain MyDomain -SetMembers MyHost
	Creates a new host Set with name MyHostSet with Set Members MyHost.
.EXAMPLE	
	New-HostSet_WSAPI -HostSetName MyHostSet -Comment "this Is Test Set" -Domain MyDomain -SetMembers "MyHost,MyHost1,MyHost2"
    Creates a new host Set with name MyHostSet with Set Members MyHost.	
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[String]	$HostSetName,	  
		[String]	$Comment,	
		[String]	$Domain, 
		[String[]]	$SetMembers  
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}    
    $body["name"] = "$($HostSetName)"
    If ($Comment)     {	$body["comment"] = "$($Comment)"    }  
	If ($Domain)     {	$body["domain"] = "$($Domain)" }
	If ($SetMembers)     {	$body["setmembers"] = $SetMembers }
    $Result = $null
    $Result = Invoke-WSAPI -uri '/hostsets' -type 'POST' -body $body
	$status = $Result.StatusCode	
	if($status -eq 201)
	{	write-host "`n SUCCESS: Host Set:$HostSetName created successfully. `n" -foreground green
		Get-HostSet_WSAPI -HostSetName $HostSetName
	}
	else
	{	write-host "`nFAILURE : While creating Host Set:$HostSetName `n" 
		return $Result.StatusDescription
	}	
}
}

Function Update-HostSet_WSAPI 
{
<#
.SYNOPSIS
	Update an existing Host Set.
.DESCRIPTION
	Update an existing Host Set.
    Any user with the Super or Edit role can modify a host set. Any role granted hostset_set permission can add a host to the host set or remove a host from the host set.   
.EXAMPLE    
	Update-HostSet_WSAPI -HostSetName xxx -RemoveMember -Members as-Host4
.EXAMPLE
	Update-HostSet_WSAPI -HostSetName xxx -AddMember -Members as-Host4
.EXAMPLE	
	Update-HostSet_WSAPI -HostSetName xxx -ResyncPhysicalCopy
.EXAMPLE	
	Update-HostSet_WSAPI -HostSetName xxx -StopPhysicalCopy 
.EXAMPLE
	Update-HostSet_WSAPI -HostSetName xxx -PromoteVirtualCopy
.EXAMPLE
	Update-HostSet_WSAPI -HostSetName xxx -StopPromoteVirtualCopy
.EXAMPLE
	Update-HostSet_WSAPI -HostSetName xxx -ResyncPhysicalCopy -Priority high
.PARAMETER HostSetName
	Existing Host Name, required for all other options. 
.PARAMETER AddMember
	Adds a member to the VV set, must also set the Members value, but no others
.PARAMETER RemoveMember
	Removes a member from the VV set, must also set the Members value but no others
.PARAMETER ResyncPhysicalCopy
	Resynchronize the physical copy to its VV set. No other values can be set other than the hostsetname
.PARAMETER StopPhysicalCopy
	Stops the physical copy. No other values can be set other than the hostsetname
.PARAMETER PromoteVirtualCopy
	Promote virtual copies in a VV set. No other values can be set other than the hostsetname
.PARAMETER StopPromoteVirtualCopy
	Stops the promote virtual copy operations in a VV set.
.PARAMETER NewName
	New name of the set. Should set no other values other than hostsetname, comment
.PARAMETER Comment
	New comment for the VV set or host set. Should only set the hostsetname and optionally the newname
	To remove the comment, use “”.
.PARAMETER Members
	The volume or host to be added to or removed from the set.
.PARAMETER Priority
	Is required and can be either { high | medium | low }
#>
[CmdletBinding(DefaultParameterSetName='NN')]
Param(	[Parameter(Mandatory=$true)]								[String]	$HostSetName,
		[Parameter(Mandatory=$true, ParameterSetName='AM')]			[switch]	$AddMember,	
		[Parameter(Mandatory=$true, ParameterSetName='RM')]			[switch]	$RemoveMember,
		[Parameter(Mandatory=$true, ParameterSetName='RPC')]		[switch]	$ResyncPhysicalCopy,
		[Parameter(Mandatory=$true, ParameterSetName='SVC')]		[switch]	$StopPhysicalCopy,
		[Parameter(Mandatory=$true, ParameterSetName='PVC')]		[switch]	$PromoteVirtualCopy,
		[Parameter(Mandatory=$true, ParameterSetName='SPVC')]		[switch]	$StopPromoteVirtualCopy,
		[Parameter(Mandatory=$true, ParameterSetName='NN')]			[String]	$NewName,
		[Parameter(ParameterSetName='NN')]
		[Parameter(Mandatory=$true, ParameterSetName='CM')]			[String]	$Comment,
		[Parameter(Mandatory=$true, ParameterSetName='AM')]
		[Parameter(Mandatory=$true, ParameterSetName='RPC')]
		[Parameter(Mandatory=$true, ParameterSetName='SPC')]
		[Parameter(Mandatory=$true, ParameterSetName='PVC')]
		[Parameter(Mandatory=$true, ParameterSetName='SPVC')]
		[Parameter(Mandatory=$true, ParameterSetName='RM')]			[String[]]	$Members,
	[Parameter(Mandatory)]
	[ValidateSet('high','medium','low')][String]	$Priority
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}
	If ($AddMember) 			{	$body["action"] = 1	}
	If ($RemoveMember) 			{	$body["action"] = 2	}
	If ($ResyncPhysicalCopy)	{	$body["action"] = 3 }
	If ($StopPhysicalCopy) 		{	$body["action"] = 4 }
	If ($PromoteVirtualCopy) 	{	$body["action"] = 5 }
	If ($StopPromoteVirtualCopy){	$body["action"] = 6	}
	If ($NewName) 				{	$body["newName"] = "$($NewName)"	 }
	If ($Comment) 				{	$body["comment"] = "$($Comment)"    }
	If ($Members) 				{	$body["setmembers"] = $Members	 }
	If ($Priority -eq "high")	{	$body["priority"] = 1	}	
	if ($Priority -eq "medium")	{	$body["priority"] = 2	}
	if ($Priority -eq "low")	{	$body["priority"] = 3	}
    $Result = $null	
	$uri = '/hostsets/'+$HostSetName 
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body
	if($Result.StatusCode -eq 200)
	{	write-host "`n SUCCESS: Host Set:$HostSetName successfully Updated.`n" -foreground green
		if($NewName)	{ return (Get-HostSet_WSAPI -HostSetName $NewName) }
		else			{ return (Get-HostSet_WSAPI -HostSetName $HostSetName)	}
	}
	else
	{	write-Error "`n FAILURE : While Updating Host Set: $HostSetName.`n"
		return $Result.StatusDescription
	}
}
}

Function Remove-HostSet_WSAPI
{
<#
.SYNOPSIS
	Remove a Host Set.
.DESCRIPTION
	Remove a Host Set.
	Any user with Super or Edit role, or any role granted host_remove permission, can perform this operation. Requires access to all domains.
.EXAMPLE    
	Remove-HostSet_WSAPI -HostSetName MyHostSet
.PARAMETER HostSetName 
	Specify the name of Host Set to be removed.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory = $true)]	[String]$HostSetName
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{   $uri = '/hostsets/'+$HostSetName
	$Result = $null
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE' -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode
	if($status -eq 200)
	{	write-host "`n SUCCESS: Host Set:$HostSetName successfully removed.`n" -foreground green
		return 
	}
	else
	{	write-Error "`n FAILURE : While Removing Host Set:$HostSetName `n"
		return $Result.StatusDescription
	}    
}
}

Function Get-HostSet_WSAPI 
{
<#
.SYNOPSIS
	Get Single or list of Hotes Set.
.DESCRIPTION
	Get Single or list of Hotes Set.
.EXAMPLE
	Get-HostSet_WSAPI
	Display a list of Hotes Set.
.EXAMPLE
	Get-HostSet_WSAPI -HostSetName MyHostSet
	Get the information of given Hotes Set.
.EXAMPLE
	Get-HostSet_WSAPI -Members MyHost
	Get the information of Hotes Set that contain MyHost as Member.
.EXAMPLE
	Get-HostSet_WSAPI -Members "MyHost,MyHost1,MyHost2"
	Multiple Members.
.EXAMPLE
	Get-HostSet_WSAPI -Id 10
	Filter Host Set with Id
.EXAMPLE
	Get-HostSet_WSAPI -Uuid 10
	Filter Host Set with uuid
.EXAMPLE
	Get-HostSet_WSAPI -Members "MyHost,MyHost1,MyHost2" -Id 10 -Uuid 10
	Multiple Filter
.PARAMETER HostSetName
	Specify name of the Hotes Set.
.PARAMETER Members
	Specify name of the Hotes.
.PARAMETER Id
	Specify id of the Hotes Set.
.PARAMETER Uuid
	Specify uuid of the Hotes Set.
#>
[CmdletBinding()]
Param(	[String]	$HostSetName,
		[String]	$Members,
		[String]	$Id,
		[String]	$Uuid
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null
	$dataPS = $null		
	$Query="?query=""  """
	if($HostSetName)
	{	$uri = '/hostsets/'+$HostSetName
		$Result = Invoke-WSAPI -uri $uri -type 'GET'
		If($Result.StatusCode -eq 200)
		{	$dataPS = $Result.content | ConvertFrom-Json
			write-host "`n SUCCESS: Get-HostSet_WSAPI successfully Executed.`n" -foreground green
			return $dataPS
		}
		else
		{	write-Error "`n FAILURE : While Executing Get-HostSet_WSAPI.`n" 
			return $Result.StatusDescription
		}
	}
	if($Members)
	{	$count = 1
		$lista = $Members.split(",")
		foreach($sub in $lista)
		{	$Query = $Query.Insert($Query.Length-3," setmembers EQ $sub")			
			if($lista.Count -gt 1)
			{	if($lista.Count -ne $count)
				{	$Query = $Query.Insert($Query.Length-3," OR ")
					$count = $count + 1
				}				
			}
		}		
	}
	if($Id)
	{	if($Members)
		{	$Query = $Query.Insert($Query.Length-3," OR id EQ $Id")
		}
		else
		{	$Query = $Query.Insert($Query.Length-3," id EQ $Id")
		}
	}
	if($Uuid)
	{	if($Members -or $Id)
		{	$Query = $Query.Insert($Query.Length-3," OR uuid EQ $Uuid")
		}
		else
		{	$Query = $Query.Insert($Query.Length-3," uuid EQ $Uuid")
		}
	}
	if($Members -Or $Id -Or $Uuid)
	{	$uri = '/hostsets/'+$Query
		$Result = Invoke-WSAPI -uri $uri -type 'GET'
		If($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}
	}	
	else
	{	$Result = Invoke-WSAPI -uri '/hostsets' -type 'GET' 
		If($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}		
	}
	If($Result.StatusCode -eq 200)
	{	if($dataPS.Count -gt 0)
		{	write-host "`n Cmdlet executed successfully.`n" -foreground green
			return $dataPS
		}
		else
		{	write-error "`n FAILURE : While Executing Get-HostSet_WSAPI. Expected Result Not Found with Given Filter Option : Members/$Members Id/$Id Uuid/$Uuid."
			return 
		}		
	}
	else
	{	write-error "`n FAILURE : While Executing Get-HostSet_WSAPI.`n"
		return $Result.StatusDescription
	}
}
}

Function New-VvSet_WSAPI 
{
<#
.SYNOPSIS
	Creates a new virtual volume Set.
.DESCRIPTION
	Creates a new virtual volume Set.
    Any user with the Super or Edit role can create a host set. Any role granted hostset_set permission can add hosts to a host set.
	You can add hosts to a host set using a glob-style pattern. A glob-style pattern is not supported when removing hosts from sets.
	For additional information about glob-style patterns, see “Glob-Style Patterns” in the HPE 3PAR Command Line Interface Reference.
.EXAMPLE
	New-VvSet_WSAPI -VVSetName MyVVSet
    Creates a new virtual volume Set with name MyVVSet.
.EXAMPLE
	New-VvSet_WSAPI -VVSetName MyVVSet -Comment "this Is Test Set" -Domain MyDomain
    Creates a new virtual volume Set with name MyVVSet.
.EXAMPLE
	New-VvSet_WSAPI -VVSetName MyVVSet -Comment "this Is Test Set" -Domain MyDomain -SetMembers xxx
	Creates a new virtual volume Set with name MyVVSet with Set Members xxx.
.EXAMPLE	
	New-VvSet_WSAPI -VVSetName MyVVSet -Comment "this Is Test Set" -Domain MyDomain -SetMembers "xxx1,xxx2,xxx3"
    Creates a new virtual volume Set with name MyVVSet with Set Members xxx.
.PARAMETER VVSetName
	Name of the virtual volume set to be created.
.PARAMETER Comment
	Comment for the virtual volume set.
.PARAMETER Domain
	The domain in which the virtual volume set will be created.
.PARAMETER SetMembers
	The virtual volume to be added to the set. The existence of the hist will not be checked.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]			[String]	$VVSetName,	  
																		[String]	$Comment,	
																		[String]	$Domain, 
																		[String[]]	$SetMembers
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}    
    $body["name"] = "$($VVSetName)"
	If ($Comment) 	{	$body["comment"] = "$($Comment)"	}  
	If ($Domain) 	{	$body["domain"] = "$($Domain)"    	}
	If ($SetMembers){	$body["setmembers"] = $SetMembers   }
    $Result = $null
    $Result = Invoke-WSAPI -uri '/volumesets' -type 'POST' -body $body
	$status = $Result.StatusCode	
	if($status -eq 201)
	{	write-host "`n Cmdlet executed successfully. `n" -foreground green
		return (Get-VvSet_WSAPI -VVSetName $VVSetName)
	}
	else
	{	write-error "`n FAILURE : While creating virtual volume Set:$VVSetName.`n "
		return $Result.StatusDescription
	}	
}
}

Function Update-VvSet_WSAPI 
{
<#
.SYNOPSIS
	Update an existing virtual volume Set.
.DESCRIPTION
	Update an existing virtual volume Set.
    Any user with the Super or Edit role can modify a host set. Any role granted hostset_set permission can add a host to the host set or remove a host from the host set.   
.EXAMPLE
	Update-VvSet_WSAPI -VVSetName xxx -RemoveMember -Members testvv3.0
.EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -AddMember -Members testvv3.0
.EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -ResyncPhysicalCopy 
.EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -StopPhysicalCopy 
.EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -PromoteVirtualCopy
.EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -StopPromoteVirtualCopy
.EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -Priority xyz
.EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -ResyncPhysicalCopy -Priority high
.EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -ResyncPhysicalCopy -Priority medium
.EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -ResyncPhysicalCopy -Priority low
.EXAMPLE 
	Update-VvSet_WSAPI -VVSetName xxx -NewName as-vvSet1 -Comment "Updateing new name"
.PARAMETER VVSetName
	Existing virtual volume Name
.PARAMETER AddMember
	Adds a member to the virtual volume set.
.PARAMETER RemoveMember
	Removes a member from the virtual volume set.
.PARAMETER ResyncPhysicalCopy
	Resynchronize the physical copy to its virtual volume set.
.PARAMETER StopPhysicalCopy
	Stops the physical copy.
.PARAMETER PromoteVirtualCopy
	Promote virtual copies in a virtual volume set.
.PARAMETER StopPromoteVirtualCopy
	Stops the promote virtual copy operations in a virtual volume set.
.PARAMETER NewName
	New name of the virtual volume set.
.PARAMETER Comment
	New comment for the virtual volume set or host set.
	To remove the comment, use “”.
.PARAMETER Members
	The volume to be added to or removed from the virtual volume set.
.PARAMETER Priority
	1: high
	2: medium
	3: low
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VVSetName,
	[Parameter(ParameterSetName='AM')]	[switch]	$AddMember,	
	[Parameter(ParameterSetName='RM')]	[switch]	$RemoveMember,
	[Parameter(ParameterSetName='RPC')]	[switch]	$ResyncPhysicalCopy,
	[Parameter(ParameterSetName='SPC')]	[switch]	$StopPhysicalCopy,
	[Parameter(ParameterSetName='PVC')]	[switch]	$PromoteVirtualCopy,
	[Parameter(ParameterSetName='SPVC')][switch]	$StopPromoteVirtualCopy,
	[Parameter(ParameterSetName='NN')]	[String]	$NewName,
	[Parameter(ParameterSetName='NN')]	[String]	$Comment,
	[Parameter(ParameterSetName='AM')]
	[Parameter(ParameterSetName='RM')]
	[Parameter(ParameterSetName='RPC')]
	[Parameter(ParameterSetName='SPC')]
	[Parameter(ParameterSetName='PVC')]
	[Parameter(ParameterSetName='SPVC')][String[]]	$Members,
	[ValidateSet('high','medium','low')][String]	$Priority
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$body = @{}
	$counter
    If ($AddMember) 		{	$body["action"] = 1 }
	If ($RemoveMember) 		{	$body["action"] = 2 }
	If ($ResyncPhysicalCopy){	$body["action"] = 3 }
	If ($StopPhysicalCopy) 	{	$body["action"] = 4 }
	If ($PromoteVirtualCopy){	$body["action"] = 5	}
	If ($StopPromoteVirtualCopy) {	$body["action"] = 6 }
	If ($NewName) 			{	$body["newName"] = "$($NewName)" }
	If ($Comment) 			{	$body["comment"] = "$($Comment)" }
	If ($Members) 			{	$body["setmembers"] = $Members   }
	if($Priority -eq "high"){	$body["priority"] = 1	}	
	if($Priority -eq "medium"){	$body["priority"] = 2	}
	if($Priority -eq "low")	{	$body["priority"] = 3	}	
    $Result = $null	
	$uri = '/volumesets/'+$VVSetName 
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body
	if($Result.StatusCode -eq 200)
	{	write-host ""
		write-host "`n SUCCESS: virtual volume Set:$VVSetName successfully Updated.`n" -foreground green
		if($NewName)	{	return ( Get-VvSet_WSAPI -VVSetName $NewName )	}
		else			{	return ( Get-VvSet_WSAPI -VVSetName $VVSetName )	}
	}
	else
	{	write-error "`n FAILURE : While Updating virtual volume Set: $VVSetName.`n "
		return $Result.StatusDescription
	}
}
}

Function Remove-VvSet_WSAPI
{
  <#
  .SYNOPSIS
	Remove a virtual volume Set.
  
  .DESCRIPTION
	Remove a virtual volume Set.
	Any user with Super or Edit role, or any role granted host_remove permission, can perform this operation. Requires access to all domains.
        
  .EXAMPLE    
	Remove-VvSet_WSAPI -VVSetName MyvvSet
	
  .PARAMETER VVSetName 
	Specify the name of virtual volume Set to be removed.

  .PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
	
  .Notes
    NAME    : Remove-VvSet_WSAPI     
    LASTEDIT: February 2020
    KEYWORDS: Remove-VvSet_WSAPI
   
  .Link
     http://www.hpe.com
 
  #Requires PS -Version 3.0	
  #>
  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param(
	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Specifies the name of virtual volume Set.')]
	[String]$VVSetName,
	
	[Parameter(Mandatory=$false, ValueFromPipeline=$true , HelpMessage = 'Connection Paramater')]
	$WsapiConnection = $global:WsapiConnection
	)
  Begin 
  {
    # Test if connection exist
    Test-WSAPIConnection -WsapiConnection $WsapiConnection
  }

  Process 
  {    
	#Build uri
	Write-DebugLog "Running: Building uri to Remove-VvSet_WSAPI." $Debug
	$uri = '/volumesets/'+$VVSetName
	
	$Result = $null

	#Request
	Write-DebugLog "Request: Request to Remove-VvSet_WSAPI : $VVSetName (Invoke-WSAPI)." $Debug
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE' -WsapiConnection $WsapiConnection
	
	$status = $Result.StatusCode
	if($status -eq 200)
	{
		write-host ""
		write-host "Cmdlet executed successfully" -foreground green
		write-host ""
		Write-DebugLog "SUCCESS: virtual volume Set:$VVSetName successfully remove" $Info
		Write-DebugLog "End: Remove-VvSet_WSAPI" $Debug
		
		return ""
	}
	else
	{
		write-host ""
		write-host "FAILURE : While Removing virtual volume Set:$VVSetName " -foreground red
		write-host ""
		Write-DebugLog "FAILURE : While creating virtual volume Set:$VVSetName " $Info
		Write-DebugLog "End: Remove-VvSet_WSAPI" $Debug
		
		return $Result.StatusDescription
	}    
	
  }
  End {}  
}

Function Get-VvSet_WSAPI 
{
<#
.SYNOPSIS
	Get Single or list of virtual volume Set.
.DESCRIPTION
	Get Single or list of virtual volume Set.
.EXAMPLE
	Get-VvSet_WSAPI
	Display a list of virtual volume Set.
.EXAMPLE
	Get-VvSet_WSAPI -VVSetName MyvvSet
	Get the information of given virtual volume Set.
.EXAMPLE
	Get-VvSet_WSAPI -Members Myvv
	Get the information of virtual volume Set that contain MyHost as Member.
.EXAMPLE
	Get-VvSet_WSAPI -Members "Myvv,Myvv1,Myvv2"
	Multiple Members.
.EXAMPLE
	Get-VvSet_WSAPI -Id 10
	Filter virtual volume Set with Id
.EXAMPLE
	Get-VvSet_WSAPI -Uuid 10
	Filter virtual volume Set with uuid
.EXAMPLE
	Get-VvSet_WSAPI -Members "Myvv,Myvv1,Myvv2" -Id 10 -Uuid 10
	Multiple Filter
.PARAMETER VVSetName
	Specify name of the virtual volume Set.
.PARAMETER Members
	Specify name of the virtual volume.
.PARAMETER Id
	Specify id of the virtual volume Set.
.PARAMETER Uuid
	Specify uuid of the virtual volume Set.
#>
[CmdletBinding()]
Param(	[String]	$VVSetName,
		[String]	$Members,
		[String]	$Id,
		[String]	$Uuid
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null
	$dataPS = $null		
	$Query="?query=""  """
	if($VVSetName)
	{	$uri = '/volumesets/'+$VVSetName
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection		 
		If($Result.StatusCode -eq 200)
		{	$dataPS = $Result.content | ConvertFrom-Json
			write-host "`n SUCCESS: Get-VvSet_WSAPI successfully Executed.`n" -foreground green
			return $dataPS
		}
		else
		{	write-error "`n FAILURE : While Executing Get-VvSet_WSAPI.`n " 
			return $Result.StatusDescription
		}
	}
	if($Members)
	{	$count = 1
		$lista = $Members.split(",")
		foreach($sub in $lista)
		{	$Query = $Query.Insert($Query.Length-3," setmembers EQ $sub")			
			if($lista.Count -gt 1)
			{	if($lista.Count -ne $count)
				{	$Query = $Query.Insert($Query.Length-3," OR ")
					$count = $count + 1
				}				
			}
		}		
	}
	if($Id)
	{	if($Members)
		{	$Query = $Query.Insert($Query.Length-3," OR id EQ $Id")
		}
		else
		{	$Query = $Query.Insert($Query.Length-3," id EQ $Id")
		}
	}
	if($Uuid)
	{	if($Members -or $Id)
		{	$Query = $Query.Insert($Query.Length-3," OR uuid EQ $Uuid")
		}
		else
		{	$Query = $Query.Insert($Query.Length-3," uuid EQ $Uuid")
		}
	}
	if($Members -Or $Id -Or $Uuid)
	{	$uri = '/volumesets/'+$Query
		$Result = Invoke-WSAPI -uri $uri -type 'GET' -WsapiConnection $WsapiConnection	
		If($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}
	}	
	else
	{	$Result = Invoke-WSAPI -uri '/volumesets' -type 'GET' -WsapiConnection $WsapiConnection
		If($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}		
	}
	If($Result.StatusCode -eq 200)
	{	if($dataPS.Count -gt 0)
		{	write-host "`n SUCCESS: Get-VvSet_WSAPI successfully Executed.`n" -foreground green
			return $dataPS
		}
		else
		{	write-error "`n FAILURE : While Executing Get-VvSet_WSAPI. Expected Result Not Found with Given Filter Option : Members/$Members Id/$Id Uuid/$Uuid.`n " 
			return 
		}
	}
	else
	{	write-error "`n FAILURE : While Executing Get-VvSet_WSAPI. `n"
		return $Result.StatusDescription
	}
}
}

Function Set-VvSetFlashCachePolicy_WSAPI 
{
<#      
.SYNOPSIS	
	Setting a VV-set Flash Cache policy.
.DESCRIPTION	
    Setting a VV-set Flash Cache policy.
.EXAMPLE	
	Set-VvSetFlashCachePolicy_WSAPI
.PARAMETER VvSet
	Name Of the VV-set to Set Flash Cache policy.
.PARAMETER Enable
	To Enable VV-set Flash Cache policy
.PARAMETER Disable
	To Disable VV-set Flash Cache policy
#>
[CmdletBinding(DefaultParameterSetName='DisabledDefault')]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]	[String]	$VvSet,
		[Parameter(ParameterSet='Enabled')]						[Switch]	$Enable,
		[Parameter(ParameterSet='Disabled')]					[Switch]	$Disable
)
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Message = $PSCmdlet.ParameterSetName
    $body = @{}		
	$body["flashCachePolicy"] = 2 
	If($Enable) {	$body["flashCachePolicy"] = 1 }		
	If($Disable){	$body["flashCachePolicy"] = 2 }
    $Result = $null
	$uri = '/volumesets/'+$VvSet
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body
	$status = $Result.StatusCode
	if($status -eq 200)
	{	write-host "`n SUCCESS: Successfully Set Flash Cache policy $Message to vv-set $VvSet.`n" -foreground green
		return $Result
	}
	else
	{	write-error "`n FAILURE : While Setting Flash Cache policy $Message to vv-set $VvSet.`n"
		return $Result.StatusDescription
	}
}
}

Export-ModuleMember New-HostSet_WSAPI , Update-HostSet_WSAPI , Remove-HostSet_WSAPI , Get-HostSet_WSAPI , New-VvSet_WSAPI ,
Update-VvSet_WSAPI , Remove-VvSet_WSAPI , Get-VvSet_WSAPI , Set-VvSetFlashCachePolicy_WSAPI
