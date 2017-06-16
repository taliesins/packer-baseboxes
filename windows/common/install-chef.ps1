$ProgressPreference="SilentlyContinue"

for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
	$variablePath = [char]$c + ':\variables.ps1'

	if (test-path $variablePath) {
		. $variablePath
		break
	}
}

$version = '13.1.31'
$build = '-1'
$msi_file_name = "chef-client-$($version)$($build)-x64.msi"

if ($httpIp){
	if (!$httpPort){
    	$httpPort = "80"
    }
    $download_url = "http://$($httpIp):$($httpPort)/$msi_file_name"
} else {
    $download_url = "https://packages.chef.io/files/stable/chef/$($version)/windows/2012/$msi_file_name"
}

(New-Object System.Net.WebClient).DownloadFile($download_url, "C:\Windows\Temp\$msi_file_name")

$argumentList = '/quiet /qn /norestart /i "C:\Windows\Temp\' + $msi_file_name + '"'

$process = Start-Process -FilePath "msiexec" -ArgumentList $argumentList -NoNewWindow -PassThru -Wait
$process.ExitCode