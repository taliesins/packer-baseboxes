$ProgressPreference="SilentlyContinue"
$ErrorActionPreference = "stop"

for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
	$variablePath = [char]$c + ':\variables.ps1'

	if (test-path $variablePath) {
		. $variablePath
		break
	}
}

$tempfolders = @("C:\Windows\Temp\*", "C:\Windows\Prefetch\*", "C:\Documents and Settings\*\Local Settings\temp\*", "C:\Users\*\Appdata\Local\Temp\*")
Remove-Item $tempfolders -ErrorAction SilentlyContinue -Force -Recurse

try{
	Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
} catch {
	Write-Host "Unable to reset base. Should be ok if patches have been slipstreamed."
}

$moduleExist = Get-Module servermanager

if ($moduleExist){
	import-module servermanager

	Get-WindowsFeature | ? { $_.InstallState -eq 'Available' } | Uninstall-WindowsFeature -Remove
}