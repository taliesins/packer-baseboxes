$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\Update-WindowsImage.ps1")
}
catch {
    Write-Host "Error while loading supporting PowerShell Scripts" 
}

$OsName = '14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US'
$TargetPath = 'Windows Server 2016'
$WsusContentFolder = 'E:\WSUS\WsusContent'
$WsusServerName = 'localhost'

$IsoPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("..\$OsName")
$OfflineMountFolder = $IsoPath + "_Slipstream"
$WimPath = join-path $IsoPath 'sources\install.wim'

$Images = @(
	@{'Path'=$WimPath; 'Index' = 1}
	@{'Path'=$WimPath; 'Index' = 2}
)

if (!(Test-Path $WsusContentFolder)) {
	for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
	{  
		$WsusContentFolder = [char]$c + ':\WSUS\WsusContent'

		if (test-path $WsusContentFolder) {
			break
		}
	}
}

Update-WindowsImage -Images $Images -TargetProduct $TargetPath -WsusContentFolder $WsusContentFolder -WsusServerName $WsusServerName -OfflineMountFolder $OfflineMountFolder