####################################################################################
## 	© 2019,2020,2023 Hewlett Packard Enterprise Development LP
##

Function New-Cpg_WSAPI 
{
<#
.SYNOPSIS
	The New-Cpg_WSAPI command creates a Common Provisioning Group (CPG).
.DESCRIPTION
	The New-Cpg_WSAPI command creates a Common Provisioning Group (CPG).
.EXAMPLE    
	New-Cpg_WSAPI -CPGName XYZ 
.EXAMPLE	
	New-Cpg_WSAPI -CPGName "MyCPG" -Domain Chef_Test
.EXAMPLE	
	New-Cpg_WSAPI -CPGName "MyCPG" -Domain Chef_Test -Template Test_Temp
.EXAMPLE	
	New-Cpg_WSAPI -CPGName "MyCPG" -Domain Chef_Test -Template Test_Temp -GrowthIncrementMiB 100
.EXAMPLE	
	New-Cpg_WSAPI -CPGName "MyCPG" -Domain Chef_Test -RAIDType R0
.PARAMETER CPGName
	Specifies the name of the CPG.  
.PARAMETER Domain
	Specifies the name of the domain in which the object will reside.  
.PARAMETER Template
	Specifies the name of the template from which the CPG is created.
.PARAMETER GrowthIncrementMiB
	Specifies the growth increment, in MiB, the amount of logical disk storage created on each auto-grow operation.  
.PARAMETER GrowthLimitMiB
	Specifies that the autogrow operation is limited to the specified storage amount, in MiB, that sets the growth limit.
.PARAMETER UsedLDWarningAlertMiB
	Specifies that the threshold of used logical disk space, in MiB, when exceeded results in a warning alert.
.PARAMETER RAIDType
	RAID type for the logical disk
	R0 RAID level 0
	R1 RAID level 1
	R5 RAID level 5
	R6 RAID level 6
.PARAMETER SetSize
	Specifies the set size in the number of chunklets.
.PARAMETER HA
	Specifies that the layout must support the failure of one port pair, one cage, or one magazine.
	PORT Support failure of a port.
	CAGE Support failure of a drive cage.
	MAG Support failure of a drive magazine.
.PARAMETER Chunklets
	FIRST Lowest numbered available chunklets, where transfer rate is the fastest.
	LAST  Highest numbered available chunklets, where transfer rate is the slowest.
.PARAMETER NodeList
	Specifies one or more nodes. Nodes are identified by one or more integers. Multiple nodes are separated with a single comma (1,2,3). 
	A range of nodes is separated with a hyphen (0–7). The primary path of the disks must be on the specified node number.
.PARAMETER SlotList
	Specifies one or more PCI slots. Slots are identified by one or more integers. Multiple slots are separated with a single comma (1,2,3). 
	A range of slots is separated with a hyphen (0–7). The primary path of the disks must be on the specified PCI slot number(s).
.PARAMETER PortList
	Specifies one or more ports. Ports are identified by one or more integers. Multiple ports are separated with a single comma (1,2,3). 
	A range of ports is separated with a hyphen (0–4). The primary path of the disks must be on the specified port number(s).
.PARAMETER CageList
	Specifies one or more drive cages. Drive cages are identified by one or more integers. Multiple drive cages are separated with a single comma (1,2,3). 
	A range of drive cages is separated with a hyphen (0– 3). The specified drive cage(s) must contain disks.
.PARAMETER MagList 
	Specifies one or more drive magazines. Drive magazines are identified by one or more integers. Multiple drive magazines are separated with a single comma (1,2,3). 
	A range of drive magazines is separated with a hyphen (0–7). The specified magazine(s) must contain disks.  
.PARAMETER DiskPosList
	Specifies one or more disk positions within a drive magazine. Disk positions are identified by one or more integers. Multiple disk positions are separated with a single comma (1,2,3). 
	A range of disk positions is separated with a hyphen (0–3). The specified portion(s) must contain disks.
.PARAMETER DiskList
	Specifies one or more physical disks. Disks are identified by one or more integers. Multiple disks are separated with a single comma (1,2,3). 
	A range of disks is separated with a hyphen (0–3). Disks must match the specified ID(s). 
.PARAMETER TotalChunkletsGreaterThan
	Specifies that physical disks with total chunklets greater than the number specified be selected.  
.PARAMETER TotalChunkletsLessThan
	Specifies that physical disks with total chunklets less than the number specified be selected. 
.PARAMETER FreeChunkletsGreaterThan
	Specifies that physical disks with free chunklets less than the number specified be selected.  
.PARAMETER FreeChunkletsLessThan
	Specifies that physical disks with free chunklets greater than the number specified be selected. 
.PARAMETER DiskType
	Specifies that physical disks must have the specified device type.
	FC Fibre Channel
	NL Near Line
	SSD SSD
.PARAMETER Rpm
	Disks must be of the specified speed.
.PARAMETER WsapiConnection 
    WSAPI Connection object created with Connection command
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
		[String]		$CPGName,
		[String]		$Domain = $null,
		[String]		$Template = $null,
		[Int]			$GrowthIncrementMiB = $null,
		[int]			$GrowthLimitMiB = $null,
		[int]			$UsedLDWarningAlertMiB = $null,
		[ValidateSet('R0','R1','R5','R6')]
		[string]		$RAIDType = $null, 
		[int]			$SetSize = $null,
		[ValidateSet('PORT','CAGE','MAG')]
		[string]		$HA = $null,
		[ValidateSet('FIRST','LAST')]
		[string]		$Chunklets = $null,
		[String]		$NodeList = $null,
		[String]		$SlotList = $null,
		[String]		$PortList = $null,
		[String]		$CageList = $null,
		[String]		$MagList = $null,
		[String]		$DiskPosList = $null,
		[String]		$DiskList = $null,
		[int]			$TotalChunkletsGreaterThan = $null,
		[int]			$TotalChunkletsLessThan = $null,
		[int]			$FreeChunkletsGreaterThan = $null,
		[int]			$FreeChunkletsLessThan = $null,
		[ValidateSet('FC','NL','SSD')]
		[string]		$DiskType = $null,
		[int]			$Rpm = $null
	)
Begin 
{	Test-WSAPIConnection 
}
Process 
{	# Creation of the body hash
	Write-DebugLog "Running: Creation of the body hash" $Debug
    $body = @{}		
    $body["name"] = "$($CPGName)"
    If ($Domain) 				{	$body["domain"] = "$($Domain)"	}
    If ($Template) 				{	$body["template"] = "$($Template)"}	 
    If ($GrowthIncrementMiB)	{	$body["growthIncrementMiB"] = $GrowthIncrementMiB		} 
    If ($GrowthLimitMiB) 		{	$body["growthLimitMiB"] = $GrowthLimitMiB		}	 	
    If ($UsedLDWarningAlertMiB) {	$body["usedLDWarningAlertMiB"] = $UsedLDWarningAlertMiB		} 
	$LDLayoutBody = @{}
	if ($RAIDType -eq "R0")		{	$LDLayoutBody["RAIDType"] = 1	}
	if ($RAIDType -eq "R1")		{	$LDLayoutBody["RAIDType"] = 2	}
	if ($RAIDType -eq "R5")		{	$LDLayoutBody["RAIDType"] = 3	}
	if ($RAIDType -eq "R6")		{	$LDLayoutBody["RAIDType"] = 4	}
    if ($SetSize)				{	$LDLayoutBody["setSize"] = $SetSize		}
	if ($HA -eq "PORT")			{	$LDLayoutBody["HA"] = 1			}
	if ($HA -eq "CAGE")			{	$LDLayoutBody["HA"] = 2			}
	if ($HA -eq "MAG")			{	$LDLayoutBody["HA"] = 3			}
	if ($Chunklets -eq "FIRST")	{	$LDLayoutBody["chunkletPosPref"] = 1	}
	if($Chunklets -eq "LAST")	{	$LDLayoutBody["chunkletPosPref"] = 2	}
	$LDLayoutDiskPatternsBody=@()	
	if ($NodeList)
		{	$nodList=@{}
			$nodList["nodeList"] = "$($NodeList)"	
			$LDLayoutDiskPatternsBody += $nodList 			
		}	
	if ($SlotList)
		{	$sList=@{}
			$sList["slotList"] = "$($SlotList)"	
			$LDLayoutDiskPatternsBody += $sList 		
		}
	if ($PortList)
		{	$pList=@{}
			$pList["portList"] = "$($PortList)"	
			$LDLayoutDiskPatternsBody += $pList 		
		}	
	if ($CageList)
		{	$cagList=@{}
			$cagList["cageList"] = "$($CageList)"	
			$LDLayoutDiskPatternsBody += $cagList 		
		}
	if ($MagList)
		{	$mList=@{}
			$mList["magList"] = "$($MagList)"	
			$LDLayoutDiskPatternsBody += $mList 		
		}
	if ($DiskPosList)
		{	$dpList=@{}
			$dpList["diskPosList"] = "$($DiskPosList)"	
			$LDLayoutDiskPatternsBody += $dpList 		
		}
	if ($DiskList)
		{	$dskList=@{}
			$dskList["diskList"] = "$($DiskList)"	
			$LDLayoutDiskPatternsBody += $dskList 		
		}
	if ($TotalChunkletsGreaterThan)
		{	$tcgList=@{}
			$tcgList["totalChunkletsGreaterThan"] = $TotalChunkletsGreaterThan	
			$LDLayoutDiskPatternsBody += $tcgList 		
		}
	if ($TotalChunkletsLessThan)
		{	$tclList=@{}
			$tclList["totalChunkletsLessThan"] = $TotalChunkletsLessThan	
			$LDLayoutDiskPatternsBody += $tclList 		
		}
	if ($FreeChunkletsGreaterThan)
		{	$fcgList=@{}
			$fcgList["freeChunkletsGreaterThan"] = $FreeChunkletsGreaterThan	
			$LDLayoutDiskPatternsBody += $fcgList 		
		}
	if ($FreeChunkletsLessThan)
		{	$fclList=@{}
			$fclList["freeChunkletsLessThan"] = $FreeChunkletsLessThan	
			$LDLayoutDiskPatternsBody += $fclList 		
		}
	if($DiskType -eq "FC")
				{	$dtList=@{}
					$dtList["diskType"] = 1	
					$LDLayoutDiskPatternsBody += $dtList						
				}
	if($DiskType -eq "NL")
				{	$dtList=@{}
					$dtList["diskType"] = 2	
					$LDLayoutDiskPatternsBody += $dtList						
				}
	if($DiskType -eq "SSD")
				{	$dtList=@{}
					$dtList["diskType"] = 3	
					$LDLayoutDiskPatternsBody += $dtList						
				}
	if ($Rpm)
		{	$rpmList=@{}
			$rpmList["RPM"] = $Rpm	
			$LDLayoutDiskPatternsBody += $rpmList
		}			
	if($LDLayoutDiskPatternsBody.Count -gt 0)	{	$LDLayoutBody["diskPatterns"] = $LDLayoutDiskPatternsBody	}		
	if($LDLayoutBody.Count -gt 0)
		{	$body["LDLayout"] = $LDLayoutBody 
		}	
    #init the response var
    $Result = $null		
    #Request
    $Result = Invoke-WSAPI -uri '/cpgs' -type 'POST' -body $body -WsapiConnection $WsapiConnection
	$status = $Result.StatusCode
	if($status -eq 201)
		{	write-host "`n Cmdlet executed successfully. `n" -foreground green
			Write-DebugLog "SUCCESS: CPG:$CPGName created successfully" $Info
			Get-Cpg_WSAPI -CPGName $CPGName
			Write-DebugLog "End: New-Cpg_WSAPI" $Debug
		}
	else
		{	write-error "`n FAILURE : While creating CPG:$CPGName `n"
			Write-DebugLog "FAILURE : While creating CPG:$CPGName " $Info
			return $Result.StatusDescription
		}	
}
}

Function Update-Cpg_WSAPI 
{
<#
.SYNOPSIS
	The Update-Cpg_WSAPI command Update a Common Provisioning Group (CPG).
.DESCRIPTION
	The Update-Cpg_WSAPI command Update a Common Provisioning Group (CPG).
	This operation requires access to all domains, as well as Super, Service, or Edit roles, or any role granted cpg_set permission.
.EXAMPLE   
	Update-Cpg_WSAPI -CPGName ascpg -NewName as_cpg
.EXAMPLE 	
	Update-Cpg_WSAPI -CPGName xxx -RAIDType R1
.EXAMPLE 	
	Update-Cpg_WSAPI -CPGName xxx -DisableAutoGrow $true
.EXAMPLE 	
	Update-Cpg_WSAPI -CPGName xxx -RmGrowthLimit $true
.EXAMPLE 	
	Update-Cpg_WSAPI -CPGName xxx -RmWarningAlert $true
.EXAMPLE 
	Update-Cpg_WSAPI -CPGName xxx -SetSize 10
.EXAMPLE 	
	Update-Cpg_WSAPI -CPGName xxx -HA PORT
.EXAMPLE 	
	Update-Cpg_WSAPI -CPGName xxx -Chunklets FIRST
.EXAMPLE 	
	Update-Cpg_WSAPI -CPGName xxx -NodeList 0
.PARAMETER CPGName,
	pecifies the name of Existing CPG.  
.PARAMETER NewName,
	Specifies the name of CPG to Update.
.PARAMETER RmGrowthLimit
	Enables (false) or disables (true) auto grow limit enforcement. Defaults to false.  
.PARAMETER DisableAutoGrow
	Enables (false) or disables (true) CPG auto grow. Defaults to false..
.PARAMETER RmWarningAlert
	Enables (false) or disables (true) warning limit enforcement. Defaults to false..
.PARAMETER RAIDType
	RAID type for the logical disk, which can be either R0, R1, R5, R6 which represent the RAID levels.
.PARAMETER SetSize
	Specifies the set size in the number of chunklets.
.PARAMETER HA
	Specifies that the layout must support the failure of one port pair, one cage, or one magazine.
	PORT Support failure of a port.
	CAGE Support failure of a drive cage.
	MAG Support failure of a drive magazine.
.PARAMETER Chunklets
	FIRST Lowest numbered available chunklets, where transfer rate is the fastest.
	LAST  Highest numbered available chunklets, where transfer rate is the slowest.
.PARAMETER NodeList
	Specifies one or more nodes. Nodes are identified by one or more integers. Multiple nodes are separated with a single comma (1,2,3). 
	A range of nodes is separated with a hyphen (0–7). The primary path of the disks must be on the specified node number.
.PARAMETER SlotList
	Specifies one or more PCI slots. Slots are identified by one or more integers. Multiple slots are separated with a single comma (1,2,3). 
	A range of slots is separated with a hyphen (0–7). The primary path of the disks must be on the specified PCI slot number(s).
.PARAMETER PortList
	Specifies one or more ports. Ports are identified by one or more integers. Multiple ports are separated with a single comma (1,2,3). 
	A range of ports is separated with a hyphen (0–4). The primary path of the disks must be on the specified port number(s).
.PARAMETER CageList
	Specifies one or more drive cages. Drive cages are identified by one or more integers. Multiple drive cages are separated with a single comma (1,2,3). 
	A range of drive cages is separated with a hyphen (0– 3). The specified drive cage(s) must contain disks.
.PARAMETER MagList 
	Specifies one or more drive magazines. Drive magazines are identified by one or more integers. Multiple drive magazines are separated with a single comma (1,2,3). 
	A range of drive magazines is separated with a hyphen (0–7). The specified magazine(s) must contain disks.  
.PARAMETER DiskPosList
	Specifies one or more disk positions within a drive magazine. Disk positions are identified by one or more integers. Multiple disk positions are separated with a single comma (1,2,3). 
	A range of disk positions is separated with a hyphen (0–3). The specified portion(s) must contain disks.
.PARAMETER DiskList
	Specifies one or more physical disks. Disks are identified by one or more integers. Multiple disks are separated with a single comma (1,2,3). 
	A range of disks is separated with a hyphen (0–3). Disks must match the specified ID(s). 
.PARAMETER TotalChunkletsGreaterThan
	Specifies that physical disks with total chunklets greater than the number specified be selected.  
.PARAMETER TotalChunkletsLessThan
	Specifies that physical disks with total chunklets less than the number specified be selected. 
.PARAMETER FreeChunkletsGreaterThan
	Specifies that physical disks with free chunklets less than the number specified be selected.  
.PARAMETER FreeChunkletsLessThan
	Specifies that physical disks with free chunklets greater than the number specified be selected. 
.PARAMETER DiskType
	Specifies that physical disks must have the specified device type.
	FC Fibre Channel
	NL Near Line
	SSD SSD
.PARAMETER Rpm
	Disks must be of the specified speed.
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
	[String]	$CPGName,
	[String]	$NewName,
	[Boolean]	$DisableAutoGrow = $false,
	[Boolean]	$RmGrowthLimit = $false,
	[Boolean]	$RmWarningAlert = $false,
	[ValidateSet('R0','R1','R5','R6')]
    [string]	$RAIDType = $null, 
    [int]		$SetSize = $null,
    [ValidateSet('PORT','CAGE','MAG')]
	[string]	$HA = $null,
    [ValidateSet('FIRST','LAST')]
	[string]	$Chunklets = $null,
	[String]	$NodeList = $null,
	[String]	$SlotList = $null,
	[String]	$PortList = $null,
	[String]	$CageList = $null,
	[String]	$MagList = $null,
	[String]	$DiskPosList = $null,
	[String]	$DiskList = $null,
	[int]		$TotalChunkletsGreaterThan = $null,
	[int]		$TotalChunkletsLessThan = $null,
	[int]		$FreeChunkletsGreaterThan = $null,
	[int]		$FreeChunkletsLessThan = $null,
	[ValidateSet('FC','NL','SSD')]
	[int]		$DiskType = $null,
	[int]		$Rpm = $null
	)
Begin 
{	Test-WSAPIConnection
}
Process 
{	# Creation of the body hash
	Write-DebugLog "Running: Creation of the body hash" $Debug
    $body = @{}
    If ($NewName) 			{ 	$body["newName"] 			= "$($NewName)" 	} 
	If($DisableAutoGrow) 	{ 	$body["disableAutoGrow"]	= $DisableAutoGrow 	} 
    If($RmGrowthLimit) 		{ 	$body["rmGrowthLimit"] 		= $RmGrowthLimit 	} 
    If($RmWarningAlert) 	{ 	$body["rmWarningAlert"] 	= $RmWarningAlert	} 
	$LDLayoutBody = @{}
	if($RAIDType -eq "R0")	{	$LDLayoutBody["RAIDType"] 	= 1 				}
	if($RAIDType -eq "R1")	{	$LDLayoutBody["RAIDType"] 	= 2					}
	if($RAIDType -eq "R5")	{	$LDLayoutBody["RAIDType"] 	= 3					}
	if($RAIDType -eq "R6")	{	$LDLayoutBody["RAIDType"] 	= 4					}
    if($SetSize)			{	$LDLayoutBody["setSize"] 	= $SetSize			}
	if($HA -eq "PORT")		{	$LDLayoutBody["HA"] 		= 1					}
	if($HA -eq "CAGE")		{	$LDLayoutBody["HA"] 		= 2					}
	if($HA -eq "MAG")		{	$LDLayoutBody["HA"] 		= 3					}
	if($Chunklets -eq "FIRST"){	$LDLayoutBody["chunkletPosPref"] = 1			}
	if($Chunklets -eq "LAST"){	$LDLayoutBody["chunkletPosPref"] = 2			}
	$LDLayoutDiskPatternsBody=@()	
	if ($NodeList)
		{	$nodList=@{}
			$nodList["nodeList"] = "$($NodeList)"	
			$LDLayoutDiskPatternsBody += $nodList 			
		}
	if ($SlotList)
		{	$sList=@{}
			$sList["slotList"] = "$($SlotList)"	
			$LDLayoutDiskPatternsBody += $sList 		
		}	
	if ($PortList)
		{	$pList=@{}
			$pList["portList"] = "$($PortList)"	
			$LDLayoutDiskPatternsBody += $pList 		
		}
	if ($CageList)
		{	$cagList=@{}
			$cagList["cageList"] = "$($CageList)"	
			$LDLayoutDiskPatternsBody += $cagList 		
		}
	if ($MagList)
		{	$mList=@{}
			$mList["magList"] = "$($MagList)"	
			$LDLayoutDiskPatternsBody += $mList 		
		}	
	if ($DiskPosList)
		{	$dpList=@{}
			$dpList["diskPosList"] = "$($DiskPosList)"	
			$LDLayoutDiskPatternsBody += $dpList 		
		}
	if ($DiskList)
		{	$dskList=@{}
			$dskList["diskList"] = "$($DiskList)"	
			$LDLayoutDiskPatternsBody += $dskList 		
		}	
	if ($TotalChunkletsGreaterThan)
		{	$tcgList=@{}
			$tcgList["totalChunkletsGreaterThan"] = $TotalChunkletsGreaterThan	
			$LDLayoutDiskPatternsBody += $tcgList 		
		}
	if ($TotalChunkletsLessThan)
		{	$tclList=@{}
			$tclList["totalChunkletsLessThan"] = $TotalChunkletsLessThan	
			$LDLayoutDiskPatternsBody += $tclList 		
		}
	if ($FreeChunkletsGreaterThan)
		{	$fcgList=@{}
			$fcgList["freeChunkletsGreaterThan"] = $FreeChunkletsGreaterThan	
			$LDLayoutDiskPatternsBody += $fcgList 		
		}
	if ($FreeChunkletsLessThan){	$fclList=@{}
									$fclList["freeChunkletsLessThan"] = $FreeChunkletsLessThan	
									$LDLayoutDiskPatternsBody += $fclList 		
								}
	if($DiskType -eq "FC")	{	$dtList=@{}
								$dtList["diskType"] = 1	
								$LDLayoutDiskPatternsBody += $dtList						
							}
	if($DiskType -eq "NL")	{	$dtList=@{}
								$dtList["diskType"] = 2	
								$LDLayoutDiskPatternsBody += $dtList						
							}
	if($DiskType -eq "SSD")	{	$dtList=@{}
								$dtList["diskType"] = 3	
								$LDLayoutDiskPatternsBody += $dtList						
							}
	if ($Rpm)
		{	$rpmList=@{}
			$rpmList["RPM"] = $Rpm	
			$LDLayoutDiskPatternsBody += $rpmList
		}
	if($LDLayoutDiskPatternsBody.Count -gt 0)	{	$LDLayoutBody["diskPatterns"] = $LDLayoutDiskPatternsBody	}		
	if($LDLayoutBody.Count -gt 0)				{	$body["LDLayout"] = $LDLayoutBody 	}
	Write-DebugLog "Info:Body : $body" $Info    
    $Result = $null
	#Build uri
    $uri = '/cpgs/'+$CPGName	
    #Request
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "`n Cmdlet executed successfully. `n" -foreground green
			Write-DebugLog "SUCCESS: CPG:$CPGName successfully Updated" $Info
			if($NewName)	{	Get-Cpg_WSAPI -CPGName $NewName	}
			else			{	Get-Cpg_WSAPI -CPGName $CPGName	}
			Write-DebugLog "End: Update-Cpg_WSAPI" $Debug
		}
	else
		{	write-Error "`n FAILURE : While Updating CPG:$CPGName `n"
			Write-DebugLog "FAILURE : While creating CPG:$CPGName " $Info	
			return $Result.StatusDescription
		}
}
}

Function Remove-Cpg_WSAPI
{
<#	
.SYNOPSIS
	Removes a Common Provision Group(CPG).
.DESCRIPTION
	Removes a CommonProvisionGroup(CPG)
    This operation requires access to all domains, as well as Super, or Edit roles, or any role granted cpg_remove permission.    
.EXAMPLE    
	Remove-Cpg_WSAPI -CPGName MyCPG
	Removes a Common Provision Group(CPG) "MyCPG".
.PARAMETER CPGName 
    Specify name of the CPG.
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipelinebyPropertyName=$True)]
		[String]$CPGName
	)
Begin 
{ 	Test-WSAPIConnection
}
Process 
{   #Build uri
	Write-DebugLog "Running: Building uri to Remove-Cpg_WSAPI  ." $Debug
	$uri = '/cpgs/'+$CPGName
	#init the response var
	$Result = $null
	#Request
	Write-DebugLog "Request: Request to Remove-Cpg_WSAPI : $CPGName (Invoke-WSAPI)." $Debug
	$Result = Invoke-WSAPI -uri $uri -type 'DELETE'
	$status = $Result.StatusCode
	if($status -eq 200)
		{	write-host "`n Cmdlet executed successfully. `n" -foreground green
			Write-DebugLog "SUCCESS: CPG:$CPGName successfully remove" $Info
			Write-DebugLog "End: Remove-Cpg_WSAPI" $Debug
			return ""		
		}
	else
		{	write-Error "`n FAILURE : While Removing CPG:$CPGName `n"
			Write-DebugLog "FAILURE : While creating CPG:$CPGName " $Info
			Write-DebugLog "End: Remove-Cpg_WSAPI" $Debug
			return $Result.StatusDescription
		}    
}
}

Function Get-Cpg_WSAPI 
{
<#
.SYNOPSIS	
	Get list or single common provisioning groups (CPGs) all CPGs in the storage system.
.DESCRIPTION
	Get list or single common provisioning groups (CPGs) all CPGs in the storage system.
.EXAMPLE
	Get-Cpg_WSAPI
	List all/specified common provisioning groups (CPGs) in the system.
.EXAMPLE
	Get-Cpg_WSAPI -CPGName "MyCPG" 
	List Specified CPG name "MyCPG"
.PARAMETER CPGName
	Specify name of the cpg to be listed
#>
[CmdletBinding()]
Param(	[Parameter(ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
		[String]	$CPGName
		)
Begin 
{	Test-WSAPIConnection 
}
Process 
{	$Result = $null
	$dataPS = $null	
	#Build uri
	if($CPGName)
	{	$uri = '/cpgs/'+$CPGName
		$Result = Invoke-WSAPI -uri $uri -type 'GET'
		if($Result.StatusCode -eq 200)
			{	$dataPS = $Result.content | ConvertFrom-Json
			}
	}
	else
	{	$Result = Invoke-WSAPI -uri '/cpgs' -type 'GET'
		if($Result.StatusCode -eq 200)
			{	$dataPS = ($Result.content | ConvertFrom-Json).members
			}		
	}
	if($Result.StatusCode -eq 200)
		{	write-host "`n Executed successfully. `n" -foreground green
			Write-DebugLog "SUCCESS: CPG:$CPGName Successfully Executed" $Info
			# Add custom type to the resulting oject for formating purpose
			Write-DebugLog "Running: Add custom type to the resulting object for formatting purpose" $Debug
			[array]$AlldataPS = Format-Result -dataPS $dataPS -TypeName ( $ArrayType + '.Cpgs' )		
			return $AlldataPS
		}
	else
		{	write-Error "`n FAILURE : While Executing Get-Cpg_WSAPI CPG:$CPGName `n"
			Write-DebugLog "FAILURE : While Executing Get-Cpg_WSAPI CPG:$CPGName " $Info	
			return $Result.StatusDescription
		}
}	
}

Export-ModuleMember New-Cpg_WSAPI
Export-ModuleMember Update-Cpg_WSAPI
Export-ModuleMember Remove-Cpg_WSAPI
Export-ModuleMember Get-Cpg_WSAPI
