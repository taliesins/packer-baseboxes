$osFolder = 'windows-2016-serverstandard-amd64'
$isoFolder = 'answer-iso'
if (test-path $isoFolder){
	remove-item $isoFolder -Force -Recurse
}

if (test-path windows\$osFolder\answer.iso){
	remove-item windows\$osFolder\answer.iso -Force
}

mkdir $isoFolder

copy windows\$osFolder\Autounattend.xml $isoFolder\
copy windows\$osFolder\sysprep-unattend.xml $isoFolder\

copy windows\common\set-power-config.ps1 $isoFolder\
copy windows\common\microsoft-updates.ps1 $isoFolder\
copy windows\common\win-updates.ps1 $isoFolder\
copy windows\common\run-sysprep.ps1 $isoFolder\
copy windows\common\run-sysprep.cmd $isoFolder\
copy windows\common\oracle-cert.cer $isoFolder\
copy windows\common\enablewinrm.ps1 $isoFolder\
copy windows\common\fixnetwork.ps1 $isoFolder\
copy windows\common\sdelete.exe $isoFolder\
copy windows\common\Set-ClientWSUSSetting.ps1 $isoFolder\

#Enable UEFI and disable Non UEFI
$textFile = "$isoFolder\Autounattend.xml" 
$c = Get-Content -Encoding UTF8 $textFile
$c | % { $_ -replace '<!-- Start Non UEFI -->','<!-- Start Non UEFI' } | % { $_ -replace '<!-- Finish Non UEFI -->','Finish Non UEFI -->' } | % { $_ -replace '<!-- Start UEFI compatible','<!-- Start UEFI compatible -->' } | % { $_ -replace 'Finish UEFI compatible -->','<!-- Finish UEFI compatible -->' } | % { $_ -replace '<!-- Start floppy for drivers -->','<!-- Start floppy for drivers' } | % { $_ -replace '<!-- Finish floppy for drivers -->','Finish floppy for drivers -->' } | % { $_ -replace '<!-- Start cdrom for drivers','<!-- Start cdrom for drivers -->' } | % { $_ -replace 'Finish cdrom for drivers -->','<!-- Finish cdrom for drivers -->' } | sc -Path $textFile

& .\mkisofs.exe -r -iso-level 4 -UDF -o windows\$osFolder\answer.iso $isoFolder

if (test-path $isoFolder){
	remove-item $isoFolder -Force -Recurse
}