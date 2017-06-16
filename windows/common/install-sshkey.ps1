$ProgressPreference="SilentlyContinue"
$ErrorActionPreference = "Stop"

for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
	$variablePath = [char]$c + ':\variables.ps1'

	if (test-path $variablePath) {
		. $variablePath
		break
	}
}

$username = "vagrant"
if ($UnAttendWindowsUsername) {
	$username = $UnAttendWindowsUsername
}

if ($AuthorizedKeys) {
	Set-Content -Path "C:\Users\$username\.ssh\authorized_keys" -Value $AuthorizedKeys -Encoding Ascii
} elseif (Test-Path a:\vagrant.pub) {
	Copy-Item a:\vagrant.pub C:\Users\$username\.ssh\authorized_keys -Force
} elseif (Test-Path d:\vagrant.pub) {
	Copy-Item d:\vagrant.pub C:\Users\$username\.ssh\authorized_keys -Force
} elseif (Test-Path e:\vagrant.pub) {
	Copy-Item e:\vagrant.pub C:\Users\$username\.ssh\authorized_keys -Force
} elseif (Test-Path f:\vagrant.pub) {
	Copy-Item f:\vagrant.pub C:\Users\$username\.ssh\authorized_keys -Force
} else {
	(New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub', "C:\Users\$username\.ssh\authorized_keys")
}