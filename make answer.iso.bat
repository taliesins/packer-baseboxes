RD /S /Q answer-iso
mkdir answer-iso
copy windows\windows-2012R2-serverdatacenter-amd64\Autounattend.xml answer-iso\
copy windows\windows-2012R2-serverdatacenter-amd64\sysprep-unattend.xml answer-iso\
copy windows\common\set-power-config.ps1 answer-iso\
copy windows\common\microsoft-updates.ps1 answer-iso\
copy windows\common\win-updates.ps1 answer-iso\
copy windows\common\run-sysprep.ps1 answer-iso\
copy windows\common\run-sysprep.cmd answer-iso\

mkisofs -r -iso-level 4 -o windows\windows-2012R2-serverdatacenter-amd64\answer.iso answer-iso
RD /S /Q answer-iso