$ProgressPreference="SilentlyContinue"

for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
	$variablePath = [char]$c + ':\variables.ps1'

	if (test-path $variablePath) {
		. $variablePath
		break
	}
}

$msi_file_name = "sdelete.exe"

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$download_path = join-path $scriptPath $msi_file_name 

&"$download_path" -accepteula -z $($env:SystemDrive)