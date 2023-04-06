####################################################################################
## 	© 2019,2020, 2023 Hewlett Packard Enterprise Development LP
##
##	Description: 	Common Module functions.
##		
##	Pre-requisites: Needs HPE 3PAR cli.exe for New-CLIConnection
##					Needs POSH SSH Module for New-PoshSshConnection
##					WSAPI uses HPE 3PAR CLI commands to start, configure, and modify the WSAPI server.
##					For more information about using the CLI, see:
##					• HPE 3PAR Command Line Interface Administrator Guide
##					• HPE 3PAR Command Line Interface Reference
##
##					Starting the WSAPI server    : The WSAPI server does not start automatically.
##					Using the CLI, enter startwsapi to manually start the WSAPI server.
## 					Configuring the WSAPI server: To configure WSAPI, enter setwsapi in the CLI.
##
##	Created:		June 2015
##	Last Modified:	July 2020
##
##	History:		v1.0 - Created
##					v2.0 - Added support for HP3PAR CLI
##                     v2.1 - Added support for POSH SSH Module
##					v2.2 - Added support for WSAPI
##                  v2.3 - Added Support for all CLI cmdlets
##                     v2.3.1 - Added support for primara array with wsapi
##                  v3.0 - Added Support for wsapi 1.7 
##                  v3.0 - Modularization
##                  v3.0.1 (07/30/2020) - Fixed the Show-RequestException function to show the actual error message
##	
#####################################################################################
# Generic connection object 

add-type @" 
public struct _Connection{	public string SessionId;
							public string Name;
							public string IPAddress;
							public string SystemVersion;
							public string Model;
							public string Serial;
							public string TotalCapacityMiB;
							public string AllocatedCapacityMiB;
							public string FreeCapacityMiB;     
							public string UserName;
							public string epwdFile;
							public string CLIDir;
							public string CLIType;
						}
"@

add-type @" 
public struct _SANConnection{	public string SessionId;
								public string Name;
								public string IPAddress;
								public string SystemVersion;
								public string Model;
								public string Serial;
								public string TotalCapacityMiB;
								public string AllocatedCapacityMiB;
								public string FreeCapacityMiB;     
								public string UserName;
								public string epwdFile;
								public string CLIDir;
								public string CLIType;
							}
"@ 

add-type @" 
public struct _TempSANConn{	public string SessionId;
							public string Name;
							public string IPAddress;
							public string SystemVersion;
							public string Model;
							public string Serial;
							public string TotalCapacityMiB;
							public string AllocatedCapacityMiB;
							public string FreeCapacityMiB;     
							public string UserName;
							public string epwdFile;
							public string CLIDir;
							public string CLIType;
						}
"@ 

add-type @" 
public struct _vHost {	public string Id;
						public string Name;
						public string Persona;
						public string Address;
						public string Port;
					}
"@

add-type @" 
public struct _vLUN {	public string Name;
						public string LunID;
						public string PresentTo;
						public string vvWWN;
					}
"@

add-type @"
public struct _Version{	public string ReleaseVersionName;
						public string Patches;
						public string CliServer;
						public string CliClient;
						public string SystemManager;
						public string Kernel;
						public string TPDKernelCode;
					}
"@

add-type @" 
public struct _vHostSet {	public string ID;
							public string Name;
							public string Members;		
						}
"@

add-type @" 
public struct _vHostSetSummary {	public string ID;
									public string Name;
									public string HOST_Cnt;
									public string VVOLSC;
									public string Flashcache;
									public string QoS;
									public string RC_host;
}
"@

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

$global:LogInfo 		= $true
$global:DisplayInfo 	= $true
$global:SANConnection 	= $null #set in HPE3PARPSToolkit.psm1 
$global:WsapiConnection = $null
$global:ArrayType 		= $null
$global:ArrayName 		= $null
$global:ConnectionType 	= $null
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
if (!$global:VSVersion) 
	{	$global:VSVersion = "v3.0"
	}
if (!$global:ConfigDir)
	{	$global:ConfigDir = $null 
	}
$Info 					= "INFO:"
$Debug 					= "DEBUG:"
$global:VSLibraries 	= Split-Path $MyInvocation.MyCommand.Path

Function New-PWSHObjectFromCLIOutputSingle
{	
Param (	$SingleTable 
	)
Process
{	foreach( $Line in $SingleTable)
	{	write-verbose "SO: $Line"
	}
	#write-host "Entering the Non-recursive part of New-PWSHObject function."
	if ( $SingleTable[0].trim -eq '' )
		{	#write-verbose "Trimmed a blank first line from a table"
			$SingleTable = $SingleTable[1..($SingleTable.count -1)]
		}
	# At this point, we know only single tables should be coming in		
	#		{	write-verbose "Detected that this is a none titled response, calling to create a object without a title"
	$LineNum = 0
	if ( $SingleTable[$LineNum].indexof('-------') -eq 0 )
				{	# this will detect lines that start with things like '------------------------------------connectivity-------------------------------------'			
					$TitleFound = $True
					$CurrentTitle = $SingleTable[$LineNum].Trim('-')
					$LineNum += 1
					write-verbose "The Detected Title is $CurrentTitle"
				}	
	$Testline = $SingleTable[$LineNum].trim()		# On the next line we need to see if its a second title line
	$Testline = $Testline.trim('-')					# a 2nd title will look like '                      ----(gbps)----                     '
	$Testline = $Testline.split()					# After a trim. if its a second title if will not be splitable.
	if ( $Testline.count -eq 1 )
				{	Write-verbose "The second title line is $TestLine"
					$LineNum += 1
				}
	# Now lets look for the header line. It may be a first line header, see the next two lines, the Ports and Size are considered parts of a 2 level header
	# '                                -----Ports------          ------------Size-------------        '
	# 'col1 ---col2------ ----col3---- col4 col5 -col6- --col7-- -----col8---- ----col9------- -col10-'	
	# in the above case, col4 and col5 and col6 should be prefixed with Ports		
	$Testline = $SingleTable[$LineNum].trim() 				# get rid of the spaces at the edges first
	$TestlineSplit = $Testline.split()
	$Testline1Length = $Testline.length
	$NextLineLength = $SingleTable[$LineNum +1].length 		# if this is a header line then it will match the length of the next line.
	write-verbose "Looking for double Header, Header1 length is $Testline1Length and next line length is $NextLineLength"
	$C = $TestlineSplit.count
	write-verbose "The double header count is $C"
	$DoubleHeaderRaw = $SingleTable[$LineNum]
	# This assumes that a double header line will be significantly shorte (more that 5) than the following full header
	# Additionally a secondheader line will likely not be splitable to more than 4 sections
	# Unlike a title, the second header will be splitable after a trim.
	if ( ($NextLineLength -5) -gt $TestLineLength -and $TestlineSplit.count -gt 1 -and $TestlineSplit.count -lt 4)
			{	write-verbose "Detected a Double Header"
				$DoubleHeaderFound = $true
				# The possible double header will contain more than a single entrie, and and if trimmed be much shorter than 
				$LineNum += 1
				# Now lets split and create the second header list
				$DH = $DoubleHeaderRaw.trim()
				$DHS = $DH.split()
				$DoubleHeaderSet = @()
				foreach ( $SDH in $DHS)
				{	$DoubleHeaderSet += $SDH
					write-verbose "Adding DoubleHeaderset member $SDH"
				}

			}	
			else 
			{	$DoubleHeaderFound = $false
			}
	$UnsplitHeader = $SingleTable[$LineNum]
	#	write-host "Unsplit Header = $UnsplitHeader"
	$HeaderRaw1 = $UnsplitHeader.Split()		# Split the headers into columns
	$HeaderRaw2 = $HeaderRaw1.where({ $_ -ne ""})	# Trim the empty items from the list
	$LineNum += 1
	$CurrentObject = @()		
	foreach($Line in $SingleTable[$LineNum..($SingleTable.count-1)])
				{	if ( $line.trim() -ne '')
							{ 	# write-host "Processing a data line $line"
								$MySingleRow = @{}
								# write-host "My HeaderRaw2 = $HeaderRaw2"
								foreach( $HeaderName in $HeaderRaw2 )
									{	# Some of the data fields have spaces in the values, so need to extract from the data line the location start and end from the header hint.
										$LengthOfHeaderName = $HeaderName.Length
										$startPositionOfHeaderName = $UnsplitHeader.indexof($HeaderName)
										$MyDataPointRaw = $Line.Substring($StartPositionOfHeaderName, $LengthOfHeaderName)	
										$MyDataPoint1 = $MyDataPointRaw.trim()
										$FixedHeaderName = $HeaderName.trim('-')
										# Now lets see if I should prefix the Header name with a 2nd header line addition
										if ( $DoubleHeaderFound )
											{	foreach ( $SingleDoubleHeadername in $DoubleHeaderSet)
													{
														$DHLocation = $DoubleHeaderRaw.indexof($SingleDoubleHeadername)	
														$HLocation = $UnsplitHeader.indexof($FixedHeaderName)
														# write-host "The double header for $singleDoubleHeaderName occurs at location $DHLocation"
														# write-host "The header for $FixedHeader is found at location $HLocation"
														$endloc = $DHLocation + $singleDoubleHeaderName.length
														if ( $HLocation -ge $DHLocation -and $HLocation -le $endloc )
															{	write-verbose "Found a included doubleheader"
																write-verbose "The double header for $singleDoubleHeaderName occurs at location $DHLocation"
																write-verbose "The header for $FixedHeaderName is found at location $HLocation"
																$FixedHeaderName = $SingleDoubleHeadername.trim('-') + '-' + $FixedHeaderName
															}
													}

											}
										# write-host "Adding Datapoint $FixedHeaderName = $MyDataPoint1"
										$MySingleRow["$FixedHeaderName"] += $MyDataPoint1
									}
								$CurrentObject += $MySingleRow
							}
				}
	if ( $TitleFound ) 
				{	$ReturnObject = @{ $CurrentTitle = $CurrentObject } | convertto-json | convertfrom-json 
					return $ReturnObject 
				}
			else 
				{	$ReturnObject = $CurrentObject | convertTo-JSON | ConvertFrom-Json
					return $ReturnObject
				}
	}	
}
Function New-PWSHObjectFromCLIOutput
{
[CmdletBinding()]
param 	(	$InterimResults
		)
Process
{		$ReturnObject = @()
		# First lets split up the return data. I will first split the data using blank lines and recurse back to this function with the individual objects
		$BlankLines = @()
		$LineNum = 0
		while ( $InterimResults[0].trim() -eq '')
			{	# If first line is blank, delete that line.
				$InterimResults = $InterimResults[1..($InterimResults.count-1)]
			}
		$Temp=@()
		foreach( $Line in $InterimResults)
			{	$SkipLine=$false
				# If a line is nothing but ------ marks, we can delete it.
				if ( $Line.Trim('-') -eq '' -and $Line[0] -eq '-')		{	$SkipLine = $true	}
				if ( $Line.contains('total'))							{	$SkipLine = $true	}
				if ( -not $SkipLine )									{	$Temp += $Line		}
			}
		$InterimResults = $Temp
		foreach( $testline in $InterimResults)
		{	if ($testline.trim() -eq '')
			{ 	#write-verbose "Blankline is $LineNum "
				$BlankLines += $LineNum
				# This makes an array of the blanklines, i.e. ( 0, 4, 7, 9) would mean that line 4 is blank, as is 7 as it 9. We also artificially add the last line 
			} 
			$LineNum += 1
		}
		# The blanklines needs to contain the last line of data.
		$BlankLines += ( $LineNum -1 )
		$ReturnObject = @()
		$Startline = -1
		$BlankLines = ( $BlankLines | sort-object )
		#write-host "Test blanklines = $BlankLines, Count =" -nonewline
		# $BlankLines.count | out-string
		# $BlankLines | out-string
		if ( $BlankLines.count -eq $InterminResults.count)
			{	#write-host "Nothing but blanks"
				return
			}
		foreach ( $entry in $BlankLines)
		{	# write-verbose "Doing a recursive call on a sub-table from the main table"
			# subdivideds the data into groups. i.e. If blanklines is 0,4,7,9 it will create 3 objects from line 0-4, another from line 4-7, another from 7-9. 
			# write-host "The start and finish will be $StartLine and $entry "
			if ( $entry -ne ($StartLine+1) )
			{	$SingleResult = $InterimResults[($StartLine+1)..($entry)]
				#write-host "This is what is sent to the next call `n "
				foreach ( $xline in $SingleResult)
					{	# write-host "p->$xline"
					}
				if ($SingleResult.count -gt 1)
				{	$ReturnObject += New-PWSHObjectFromCLIOutputSingle $SingleResult 
				}
				else 
				{	#write-host "Nothing in this set to send. skipping it."
				}
			}
			else
			{	#write-host 'skipped double blank line'
			}
			$Startline = $entry
		}
		return $ReturnObject
}
}

<# Function New-PWSHObjectFromCLIOutputWithoutTitle
{
[CmdletBinding()]
param (	$InterimResults)
Begin
{}
Process
{	write-verbose " Starting Function"
	$HeaderNotFound = $true
	foreach($Line in $InterimResults)
	{	write-verbose "Processing $Line"
		if ( $HeaderNotFound )
		{	Write-verbose "No Header found, so the first line should be a header. `n"
			$UnsplitHeader = $Line
			$HeaderRaw1 = $Line.Split()		# Split the headers into columns
			$HeaderRaw2 = $HeaderRaw1.where({ $_ -ne ""})	# Trim the empty items from the list
			$HeaderNotFound = $False
			$CurrentObject = @()
		}
		else
		{	write-verbose "This is a data line "
			if ( $line.trim() -ne '')
			{ 	write-verbose "This data line is not NULL"
				$MySingleRow = @{}
				foreach( $HeaderName in $HeaderRaw2 )
				{	# Some of the data fields have spaces in the values, so need to extract from the data line the location start and end from the header hint.
					$LengthOfHeaderName = $HeaderName.Length
					$startPositionOfHeaderName = $UnsplitHeader.indexof($HeaderName)
					$MyDataPointRaw = $Line.Substring($StartPositionOfHeaderName, $LengthOfHeaderName)	
					$MyDataPoint1 = $MyDataPointRaw.trim()
					$FixedHeaderName = $HeaderName.trim('-')
					$MySingleRow["$FixedHeaderName"] = $MyDataPoint1
					write-verbose "Dataline addeded using $FixedHeaderName and $MyDataPoint1"
				}
				$CurrentObject += $MySingleRow
			}
		}
	}
	# Producing last object addition
	return ( $CurrentObject | convertto-json | convertfrom-json )
}
}
#>

Function Invoke-CLICommand 
{
<#
.SYNOPSIS
	Execute a command against a device using HP3PAR SSH 
.DESCRIPTION
	Execute a command against a device using HP3PAR SSH
.PARAMETER Connection
	Pointer to an connection object which is autogenerated when the Connect command is used. This will default to the last connection command value.
.PARAMETER Cmds
	Command to be executed
.EXAMPLE		
	Invoke-CLICommand -Cmds "showsysmgr"
	The command queries a array to get the system information
	$global:SANConnection is created wiith the cmdlet New-PoshSshConnection			
#>
[CmdletBinding()]
Param(											$Connection = $global:SANConnection,
		[Parameter(Mandatory = $true)]	[string]$Cmds  
	)
Begin
{	Test-CLIConnectionB	
}
Process
{	$clittype = $Connection.cliType
	if ($clittype -eq "SshClient") 
		{	$Result = Invoke-SSHCommand -Command $Cmds -SessionId $Connection.SessionId
			if ($Result.ExitStatus -eq 0) 
				{	return $Result.Output
				}
			else 
				{	$ErrorString = "Error :-" + $Result.Error + $Result.Output			    
					return $ErrorString
				}		
		}
	else 
		{	Throw "FAILURE : Invalid cliType option selected/chosen"
		}
}
}

Function Set-DebugLog 
{
<#
.SYNOPSIS
    Enables creating debug logs.
.DESCRIPTION
	Creates Log folder and debug log files in the directory structure where the current modules are running.
.EXAMPLE
    Set-DebugLog -LogDebugInfo $true -Display $true
	Set-DEbugLog -LogDebugInfo $true -Display $false
.PARAMETER LogDebugInfo 
    Specify the LogDebugInfo value to $true to see the debug log files to be created or $false if no debug log files are needed.	
.PARAMETER Display 
    Specify the value to $true. This will enable seeing messages on the PS console. This switch is set to true by default. Turn it off by setting it to $false. Look at examples.
#>
[CmdletBinding()]
param(	[Boolean]	$LogDebugInfo = $false,		
		[Boolean]	$Display = $true
	)
Process
{	$global:LogInfo = $LogDebugInfo
	$global:DisplayInfo = $Display	
	Write-warning "The value of logging debug information is set to $global:LogInfo and the value of Display on console is $global:DisplayInfo" 
}
}

Function Invoke-CLI 
{
<#
.SYNOPSIS
    This is private method not to be used. For internal use only.
.DESCRIPTION
    Executes 3par cli command with the specified paramaeters to get data from the specified virtual Connect IP Address 
.EXAMPLE
    Invoke-CLI -DeviceIPAddress "DeviceIPAddress" -CLIDir "Full Installed Path of cli.exe" -epwdFile "C:\loginencryptddetails.txt"  -cmd "show server $serverID"
.PARAMETER DeviceIPAddress 
    Specify the IP address for Virtual Connect(VC) or Onboard Administrator(OA) or Storage or any other device
.PARAMETER CLIDir 
    Specify the absolute path of HP3PAR CLI's cli.exe
.PARAMETER epwdFIle 
    Specify the encrypted password file location
.PARAMETER cmd 
    Specify the command to be run for Virtual Connect
#>
[CmdletBinding()]
param(	[String]		$DeviceIPAddress = $null,	
		[String]		$CLIDir = "C:\Program Files (x86)\Hewlett Packard Enterprise\HPE 3PAR CLI\bin",	
		[String]		$epwdFile = "C:\HP3PARepwdlogin.txt",
		[String]		$cmd = "show -help"
	)
Process
{	#write-host  "Password in Invoke-CLI = ",$password	
	Write-DebugLog "start:In function Invoke-CLI. Validating PUTTY path." $Debug
	if (Test-Path -Path $CLIDir) 
		{	$clifile = $CLIDir + "\cli.exe"
			if ( -not (Test-Path $clifile)) 
				{	return "HP3PAR cli.exe file not found. Make sure the cli.exe file present in $CLIDir. "
				}
		}
	else 
		{	$SANCObj = $global:SANConnection
			$CLIDir = $SANCObj.CLIDir
		}
	if (-not (Test-Path -Path $CLIDir )) 
		{	return "FAILURE : HP3PAR cli.exe not found. Make sure the HP3PAR CLI installed"
		}		
	Write-verbose "Running: Calling function Invoke-CLI. Calling Test Network with IP Address $DeviceIPAddress" 	
	$Status = Test-Network $DeviceIPAddress
	if ($null -eq $Status) 
		{	Throw "Invalid IP Address"
		}
	if ($Status -eq "Failed") 
		{	Throw "Unable to ping the device with IP $DeviceIPAddress. Check the IP address and try again."
		}
	Write-DebugLog "Running: Calling function Invoke-CLI. Check the Test Network with IP Address = $DeviceIPAddress. Invoking the HP3par cli...." $Debug	
	try {	#if(!($global:epwdFile)){
			#	Write-DebugLog "Stop:Please create encrpted password file first using New-CLIConnection"  "ERR:"
			#	return "`nFAILURE : Please create encrpted password file first using New-CLIConnection"
			#}	
			#write-host "encrypted password file is $epwdFile"
			$pwfile = $epwdFile
			$test = $cmd.split(" ")
			#$test = [regex]::split($cmd," ")
			$fcmd = $test[0].trim()
			$count = $test.count
			$fcmd1 = $test[1..$count]
			#$cmdtemp= [regex]::Replace($fcmd1,"\n"," ")
			#$cmd2 = $fcmd+".bat"
			#$cmdFinal = " $cmd2 -sys $DeviceIPAddress -pwf $pwfile $fcmd1"
			#write-host "Command is  : $cmdFinal"
			#Invoke-Expression $cmdFinal	
			$CLIDir = "$CLIDir\cli.exe"
			$path = "$CLIDir\$fcmd"
			#write-host "command is 1:  $cmd2  $fcmd1 -sys $DeviceIPAddress -pwf $pwfile"
			& $CLIDir -sys $DeviceIPAddress -pwf $pwfile $fcmd $fcmd1
			if (!($?	)) 
				{	return "FAILURE : FATAL ERROR"
				}	
		}
	catch 
		{	$msg = "Calling function Invoke-CLI -->Exception Occured. "
			$msg += $_.Exception.ToString()			
			Write-Exception $msg -error
			Throw $msg
		}	
}
}

Function Test-Network ([string]$IPAddress) 
{
<#
.SYNOPSIS
    Pings the given IP Adress.
.DESCRIPTION
	Pings the IP address to test for connectivity.
.EXAMPLE
    Test-Network -IPAddress 10.1.1.
.PARAMETER IPAddress 
    Specify the IP address which needs to be pinged.
#>
Process
{	$Status = Test-IPFormat $IPAddress
	if ($Status -eq $null)
		{	return $Status 
		}
	try {	$Ping = new-object System.Net.NetworkInformation.Ping
			$result = $ping.Send($IPAddress)
			$Status = $result.Status.ToString()
		}
	catch [Exception]	{	$Status = "Failed" }
	return $Status
}
}

Function Test-IPFormat 
{
<#
.SYNOPSIS
    Validate IP address format
.DESCRIPTION
	Validates the given value is in a valid IP address format.        
.EXAMPLE
    Test-IPFormat -Address
.PARAMETER Address 
    Specify the Address which will be validated to check if its a valid IP format.
#>
param(	[string]$Address = $(throw "Missing IP address parameter"))
		trap { $false; continue; }
		[bool][System.Net.IPAddress]::Parse($Address);
}

Function Test-WSAPIConnection 
{
[CmdletBinding()]
Param(	$WsapiConnection = $global:WsapiConnection
	)
Process
{	if (($null -eq $WsapiConnection) -or (-not ($WsapiConnection.IPAddress)) -or (-not ($WsapiConnection.Key))) 
		{	Write-Warning "`nStop: No active WSAPI connection to an HPE Alletra 9000 or Primera or 3PAR storage system or the current session key is expired. Use New-WSAPIConnection cmdlet to connect back."
			throw 
		}
	else 
		{	Write-DebugLog " End: Connected" $Info
		}
	Write-DebugLog "End: Test-WSAPIConnection" $Debug  
	# Returning without an error indicates it worked
}
}

function Invoke-WSAPI 
{
[CmdletBinding()]
Param (	[parameter(Mandatory = $true)]
		[ValidateScript( { if ($_.startswith('/')) { $true } else { throw "-URI must begin with a '/' (eg. /volumes) in its value. Correct the value and try again." } })]
		[string]	$uri,
		
		[ValidateSet('GET','PUT','DELETE')]
		[string]	$type,
		
		[array]		$body,
		
					$WsapiConnection = $global:WsapiConnection
	)
Process
{	$ip = $WsapiConnection.IPAddress
	$key = $WsapiConnection.Key
	$arrtyp = $global:ArrayType
	if ($arrtyp.ToLower() -eq "3par") 
		{	$APIurl = 'https://' + $ip + ':8080/api/v1' 	
		}
	Elseif (($arrtyp.ToLower() -eq "primera") -or ($arrtyp.ToLower() -eq "alletra9000")) 
		{	$APIurl = 'https://' + $ip + ':443/api/v1'	
		}
	else 
		{	return "Array type is Null."
		}
	$url = $APIurl + $uri	
	#Construct header
	Write-DebugLog "Running: Constructing header." $Debug
	$headers = @{}
	$headers["Accept"] = "application/json"
	$headers["Accept-Language"] = "en"
	$headers["Content-Type"] = "application/json"
	$headers["X-HP3PAR-WSAPI-SessionKey"] = $key
	$data = $null
	If ($type -eq 'GET') 
		{	Try {	Write-verbose "Request: Invoke-WebRequest for Data, Request Type : $type"
					if ($PSEdition -eq 'Core') 
						{	$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing -SkipCertificateCheck
						}		 
					else 
						{	$data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing 
						}
					return $data
				}
			Catch {	Write-error "Stop: Exception Occurs" 
					Show-RequestException -Exception $_
					return
				}
		}
	If (($type -eq 'POST') -or ($type -eq 'PUT')) 
		{	Try 	{	Write-verbose "Request: Invoke-WebRequest for Data, Request Type : $type"
						$json = $body | ConvertTo-Json  -Compress -Depth 10	
						if ($PSEdition -eq 'Core') 
							{    $data = Invoke-WebRequest -Uri "$url" -Body $json -Headers $headers -Method $type -UseBasicParsing -SkipCertificateCheck
							} 
						else 
							{   $data = Invoke-WebRequest -Uri "$url" -Body $json -Headers $headers -Method $type -UseBasicParsing 
							}
						return $data
					}
			Catch 	{	Write-error "Stop: Exception Occurs"
						Show-RequestException -Exception $_
						return
					}
		}
	If ($type -eq 'DELETE') 
		{	Try 	{	Write-verbose "Request: Invoke-WebRequest for Data, Request Type : $type" 
						if ($PSEdition -eq 'Core') 
							{    $data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing -SkipCertificateCheck
							} 
						else 
							{    $data = Invoke-WebRequest -Uri "$url" -Headers $headers -Method $type -UseBasicParsing 
							}
						return $data
					}
			Catch 	{	Write-error "Stop: Exception Occurs" 
						Show-RequestException -Exception $_
						return
					}
		}
}
}

function Format-Result 
{
[CmdletBinding()]
Param (	[parameter(Mandatory = $true)]				$dataPS,
		[parameter(Mandatory = $true)]	[string]	$TypeName
	)
Begin 
{ 	$AlldataPS = @() 
}
Process 
{	# Add custom type to the resulting oject for formating purpose	 
	Foreach ($data in $dataPS) 
		{	If ($data) 
				{	$data.PSObject.TypeNames.Insert(0, $TypeName)
				}		
			$AlldataPS += $data
		}
	return $AlldataPS
}
}

Function Show-RequestException
{
[CmdletBinding()]
Param(	[parameter(Mandatory = $true)]
		$Exception
	)
Protect-CmsMessage
{	#Exception catch when there's a connectivity problem with the array
	If ($Exception.Exception.InnerException) 
		{	Write-Host "Please verify the connectivity with the array. Retry with the parameter -Verbose for more informations.`n" -foreground yellow
			Write-Host "Status: $($Exception.Exception.Status)" -foreground yellow
			Write-Host "Error code: $($Exception.Exception.Response.StatusCode.value__)" -foreground yellow
			Write-Host "Message: $($Exception.Exception.InnerException.Message) `n" -foreground yellow
			Return $Exception.Exception.Status
		}
	#Exception catch when the rest request return an error
	If ($_.Exception.Response) 
		{	$result = ConvertFrom-Json -InputObject $Exception.ErrorDetails.Message	
			Write-Host "The array sends an error message: $($result.desc). `n" -foreground yellow 
			Write-Host "Status: $($Exception.Exception.Status)" -foreground yellow
			Write-Host "Error code: $($result.code)" -foreground yellow
			Write-Host "HTTP Error code: $($Exception.Exception.Response.StatusCode.value__)" -foreground yellow
			Write-Host "Message: $($result.desc) `n" -foreground yellow
			Return $result.code
		}
}
}

Function Test-FilePath ([String[]]$ConfigFiles) 
{
<#
.SYNOPSIS
    Validate an array of file paths. For Internal Use only.
.DESCRIPTION
	Validates if a path specified in the array is valid.   
.EXAMPLE
    Test-FilePath -ConfigFiles
.PARAMETER -ConfigFiles 
    Specify an array of config files which need to be validated.	
#>
Process
{	$Validate = @()	
	if (-not ($global:ConfigDir)) 
		{	Write-warning "STOP: Configuration Directory path is not set. Run scripts Init-PS-Session.ps1 OR import module VS-Functions.psm1 and run cmdlet Set-ConfigDirectory" "ERR:"
			$Validate = @("Configuration Directory path is not set. Run scripts Init-PS-Session.ps1 OR import module VS-Functions.psm1 and run cmdlet Set-ConfigDirectory.")
			return $Validate
		}
	foreach ($argConfigFile in $ConfigFiles)
		{	if (-not (Test-Path -Path $argConfigFile )) 
				{	$FullPathConfigFile = $global:ConfigDir + $argConfigFile
					if (-not (Test-Path -Path $FullPathConfigFile))
						{	$Validate = $Validate + @(, "Path $FullPathConfigFile not found.")					
						}				
				}
		}	
	return $Validate
}
}

Function Test-PARCLi 
{
<#
.SYNOPSIS
    Test-PARCli object path
.EXAMPLE
    Test-PARCli t
#> 
[CmdletBinding()]
param (	[Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true)]
		$SANConnection = $global:SANConnection 
	)
Process
{	$SANCOB = $SANConnection 
	$clittype = $SANCOB.CliType
	if ($clittype -eq "SshClient") 
		{	Test-SSHSession -SANConnection $SANConnection
		}
	else 
		{	throw "FAILURE : Invalid cli type"
		}	
}
}
Function Test-SSHSession 
{
<#
.SYNOPSIS
    Test-SSHSession   
.PARAMETER pathFolder
    Test-SSHSession
.EXAMPLE
    Test-SSHSession -SANConnection $SANConnection
#> 
[CmdletBinding()]
param(	$SANConnection = $global:SANConnection 
	)
Process
{	$Result = Get-SSHSession | format-list
	if ($Result.count -gt 1) 
		{
		}
	else 
		{	Write-Error "`nFAILURE : FATAL ERROR : Please check your connection and try again"
			return 
		}
}	
}

Function Test-PARCliTest 
{
<#
.SYNOPSIS
    Test-PARCli pathFolder	
.PARAMETER pathFolder
    Specify the names of the HP3par cli path
.EXAMPLE
    Test-PARCli path -pathFolder c:\test
#> 
[CmdletBinding()]
param(	[String]	$pathFolder = "C:\Program Files (x86)\Hewlett Packard Enterprise\HPE 3PAR CLI\bin",
					$SANConnection = $global:SANConnection 
	)
process
{	$SANCOB = $SANConnection 
	$DeviceIPAddress = $SANCOB.IPAddress
	$CLIDir = $pathFolder
	if (Test-Path -Path $CLIDir) 
		{	$clitestfile = $CLIDir + "\cli.exe"
			if ( -not (Test-Path $clitestfile)) 
				{	return "FAILURE : HP3PAR cli.exe file was not found. Make sure you have cli.exe file under $CLIDir "
				}
			$pwfile = $SANCOB.epwdFile
			$cmd2 = "help.bat"
			& $cmd2 -sys $DeviceIPAddress -pwf $pwfile
			if (!($?)) 
				{	return "`nFAILURE : FATAL ERROR"
				}
		}
	else 
		{	$SANCObj = $SANConnection
			$CLIDir = $SANCObj.CLIDir	
			$clitestfile = $CLIDir + "\cli.exe"
			if (-not (Test-Path $clitestfile )) 
				{	return "FAILURE : HP3PAR cli.exe was not found. Make sure you have cli.exe file under $CLIDir "
				}
			$pwfile = $SANCObj.epwdFile
			$cmd2 = "help.bat"
			& $cmd2 -sys $DeviceIPAddress -pwf $pwfile
			if (!($?)) 
				{	return "`nFAILURE : FATAL ERROR"
				}
		}
	Write-error "Stop : in Test-PARCli function " 
}
}

Function Test-CLIConnection ($SANConnection) 
{
<#
.SYNOPSIS
	Validate CLI connection object. For Internal Use only.
.DESCRIPTION
	Validates if CLI connection object for VC and OA are null/empty    
.EXAMPLE
    Test-CLIConnection -SANConnection
.PARAMETER -SANConnection 
    Specify the VC or OA connection object. Ideally VC or Oa connection object is obtained by executing New-VCConnection or New-OAConnection.
.Notes
    NAME:  Test-CLIConnection
    LASTEDIT: 05/09/2012
    KEYWORDS: Test-CLIConnection   
.Link
	http://www.hpe.com
	Requires PS -Version 3.0
#>
Process{
	$Validate = "Success"
	if (	($SANConnection -eq $null) -or (-not ($SANConnection.AdminName)) -or (-not ($SANConnection.Password)) -or (-not ($SANConnection.IPAddress)) -or (-not ($SANConnection.SSHDir))	) 
		{	#Write-DebugLog "Connection object is null/empty or username, password,IP address are null/empty. Create a valid connection object and retry" "ERR:"
			$Validate = "Failed"		
		}
	return $Validate
}
}

Function Test-CLIConnectionB 
{
<#
.SYNOPSIS
	Validate CLI connection object. For Internal Use only.
.DESCRIPTION
	Validates if CLI connection object for VC and OA are null/empty    
.EXAMPLE
    Test-CLIConnection -SANConnection
.PARAMETER -SANConnection 
    Specify the VC or OA connection object. Ideally VC or Oa connection object is obtained by executing New-VCConnection or New-OAConnection.
#>
Param(	$SanConnection = $Global:SanConnection	
	)
Process{
	if ( ($SANConnection -eq $null)  ) 		{	$Validate = $False	}
	if ( -not ($SANConnection.IPAddress) ) 	{	$Validate = $False	}
	if ( $Validate -eq $false ) 
		{ throw "`nThis command failed as you must first connect to the device using the New-POSHSSHConnection Command. No Valid connection detected.`n"	}
	return 
}
}

Export-ModuleMember Test-CLIConnectionB,  Test-CLIConnection, Test-SSHSession, Test-WSAPIConnection , Test-Network ,
					Invoke-WSAPI , Invoke-CLI , Invoke-CLICommand,
					New-PWSHObjectFromCLIOutput, 
					Format-Result , Show-RequestException , Set-DebugLog ,  Test-IPFormat , Test-FilePath , 
					Test-PARCli , Test-PARCliTest
