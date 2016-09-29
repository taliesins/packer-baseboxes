$ProgressPreference="SilentlyContinue"
$version = '5.1.6'
$iso_name = "VBoxGuestAdditions_$version.iso"

if ($ENV:HttpIp){
    $httpIp = $ENV:HttpIp
    $httpPort = $ENV:HttpPort
    $download_url = "http://$($httpIp):$($httpPort)/$iso_name"
} else {
    $download_url = "http://download.virtualbox.org/virtualbox/$version/$iso_name"
}

(New-Object System.Net.WebClient).DownloadFile($download_url, "c:\windows\temp\$iso_name")
&"c:\7-zip\7z.exe" x "c:\windows\temp\$iso_name" -oc:\windows\temp\virtualbox -aoa | Out-Host
&certutil -addstore -f "TrustedPublisher" a:\oracle-cert.cer
&"c:\windows\temp\virtualbox\VBoxWindowsAdditions-amd64.exe" /S | Out-Host

exit 0