$ErrorActionPreference = "Stop"
$OsName = "14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US"
$IsoExtractPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("..\$OsName")
$OfflineMountFolder = $IsoExtractPath + "_Slipstream"

if (Test-Path $OfflineMountFolder){
	try {
		$OutNull = Dismount-WindowsImage -Path $OfflineMountFolder -Discard
	} catch {
	}
	Remove-Item -Recurse -Force $OfflineMountFolder
} 