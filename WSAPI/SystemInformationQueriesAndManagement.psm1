## 	© 2019,2020,2023 Hewlett Packard Enterprise Development LP
##	

Function Get-System_WSAPI 
{
<#
.SYNOPSIS	
	Retrieve informations about the array.
.DESCRIPTION
	Retrieve informations about the array.
.EXAMPLE
	Get-System_WSAPI
	Retrieve informations about the array.
#>
[CmdletBinding()]
Param()
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null	
	$dataPS = $null	
	#Request
	$Result = Invoke-WSAPI -uri '/system' -type 'GET'
	if($Result.StatusCode -eq 200)
		{	$dataPS = $Result.content | ConvertFrom-Json
		}	
	if($Result.StatusCode -eq 200)
		{	write-host "`n Cmdlet executed successfully.`n" -foreground green
			Write-DebugLog "SUCCESS:successfully Executed" $Info
			return $dataPS
		}
	else
		{	write-Error "`n FAILURE : While Executing Get-System_WSAPI `n"
			Write-DebugLog "FAILURE : While Executing Get-System_WSAPI" $Info
			return $Result.StatusDescription
		}
}	
}

Function Update-System_WSAPI 
{
<#
.SYNOPSIS
	Update storage system parameters
.DESCRIPTION
	Update storage system parameters
	You can set all of the system parameters in one request, but some updates might fail.
.EXAMPLE
	Update-System_WSAPI -RemoteSyslog $true        
.EXAMPLE
	Update-System_WSAPI -remoteSyslogHost "0.0.0.0"
.EXAMPLE	
	Update-System_WSAPI -PortFailoverEnabled $true
.EXAMPLE	
	Update-System_WSAPI -DisableDedup $true
.EXAMPLE	
	Update-System_WSAPI -OverProvRatioLimit 3
.EXAMPLE	
	Update-System_WSAPI -AllowR5OnFCDrives $true
.PARAMETER RemoteSyslog
	Enable (true) or disable (false) sending events to a remote system as syslog messages.
.PARAMETER RemoteSyslogHost
	IP address of the systems to which events are sent as syslog messages.
.PARAMETER RemoteSyslogSecurityHost
	Sets the hostname or IP address, and optionally the port, of the remote syslog servers to which security events are sent as syslog messages.
.PARAMETER PortFailoverEnabled
	Enable (true) or disable (false) the automatic fail over of target ports to their designated partner ports.
.PARAMETER FailoverMatchedSet
	Enable (true) or disable (false) the automatic fail over of matched-set VLUNs during a persistent port fail over. This does not affect host-see VLUNs, which are always failed over.
.PARAMETER DisableDedup
	Enable or disable new write requests to TDVVs serviced by the system to be deduplicated.
	true – Disables deduplication
	false – Enables deduplication
.PARAMETER DisableCompr
	Enable or disable the compression of all new write requests to the compressed VVs serviced by the system.
	True - The new writes are not compressed.
	False - The new writes are compressed.
.PARAMETER OverProvRatioLimit
	The system, device types, and all CPGs are limited to the specified overprovisioning ratio.
.PARAMETER OverProvRatioWarning
	An overprovisioning ratio, which when exceeded by the system, a device type, or a CPG, results in a warning alert.
.PARAMETER AllowR5OnNLDrives
	Enable (true) or disable (false) support for RAID-5 on NL drives.
.PARAMETER AllowR5OnFCDrives
	Enable (true) or disable (false) support for RAID-5 on FC drives.
.PARAMETER ComplianceOfficerApproval
	Enable (true) or disable (false) compliance officer approval mode.
#>
[CmdletBinding()]
Param(	[boolean]	$RemoteSyslog,
		[String]	$RemoteSyslogHost,
		[String]	$RemoteSyslogSecurityHost,
		[boolean]	$PortFailoverEnabled,
		[boolean]	$FailoverMatchedSet,
		[boolean]	$DisableDedup,
		[boolean]	$DisableCompr,
		[int]		$OverProvRatioLimit,
		[int]		$OverProvRatioWarning,
		[boolean]  	$AllowR5OnNLDrives,
		[boolean]	$AllowR5OnFCDrives,
		[boolean]	$ComplianceOfficerApproval
)
Begin 
{	Test-WSAPIConnection
}
Process 
{  	$body = @{}	
	$ObjMain=@{}		
	If ($RemoteSyslog) 
	{
		$Obj=@{}
		$Obj["remoteSyslog"] = $RemoteSyslog
		$ObjMain += $Obj				
    }
	If ($RemoteSyslogHost) 
	{
		$Obj=@{}
		$Obj["remoteSyslogHost"] = "$($RemoteSyslogHost)"
		$ObjMain += $Obj
    }
	If ($RemoteSyslogSecurityHost) 
	{
		$Obj=@{}
		$Obj["remoteSyslogSecurityHost"] = "$($RemoteSyslogSecurityHost)"
		$ObjMain += $Obj		
    }
	If ($PortFailoverEnabled) 
	{
		$Obj=@{}
		$Obj["portFailoverEnabled"] = $PortFailoverEnabled
		$ObjMain += $Obj			
    }
	If ($FailoverMatchedSet) 
	{
		$Obj=@{}
		$Obj["failoverMatchedSet"] = $FailoverMatchedSet
		$ObjMain += $Obj				
    }
	If ($DisableDedup) 
	{
		$Obj=@{}
		$Obj["disableDedup"] = $DisableDedup
		$ObjMain += $Obj				
    }
	If ($DisableCompr) 
	{
		$Obj=@{}
		$Obj["disableCompr"] = $DisableCompr
		$ObjMain += $Obj				
    }
	If ($OverProvRatioLimit) 
	{
		$Obj=@{}
		$Obj["overProvRatioLimit"] = $OverProvRatioLimit
		$ObjMain += $Obj				
    }
	If ($OverProvRatioWarning) 
	{
		$Obj=@{}
		$Obj["overProvRatioWarning"] = $OverProvRatioWarning	
		$ObjMain += $Obj			
    }
	If ($AllowR5OnNLDrives) 
	{
		$Obj=@{}
		$Obj["allowR5OnNLDrives"] = $AllowR5OnNLDrives	
		$ObjMain += $Obj				
    }
	If ($AllowR5OnFCDrives) 
	{
		$Obj=@{}
		$Obj["allowR5OnFCDrives"] = $AllowR5OnFCDrives	
		$ObjMain += $Obj				
    }
	If ($ComplianceOfficerApproval) 
	{
		$Obj=@{}
		$Obj["complianceOfficerApproval"] = $ComplianceOfficerApproval	
		$ObjMain += $Obj				
    }
	
	if($ObjMain.Count -gt 0)	{	$body["parameters"] = $ObjMain 	}	
    $Result = $null
    #Request
	Write-DebugLog "Request: Request to Update-System_WSAPI (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri '/system' -type 'PUT' -body $body
	
	if($Result.StatusCode -eq 200)
		{	write-host "`n Cmdlet executed successfully. `n" -foreground green
			Write-DebugLog "SUCCESS: Successfully Update storage system parameters." $Info	
			# Results		
			Get-System_WSAPI		
			Write-DebugLog "End: Update-System_WSAPI" $Debug
		}
	else
		{	write-Error "`n FAILURE : While Updating storage system parameters.`n"
			Write-DebugLog "FAILURE : While Updating storage system parameters." $Info
			return $Result.StatusDescription
		}
}
}

Function Get-Version_WSAPI 
{
<#
.SYNOPSIS	
	Get version information.
.DESCRIPTION
	Get version information.
.EXAMPLE
	Get-Version_WSAPI
	Get version information.
#>
[CmdletBinding()]
Param()
Begin 
{	Test-WSAPIConnection
}
Process 
{	$Result = $null	
	$dataPS = $null	
	$ip = $WsapiConnection.IPAddress
	$key = $WsapiConnection.Key
	$arrtyp = $global:ArrayType	
	$APIurl = $Null
	if($arrtyp.ToLower() -eq "3par")	{	$APIurl = 'https://'+$ip+':8080/api'	}	#$APIurl = "https://$($SANIPAddress):8080/api/v1"
	if(($arrtyp.ToLower() -eq "primera") -or ($arrtyp.ToLower() -eq "alletra9000"))	{	$APIurl = 'https://'+$ip+':443/api'}	#$APIurl = "https://$($SANIPAddress):443/api/v1"
    #Construct header
	Write-DebugLog "Running: Constructing header." $Debug
	$headers = @{}
    $headers["Accept"] = "application/json"
    $headers["Accept-Language"] = "en"
    $headers["Content-Type"] = "application/json"
    $headers["X-HP3PAR-WSAPI-SessionKey"] = $key	
	#Request
	if ($PSEdition -eq 'Core')	{	$Result = Invoke-WebRequest -Uri "$APIurl" -Headers $headers -Method GET -UseBasicParsing -SkipCertificateCheck } 
	else {	$Result = Invoke-WebRequest -Uri "$APIurl" -Headers $headers -Method GET -UseBasicParsing  }
	if($Result.StatusCode -eq 200)	{	$dataPS = $Result.content | ConvertFrom-Json }
	if($Result.StatusCode -eq 200)
		{	write-host "`n Cmdlet executed successfully. `n" -foreground green
			Write-DebugLog "SUCCESS:successfully Executed" $Info
			return $dataPS
		}
	else
		{	write-Error "`nFAILURE : While Executing Get-Version_WSAPI`n "
			Write-DebugLog "FAILURE : While Executing Get-Version_WSAPI" $Info
			return $Result.StatusDescription
		}
}	
}

Function Get-WSAPIConfigInfo 
{
<#
.SYNOPSIS	
	Get Getting WSAPI configuration information
.DESCRIPTION
	Get Getting WSAPI configuration information
.EXAMPLE
	Get-WSAPIConfigInfo
	Get Getting WSAPI configuration information
#>
[CmdletBinding()]
Param()
Begin 
{	Test-WSAPIConnection 
}
Process 
{	$Result = $null	
	$dataPS = $null		
	#Request
	$Result = Invoke-WSAPI -uri '/wsapiconfiguration' -type 'GET'
	if($Result.StatusCode -eq 200)	{	$dataPS = $Result.content | ConvertFrom-Json	}
	if($Result.StatusCode -eq 200)
		{	write-host "`n Cmdlet executed successfully. `n" -foreground green
			Write-DebugLog "SUCCESS:successfully Executed" $Info
			return $dataPS
		}
	else
		{	write-Error "`n FAILURE : While Executing Get-WSAPIConfigInfo. `n"
			Write-DebugLog "FAILURE : While Executing Get-WSAPIConfigInfo" $Info
			return $Result.StatusDescription
	}
}	
}

Function Get-Task_WSAPI 
{
<#
.SYNOPSIS	
	Get the status of all or given tasks
.DESCRIPTION
	Get the status of all or given tasks
.EXAMPLE
	Get-Task_WSAPI
	Get the status of all tasks
.EXAMPLE
	Get-Task_WSAPI -TaskID 101
	Get the status of given tasks
.PARAMETER TaskID	
    Task ID
#>
[CmdletBinding()]
Param(	[String]	$TaskID
	)
Begin 
{	Test-WSAPIConnection -WsapiConnection $WsapiConnection
}
Process 
{	$Result = $null
	$dataPS = $null	
	#Build uri
	if($TaskID)
		{	$uri = '/tasks/'+$TaskID
			#Request
			$Result = Invoke-WSAPI -uri $uri -type 'GET'
			if($Result.StatusCode -eq 200)	{	$dataPS = $Result.content | ConvertFrom-Json	}
		}
	else
		{	#Request
			$Result = Invoke-WSAPI -uri '/tasks' -type 'GET'
			if($Result.StatusCode -eq 200)	{	$dataPS = ($Result.content | ConvertFrom-Json).members	}		
		}
	if($Result.StatusCode -eq 200)
		{	write-host "`n Cmdlet executed successfully. `n" -foreground green
			Write-DebugLog "SUCCESS: Command Get-Task_WSAPI Successfully Executed" $Info
			return $dataPS
		}
	else
		{	write-Error "FAILURE : While Executing Get-Task_WSAPI." 
			Write-DebugLog "FAILURE : While Executing Get-Task_WSAPI." $Info
			return $Result.StatusDescription
		}
}	
}

Function Stop-OngoingTask_WSAPI 
{
<#
.SYNOPSIS
	Cancels the ongoing task.
.DESCRIPTION
	Cancels the ongoing task.
.EXAMPLE
	Stop-OngoingTask_WSAPI -TaskID 1
.PARAMETER TaskID
	Task id.
#>
[CmdletBinding()]
Param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[String]	$TaskID
)
Begin 
{	Test-WSAPIConnection 
}
Process 
{  	$body = @{}	
	$body["action"] = 4
    $Result = $null	
	$uri = "/tasks/" + $TaskID
    #Request
	Write-DebugLog "Request: Request to Stop-OngoingTask_WSAPI : $TaskID (Invoke-WSAPI)." $Debug
    $Result = Invoke-WSAPI -uri $uri -type 'PUT' -body $body
	if($Result.StatusCode -eq 200)
		{	write-host "`n Cmdlet executed successfully. `n" -foreground green
			Write-DebugLog "SUCCESS: Successfully Cancels the ongoing task : $TaskID ." $Info	
			# Results		
			return $Result		
			Write-DebugLog "End: Stop-OngoingTask_WSAPI." $Debug
		}
	else
		{
		write-Error "`nFAILURE : While Cancelling the ongoing task : $TaskID `n"
		Write-DebugLog "FAILURE : While Cancelling the ongoing task : $TaskID " $Info
		return $Result.StatusDescription
	}
}
}

Export-ModuleMember Get-System_WSAPI , Update-System_WSAPI , Get-Version_WSAPI , Get-WSAPIConfigInfo , Get-Task_WSAPI , Stop-OngoingTask_WSAPI
