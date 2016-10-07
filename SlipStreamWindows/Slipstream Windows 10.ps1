$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\Update-WindowsImage.ps1")
}
catch {
    Write-Host "Error while loading supporting PowerShell Scripts" 
}

$OsName = '14393.0.160715-1616.RS1_RELEASE_CLIENTENTERPRISEEVAL_OEMRET_X64FRE_EN-US'
$TargetPath = 'Windows 10'
$WsusContentFolder = 'E:\WSUS\WsusContent'
$WsusServerName = 'localhost'

$IsoPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(".\$OsName")
$OfflineMountFolder = $IsoPath + "_Slipstream"
$WimPath = join-path $IsoPath 'sources\install.wim'

$Images = @(
	@{'Path'=$WimPath; 'Index' = 1}
)

Update-WindowsImage -Images $Images -TargetProduct $TargetPath -WsusContentFolder $WsusContentFolder -WsusServerName $WsusServerName -OfflineMountFolder $OfflineMountFolder