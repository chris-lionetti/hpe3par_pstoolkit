## 	© 2019,2020,2023 Hewlett Packard Enterprise Development LP
##		

$Info = "INFO:"
$Debug = "DEBUG:"
$global:VSLibraries = Split-Path $MyInvocation.MyCommand.Path
$global:ArrayType = $null
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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
param(
			[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
			[String]	$ArrayFQDNorIPAddress,

			[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
			[String]	$SANUserName=$null,

			[String]	$SANPassword=$null ,

			[Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Enter array type : 3par, primera or alletra9000")]
			[ValidateSet("3par", "primera", "alletra9000")]
			[String]	$ArrayType
		)
#(self-signed) certificate,

if ($PSEdition -eq 'Core')	{	} 
else 
{
add-type @" 
using System.Net; 
using System.Security.Cryptography.X509Certificates; 
public class TrustAllCertsPolicy : ICertificatePolicy { 
	public bool CheckValidationResult( 
		ServicePoint srvPoint, X509Certificate certificate, 
		WebRequest request, int certificateProblem) { 
		return true; 
	} 
} 
"@  
	[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}

#END of (self-signed) certificate,
	if(!($SANPassword))
		{	$SANPassword1 = Read-host "SANPassword" -assecurestring
			#$globalpwd = $SANPassword1
			$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SANPassword1)
			$SANPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
		}
		
		#Write-DebugLog "start: Entering function New-WSAPIConnection. Validating IP Address format." $Debug	
		#if(-not (Test-IPFormat $ArrayFQDNorIPAddress))		
		#{
		#	Write-DebugLog "Stop: Invalid IP Address $ArrayFQDNorIPAddress" "ERR:"
		#	return "FAILURE : Invalid IP Address $ArrayFQDNorIPAddress"
		#}
		
		<#
		# -------- Check any active CLI/PoshSSH session exists ------------ starts		
		if($global:SANConnection){
			$confirm = Read-Host "An active CLI/PoshSSH session exists.`nDo you want to close the current CLI/PoshSSH session and start a new WSAPI session (Enter y=yes n=no)"
			if ($confirm.tolower() -eq 'y') {
				Close-Connection
			}
			elseif ($confirm.tolower() -eq 'n') {
				return
			}
		}
		# -------- Check any active CLI/PoshSSH session exists ------------ ends
		
		# -------- Check any active WSAPI session exists ------------------ starts
		if($global:WsapiConnection){
			$confirm = Read-Host "An active WSAPI session exists.`nDo you want to close the current WSAPI session and start a new WSAPI session (Enter y=yes n=no)"
			if ($confirm.tolower() -eq 'y') {
				Close-WSAPIConnection
			}
			elseif ($confirm.tolower() -eq 'n') {
				return
			}
		}
		# -------- Check any active WSAPI session exists ------------------ ends		
		#>
		
		#Write-DebugLog "Running: Completed validating IP address format." $Debug		
		#Write-DebugLog "Running: Authenticating credentials - Invoke-WSAPI for user $SANUserName and SANIP= $ArrayFQDNorIPAddress" $Debug
		
		#URL
		$APIurl = $null
		if($ArrayType -eq "3par")		{	$global:ArrayType = "3par" 
											$APIurl = "https://$($ArrayFQDNorIPAddress):8080/api/v1" 	
										}
		if($ArrayType -eq "primera")	{	$global:ArrayType = "Primera" 
											$APIurl = "https://$($ArrayFQDNorIPAddress):443/api/v1" 	
										}
		if($ArrayType -eq "alletra9000"){	$global:ArrayType = "Alletra9000" 
											$APIurl = "https://$($ArrayFQDNorIPAddress):443/api/v1" 	
										}		
		#connect to WSAPI
		$postParams = @{user=$SANUserName;password=$SANPassword} | ConvertTo-Json 
		$headers = @{}  
		$headers["Accept"] = "application/json" 
		Try
		{	Write-DebugLog "Running: Invoke-WebRequest for credential data." $Debug
			if ($PSEdition -eq 'Core')
				{	$credentialdata = Invoke-WebRequest -Uri "$APIurl/credentials" -Body $postParams -ContentType "application/json" -Headers $headers -Method POST -UseBasicParsing -SkipCertificateCheck
				} 
			else 
				{	$credentialdata = Invoke-WebRequest -Uri "$APIurl/credentials" -Body $postParams -ContentType "application/json" -Headers $headers -Method POST -UseBasicParsing 
				}
		}
		catch
		{	Write-DebugLog "Stop: Exception Occurs" $Debug
			Show-RequestException -Exception $_
			write-Error "`n FAILURE : While establishing the connection. `n "
			Write-DebugLog "FAILURE : While establishing the connection " $Info
			throw
		}		
		#$global:3parArray = $ArrayFQDNorIPAddress
		$key = ($credentialdata.Content | ConvertFrom-Json).key
		#$global:3parKey = $key
		if(!$key)
			{	Write-DebugLog "Stop: No key Generated"
				Write-Error "Error: No key Generated"
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

		# Set to the prompt as "Array Name:Connection Type (WSAPI|CLI)>"		
		Function global:prompt 
		{	if ($global:WsapiConnection -ne $null)	{	$global:ArrayName + ":WSAPI>" } 
			else									{	(Get-Location).Path + ">"	}
		}			
		Write-DebugLog "End: If there are no errors reported on the console then the SAN connection object is set and ready to be used" $Info		
		#Write-Verbose -Message "Acquired token: $global:3parKey"
		Write-Verbose -Message 'You are now connected to the HPE Storage system'
		Write-Verbose -Message 'Show array informations:'	
		return $SANC
}

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
[CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
Param()
Begin 
{	Test-WSAPIConnection
}
Process 
{	if ($pscmdlet.ShouldProcess($h.name,"Disconnect from array")) 
		{	#Build uri
			#$ip = $WsapiConnection.IPAddress
			$key = $WsapiConnection.Key
			Write-DebugLog "Running: Building uri to close wsapi connection cmdlet." $Debug
			$uri = '/credentials/'+$key
			#init the response var
			$data = $null
			#Request
			Write-DebugLog "Request: Request to close wsapi connection (Invoke-WSAPI)." $Debug
			$data = Invoke-WSAPI -uri $uri -type 'DELETE'
			$global:WsapiConnection = $null
			# Set to the default prompt as current path
			if ($global:WsapiConnection -eq $null)
				{	Function global:prompt {(Get-Location).Path + ">"}
				}
			return $data
			<#
				If ($global:3parkey) 
					{	Write-Verbose -Message "Delete key session: $global:3parkey"
						Remove-Variable -name 3parKey -scope global
						Write-DebugLog "End: Key Deleted" $Debug
					}
				If ($global:3parArray) 
					{	Write-Verbose -Message "Delete Array: $global:3parArray"
						Remove-Variable -name 3parArray -scope global
						Write-DebugLog "End: Delete Array: $global:3parArray" $Debug
					}
			#>
		}
	Write-DebugLog "End: Close-WSAPIConnection" $Debug
}
}

Export-ModuleMember New-WSAPIConnection , Close-WSAPIConnection
