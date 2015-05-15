$version = '922'
$msi_file_name = "7z$version-x64.msi"
$download_url = "http://downloads.sourceforge.net/sevenzip/$msi_file_name"

(New-Object System.Net.WebClient).DownloadFile($download_url, "C:\Windows\Temp\$msi_file_name")
&msiexec /i "C:\Windows\Temp\$msi_file_name" INSTALLDIR='C:\7-zip' /qb