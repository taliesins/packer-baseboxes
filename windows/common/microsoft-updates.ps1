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

stop-service wuauserv
&reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v EnableFeaturedSoftware /t REG_DWORD /d 1 /f
&reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v IncludeRecommendedUpdates /t REG_DWORD /d 1 /f

$mu = New-Object -ComObject Microsoft.Update.ServiceManager -Strict 
$result = $mu.AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"")

start-service wuauserv