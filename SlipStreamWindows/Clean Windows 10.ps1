$OsName = "14393.0.160715-1616.RS1_RELEASE_CLIENTENTERPRISEEVAL_OEMRET_X64FRE_EN-US"
$IsoExtractPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("..\$OsName")
$OfflineMountFolder = $IsoExtractPath + "_Slipstream"

if (Test-Path $OfflineMountFolder){
	Remove-Item -Recurse -Force $OfflineMountFolder
} 