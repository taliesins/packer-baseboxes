Get-WindowsFeature | ? { $_.InstallState -eq 'Available' } | Uninstall-WindowsFeature -Remove

Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase