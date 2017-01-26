$ErrorActionPreference = "Stop"
$OsName = "9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9"
$IsoExtractPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("..\$OsName")
$OfflineMountFolder = $IsoExtractPath + "_Slipstream"

if (Test-Path $OfflineMountFolder){
	try {
		$OutNull = Dismount-WindowsImage -Path $OfflineMountFolder -Discard
	} catch {
	}
	Remove-Item -Recurse -Force $OfflineMountFolder
} 