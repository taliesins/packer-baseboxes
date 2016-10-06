$ProgressPreference="SilentlyContinue"

$ScriptDirectory = Split-Path $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDirectory variables.ps1)

$msi_file_name = "sdelete.exe"

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$download_path = join-path $scriptPath $msi_file_name 

&"$download_path" -accepteula -z $($env:SystemDrive)