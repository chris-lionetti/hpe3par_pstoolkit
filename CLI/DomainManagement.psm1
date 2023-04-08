﻿####################################################################################
## 	© 2020,2021, 2023 Hewlett Packard Enterprise Development LP
##	Description: 	Domain Management cmdlets 
##		

Function Get-Domain
{
<#
.SYNOPSIS
	Get-Domain - Show information about domains in the system.
.DESCRIPTION
	The Get-Domain command displays a list of domains in a system.
.PARAMETER D
	Specifies that detailed information is displayed.
#>
[CmdletBinding()]
param(	[switch]	$D
	)
begin
{	Test-CLIConnectionB
}
Process 
{	$Cmd = " showdomain "
	if($D)	{	$Cmd += " -d "	}
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
	Write-DebugLog "Executing Function : Get-Domain Command -->" INFO: 
	if($Result.count -gt 1)
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -2  
			foreach ($s in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s," +",",")	
					$s= [regex]::Replace($s,"-","")
					$s= $s.Trim() 
					$temp1 = $s -replace 'CreationTime','Date,Time,Zone'
					$s = $temp1		
					Add-Content -Path $tempfile -Value $s				
				}
			Import-Csv $tempFile 
			remove-item $tempFile 	
		}
	else
		{	return  $Result	
		}
	if($Result.count -gt 1)
		{	return  " Success : Executing Get-Domain"
		}
	else
		{	return  $Result
		} 
}
}

Function Get-DomainSet
{
<#
.SYNOPSIS
	Get-DomainSet - show domain set information
.DESCRIPTION
	The Get-DomainSet command lists the domain sets defined on the system and their members.
.EXAMPLE
	Get-DomainSet -D
.PARAMETER D
	Show a more detailed listing of each set.
.PARAMETER Domain
	Show domain sets that contain the supplied domains or patterns
.PARAMETER SetOrDomainName
	specify either Domain Set name or domain name (member of Domain set)
#>
[CmdletBinding()]
param(	[switch]	$D,
		[switch]	$Domain, 
		[String]	$SetOrDomainName
	)
Begin
{	Test-CLIConnectionB
}
Process 
{	$Cmd = " showdomainset "
	if($D)		{	$Cmd += " -d " }
	if($Domain)	{	$Cmd += " -domain "	} 
	if($SetOrDomainName){	$Cmd += " $SetOrDomainName "}
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
	return  $Result
}
}

Function Move-Domain
{
<#
.SYNOPSIS
	Move-Domain - Move objects from one domain to another, or into/out of domains
.DESCRIPTION
	The Move-Domain command moves objects from one domain to another.
.PARAMETER ObjName
	Specifies the name of the object to be moved.
.PARAMETER DomainName
	Specifies the domain or domain set to which the specified object is moved. 
	The domain set name must start with "set:". To remove an object from any domain, specify the string "-unset" for the domain name or domain set specifier.
.PARAMETER Vv
	Specifies that the object is a virtual volume.
.PARAMETER Cpg
	Specifies that the object is a common provisioning group (CPG).
.PARAMETER HostObj
	Specifies that the object is a host.
.PARAMETER F
	Specifies that the command is forced. If this option is not used, the command requires confirmation before proceeding with its operation.
#>
[CmdletBinding()]
param(	[switch]	$vv,
		[switch]	$Cpg,
		[switch]	$HostObj,
		[switch]	$F,
		[String]	$ObjName,
		[String]	$DomainName
	)
begin
{	Test-CLIConnectionB
}
Process
{	$Cmd = " movetodomain "
	if($Vv)		{	$Cmd += " -vv " 	}
	if($Cpg)	{	$Cmd += " -cpg " 	}
	if($HostObj){	$Cmd += " -host " 	}
	if($F) 		{	$Cmd += " -f " 		}
	if($ObjName){	$Cmd += " $ObjName "}
	if($DomainName){$Cmd += " $DomainName " }
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
	if($Result -match "Id")
		{	$tempFile = [IO.Path]::GetTempFileName()
			$LastItem = $Result.Count -1  
			foreach ($s in  $Result[0..$LastItem] )
				{	$s= [regex]::Replace($s,"^ ","")			
					$s= [regex]::Replace($s," +",",")	
					$s= [regex]::Replace($s,"-","")
					$s= $s.Trim()
					Add-Content -Path $tempfile -Value $s				
				}
			Import-Csv $tempFile 
			remove-item $tempFile 	
		}
	if($Result -match "Id")
		{	return  " Success : Executing Move-Domain"
		}
	else{	return "FAILURE : While Executing Move-Domain `n $Result"
		}
} 
}

Function New-Domain
{
<#
.SYNOPSIS
	New-Domain : Create a domain.
.DESCRIPTION
	The New-Domain command creates system domains.
.EXAMPLE
	New-Domain -Domain_name xxx
.EXAMPLE
	New-Domain -Domain_name xxx -Comment "Hello"
.PARAMETER Domain_name
	Specifies the name of the domain you are creating. The domain name can be no more than 31 characters. The name "all" is reserved.
.PARAMETER Comment
	Specify any comments or additional information for the domain. The comment can be up to 511 characters long. Unprintable characters are not allowed. 
	The comment must be placed inside quotation marks if it contains spaces.
.PARAMETER Vvretentiontimemax
	Specify the maximum value that can be set for the retention time of a volume in this domain. <time> is a positive integer value and in the range of 0 - 43,800 hours (1825 days).	
	Time can be specified in days or hours providing either the 'd' or 'D' for day and 'h' or 'H' for hours following the entered time value.
	To disable setting the volume retention time in the domain, enter 0 for <time>.
#>
[CmdletBinding()]
param(									[String]	$Comment,
										[String]	$Vvretentiontimemax,
		[Parameter(Mandatory=$true)]	[String]	$DomainName
)
Begin
{	Test-CLIConnectionB
}
Process
{	$Cmd = " createdomain "
	if($Comment)			{	$Cmd += " -comment " + '" ' + $Comment +' "'	 }
	if($Vvretentiontimemax)	{	$Cmd += " -vvretentiontimemax $Vvretentiontimemax " } 
	if($DomainName)		{	$Cmd += " $DomainName " }
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
	Return $Result
	if ([string]::IsNullOrEmpty($Result))
		{    Return $Result = "Domain : $DomainName Created Successfully."
		}
	else
		{	Return $Result
		}
}
}

Function New-DomainSet
{
<#
.SYNOPSIS
	New-DomainSet : create a domain set or add domains to an existing set
.DESCRIPTION
	The New-DomainSet command defines a new set of domains and provides the option of assigning one or more existing domains to that set. 
	The command also allows the addition of domains to an existing set by use of the -add option.
.EXAMPLE
	New-DomainSet -SetName xyz 
.PARAMETER SetName
	Specifies the name of the domain set to create or add to, using up to 27 characters in length.
.PARAMETER Add
	Specifies that the domains listed should be added to an existing set. At least one domain must be specified.
.PARAMETER Comment
	Specifies any comment or additional information for the set. The comment can be up to 255 characters long. Unprintable characters are not allowed.
#>
[CmdletBinding()]
param(	[Parameter(Mandatory=$true)]	[String]	$SetName,
										[switch]	$Add,
										[String]	$Comment
	)
Begin
{	Test-CLIConnectionB
}
Process
{	$Cmd = " createdomainset " 
	if($Add)	{	$Cmd += " -add " }
	if($Comment){	$Cmd += " -comment " + '" ' + $Comment +' "' }
	if($SetName){	$Cmd += " $SetName " }
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
	Return $Result
}
}

Function Remove-Domain
{
<#
.SYNOPSIS
	Remove-Domain - Remove a domain
.DESCRIPTION
	The Remove-Domain command removes an existing domain from the system.
.EXAMPLE
	Remove-Domain -DomainName xyz
.PARAMETER DomainName
	Specifies the domain that is removed. If the -pat option is specified the DomainName will be treated as a glob-style pattern, and multiple domains will be considered.
.PARAMETER Pat
	Specifies that names will be treated as glob-style patterns and that all domains matching the specified pattern are removed.
#>
[CmdletBinding()]
param(									[switch]	$Pat,
		[Parameter(Mandatory=$true)]	[String]	$DomainName
	)
begin
{	Test-CLIConnection
}
Process
{	$Cmd = " removedomain -f "
	if($Pat)		{	$Cmd += " -pat " }
	if($DomainName)	{	$Cmd += " $DomainName "}
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
	Return $Result
}
}

Function Remove-DomainSet
{
<#
.SYNOPSIS
	Remove-DomainSet : remove a domain set or remove domains from an existing set
.DESCRIPTION
	The Remove-DomainSet command removes a domain set or removes domains from an existing set.
.EXAMPLE
	Remove-DomainSet -SetName xyz
.PARAMETER SetName
	Specifies the name of the domain set. If the -pat option is specified the setname will be treated as a glob-style pattern, and multiple domain sets will be considered.
.PARAMETER Domain
	Optional list of domain names that are members of the set.
	If no <Domain>s are specified, the domain set is removed, otherwise the specified <Domain>s are removed from the domain set. 
	If the -pat option is specified the domain will be treated as a glob-style pattern, and multiple domains will be considered.
.PARAMETER F
	Specifies that the command is forced. If this option is not used, the command requires confirmation before proceeding with its operation.
.PARAMETER Pat
	Specifies that both the set name and domains will be treated as glob-style patterns.
#>
[CmdletBinding()]
param(	[switch]	$F,
		[switch]	$Pat,
		[String]	$SetName,
		[String]	$Domain
	)
begin
{	Test-CLIConnectionB
}
Process
{	$Cmd = " removedomainset "
	if($F)		{ 	$Cmd += " -f " }
	if($Pat)	{	$Cmd += " -pat "}
	if($SetName){	$Cmd += " $SetName " }
	if($Domain)	{	$Cmd += " $Domain " }
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
	Return $Result
}
}

Function Set-Domain
{
<#
.SYNOPSIS
	Set-Domain Change current domain CLI environment parameter.
.DESCRIPTION
	The Set-Domain command changes the current domain CLI environment parameter.
.EXAMPLE
	Set-Domain
.EXAMPLE
	Set-Domain -Domain "XXX"
.PARAMETER Domain
	Name of the domain to be set as the working domain for the current CLI session.  
	If the <domain> parameter is not present or is equal to -unset then the working domain is set to no current domain.
#>
[CmdletBinding()]
param(	[String]	$Domain
	)
begin
{	Test-CLIConnetionB
}
Process
{	$Cmd = " changedomain "
	if($Domain) 	{	$Cmd += " $Domain " }
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
	if([String]::IsNullOrEmpty($Domain))
		{	$Result = "Working domain is unset to current domain."
		}
	else
		{	if([String]::IsNullOrEmpty($Result))
				{	$Result = "Domain : $Domain to be set as the working domain for the current CLI session."
				}
		}
	Return $Result
}
} 

Function Update-Domain
{
<#
.SYNOPSIS
	Update-Domain : Set parameters for a domain.
.DESCRIPTION
	The Update-Domain command sets the parameters and modifies the properties of a domain.
.EXAMPLE
	Update-Domain -DomainName xyz
.PARAMETER DomainName
	Indicates the name of the domain.(Existing Domain Name)
.PARAMETER NewName
	Changes the name of the domain.
.PARAMETER Comment
	Specifies comments or additional information for the domain. The comment can be up to 511 characters long and must be enclosed in quotation
	marks. Unprintable characters are not allowed within the <comment> specifier.
.PARAMETER Vvretentiontimemax
	Specifies the maximum value that can be set for the retention time of a volume in this domain. <time> is a positive integer value and in the
	range of 0 - 43,800 hours (1825 days). Time can be specified in days or hours providing either the 'd' or 'D' for day and 'h' or 'H' for hours
	following the entered time value. To remove the maximum volume retention time for the domain, enter '-vvretentiontimemax ""'. As a result, 
	the maximum volume retention time for the system is used instead. To disable setting the volume retention time in the domain, enter 0 for <time>.
#>
[CmdletBinding()]
param(	[String]	$NewName,
		[String]	$Comment,
		[String]	$Vvretentiontimemax,
		[String]	$DomainName
	)
Begin
{	Test-CLIConnectionB
}
Process
{	$Cmd = " setdomain "
	if($NewName) 			{	$Cmd += " -name $NewName " }
	if($Comment) 			{	$Cmd += " -comment " + '" ' + $Comment +' "' }
	if($Vvretentiontimemax)	{	$Cmd += " -vvretentiontimemax $Vvretentiontimemax " }
	if($DomainName)			{	$Cmd += " $DomainName " }
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
	Return $Result
}
}

Function Update-DomainSet
{
<#
.SYNOPSIS
	Update-DomainSet : set parameters for a domain set
.DESCRIPTION
	The Update-DomainSet command sets the parameters and modifies the properties of a domain set.
.EXAMPLE
	Update-DomainSet -DomainSetName xyz
.PARAMETER DomainSetName
	Specifies the name of the domain set to modify.
.PARAMETER Comment
	Specifies any comment or additional information for the set. The comment can be up to 255 characters long. Unprintable characters are not allowed.
.PARAMETER NewName
	Specifies a new name for the domain set, using up to 27 characters in length.
#>
[CmdletBinding()]
param(							[String]	$Comment,
								[String]	$NewName,
		[Parameter(Mandatory)]	[String]	$DomainSetName
)
begin
{	Test-CLIConnectionB
}
process
{	$Cmd = " setdomainset "
	if($Comment)	{	$Cmd += " -comment " + '" ' + $Comment +' "' }
	if($NewName) 	{	$Cmd += " -name $NewName " }
	if($DomainSetName){	$Cmd += " $DomainSetName " }
	$Result = Invoke-CLICommand -Connection $SANConnection -cmds  $Cmd
	Return $Result
}
}

Export-ModuleMember Get-Domain , Get-DomainSet , Move-Domain , New-Domain , New-DomainSet , Remove-Domain , Remove-DomainSet , Set-Domain , Update-Domain , Update-DomainSet