####################################################################################
## 	© 2020,2021,2023 Hewlett Packard Enterprise Development LP
##	Description: 	Internal cmdlets
##		

$Info = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Function Close-Connection
{
<#
.SYNOPSIS   
	Session Management Command to close the connection
.DESCRIPTION
	Session Management Command to close the connection
.EXAMPLE
	Close-Connection
#>
[CmdletBinding()]
param(	$SANConnection = $global:SANConnection       
	)
Process
{	if (($global:WsapiConnection) -or ($global:ConnectionType -eq "WSAPI"))
		{	write-error "A WSAPI Session is enabled. Use Close-WSAPIConnection cmdlet to close and exit from the current WSAPI session"
			return
		}
	if (!$SANConnection)
		{	write-error "No active CLI/PoshSSH session/connection exists"
			return
		}	
	$SANCOB = $SANConnection		
	$clittype = $SANCOB.CliType
	$SecnId =""
	if($clittype -eq "SshClient")	{	$SecnId = $SANCOB.SessionId	}	
	$global:SANConnection = $null
	$SANConnection = $global:SANConnection
	if(!$SANConnection)
	{	$Validate1 = Test-CLIConnection $SANConnection
		if($Validate1 -eq "Failed")
		{	$Validate2 = Test-CLIConnection $global:SANConnection
			if($Validate2 -eq "Failed")
			{	Write-warning "Connection object is null/empty or Connection object username, password, IPAaddress are null/empty. Create a valid connection object using New-CLIConnection or New-PoshSshConnection" "ERR:"
				Write-error "Stop: Exiting GGet-UserConnection since SAN connection object values are null/empty"
				if($clittype -eq "SshClient")
					{	$res = Remove-SSHSession -Index $SecnId
						clear-variable -name res  
					}				
				if ($global:SANConnection -eq $null)
					{	$global:ConnectionType = $null	
						Function global:prompt {(Get-Location).Path + ">"}
					}
				Write-host "Success : Exiting SAN connection session End`n" -ForegroundColor Green
				return 
			}
		}
	}	
}
}

Function Get-CmdList
{
<#
.SYNOPSIS
    Get list of  all HPE Alletra 9000, Primera and 3PAR PowerShell cmdlets
.DESCRIPTION
    Note : This cmdlet (Get-CmdList) is deprecated and will be removed in a 
	subsequent release of PowerShell Toolkit. Consider using the cmdlet (Get-CmdList) instead.
	Get list of  all HPE Alletra 9000, Primera and 3PAR PowerShell cmdlets 
.EXAMPLE
    Get-CmdList	
	List all available HPE Alletra 9000, Primera and 3PAR PowerShell cmdlets.
.EXAMPLE
    Get-CmdList -WSAPI
	List all available HPE Alletra 9000, Primera and 3PAR PowerShell WSAPI cmdlets only.
.EXAMPLE
    Get-CmdList -CLI
	List all available HPE Alletra 9000, Primera and 3PAR PowerShell CLI cmdlets only.
#>
[CmdletBinding()]
param(	[Switch]	$CLI, 	
		[Switch]	$WSAPI
	)
Process
{   $Array = @()
	$psToolKitModule = (Get-Module HPEStoragePowerShellToolkit);
    $nestedModules = $psToolKitModule.NestedModules;
    $noOfNestedModules = $nestedModules.Count;
    $totalCmdlets = 0;
    $totalCLICmdlets = 0;
    $totalWSAPICmdlets = 0;
    $totalDeprecatedCmdlets = 0;
    if($WSAPI)
    {	foreach ($nestedModule in $nestedModules[0..$noOfNestedModules])
        {   $ExpCmdlets = $nestedModule.ExportedCommands;
			if ($nestedModule.Path.Contains("\WSAPI\"))
            {   foreach ($h in $ExpCmdlets.GetEnumerator()) 
                {   $Result1 = "" | Select-Object CmdletName, CmdletType, ModuleVersion, SubModule, Module, Remarks
                    $Result1.CmdletName = $($h.Key);            
                    $Result1.ModuleVersion = $psToolKitModule.Version;
                    $Result1.CmdletType = "WSAPI";
                    $Result1.SubModule = $nestedModule.Name;
                    $Result1.Module = $psToolKitModule.Name;
                    If ($nestedModule.Name -eq "HPE3PARPSToolkit-WSAPI")
                    {	$Result1.Remarks = "Deprecated";
                        $totalDeprecatedCmdlets += 1;
                    }
                    $totalCmdlets += 1;
                    $totalWSAPICmdlets += 1;
                    $Array += $Result1
                }
            }
        }
    }
    elseif($CLI)
    {	foreach ($nestedModule in $nestedModules[0..$noOfNestedModules])
        {   $ExpCmdlets = $nestedModule.ExportedCommands;    
            if ($nestedModule.Path.Contains("\CLI\"))
            {   foreach ($h in $ExpCmdlets.GetEnumerator()) 
                {   $Result1 = "" | Select-object CmdletName, CmdletType, ModuleVersion, SubModule, Module, Remarks
                    $Result1.CmdletName = $($h.Key);            
                    $Result1.ModuleVersion = $psToolKitModule.Version;
                    $Result1.CmdletType = "CLI";
                    $Result1.SubModule = $nestedModule.Name;
                    $Result1.Module = $psToolKitModule.Name;
                    If ($nestedModule.Name -eq "HPE3PARPSToolkit-CLI")
                    {   $Result1.Remarks = "Deprecated";
                        $totalDeprecatedCmdlets += 1;
                    }
                    $totalCmdlets += 1;
                    $totalCLICmdlets += 1;
                    $Array += $Result1
                }
            }
        }
    }
    else
    {   foreach ($nestedModule in $nestedModules[0..$noOfNestedModules])
        {   if ($nestedModule.Path.Contains("\CLI\") -or $nestedModule.Path.Contains("\WSAPI\"))        
            {	$ExpCmdlets = $nestedModule.ExportedCommands;    
                foreach ($h in $ExpCmdlets.GetEnumerator()) 
                {   $Result1 = "" | Select-object CmdletName, CmdletType, ModuleVersion, SubModule, Module, Remarks
                    $Result1.CmdletName = $($h.Key);            
                    $Result1.ModuleVersion = $psToolKitModule.Version;                
                    $Result1.SubModule = $nestedModule.Name;
                    $Result1.Module = $psToolKitModule.Name;                
                    $Result1.CmdletType = if ($nestedModule.Path.Contains("\CLI\")) {"CLI"} else {"WSAPI"}
					If ($nestedModule.Name -eq "HPE3PARPSToolkit-WSAPI" -or $nestedModule.Name -eq "HPE3PARPSToolkit-CLI")
                    {	$Result1.Remarks = "Deprecated";
                        $totalDeprecatedCmdlets += 1;
                    }
                    $totalCmdlets += 1;                            
                    $Array += $Result1
                }            
            }        
        }
    }
    $Array | Format-Table
    $Array = $null;
    Write-Host "$totalCmdlets Cmdlets listed. ($totalDeprecatedCmdlets are deprecated)";
} 
}

Function Get-FcPorts
{
<#
.SYNOPSIS
	Query to get FC ports. 
.DESCRIPTION
	Get information for FC Ports. This command also replaces the old Get-FCPortsToCSV command since there is a default way to output this powershell object into a CSV using ConvertToCSV
.EXAMPLE
	Get-FcPorts 
.NOTES
	This command required the use of an SSH tunnel as no WSAPI call exists to generate this exact data.
#>
[CmdletBinding()]
Param(	$SANConnection=$Global:SANConnection
	)
Process
{	$plinkresult = Test-PARCli -SANConnection $SANConnection 
	if($plinkresult -match "FAILURE :")
	{	write-debuglog "$plinkresult" "ERR:" 
		return $plinkresult
	}
	$ListofPorts = Get-HostPorts -SANConnection $SANConnection| where-object { ( $_.Type -eq "host" ) -and ($_.Protocol -eq "FC")}
	$Port_Pattern = "(\d):(\d):(\d)"							# Pattern matches value of port: 1:2:3
	$WWN_Pattern = "([0-9a-f][0-9a-f])" * 8						# Pattern matches value of WWN
	$ColObj=@()
	$ReturnObj=[pscustomobject]@{}	
	foreach ($Port in $ListofPorts)
	{	$NSP  = $Port.Device
		#$SW = $NSP.Split(':')[-1]	
		$NSP = $NSP -replace $Port_Pattern , 'N$1:S$2:P$3'
		$WWN = $Port.Port_WWN
		$WWN = $WWN -replace $WWN_Pattern , '$1:$2:$3:$4:$5:$6:$7:$8'
		$ReturnObj=[pscustomobject]@{ Controller = $NSP; WWN = $WWN }	
		$ColObj += $ReturnObj
	}
	return $ColObj
}
}

function Get-ConnectedSession 
{
<#
.SYNOPSIS
    Command Get-ConnectedSession display connected session detail
.DESCRIPTION
	Command Get-ConnectedSession display connected session detail 
.EXAMPLE
    Get-ConnectedSession
#>
Process
{  	return $global:SANConnection		 
}
}

Function New-PoshSshConnection
{
<#
.SYNOPSIS
    Builds a SAN Connection object using Posh SSH connection
.DESCRIPTION
	Creates a SAN Connection object with the specified parameters. 
    No connection is made by this cmdlet call, it merely builds the connection object. 
.EXAMPLE
    New-PoshSshConnection -SANUserName Administrator -SANPassword mypassword -ArrayNameOrIPAddress 10.1.1.1 
	Creates a SAN Connection object with the specified Array Name or Array IP Address
.EXAMPLE
    New-PoshSshConnection -SANUserName Administrator -SANPassword mypassword -ArrayNameOrIPAddress 10.1.1.1 -AcceptKey
	Creates a SAN Connection object with the specified Array Name or Array IP Address
.PARAMETER UserName 
    Specify the SAN Administrator user name.
.PARAMETER Password 
    Specify the SAN Administrator password 
.PARAMETER ArrayNameOrIPAddress 
    Specify Array Name or Array IP Address
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String] 	$ArrayNameOrIPAddress,
		[Parameter(Mandatory=$true)]	[String]	$SANUserName,
										[String]	$SANPassword,
										[switch]	$AcceptKey
		)
Process
{	$Session
	if (Get-Module -ListAvailable -Name Posh-SSH) 
		{ <# do nothing #> }
	else 
		{ 	try
				{	# install the module automatically
					[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
					Invoke-Expression (New-Object Net.WebClient).DownloadString("https://gist.github.com/darkoperator/6152630/raw/c67de4f7cd780ba367cccbc2593f38d18ce6df89/instposhsshdev")
				}
			catch
				{	$msg = "Error occurred while installing POSH SSH Module. `nPlease check if internet is enabled. If internet is enabled and you are getting this error,`n Execute Save-Module -Name Posh-SSH -Path <path Ex D:\xxx> `n Then Install-Module -Name Posh-SSH `n If you are getting error like Save-Module is incorrect then `n Check you Power shell Version and Update to 5.1 for this particular Process  `n Or visit https://www.powershellgallery.com/packages/Posh-SSH/2.0.2 `n"
					write-error "`n Failure : $msg"
					return 
				}			
		}	
	# Authenticate		
	try
		{	if(!($SANPassword))
				{	$securePasswordStr = Read-Host "SANPassword" -AsSecureString				
					$mycreds = New-Object System.Management.Automation.PSCredential ($SANUserName, $securePasswordStr)
				}
			else
				{	$tempstring  = convertto-securestring $SANPassword -asplaintext -force				
					$mycreds = New-Object System.Management.Automation.PSCredential ($SANUserName, $tempstring)									
				}
			try
			{	if($AcceptKey) 	{	$Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential $mycreds -AcceptKey   }
				else 			{	$Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential $mycreds				}
			}
			catch 
			{	$msg = "In function New-PoshSshConnection. "
				$msg+= $_.Exception.ToString()	
				Write-Exception $msg -error
				Write-Error "Failure : $msg"		
				return 
			}
			Write-warning "Running: Executed . Check on PS console if there are any errors reported" 
			if (!$Session)
			{	write-error "New-PoshSshConnection command failed to connect the array."
				return
			}
		}
	catch 
		{	$msg = "In function New-PoshSshConnection. "
			$msg+= $_.Exception.ToString()	
			Write-Error "Failure : $msg"
			return
		}					
	$global:SANObjArr += @()
	$global:SANObjArr1 += @()
	if($global:SANConnection)
		{	$SANC = New-Object "_SANConnection"
			$SANC.SessionId = $Session.SessionId		
			$SANC.IPAddress = $ArrayNameOrIPAddress			
			$SANC.UserName = $SANUserName
			$SANC.epwdFile = "Secure String"			
			$SANC.CLIType = "SshClient"
			$SANC.CLIDir = "Null"			
			$global:SANConnection = $SANC
			$SystemDetails = Get-System
			$SANC.Name = $SystemDetails.Name
			$SANC.SystemVersion = Get-Version -S -B
			$SANC.Model = $SystemDetails.Model
			$SANC.Serial = $SystemDetails.Serial
			$SANC.TotalCapacityMiB = $SystemDetails.TotalCap
			$SANC.AllocatedCapacityMiB = $SystemDetails.AllocCap
			$SANC.FreeCapacityMiB = $SystemDetails.FreeCap
			$global:ArrayName = $SANC.Name
			$global:ConnectionType = "CLI"
			###making multiple object support
			$SANC1 = New-Object "_TempSANConn"
			$SANC1.IPAddress = $ArrayNameOrIPAddress			
			$SANC1.UserName = $SANUserName
			$SANC1.epwdFile = "Secure String"		
			$SANC1.SessionId = $Session.SessionId			
			$SANC1.CLIType = "SshClient"
			$SANC1.CLIDir = "Null"		
			$global:SANObjArr += @($SANC)
			$global:SANObjArr1 += @($SANC1)			
		}
		else
		{	$global:SANObjArr = @()
			$global:SANObjArr1 = @()
			$SANC = New-Object "_SANConnection"
			$SANC.IPAddress = $ArrayNameOrIPAddress			
			$SANC.UserName = $SANUserName			
			$SANC.epwdFile = "Secure String"		
			$SANC.SessionId = $Session.SessionId
			$SANC.CLIType = "SshClient"
			$SANC.CLIDir = "Null"
			$global:SANConnection = $SANC		
			$SystemDetails = Get-System
			$SANC.Name = $SystemDetails.Name
			$SANC.SystemVersion = Get-Version -S -B
			$SANC.Model = $SystemDetails.Model
			$SANC.Serial = $SystemDetails.Serial
			$SANC.TotalCapacityMiB = $SystemDetails.TotalCap
			$SANC.AllocatedCapacityMiB = $SystemDetails.AllocCap
			$SANC.FreeCapacityMiB = $SystemDetails.FreeCap
			$global:ArrayName = $SANC.Name
			$global:ConnectionType = "CLI"
			###making multiple object support
			$SANC1 = New-Object "_TempSANConn"
			$SANC1.IPAddress = $ArrayNameOrIPAddress			
			$SANC1.UserName = $SANUserName
			$SANC1.epwdFile = "Secure String"
			$SANC1.SessionId = $Session.SessionId
			$SANC1.CLIType = "SshClient"
			$SANC1.CLIDir = "Null"		
			$global:SANObjArr += @($SANC)
			$global:SANObjArr1 += @($SANC1)		
		}
	return $SANC
}
}

Function Set-PoshSshConnectionPasswordFile
{
<#
.SYNOPSIS
	Creates a encrypted password file on client machine to be used by "Set-PoshSshConnectionUsingPasswordFile"
.DESCRIPTION
	Creates an encrypted password file on client machine
.EXAMPLE
	Set-PoshSshConnectionPasswordFile -ArrayNameOrIPAddress "15.1.1.1" -SANUserName "3parDemoUser"  -$SANPassword "demoPass1"  -epwdFile "C:\hpe3paradmepwd.txt"
	
	This examples stores the encrypted password file hpe3paradmepwd.txt on client machine c:\ drive, subsequent commands uses this encryped password file ,
	This example authenticates the entered credentials if correct creates the password file.
.PARAMETER SANUserName 
    Specify the SAN SANUserName .
.PARAMETER ArrayNameOrIPAddress 
    Specify Array Name or Array IP Address
.PARAMETER SANPassword 
    Specify the Password with the Linked IP
.PARAMETER epwdFile 
    Specify the file location to create encrypted password file
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]							[String] 	$ArrayNameOrIPAddress,
		[Parameter(Mandatory=$true)]							[String]	$SANUserName,	
		[Parameter(ParameterSetName='Arg',  Mandatory=$true)]	[String]	$SANPassword,
		[Parameter(ParameterSetName='File', Mandatory=$true)]	[String]    $epwdFile=$null,
																[switch]	$AcceptKey       
	)	
Process
{	try
	{	if($PSCmdlet.ParameterSetName -eq 'File')
		{	$securePasswordStr = Read-Host "SANPassword" -AsSecureString				
			$mycreds = New-Object System.Management.Automation.PSCredential ($SANUserName, $securePasswordStr)
			$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePasswordStr)
			$tempPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
		}
		if($PSCmdlet.ParameterSetName -eq 'Arg')
		{	$tempstring  = convertto-securestring $SANPassword -asplaintext -force				
			$mycreds = New-Object System.Management.Automation.PSCredential ($SANUserName, $tempstring)	
			$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($tempstring)
			$tempPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
		}			
		if($AcceptKey) 
		{	$Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential $mycreds -AcceptKey
		}
		else 
		{	$Session = New-SSHSession -ComputerName $ArrayNameOrIPAddress -Credential $mycreds
		}
		
		if (!$Session)
		{	write-error "FAILURE : In function Set-PoshSshConnectionPasswordFile."
			return
		}
		else
		{	$RemoveResult = Remove-SSHSession -Index $Session.SessionId
		}		
		$Enc_Pass = Protect-String $tempPwd 
		$Enc_Pass,$ArrayNameOrIPAddress,$SANUserName | Export-CliXml $epwdFile	
	}
	catch 
	{	$msg = "In function Set-PoshSshConnectionPasswordFile. "
		$msg+= $_.Exception.ToString()	
		Write-Exception $msg -error		
		write-error "FAILURE : $msg `n credentials incorrect"
		return
	}
	Write-Error "Running: encrypted password file has been created successfully and the file location is $epwdFile "
	return 
}
}

Function Set-PoshSshConnectionUsingPasswordFile
{
<#
.SYNOPSIS
    Creates a SAN Connection object using Encrypted password file
.DESCRIPTION
	Creates a SAN Connection object using Encrypted password file.
    No connection is made by this cmdlet call, it merely builds the connection object. 
.EXAMPLE
    Set-PoshSshConnectionUsingPasswordFile  -ArrayNameOrIPAddress 10.1.1.1 -SANUserName "3parUser" -epwdFile "C:\HPE3PARepwdlogin.txt"
	Creates a SAN Connection object with the specified the Array Name or Array IP Address and password file
.PARAMETER ArrayNameOrIPAddress 
    Specify Array Name or Array IP Address
.PARAMETER SANUserName
	Specify the SAN UserName.
.PARAMETER epwdFile 
    Specify the encrypted password file location , example “c:\hpe3parstoreserv244.txt” To create encrypted password file use “New-3parSSHCONNECTION_PassFile” cmdlet           
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]    $ArrayNameOrIPAddress,
		[Parameter(Mandatory=$true)]	[String]    $SANUserName,
		[Parameter(Mandatory=$true)]	[String]    $epwdFile        
	)
Process
{ 	try{			
		if( -not (Test-Path $epwdFile))
		{	Write-warning "Running: Path for encrypted password file  was not found. Now created new epwd file." "INFO:"
			write-warning "Encrypted password file does not exist , create encrypted password file using 'Set-3parSSHConnectionPasswordFile' "
			return
		}		
		$tempFile=$epwdFile			
		$Temp=import-CliXml $tempFile
		$pass=$temp[0]
		$ip=$temp[1]
		$user=$temp[2]
		if($ip -eq $ArrayNameOrIPAddress)  
		{	if($user -eq $SANUserName)
			{	$Passs = UnProtect-String $pass 
				New-PoshSshConnection -ArrayNameOrIPAddress $ArrayNameOrIPAddress -SANUserName $SANUserName -SANPassword $Passs
			}
			else
			{ 	write-warning "Password file SANUserName $user and entered SANUserName $SANUserName dose not match. "
				return
			}
		}
		else 
		{	write-warning "Password file ip $ip and entered ip $ArrayNameOrIPAddress dose not match"
			return
		}
	}
	catch 
	{	$msg = "In function Set-PoshSshConnectionUsingPasswordFile. "
		$msg+= $_.Exception.ToString()	
		Write-Exception $msg -error		
		write-error "FAILURE : $msg"
		return
	}
} 
}

Function Get-UserConnectionTemp
{
<#
.SYNOPSIS
    Displays information about users who are currently connected (logged in) to the storage system.
.DESCRIPTION
	Displays information about users who are currently connected (logged in) to the storage system.
.EXAMPLE
    Get-UserConnection  -ArrayNameOrIPAddress 10.1.1.1 -CLIDir "C:\cli.exe" -epwdFile "C:\HPE3parepwdlogin.txt" -Option current
	Shows all information about the current connection only.
.EXAMPLE
    Get-UserConnection  -ArrayNameOrIPAddress 10.1.1.1 -CLIDir "C:\cli.exe" -epwdFile "C:\HPE3parepwdlogin.txt" 
	Shows information about users who are currently connected (logged in) to the storage system.
.PARAMETER ArrayNameOrIPAddress 
    Specify Array Name or Array IP Address
.PARAMETER CLIDir 
    Specify the absolute path of HPE 3PAR cli.exe. Default is "C:\Program Files (x86)\Hewlett Packard Enterprise\HPE 3PAR CLI\bin"
.PARAMETER epwdFile 
    Specify the encrypted password file , if file does not exists it will create encrypted file using deviceip,username and password  
.PARAMETER Option
    current
	Shows all information about the current connection only.
#>
[CmdletBinding()]
param(									[String]	$CLIDir="C:\Program Files (x86)\Hewlett Packard Enterprise\HPE 3PAR CLI\bin",
		[Parameter(Mandatory=$true)]	[String]	$ArrayNameOrIPAddress=$null,
		[Parameter(Mandatory=$true)]	[String]	$epwdFile ="C:\HPE3parepwdlogin.txt",
		[Parameter(Mandatory=$false)]	[String]	$Option
	)
Process
{	if( Test-Path $epwdFile) {	Write-Host "Running: password file was found , it will use the mentioned file" }
	$cmd2 = "showuserconn "
	$options1 = "current"
	if(!($options1 -eq $option))
		{	write-warning "Failure : option should be in ( $options1 )"
			return
		}
	if($option -eq "current")	{	$cmd2 += " -current "	}
	$result = Invoke-CLI -DeviceIPAddress $ArrayNameOrIPAddress -CLIDir $CLIDir -epwdFile $epwdFile -cmd $cmd2	
	$count = $result.count - 3
	$tempFile = [IO.Path]::GetTempFileName()	
	Add-Content -Path $tempFile -Value "Id,Name,IP_Addr,Role,Connected_since,Current,Client,ClientName"	
	foreach($s in $result[1..$count])
		{	$s= [regex]::Replace($s,"^ +","")
			$s= [regex]::Replace($s," +"," ")
			$s= [regex]::Replace($s," ",",")
			$s = $s.trim()
			Add-Content -Path $tempFile -Value $s
		}
	Import-CSV $tempFile	
    remove-item $tempFile
}
}

Function Test-CLIObject 
{
Param(	[string]	$ObjectType, 
		[string]	$ObjectName ,
		[string]	$ObjectMsg = $ObjectType, 
					$SANConnection = $global:SANConnection
	)
Process
{	$IsObjectExisted = $True
	$ObjCmd = $ObjectType -replace ' ', '' 
	$Cmds = "show$ObjCmd $ObjectName"	
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmds
	if ($Result -like "no $ObjectMsg listed")	{	$IsObjectExisted = $false	}
	return $IsObjectExisted
}
}

Export-ModuleMember Close-Connection , Get-CmdList , Get-FcPorts , Get-ConnectedSession , New-CLIConnection , New-PoshSshConnection ,
Set-PoshSshConnectionPasswordFile , Set-PoshSshConnectionUsingPasswordFile