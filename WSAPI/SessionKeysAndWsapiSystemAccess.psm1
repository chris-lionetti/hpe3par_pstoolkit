####################################################################################
## 	© 2020,2021 Hewlett Packard Enterprise Development LP
##

$Info = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
$global:ArrayType = $null
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$global:LogInfo 	= $true
$global:DisplayInfo = $true
if(!$global:VSVersion)	{	$global:VSVersion = "v3.0"	}
if(!$global:ConfigDir) 	{	$global:ConfigDir = $null 	}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$curPath  = Split-Path -Path $MyInvocation.MyCommand.Definition | Split-path  
$Global:pathLogs = join-path $curPath "X-Logs"
write-host "Curpath = $CurPath"
if(-Not (Test-Path $pathLogs) )
	{	try	{	New-Item $pathLogs -Type Directory | Out-Null
			}
		catch
			{	$global:LogInfo = $false
				Write-Warning "Failed to create Logs Directory $_.Exception.ToString() Log file will not be created."
			}
	}
[String]$temp 	= Get-Date -f s


Function New-WSAPIConnection {
<#	
.SYNOPSIS
	Create a WSAPI session key
.DESCRIPTION
	To use Web Services, you must create a session key. Use the same username and password that you use to
	access the storage system through the 3PAR CLI or the 3PAR MC. Creating this authorization allows
	you to complete the same operations using WSAPI as you would the CLI or MC.
.EXAMPLE
    New-WSAPIConnection -ArrayFQDNorIPAddress 10.10.10.10 -SANUserName XYZ -SANPassword XYZ@123 -ArrayType 3par
	create a session key with array.
.EXAMPLE
    New-WSAPIConnection -ArrayFQDNorIPAddress 10.10.10.10 -SANUserName XYZ -SANPassword XYZ@123 -ArrayType primera
	create a session key with Primera array.
.EXAMPLE
    New-WSAPIConnection -ArrayFQDNorIPAddress 10.10.10.10 -SANUserName XYZ -SANPassword XYZ@123 -ArrayType alletra9000
	create a session key with Alletra 9000 array.
.PARAMETER ArrayFQDNorIPAddress 
    Specify the Array FQDN or Array IP address.
.PARAMETER UserName 
    Specify the user name
.PARAMETER Password 
    Specify the password 
.PARAMETER ArrayType
	Specify the array type ie. 3Par, Primera or Alletra9000
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[String]	$ArrayFQDNorIPAddress,

		[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
		[String]	$SANUserName,

		[Parameter(ValueFromPipeline=$true)]
		[String]
		$SANPassword=$null ,

		[Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Enter array type : 3par, primera or alletra9000")]
		[ValidateSet("3par", "Primera", "Alletra9000")]
		[String]	$ArrayType
		)
Process
{	#(self-signed) certificate,
	if ($PSEdition -eq 'Core')
	{} 
	else 
	{	add-type @" 
			using System.Net; 
			using System.Security.Cryptography.X509Certificates; 
			public class TrustAllCertsPolicy : ICertificatePolicy 	{ public bool CheckValidationResult	( 	ServicePoint srvPoint, X509Certificate certificate, 
																										WebRequest request, int certificateProblem
																										) 
																		{ 	return true; 	} 
																	} 
"@  
		[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
	}
	#END of (self-signed) certificate,
	if(!($SANPassword))
		{	$SANPassword1 = Read-host "SANPassword" -assecurestring
			$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SANPassword1)
			$SANPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
		}
		$APIurl = $null
		$Global:ArrayType = $ArrayType
		if($ArrayType -eq "3par")		{	$APIurl = "https://$($ArrayFQDNorIPAddress):8080/api/v1" 	}
		if($ArrayType -eq "primera")	{	$APIurl = "https://$($ArrayFQDNorIPAddress):443/api/v1" 	}
		if($ArrayType -eq "alletra9000"){	$APIurl = "https://$($ArrayFQDNorIPAddress):443/api/v1" 	}
		#connect to WSAPI
		$postParams = @{user=$SANUserName;password=$SANPassword} | ConvertTo-Json 
		$headers = @{}  
		$headers["Accept"] = "application/json" 
		Try
		{	if ($PSEdition -eq 'Core')
			{	$credentialdata = Invoke-WebRequest -Uri "$APIurl/credentials" -Body $postParams -ContentType "application/json" -Headers $headers -Method POST -UseBasicParsing -SkipCertificateCheck
			} 
			else 
			{	$credentialdata = Invoke-WebRequest -Uri "$APIurl/credentials" -Body $postParams -ContentType "application/json" -Headers $headers -Method POST -UseBasicParsing 
			}
		}
		catch
		{	Show-RequestException -Exception $_
			write-error "`nFAILURE : While establishing the connection.`n" 
			throw
		}
		$key = ($credentialdata.Content | ConvertFrom-Json).key
		if(!$key)
			{	write-error "Error: No key Generated" 
				return 
			}		
		$SANC1 = New-Object "WSAPIconObject"
		$SANC1.IPAddress = $ArrayFQDNorIPAddress					
		$SANC1.Key = $key				
		$Result = Get-System_WSAPI -WsapiConnection $SANC1
		$SANC = New-Object "WSAPIconObject"		
		$SANC.Id = $Result.id
		$SANC.Name = $Result.name
		$SANC.SystemVersion = $Result.systemVersion
		$SANC.Patches = $Result.patches
		$SANC.IPAddress = $ArrayFQDNorIPAddress
		$SANC.Model = $Result.model
		$SANC.SerialNumber = $Result.serialNumber
		$SANC.TotalCapacityMiB = $Result.totalCapacityMiB
		$SANC.AllocatedCapacityMiB = $Result.allocatedCapacityMiB
		$SANC.FreeCapacityMiB = $Result.freeCapacityMiB					
		$SANC.Key = $key		
		$global:WsapiConnection = $SANC
		$global:ArrayName = $Result.name
		Write-Verbose "End: If there are no errors reported on the console then the SAN connection object is set and ready to be used."		
		Write-Verbose 'You are now connected to the HPE Storage system. `n Show array informations:'
	# Start PowerShell Transcript
		[String]$temp 	= Get-Date -f s
		$timeStamp 		= $temp.ToString().Replace(":","-")
		$Global:TranscriptPath = ($pathLogs + '\Transcript_' + $timeStamp)
		try {	$dumpresult = Stop-Transcript -erroraction SilentlyContinue }
		catch { }
		Start-Transcript -path $TranscriptPath
	#end Start PowerShell Transcript
		return $SANC
}
}
#End of New-WSAPIConnection

############################################################################################################################################
## FUNCTION Close-WSAPIConnection
############################################################################################################################################
Function Close-WSAPIConnection
{
<#
.SYNOPSIS
	Delete a WSAPI session key.
.DESCRIPTION
	When finishes making requests to the server it should delete the session keys it created .
	Unused session keys expire automatically after the configured session times out.
.EXAMPLE
    Close-WSAPIConnection
	Delete a WSAPI session key.
#>
[CmdletBinding()]
Param()
Begin 
{}
Process 
{	if ( $WsapiConnection -ne $null )
	{	write-Verbose "Connection to a system has been detected. "
		$key = $WsapiConnection.Key
		Write-Verbose "Running: Building uri to close wsapi connection cmdlet." 
		$uri = '/credentials/'+$key
		Write-Verbose "Request: Request to close wsapi connection (Invoke-WSAPI)."
		$data = Invoke-WSAPI -uri $uri -type 'DELETE'
		Clear-Variable  WsapiConnection
		write-warning "Stopping any running transcript."
		try 	{	$dumpresult = Stop-Transcript -erroraction SilentlyContinue 
					Clear-Variable dumpresult
				}
		catch 	{ }
		return $data
	} 
	else 
	{	Test-WSAPIConnection
		return
	}
}
}

Export-ModuleMember New-WSAPIConnection , Close-WSAPIConnection