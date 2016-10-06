$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"

for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
	$variablePath = [char]$c + ':\variables.ps1'

	if (test-path $variablePath) {
		. $variablePath
		break
	}
}

"Starting $($MyInvocation.MyCommand.Name)" | Out-File -Filepath "$($env:TEMP)\BoxImageCreation_$($MyInvocation.MyCommand.Name).started.txt" -Append

#Set power configuration to High Performance
&powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
#Monitor timeout
&powercfg -Change -monitor-timeout-ac 0
&powercfg -Change -monitor-timeout-dc 0
&powercfg -hibernate OFF