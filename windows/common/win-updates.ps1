
param($global:RestartRequired=0,
        $global:MoreUpdates=0,
        $global:MaxCycles=100,
        $MaxUpdatesPerCycle=500)

"Starting $($MyInvocation.MyCommand.Name)" | Out-File -Filepath "$($env:TEMP)\BoxImageCreation_$($MyInvocation.MyCommand.Name).started.txt" -Append
        
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"

$Logfile = "$env:TEMP\\win-updates.log"

function LogWrite {
   Param ([string]$logstring)
   $now = Get-Date -format s
   Add-Content $Logfile -value "$now $logstring"
   Write-Host $logstring
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

function EnableWinRm() {
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

    $line = 0
    do {
      Start-Sleep -m 100
      $line = SlurpOutput $line
    } while (!($t.state -eq 3))

    $result = $t.LastTaskResult
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($s) | Out-Null

    cmd /c schtasks.exe /delete /TN "$name" /f

    cmd /c netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in localport=5985 action=allow
    cmd /c netsh firewall add portopening TCP 5985 "Port 5985"
    cmd /c netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allow
    cmd /c netsh firewall add portopening TCP 5986 "Port 5986"

    $configureServiceStartup = "sc.exe config winrm start= auto"
    Invoke-Expression -Command $configureServiceStartup -ErrorAction Stop
    start-service winrm
}

function Check-ContinueRestartOrEnd() {
    $RegistryKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    $RegistryEntry = "InstallWindowsUpdates"
    switch ($global:RestartRequired) {
        0 {
            $prop = (Get-ItemProperty $RegistryKey).$RegistryEntry
            if ($prop) {
                LogWrite "Restart Registry Entry Exists - Removing It"
                Remove-ItemProperty -Path $RegistryKey -Name $RegistryEntry -ErrorAction SilentlyContinue
            }

            LogWrite "No Restart Required"
            Check-WindowsUpdates

            if (($global:MoreUpdates -eq 1) -and ($script:Cycles -le $global:MaxCycles)) {
                Install-WindowsUpdates
            } elseif ($script:Cycles -gt $global:MaxCycles) {
                LogWrite "Exceeded Cycle Count - Stopping"
                EnableWinRm
            } else {
                LogWrite "Done Installing Windows Updates"
                EnableWinRm
            }
        }
        1 {
            $prop = (Get-ItemProperty $RegistryKey).$RegistryEntry
            if (-not $prop) {
                LogWrite "Restart Registry Entry Does Not Exist - Creating It"
                Set-ItemProperty -Path $RegistryKey -Name $RegistryEntry -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -File $($script:ScriptPath) -MaxUpdatesPerCycle $($MaxUpdatesPerCycle)"
            } else {
                LogWrite "Restart Registry Entry Exists Already"
            }

            LogWrite "Restart Required - Restarting..."
            Restart-Computer
        }
        default {
            LogWrite "Unsure If A Restart Is Required"
            break
        }
    }
}

function Install-WindowsUpdates() {
    $script:Cycles++
    LogWrite "Evaluating Available Updates with limit of $($MaxUpdatesPerCycle):"
    $UpdatesToDownload = New-Object -ComObject 'Microsoft.Update.UpdateColl'
    $script:i = 0;
    $CurrentUpdates = $SearchResult.Updates | Select-Object
    while($script:i -lt $CurrentUpdates.Count -and $script:CycleUpdateCount -lt $MaxUpdatesPerCycle) {
        $Update = $CurrentUpdates[$script:i]
        if (($Update -ne $null) -and (!$Update.IsDownloaded)) {
            [bool]$addThisUpdate = $false
            if ($Update.InstallationBehavior.CanRequestUserInput) {
                LogWrite "> Skipping: $($Update.Title) because it requires user input"
            } else {
                if (!($Update.EulaAccepted)) {
                    LogWrite "> Note: $($Update.Title) has a license agreement that must be accepted. Accepting the license."
                    $Update.AcceptEula()
                    [bool]$addThisUpdate = $true
                    $script:CycleUpdateCount++
                } else {
                    [bool]$addThisUpdate = $true
                    $script:CycleUpdateCount++
                }
            }

            if ([bool]$addThisUpdate) {
                LogWrite "Adding: $($Update.Title)"
                $UpdatesToDownload.Add($Update) |Out-Null
            }
        }
        $script:i++
    }

    if ($UpdatesToDownload.Count -eq 0) {
        LogWrite "No Updates To Download..."
    } else {
        LogWrite 'Downloading Updates...'
        $ok = 0;
        while (! $ok) {
            try {
                $Downloader = $UpdateSession.CreateUpdateDownloader()
                $Downloader.Updates = $UpdatesToDownload
                $Downloader.Download()
                $ok = 1;
            } catch {
                LogWrite $_.Exception | Format-List -force
                LogWrite "Error downloading updates. Retrying in 30s."
                $script:attempts = $script:attempts + 1
                Start-Sleep -s 30
            }
        }
    }

    $UpdatesToInstall = New-Object -ComObject 'Microsoft.Update.UpdateColl'
    [bool]$rebootMayBeRequired = $false
    LogWrite 'The following updates are downloaded and ready to be installed:'
    foreach ($Update in $SearchResult.Updates) {
        if (($Update.IsDownloaded)) {
            LogWrite "> $($Update.Title)"
            $UpdatesToInstall.Add($Update) |Out-Null

            if ($Update.InstallationBehavior.RebootBehavior -gt 0){
                [bool]$rebootMayBeRequired = $true
            }
        }
    }

    if ($UpdatesToInstall.Count -eq 0) {
        LogWrite 'No updates available to install...'
        $global:MoreUpdates=0
    }

    if ($rebootMayBeRequired) {
        LogWrite 'These updates may require a reboot'
        $global:RestartRequired=1
    }

    if ($UpdatesToInstall.Count -gt 0) {
        LogWrite 'Installing updates...'

        $Installer = $script:UpdateSession.CreateUpdateInstaller()
        $Installer.Updates = $UpdatesToInstall
        $InstallationResult = $Installer.Install()

        LogWrite "Installation Result: $($InstallationResult.ResultCode)"
        LogWrite "Reboot Required: $($InstallationResult.RebootRequired)"
        LogWrite 'Listing of updates installed and individual installation results:'
        if ($InstallationResult.RebootRequired) {
            $global:RestartRequired=1
        } else {
            $global:RestartRequired=0
        }

        for($i=0; $i -lt $UpdatesToInstall.Count; $i++) {
            New-Object -TypeName PSObject -Property @{
                Title = $UpdatesToInstall.Item($i).Title
                Result = $InstallationResult.GetUpdateResult($i).ResultCode
            }
        }
    }
    Check-ContinueRestartOrEnd
}

function Check-WindowsUpdates() {
    LogWrite "Checking For Windows Updates"
    $Username = $env:USERDOMAIN + "\" + $env:USERNAME

    New-EventLog -Source $ScriptName -LogName 'Windows Powershell' -ErrorAction SilentlyContinue

    $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()

    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
    LogWrite $Message

    $script:UpdateSearcher = $script:UpdateSession.CreateUpdateSearcher()
    $script:successful = $FALSE
    $script:attempts = 0
    $script:maxAttempts = 12
    while(-not $script:successful -and $script:attempts -lt $script:maxAttempts) {
        try {
            $script:SearchResult = $script:UpdateSearcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")
            $script:successful = $TRUE
        } catch {
            LogWrite $_.Exception | Format-List -force
            LogWrite "Search call to UpdateSearcher was unsuccessful. Retrying in 10s."
            $script:attempts = $script:attempts + 1
            Start-Sleep -s 10
        }
    }

    if ($SearchResult.Updates.Count -ne 0) {
        $Message = "There are " + $SearchResult.Updates.Count + " more updates."
        LogWrite $Message
        try {
            $script:SearchResult.Updates |Select-Object -Property Title, Description, SupportUrl, UninstallationNotes, RebootRequired, EulaAccepted |Format-List
            $global:MoreUpdates=1
        } catch {
            LogWrite $_.Exception | Format-List -force
            LogWrite "Showing SearchResult was unsuccessful. Rebooting."
            $global:RestartRequired=1
            $global:MoreUpdates=0
            Check-ContinueRestartOrEnd
            LogWrite "Show never happen to see this text!"
            Restart-Computer
        }
    } else {
        LogWrite 'There are no applicable updates'
        $global:RestartRequired=0
        $global:MoreUpdates=0
    }
}

$script:ScriptName = $MyInvocation.MyCommand.ToString()
$script:ScriptPath = $MyInvocation.MyCommand.Path
$script:UpdateSession = New-Object -ComObject 'Microsoft.Update.Session'
$script:UpdateSession.ClientApplicationID = 'Packer Windows Update Installer'

$proxyServerAddress = ""
$proxyServerUsername = ""
$proxyServerPassword = ""

if ($proxyServerAddress) {
    $script:WebProxy = New-Object -ComObject 'Microsoft.Update.WebProxy'
    $script:WebProxyBypass = New-Object -ComObject 'Microsoft.Update.StringColl'
    $script:WebProxyBypass.Add("*.localtest.me")
    $script:WebProxy.AutoDetect = $false
    $script:WebProxy.Address = $proxyServerAddress
    if ($proxyServerUsername) {
        $script:WebProxy.Username = $proxyServerUsername
    }
    if ($proxyServerPassword) {
        $script:WebProxy.SetPassword($proxyServerPassword)
    }
    $script:WebProxy.BypassProxyOnLocal = $true
    $script:WebProxy.BypassList = $script:WebProxyBypass
    $script:UpdateSession.WebProxy = $script:WebProxy
}

$script:UpdateSearcher = $script:UpdateSession.CreateUpdateSearcher()
$script:SearchResult = New-Object -ComObject 'Microsoft.Update.UpdateColl'
$script:Cycles = 0
$script:CycleUpdateCount = 0

Check-WindowsUpdates
if ($global:MoreUpdates -eq 1) {
    Install-WindowsUpdates
} else {
    Check-ContinueRestartOrEnd
}
