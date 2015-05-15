$iso_name = 'VMware-tools-windows-9.4.12-2627939.iso'
$download_url = "https://packages.vmware.com/tools/esx/latest/windows/x64/$iso_name"

(New-Object System.Net.WebClient).DownloadFile($download_url, "c:\windows\temp\$iso_name")
&c:\7-zip\7z.exe x "c:\windows\temp\$iso_name" -oc:\windows\temp\vmware -aoa | Out-Host
&c:\windows\temp\vmware\setup.exe /S /v`"/qn REBOOT=R`" | Out-Host

exit 0