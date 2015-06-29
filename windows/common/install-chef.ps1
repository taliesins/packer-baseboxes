$version = '12.4.0-1'
$msi_file_name = "chef-client-$($version).msi"

if ($ENV:HttpIp){
    $httpIp = $ENV:HttpIp
    $httpPort = $ENV:HttpPort
    $download_url = "http://$httpIp:$httpPort/$msi_file_name"
} else {
    $download_url = "https://opscode-omnibus-packages.s3.amazonaws.com/windows/2008r2/x86_64/$msi_file_name"
}

(New-Object System.Net.WebClient).DownloadFile($download_url, "C:\Windows\Temp\$msi_file_name")
Start-Process 'msiexec' -ArgumentList '/qb /i C:\\Windows\\Temp\\$msi_file_name' -NoNewWindow -Wait