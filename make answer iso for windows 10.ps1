$isoFolder = "answer-iso"
if (test-path $isoFolder){
	remove-item $isoFolder -Force -Recurse
}

if (test-path windows\windows-10-amd64\answer.iso){
	remove-item windows\windows-10-amd64\answer.iso -Force
}



mkdir $isoFolder

copy windows\windows-10-amd64\Autounattend.xml $isoFolder\
copy windows\windows-10-amd64\sysprep-unattend.xml $isoFolder\
copy windows\common\set-power-config.ps1 $isoFolder\
copy windows\common\microsoft-updates.ps1 $isoFolder\
copy windows\common\win-updates.ps1 $isoFolder\
copy windows\common\run-sysprep.ps1 $isoFolder\
copy windows\common\run-sysprep.cmd $isoFolder\

$textFile = "$isoFolder\Autounattend.xml" 

$c = Get-Content -Encoding UTF8 $textFile

$c | % { $_ -replace '<!-- Start Non UEFI -->','<!-- Start Non UEFI' } | % { $_ -replace '<!-- Finish Non UEFI -->','Finish Non UEFI -->' } | % { $_ -replace '<!-- Start UEFI compatible','<!-- Start UEFI compatible -->' } | % { $_ -replace 'Finish UEFI compatible -->','<!-- Finish UEFI compatible -->' } | sc -Path $textFile

& .\mkisofs.exe -r -iso-level 4 -UDF -o windows\windows-10-amd64\answer.iso $isoFolder

if (test-path $isoFolder){
	remove-item $isoFolder -Force -Recurse
}