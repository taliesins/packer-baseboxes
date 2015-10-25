
&c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /mode:vm /quiet /quit
Write-Host "sysprep exit code was $LASTEXITCODE"

@('c:\unattend.xml', 'c:\windows\panther\unattend\unattend.xml', 'c:\windows\panther\unattend.xml', 'c:\windows\system32\sysprep\unattend.xml') | %{
	if (test-path $_){
		remove-item $_
	}	
}

if (!(test-path 'c:\windows\panther\unattend')) {
     New-Item -path 'c:\windows\panther\unattend' -type directory
}

if (Test-Path 'a:\sysprep-unattend.xml'){
	Copy-Item 'a:\sysprep-unattend.xml' 'c:\windows\panther\unattend\unattend.xml'
} else {
	Copy-Item 'f:\sysprep-unattend.xml' 'c:\windows\panther\unattend\unattend.xml'	
}
&shutdown -s

exit 0 