 c:/windows/system32/sysprep/sysprep.exe /generalize /oobe /mode:vm /quiet /quit

@('c:\unattend.xml', 'c:\windows\panther\unattend\unattend.xml', 'c:\windows\panther\unattend.xml', 'c:\windows\system32\sysprep\unattend.xml') | %{
	if (test-path $_){
		remove-item $_
	}	
}

if (!(test-path c:\windows\panther\unattend)) {
	mkdir c:\windows\panther\unattend
}

cp C:\sysprep-unattend.xml c:\windows\panther\unattend\unattend.xml

$result = Stop-Computer -Force

exit 0 