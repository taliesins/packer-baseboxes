$ProgressPreference="SilentlyContinue"
$taskDescription = "Enable WinRM"
$taskName = "EnableWinRM"
$username = "vagrant"
$password = "vagrant"

$script = @'
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Value 1 -Type DWord
enable-psremoting -SkipNetworkProfileCheck -Force
Set-WSManQuickConfig -SkipNetworkProfileCheck -Force
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Value 1 -Type DWord

Set-Item WSMan:\localhost\Client\TrustedHosts -Value * -Force
Set-Item WSMan:\localhost\Client\AllowUnencrypted -Value $true -Force
Set-Item WSMan:\localhost\Client\Auth\Basic -Value $true -Force

Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true -Force

if ((Get-Item WSMan:\localhost\Service\AllowUnencrypted).Value -ne $true) {
	Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $true -Force  #firewall exception will occur if we have any interfaces that are public (fixnetwork.ps1 should make it private)
}

if ((Get-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB).Value -lt 300) {
	Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB -Value 300 -Force
}

if ((Get-Item WSMan:\localhost\Shell\MaxShellRunTime).Value -lt 1800000) {
	Set-Item WSMan:\localhost\Shell\MaxShellRunTime -Value 1800000 -Force #depreceated 
}

Set-Item WSMan:\localhost\Listener\*\Port -Value 5985 -Force
stop-service winrm
cmd /c sc config winrm start= disabled
'@

$commandBytes = [System.Text.Encoding]::Unicode.GetBytes($script)
$encodedCommand = [Convert]::ToBase64String($commandBytes)

$name = $taskName
$log = "$env:TEMP\$name.out"
$s = New-Object -ComObject "Schedule.Service"
$s.Connect()
$t = $s.NewTask($null)

$t.XmlText = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
	<Description>$taskDescription</Description>
  </RegistrationInfo>
  <Principals>
    <Principal id="Author">
      <UserId>$username</UserId>
      <LogonType>Password</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT24H</ExecutionTimeLimit>
    <Priority>4</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>cmd</Command>
	  <Arguments>/c powershell.exe -EncodedCommand $encodedCommand &gt; %TEMP%\$($taskName).out 2&gt;&amp;1</Arguments>
    </Exec>
  </Actions>
</Task>
"@

$f = $s.GetFolder("\")
$f.RegisterTaskDefinition($name, $t, 6, $username, $password, 1, $null) | Out-Null
$t = $f.GetTask("\$name")
$t.Run($null) | Out-Null
$timeout = 10
$sec = 0
while ((!($t.state -eq 4)) -and ($sec -lt $timeout)) {
  Start-Sleep -s 1
  $sec++
}

function SlurpOutput($l) {
  if (Test-Path $log) {
    Get-Content $log | select -skip $l | ForEach {
      $l += 1
      "$_" | Out-File -Filepath "$($env:TEMP)\enablewinrm.log" -Append
    }
  }
  return $l
}

$line = 0
do {
  Start-Sleep -m 100
  $line = SlurpOutput $line
} while (!($t.state -eq 3))

$result = $t.LastTaskResult
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($s) | Out-Null

cmd /c schtasks.exe /delete /TN "$name" /f

exit $result