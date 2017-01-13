$ProgressPreference="SilentlyContinue"

$variablePath = ""
for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
	$variablePath = [char]$c + ':\variables.ps1'

	if (test-path $variablePath) {
		. $variablePath
		break
	}
}

$msi_file_name = "sdelete.exe"

$scriptPath = split-path -parent $variablePath
$download_path = join-path $scriptPath $msi_file_name 

if ($SkipSDelete){
	Write-Host "Skipping sdelete"
	exit 0
}

&"$download_path" -accepteula -z $($env:SystemDrive)