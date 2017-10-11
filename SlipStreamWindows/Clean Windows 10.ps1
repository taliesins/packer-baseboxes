$ErrorActionPreference = "Stop"
$OsName = "15063.0.170317-1834.RS2_RELEASE_CLIENTENTERPRISEEVAL_OEMRET_X64FRE_EN-US"
$IsoExtractPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("..\$OsName")
$OfflineMountFolder = $IsoExtractPath + "_Slipstream"

if (Test-Path $OfflineMountFolder){
	try {
		$OutNull = Dismount-WindowsImage -Path $OfflineMountFolder -Discard
	} catch {
	}
	Remove-Item -Recurse -Force $OfflineMountFolder
} 