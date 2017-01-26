$ErrorActionPreference = "Stop"
$OsName = "14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US"
$IsoExtractPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("..\$OsName")
$IsoPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("..\$($OsName).iso")
$SevenZipPath = "C:\Program Files\7-Zip\7z.exe"

if (Test-Path $IsoExtractPath){
	Write-Host "ISO already extraced."
} else {
	&$SevenZipPath x $IsoPath -o"$($IsoExtractPath)" -aoa | Out-Host	
}