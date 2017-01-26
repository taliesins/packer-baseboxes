$ErrorActionPreference = "Stop"
$OsName = "9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9"
$BootImagePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("..\" + $OsName + "\boot\etfsboot.com")
$EfiBootImagePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("..\" +$OsName + "\efi\Microsoft\boot\efisys.bin")
$SlipStreamFolder = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("..\" +$OsName + "\")
$SlipStreamIsoPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("..\" +$OsName + "_Slipstream.iso")
$OscdImgPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(".\oscdimg.exe")

if (Test-Path $SlipStreamIsoPath){
	Remove-Item $SlipStreamIsoPath -Force
}

$BootData='2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$BootImagePath","$EfiBootImagePath"

$Proc = Start-Process -FilePath "$OscdImgPath" -ArgumentList @("-bootdata:$BootData",'-u2','-udfver102',"$SlipStreamFolder","$SlipStreamIsoPath") -PassThru -Wait -NoNewWindow
if($Proc.ExitCode -ne 0)
{
    Throw "Failed to generate ISO with exitcode: $($Proc.ExitCode)"
}