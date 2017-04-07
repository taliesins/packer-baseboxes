$ProgressPreference="SilentlyContinue"

for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
	$variablePath = [char]$c + ':\variables.ps1'

	if (test-path $variablePath) {
		. $variablePath
		break
	}
}

$version = '7.0.2'
$msi_file_name = "ultradefrag-portable-$($version).bin.amd64.zip"

if ($httpIp){
	if (!$httpPort){
    	$httpPort = "80"
    }
    $download_url = "http://$($httpIp):$($httpPort)/$msi_file_name"
} else {
    $download_url = "http://downloads.sourceforge.net/project/ultradefrag/stable-release/$($version)/$($msi_file_name)"
}

$download_path = "C:\Windows\Temp\$msi_file_name"
$install_path = "C:\Windows\Temp\ultradefrag"

(New-Object System.Net.WebClient).DownloadFile($download_url, $download_path)
&"c:\7-zip\7z.exe" e -y -o"$install_path" "$download_path" *\udefrag.exe *\*.dll

if ($SkipDefrag){
	Write-Host "Skipping defrag"
	exit 0
}

&"$install_path\udefrag.exe" --optimize --repeat $($env:SystemDrive)