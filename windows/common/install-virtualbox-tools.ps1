$ProgressPreference="SilentlyContinue"

for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
	$variablePath = [char]$c + ':\variables.ps1'

	if (test-path $variablePath) {
		. $variablePath
		break
	}
}

$version = '5.1.18'
$iso_name = "VBoxGuestAdditions_$version.iso"

if ($httpIp){
	if (!$httpPort){
    	$httpPort = "80"
    }
    $download_url = "http://$($httpIp):$($httpPort)/$iso_name"
} else {
    $download_url = "http://download.virtualbox.org/virtualbox/$version/$iso_name"
}

(New-Object System.Net.WebClient).DownloadFile($download_url, "c:\windows\temp\$iso_name")
&"c:\7-zip\7z.exe" x "c:\windows\temp\$iso_name" -oc:\windows\temp\virtualbox -aoa | Out-Host
&certutil -addstore -f "TrustedPublisher" a:\oracle-cert.cer
&"c:\windows\temp\virtualbox\VBoxWindowsAdditions-amd64.exe" /S | Out-Host

exit 0