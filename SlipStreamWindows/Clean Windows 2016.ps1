$OsName = "14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US"
$IsoExtractPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("..\$OsName")

if (Test-Path $IsoExtractPath){
	Remove-Item -Recurse -Force $IsoExtractPath
} 