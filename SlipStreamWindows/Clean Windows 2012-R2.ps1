$OsName = "9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9"
$IsoExtractPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("..\$OsName")

if (Test-Path $IsoExtractPath){
	Remove-Item -Recurse -Force $IsoExtractPath
} 