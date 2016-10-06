$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"

$ScriptDirectory = Split-Path $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDirectory variables.ps1)

"Starting $($MyInvocation.MyCommand.Name)" | Out-File -Filepath "$($env:TEMP)\BoxImageCreation_$($MyInvocation.MyCommand.Name).started.txt" -Append

#Set power configuration to High Performance
&powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
#Monitor timeout
&powercfg -Change -monitor-timeout-ac 0
&powercfg -Change -monitor-timeout-dc 0
&powercfg -hibernate OFF