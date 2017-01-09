$osFolder = 'windows-10-amd64'
$isoFolder = 'answer-iso'
if (test-path $isoFolder){
	remove-item $isoFolder -Force -Recurse
}

if (test-path windows\$osFolder\answer.iso){
	remove-item windows\$osFolder\answer.iso -Force
}

$ENV:UnAttendUseUefi = $true
$ENV:UnAttendUseCdrom = $true

&.\windows\update-variables.ps1

mkdir $isoFolder

copy windows\$osFolder\Autounattend.xml $isoFolder\
copy windows\$osFolder\sysprep-unattend.xml $isoFolder\
copy windows\common\variables.ps1 $isoFolder\

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
copy windows\common\Reset-ClientWSUSSetting.ps1 $isoFolder\

& .\mkisofs.exe -r -iso-level 4 -UDF -o windows\$osFolder\answer.iso $isoFolder

if (test-path $isoFolder){
	remove-item $isoFolder -Force -Recurse
}