$msi_file_name = "sdelete.exe"
$download_url = "http://live.sysinternals.com/sdelete.exe"
$download_path = "C:\Windows\Temp\$msi_file_name"

(New-Object System.Net.WebClient).DownloadFile($download_url, $download_path)

&"$download_path" -accepteula -z $($env:SystemDrive)