$ProgressPreference="SilentlyContinue"
$ErrorActionPreference = "Stop"

for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
	$drive = [char]$c + ':'
	$variablePath = join-path $drive 'variables.ps1'

	if (test-path $variablePath) {
		. $variablePath
		break
	}
}

if (Test-Path a:\vagrant.pub) {
	Copy-Item a:\vagrant.pub C:\Users\vagrant\.ssh\authorized_keys -Force
} elseif (Test-Path d:\vagrant.pub) {
	Copy-Item d:\vagrant.pub C:\Users\vagrant\.ssh\authorized_keys -Force
} elseif (Test-Path e:\vagrant.pub) {
	Copy-Item e:\vagrant.pub C:\Users\vagrant\.ssh\authorized_keys -Force
} elseif (Test-Path f:\vagrant.pub) {
	Copy-Item f:\vagrant.pub C:\Users\vagrant\.ssh\authorized_keys -Force
} else {
	(New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub', 'C:\Users\vagrant\.ssh\authorized_keys')
}