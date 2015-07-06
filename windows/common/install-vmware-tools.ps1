$version = '9.4.12-2627939'
$iso_name = 'VMware-tools-windows-$version.iso'

if ($ENV:HttpIp){
    $httpIp = $ENV:HttpIp
    $httpPort = $ENV:HttpPort
    $download_url = "http://$($httpIp):$($httpPort)/$iso_name"
} else {
    $download_url = "http://packages.vmware.com/tools/esx/latest/windows/x64/$iso_name"
}

(New-Object System.Net.WebClient).DownloadFile($download_url, "c:\windows\temp\$iso_name")
&"c:\7-zip\7z.exe" x "c:\windows\temp\$iso_name" -oc:\windows\temp\vmware -aoa | Out-Host
&"c:\windows\temp\vmware\setup.exe" /S /v`"/qn REBOOT=R`" | Out-Host

exit 0