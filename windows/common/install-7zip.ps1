$ProgressPreference="SilentlyContinue"

for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
	$variablePath = [char]$c + ':\variables.ps1'

	if (test-path $variablePath) {
		. $variablePath
		break
	}
}

$version = '1604'
$msi_file_name = "7z$version-x64.msi"

if ($httpIp){
	if (!$httpPort){
    	$httpPort = "80"
    }
    $download_url = "http://$($httpIp):$($httpPort)/$msi_file_name"
} else {
    $download_url = "http://www.7-zip.org/a/$msi_file_name"
}

(New-Object System.Net.WebClient).DownloadFile($download_url, "C:\Windows\Temp\$msi_file_name")
$argumentList = '/qb /i "C:\Windows\Temp\' + $msi_file_name + '" INSTALLDIR="C:\7-zip"'

$process = Start-Process -FilePath "msiexec" -ArgumentList $argumentList -NoNewWindow -PassThru -Wait
$process.ExitCode