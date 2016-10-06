$ProgressPreference="SilentlyContinue"

for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
	$variablePath = [char]$c + ':\variables.ps1'

	if (test-path $variablePath) {
		. $variablePath
		break
	}
}

$version = '12.5.1-1'
$msi_file_name = "chef-client-$($version)-x86.msi"

if ($httpIp){
	if (!$httpPort){
    	$httpPort = "80"
    }
    $download_url = "http://$($httpIp):$($httpPort)/$msi_file_name"
} else {
    $download_url = "http://opscode-omnibus-packages.s3.amazonaws.com/windows/2008r2/i386/$msi_file_name"
}

(New-Object System.Net.WebClient).DownloadFile($download_url, "C:\Windows\Temp\$msi_file_name")

$argumentList = '/quiet /qn /norestart /i "C:\Windows\Temp\' + $msi_file_name + '"'

$process = Start-Process -FilePath "msiexec" -ArgumentList $argumentList -NoNewWindow -PassThru -Wait
$process.ExitCode