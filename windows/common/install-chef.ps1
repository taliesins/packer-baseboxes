$ProgressPreference="SilentlyContinue"
$version = '12.6.0-1'
$msi_file_name = "chef-client-$($version)-x86.msi"

if ($ENV:HttpIp){
    $httpIp = $ENV:HttpIp
    $httpPort = $ENV:HttpPort
    $download_url = "http://$($httpIp):$($httpPort)/$msi_file_name"
} else {
    $download_url = "http://opscode-omnibus-packages.s3.amazonaws.com/windows/2012r2/i386/$msi_file_name"
}

(New-Object System.Net.WebClient).DownloadFile($download_url, "C:\Windows\Temp\$msi_file_name")

$argumentList = '/quiet /qn /norestart /i "C:\Windows\Temp\' + $msi_file_name + '"'

$process = Start-Process -FilePath "msiexec" -ArgumentList $argumentList -NoNewWindow -PassThru -Wait
$process.ExitCode