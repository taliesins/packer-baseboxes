$ProgressPreference="SilentlyContinue"

for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
	$variablePath = [char]$c + ':\variables.ps1'

	if (test-path $variablePath) {
		. $variablePath
		break
	}
}

&c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /mode:vm /quiet /quit
Write-Host "sysprep exit code was $LASTEXITCODE"

@('c:\unattend.xml', 'c:\windows\panther\unattend\unattend.xml', 'c:\windows\panther\unattend.xml', 'c:\windows\system32\sysprep\unattend.xml') | %{
	if (test-path $_){
		write-host "Removing $($_)"
		remove-item $_ > $null
	}	
}

if (!(test-path 'c:\windows\panther\unattend')) {
	write-host "Creating directory $($_)"
    New-Item -path 'c:\windows\panther\unattend' -type directory > $null
}

if (Test-Path 'a:\sysprep-unattend.xml'){
	write-host "Copying a:\sysprep-unattend.xml to c:\windows\panther\unattend\unattend.xml"
	Copy-Item 'a:\sysprep-unattend.xml' 'c:\windows\panther\unattend\unattend.xml' > $null
} elseif (Test-Path 'e:\sysprep-unattend.xml'){
	write-host "Copying e:\sysprep-unattend.xml to c:\windows\panther\unattend\unattend.xml"
	Copy-Item 'e:\sysprep-unattend.xml' 'c:\windows\panther\unattend\unattend.xml' > $null
} else {
	write-host "Copying f:\sysprep-unattend.xml to c:\windows\panther\unattend\unattend.xml"
	Copy-Item 'f:\sysprep-unattend.xml' 'c:\windows\panther\unattend\unattend.xml'> $null
}

write-host "Running shutdown"
&shutdown -s
Write-Host "shutdown exit code was $LASTEXITCODE"

write-host "Return exit 0"
exit 0 