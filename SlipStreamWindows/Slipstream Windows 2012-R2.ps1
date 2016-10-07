$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\Update-WindowsImage.ps1")
}
catch {
    Write-Host "Error while loading supporting PowerShell Scripts" 
}

$OsName = '9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9'
$TargetPath = 'Windows Server 2012 R2'
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