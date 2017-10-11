$CurrentPath = Split-Path -parent $MyInvocation.MyCommand.Definition

$UnAttendWindowsName = "vagrant"
if ($ENV:UnAttendWindowsName) {
	$UnAttendWindowsName = $ENV:UnAttendWindowsName
}

$UnAttendWindowsDisplayName = "vagrant"
if ($ENV:UnAttendWindowsDisplayName) {
	$UnAttendWindowsDisplayName = $ENV:UnAttendWindowsDisplayName
}

$UnAttendWindowsDescription = "vagrant"
if ($ENV:UnAttendWindowsDescription) {
	$UnAttendWindowsDescription = $ENV:UnAttendWindowsDescription
}

$UnAttendWindowsUsername = "vagrant"
if ($ENV:UnAttendWindowsUsername) {
	$UnAttendWindowsUsername = $ENV:UnAttendWindowsUsername
}

$UnAttendWindowsPassword = "vagrant"
if ($ENV:UnAttendWindowsPassword) {
	$UnAttendWindowsPassword = $ENV:UnAttendWindowsPassword
}

$UnAttendWindowsFullName = "vagrant"
if ($ENV:UnAttendWindowsFullName) {
	$UnAttendWindowsFullName = $ENV:UnAttendWindowsFullName
}

$UnAttendWindowsOrganization = "vagrant"
if ($ENV:UnAttendWindowsOrganization) {
	$UnAttendWindowsOrganization = $ENV:UnAttendWindowsOrganization
}

$UnAttendUseUefi = $false
if ($ENV:UnAttendUseUefi) {
	$UnAttendUseUefi = [System.Convert]::ToBoolean($ENV:UnAttendUseUefi)
}

$UnAttendUseCdrom = $false
if ($ENV:UnAttendUseCdrom) {
	$UnAttendUseCdrom = [System.Convert]::ToBoolean($ENV:UnAttendUseCdrom)
}

$UnAttendProxy = ""
if ($ENV:UnAttendProxy) {
	$UnAttendProxy = $ENV:UnAttendProxy
}

$UnAttendWindows10ProductKey = ""
if ($ENV:UnAttendWindows10ProductKey) {
	$UnAttendWindows10ProductKey = $ENV:UnAttendWindows10ProductKey
}

$UnAttendWindows2012ProductKey = ""
if ($ENV:UnAttendWindows2012ProductKey) {
	$UnAttendWindows2012ProductKey = $ENV:UnAttendWindows2012ProductKey
}

$UnAttendWindows2016ProductKey = ""
if ($ENV:UnAttendWindows2016ProductKey) {
	$UnAttendWindows2016ProductKey = $ENV:UnAttendWindows2016ProductKey
}

$UnAttendWindowsDismProductKey = ""
if ($ENV:UnAttendWindowsDismProductKey) {
	$UnAttendWindowsDismProductKey = $ENV:UnAttendWindowsDismProductKey
}

$UnAttendWindowsDismProductEdition = ""
if ($ENV:UnAttendWindowsDismProductEdition) {
	$UnAttendWindowsDismProductEdition = $ENV:UnAttendWindowsDismProductEdition
}

$UnAttendWindows10ComputerName = "win-10"
if ($ENV:UnAttendWindows10ComputerName) {
	$UnAttendWindows10ComputerName = $ENV:UnAttendWindows10ComputerName
}

$UnAttendWindows2012ComputerName = "win-2012R2"
if ($ENV:UnAttendWindows2012ComputerName) {
	$UnAttendWindows2012ComputerName = $ENV:UnAttendWindows2012ComputerName
}

$UnAttendWindows2016ComputerName = "win-2016"
if ($ENV:UnAttendWindows2016ComputerName) {
	$UnAttendWindows2016ComputerName = $ENV:UnAttendWindows2016ComputerName
}

$SkipWindowsUpdates = $false
if ($ENV:SkipWindowsUpdates) {
	$SkipWindowsUpdates = [System.Convert]::ToBoolean($ENV:SkipWindowsUpdates)
}

$SkipCleanup = $false
if ($ENV:SkipCleanup) {
	$SkipCleanup = [System.Convert]::ToBoolean($ENV:SkipCleanup)
}

$SkipCompileDotNetAssemblies = $false
if ($ENV:SkipCompileDotNetAssemblies) {
	$SkipCompileDotNetAssemblies = [System.Convert]::ToBoolean($ENV:SkipCompileDotNetAssemblies)
}

$SkipDefrag = $false
if ($ENV:SkipDefrag) {
	$SkipDefrag = [System.Convert]::ToBoolean($ENV:SkipDefrag)
}

$SkipSDelete = $false
if ($ENV:SkipSDelete) {
	$SkipSDelete = [System.Convert]::ToBoolean($ENV:SkipSDelete)
}

@("windows-10-amd64", "windows-2012R2-serverstandard-amd64", "windows-2016-serverstandard-amd64") | %{
	$osDirectory = $_
	$autounattendPath = "$CurrentPath\$osDirectory\Autounattend.xml" 
	$autounattend = Get-Content -Encoding UTF8 "$autounattendPath.template"

	$autounattend = $autounattend | % { $_ -replace '<Name>vagrant</Name>',"<Name>$UnAttendWindowsName</Name>" } 
	$autounattend = $autounattend | % { $_ -replace '<DisplayName>vagrant</DisplayName>',"<DisplayName>$UnAttendWindowsDisplayName</DisplayName>" } 
	$autounattend = $autounattend | % { $_ -replace '<Description>vagrant</Description>',"<Description>$UnAttendWindowsDescription</Description>" } 
	$autounattend = $autounattend | % { $_ -replace '<Username>vagrant</Username>',"<Username>$UnAttendWindowsUsername</Username>" } 
	$autounattend = $autounattend | % { $_ -replace '<FullName>vagrant</FullName>',"<FullName>$UnAttendWindowsFullName</FullName>" } 
	$autounattend = $autounattend | % { $_ -replace '<Organization>vagrant</Organization>',"<Organization>$UnAttendWindowsOrganization</Organization>" } 
	$autounattend = $autounattend | % { $_ -replace 'name=''vagrant''',"name='$UnAttendWindowsUsername'" }
	$autounattend = $autounattend | % { $_ -replace '<Value>vagrant</Value>',"<Value>$UnAttendWindowsPassword</Value>" }
	$autounattend = $autounattend | % { $_ -replace '/d vagrant',"/d $UnAttendWindowsPassword" }
	
	if ($UnAttendUseUefi) {
		#Enable UEFI and disable Non UEFI
		$autounattend = $autounattend | % { $_ -replace '<!-- Start Non UEFI -->','<!-- Start Non UEFI' } | % { $_ -replace '<!-- Finish Non UEFI -->','Finish Non UEFI -->' } | % { $_ -replace '<!-- Start UEFI compatible','<!-- Start UEFI compatible -->' } | % { $_ -replace 'Finish UEFI compatible -->','<!-- Finish UEFI compatible -->' } 
	}
	
	if ($UnAttendUseCdrom) {
		#Use cd rom instead of floppy drive for drivers
		$autounattend = $autounattend | % { $_ -replace '<!-- Start floppy for drivers -->','<!-- Start floppy for drivers' } | % { $_ -replace '<!-- Finish floppy for drivers -->','Finish floppy for drivers -->' } | % { $_ -replace '<!-- Start cdrom for drivers','<!-- Start cdrom for drivers -->' } | % { $_ -replace 'Finish cdrom for drivers -->','<!-- Finish cdrom for drivers -->' } 
	}
	
	if ($UnAttendProxy) {
		#Use a proxy
		$autounattend = $autounattend | % { $_ -replace '<!-- Start Setup cache proxy during installation','<!-- Start Setup cache proxy during installation -->' } | % { $_ -replace 'Finish Setup cache proxy during installation -->','<!-- Finish Setup cache proxy during installation -->' } | % { $_ -replace '<HKLMProxyServer>cachingproxy:3142</HKLMProxyServer>',"<HKLMProxyServer>$UnAttendProxy</HKLMProxyServer>"}  
	}
	
	if ($osDirectory -eq "windows-10-amd64") {
		if ($UnAttendWindows10ProductKey) {
			$autounattend = $autounattend | % { $_ -replace '<!--<Key>VTNMT-2FMYP-QCY43-QR9VK-WTVCK</Key>-->',"<Key>$UnAttendWindows10ProductKey</Key>" }
		}
		
		if ($UnAttendWindows10ComputerName) {
			$autounattend = $autounattend | % { $_ -replace '<ComputerName>win-10</ComputerName>',"<ComputerName>$UnAttendWindows10ComputerName</ComputerName>" }
		}
	}
	
	if ($osDirectory -eq "windows-2012R2-serverstandard-amd64") {
		if ($UnAttendWindows2012ProductKey) {
			$autounattend = $autounattend | % { $_ -replace '<!--<Key>D2N9P-3P6X9-2R39C-7RTCD-MDVJX</Key>-->',"<Key>$UnAttendWindows2012ProductKey</Key>" }
			$autounattend = $autounattend | % { $_ -replace '<!--<ProductKey>D2N9P-3P6X9-2R39C-7RTCD-MDVJX</ProductKey>-->',"<ProductKey>$UnAttendWindows2012ProductKey</ProductKey>" }
		}
		
		if ($UnAttendWindows2012ComputerName) {
			$autounattend = $autounattend | % { $_ -replace '<ComputerName>win-2012R2</ComputerName>',"<ComputerName>$UnAttendWindows2012ComputerName</ComputerName>" }
		}
	}

	if ($osDirectory -eq "windows-2016-serverstandard-amd64") {
		if ($UnAttendWindows2016ProductKey) {
			$autounattend = $autounattend | % { $_ -replace '<!--<Key>WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY</Key>-->',"<Key>$UnAttendWindows2016ProductKey</Key>" }
		}	
		
		if ($UnAttendWindows2016ComputerName) {
			$autounattend = $autounattend | % { $_ -replace '<ComputerName>win-2016</ComputerName>',"<ComputerName>$UnAttendWindows2016ComputerName</ComputerName>" }
		}
	}
	
	$autounattend | sc -Path $autounattendPath
	
	$sysprepunattendPath = "$CurrentPath\$osDirectory\sysprep-unattend.xml" 
	$sysprepunattend = Get-Content -Encoding UTF8 "$sysprepunattendPath.template"

	$sysprepunattend = $sysprepunattend | % { $_ -replace '<Name>vagrant</Name>',"<Name>$UnAttendWindowsName</Name>" } 
	$sysprepunattend = $sysprepunattend | % { $_ -replace '<DisplayName>vagrant</DisplayName>',"<DisplayName>$UnAttendWindowsDisplayName</DisplayName>" } 
	$sysprepunattend = $sysprepunattend | % { $_ -replace '<Description>vagrant</Description>',"<Description>$UnAttendWindowsDescription</Description>" } 
	$sysprepunattend = $sysprepunattend | % { $_ -replace '<Username>vagrant</Username>',"<Username>$UnAttendWindowsUsername</Username>" } 
	$sysprepunattend = $sysprepunattend | % { $_ -replace '<FullName>vagrant</FullName>',"<FullName>$UnAttendWindowsFullName</FullName>" } 
	$sysprepunattend = $sysprepunattend | % { $_ -replace '<Organization>vagrant</Organization>',"<Organization>$UnAttendWindowsOrganization</Organization>" } 
	$sysprepunattend = $sysprepunattend | % { $_ -replace 'name=''vagrant''',"name='$UnAttendWindowsUsername'" }
	$sysprepunattend = $sysprepunattend | % { $_ -replace '<Value>vagrant</Value>',"<Value>$UnAttendWindowsPassword</Value>" }
	
	if ($UnAttendProxy) {
		#We using a proxy so disable it afterwards
		$sysprepunattend = $sysprepunattend | % { $_ -replace '<!-- Setup proxy after sysprep','<!-- Setup proxy after sysprep -->' } | % { $_ -replace 'Finish proxy after sysprep -->','<!-- Finish proxy after sysprep -->' }   
	}
	
	$sysprepunattend | sc -Path $sysprepunattendPath
}

$variablesPath = "$CurrentPath\common\variables.ps1"
if (test-path $variablesPath){
	remove-item $variablesPath -Force
}

$WSUSServer = $ENV:WSUSServer

if (!$WSUSServer){
	if ($ENV:WsusServerName) {
		$protocol = 'http://'
		$port = '8530'
		if ($ENV:WsusServerPort) {
			$port = $ENV:WsusServerPort
			if ($port -eq '8531'){
				$protocol = 'https://'
			}
		}

		$WSUSServer = "$($protocol)$($ENV:WsusServerName):$($port)"
	}
}

if (!$WSUSServer){
	#Read WSUS Server from registry

	Push-Location
	Set-Location HKLM:
	
	$WSUSEnv = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
	$WSUSServer = Get-ItemProperty -Path $WSUSEnv -Name "WUServer" -ErrorAction SilentlyContinue
	
	if ($WSUSServer) {
		$WSUSServer = $WSUSServer.WUServer
	}
	
	Pop-Location
}

$file = @"
`$UnAttendWindowsUsername = '$($UnAttendWindowsUsername)'
`$UnAttendWindowsPassword = '$($UnAttendWindowsPassword)'
`$UnAttendWindowsDismProductKey = '$($UnAttendWindowsDismProductKey)'
`$UnAttendWindowsDismProductEdition = '$($UnAttendWindowsDismProductEdition)'
`$WSUSServer = '$($WSUSServer)'
`$proxyServerAddress = '$($ENV:proxyServerAddress)'
`$proxyServerUsername = '$($ENV:proxyServerUsername)'
`$proxyServerPassword = '$($ENV:proxyServerPassword)'
`$httpIp = '$($ENV:httpIp)'
`$httpPort = '$($ENV:httpPort)'
`$SkipWindowsUpdates = [System.Convert]::ToBoolean('$($SkipWindowsUpdates)')
`$SkipCleanup = [System.Convert]::ToBoolean('$($SkipCleanup)')
`$SkipCompileDotNetAssemblies = [System.Convert]::ToBoolean('$($SkipCompileDotNetAssemblies)')
`$SkipDefrag = [System.Convert]::ToBoolean('$($SkipDefrag)')
`$AuthorizedKeys = '$($ENV:AuthorizedKeys)'

if (`$ENV:UnAttendWindowsUsername) {
	`$UnAttendWindowsUsername = `$ENV:UnAttendWindowsUsername
}

if (`$ENV:UnAttendWindowsPassword) {
	`$UnAttendWindowsPassword = `$ENV:UnAttendWindowsPassword
}

if (`$ENV:UnAttendWindowsDismProductKey) {
	`$UnAttendWindowsDismProductKey = `$ENV:UnAttendWindowsDismProductKey
}

if (`$ENV:UnAttendWindowsDismProductEdition) {
	`$UnAttendWindowsDismProductEdition = `$ENV:UnAttendWindowsDismProductEdition
}

if (`$ENV:WSUSServer) {
	`$WSUSServer = `$ENV:WSUSServer
}

if (`$ENV:proxyServerAddress) {
	`$proxyServerAddress = `$ENV:proxyServerAddress
}

if (`$ENV:proxyServerUsername) {
	`$proxyServerUsername = `$ENV:proxyServerUsername
}

if (`$ENV:proxyServerPassword) {
	`$proxyServerPassword = `$ENV:proxyServerPassword
}

if (`$ENV:httpIp) {
	`$httpIp = `$ENV:httpIp
}

if (`$ENV:httpPort) {
	`$httpPort = `$ENV:httpPort
}

if (`$ENV:SkipWindowsUpdates) {
	`$SkipWindowsUpdates = [System.Convert]::ToBoolean(`$ENV:SkipWindowsUpdates)
}

if (`$ENV:SkipCleanup) {
	`$SkipCleanup = [System.Convert]::ToBoolean(`$ENV:SkipCleanup)
}

if (`$ENV:SkipCompileDotNetAssemblies) {
	`$SkipCompileDotNetAssemblies = [System.Convert]::ToBoolean(`$ENV:SkipCompileDotNetAssemblies)
}

if (`$ENV:SkipDefrag) {
	`$SkipDefrag = [System.Convert]::ToBoolean(`$ENV:SkipSDelete)
}

if (`$ENV:AuthorizedKeys) {
	`$AuthorizedKeys = `$ENV:AuthorizedKeys
}
"@

$file | out-file -filepath $variablesPath