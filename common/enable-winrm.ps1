$configureServiceStartup = "sc.exe config winrm start= auto"
Invoke-Expression -Command $configureServiceStartup -ErrorAction Stop
start-service winrm