$ScriptDirectory = Split-Path $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDirectory variables.ps1)

Optimize-Volume -DriveLetter $($env:SystemDrive)[0] -Verbose