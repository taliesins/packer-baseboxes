$ErrorActionPreference = "Stop"
$OsName = "9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9"
$IsoExtractPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("..\$OsName")
$IsoPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("..\$($OsName).iso")
$SevenZipPath = "C:\Program Files\7-Zip\7z.exe"

if (Test-Path $IsoExtractPath){
	Write-Host "ISO already extraced."
} else {
	&$SevenZipPath x $IsoPath -o"$($IsoExtractPath)" -aoa | Out-Host	
}