$ProgressPreference="SilentlyContinue"

for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
	$variablePath = [char]$c + ':\variables.ps1'

	if (test-path $variablePath) {
		. $variablePath
		break
	}
}

if ($SkipCompileDotNetAssemblies){
	Write-Host "Skipping compile .net assemblies"
	exit 0
}

#http://support.microsoft.com/kb/2570538
#http://robrelyea.wordpress.com/2007/07/13/may-be-helpful-ngen-exe-executequeueditems/


if ((Get-WmiObject -Class Win32_OperatingSystem -ComputerName $env:COMPUTERNAME -ea 0).OSArchitecture -eq '64-bit') {            
    &"$env:windir\microsoft.net\framework\v4.0.30319\ngen.exe" update /force /queue
	&"$env:windir\microsoft.net\framework\v4.0.30319\ngen.exe" executequeueditems
} else  {            
    &"$env:windir\microsoft.net\framework\v4.0.30319\ngen.exe" update /force /queue
	&"$env:windir\microsoft.net\framework64\v4.0.30319\ngen.exe" update /force /queue
	&"$env:windir\microsoft.net\framework\v4.0.30319\ngen.exe" executequeueditems
	&"$env:windir\microsoft.net\framework64\v4.0.30319\ngen.exe" executequeueditems          
}     