$iso_name = 'VBoxGuestAdditions_4.3.26.iso'
$download_url = "http://download.virtualbox.org/virtualbox/4.3.26/$iso_name"

(New-Object System.Net.WebClient).DownloadFile($download_url, "c:\windows\temp\$iso_name")
&"c:\7-zip\7z.exe" x "c:\windows\temp\$iso_name" -oc:\windows\temp\virtualbox -aoa | Out-Host
&certutil -addstore -f "TrustedPublisher" a:\oracle-cert.cer
&"c:\windows\temp\virtualbox\VBoxWindowsAdditions-amd64.exe" /S | Out-Host

exit 0