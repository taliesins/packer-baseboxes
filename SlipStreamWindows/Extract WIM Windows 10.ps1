$ErrorActionPreference = "Stop"
$OsName = "15063.0.170317-1834.RS2_RELEASE_CLIENTENTERPRISEEVAL_OEMRET_X64FRE_EN-US"
$IsoExtractPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("..\$OsName")
$IsoPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("..\$($OsName).iso")
$SevenZipPath = "C:\Program Files\7-Zip\7z.exe"

if (Test-Path $IsoExtractPath){
	Write-Host "ISO already extraced."
} else {
	&$SevenZipPath x $IsoPath -o"$($IsoExtractPath)" -aoa | Out-Host	
}