$ProgressPreference="SilentlyContinue"
$version = '6.1.0'
$msi_file_name = "ultradefrag-portable-$($version).bin.amd64.zip"
$download_url = "http://downloads.sourceforge.net/ultradefrag/ultradefrag-portable-6.1.0.bin.amd64.zip"
$download_path = "C:\Windows\Temp\$msi_file_name"
$install_path = "C:\Windows\Temp\ultradefrag"

(New-Object System.Net.WebClient).DownloadFile($download_url, $download_path)
&"c:\7-zip\7z.exe" e -y -o"$install_path" "$download_path" *\udefrag.exe *\*.dll

&"$install_path\udefrag.exe" --optimize --repeat $($env:SystemDrive)