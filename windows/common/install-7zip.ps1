$version = '938'
$msi_file_name = "7z$version-x64.msi"

if ($ENV:HttpIp){
    $httpIp = $ENV:HttpIp
    $httpPort = $ENV:HttpPort
    $download_url = "http://$($httpIp):$($httpPort)/$msi_file_name"
} else {
    $download_url = "http://www.7-zip.org/a/$msi_file_name"
}

(New-Object System.Net.WebClient).DownloadFile($download_url, "C:\Windows\Temp\$msi_file_name")
&msiexec /i "C:\Windows\Temp\$msi_file_name" INSTALLDIR='C:\7-zip' /qb