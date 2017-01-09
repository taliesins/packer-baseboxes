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

$taskDescription = "Enable WinRM"
$taskName = "EnableWinRM"
$username = "Administrator"

$password = "vagrant"
if ($UnAttendWindowsPassword) {
	$password = $UnAttendWindowsPassword
}

$CurrentPath = Split-Path -parent $MyInvocation.MyCommand.Definition
$scriptToExecute = "$CurrentPath\enable-winrm.ps1"

# Try to get the Schedule.Service object. If it fails, we are probably
# on an older version of Windows. On old versions, we can just execute
# directly since priv. escalation isn't a thing.
$schedule = $null
Try {
  $schedule = New-Object -ComObject "Schedule.Service"
  Write-Host "Scheduled task created"
} Catch [System.Management.Automation.PSArgumentException] {
  exit $LASTEXITCODE
}

$task_name = "WinRM_Elevated_Shell"
$out_file = "$env:SystemRoot\Temp\WinRM_Elevated_Shell.log"

if (Test-Path $out_file) {
  del $out_file
}

$task_xml = @'
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <Principals>
    <Principal id="Author">
      <UserId>{username}</UserId>
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
    <ExecutionTimeLimit>{execution_time_limit}</ExecutionTimeLimit>
    <Priority>4</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>cmd</Command>
      <Arguments>{arguments}</Arguments>
    </Exec>
  </Actions>
</Task>
'@

$arguments = "/c powershell.exe -File $scriptToExecute &gt; $out_file 2&gt;&amp;1"

$task_xml = $task_xml.Replace("{arguments}", $arguments)
$task_xml = $task_xml.Replace("{username}", $username)
$task_xml = $task_xml.Replace("{execution_time_limit}", "PT5M")

$schedule.Connect()
$task = $schedule.NewTask($null)
$task.XmlText = $task_xml
$folder = $schedule.GetFolder("\")
$folder.RegisterTaskDefinition($task_name, $task, 6, $username, $password, 1, $null) | Out-Null

$registered_task = $folder.GetTask("\$task_name")
$registered_task.Run($null) | Out-Null

$timeout = 10
$sec = 0
while ( (!($registered_task.state -eq 4)) -and ($sec -lt $timeout) ) {
  Start-Sleep -s 1
  $sec++
}

if ($timeout -lt $sec){
	throw "Task timed out"
	exit 9999
} else {
	Write-Host "Scheduled task running"
}

function SlurpOutput($out_file, $cur_line) {
  if (Test-Path $out_file) {
    get-content $out_file | select -skip $cur_line | ForEach {
      $cur_line += 1
      Write-Host "$_"
    }
  }
  return $cur_line
}

$cur_line = 0
do {
  Start-Sleep -m 100
  $cur_line = SlurpOutput $out_file $cur_line
} while (!($registered_task.state -eq 3))

$exit_code = $registered_task.LastTaskResult
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($schedule) | Out-Null

cmd /c schtasks.exe /delete /TN "$task_name" /f
Write-Host "Removed scheduled task"

exit $exit_code
