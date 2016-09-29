$ProgressPreference="SilentlyContinue"
$ErrorActionPreference = "Stop"

function Execute-DownloadUrl(
	$downloadUrl,
    $downloadPath
){
	(New-Object System.Net.WebClient).DownloadFile($downloadUrl, $downloadPath)
}

function Execute-Unzip(
	$fileToUnzip,
    $extractPath
){
    $cmd = "c:\7-zip\7z.exe"
    $cmdArgs = "x `"$fileToUnzip`" -o$extractPath -aoa"

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $cmd
    $pinfo.RedirectStandardError = $false
    $pinfo.RedirectStandardOutput = $false
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $cmdArgs

    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()

    if ($p.ExitCode -ne 0){
        throw "Unzip failed."
    }

    return $p
}

function Execute-Vmware(
	$setupPath
){
    $cmd = $setupPath

    #Have left out VMXNet3 NIC driver, paravirtual SCSI driver, PS2 Mouse driver and shared folders
    $cmdArgs = "/S /l C:\Windows\Temp\vmware_tools.log /v`"/qn REBOOT=ReallySuppress ADDLOCAL=Audio,FileIntrospection,NetworkIntrospection,VSS,Perfmon,TrayIcon,Common,Drivers,MemCtl,MouseUsb,SVGA,VMCI,Toolbox,Plugins,Unity`""

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $cmd
    $pinfo.RedirectStandardError = $false
    $pinfo.RedirectStandardOutput = $false
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $cmdArgs

    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()

    if ($p.ExitCode -ne 0 -and $p.ExitCode -ne 3010){
        throw "Vmware install failed."
    }

    return $p
}

$version = '9.4.15-2827462'
$iso_name = "VMware-tools-windows-$version.iso"

if ($ENV:HttpIp){
    $httpIp = $ENV:HttpIp
    $httpPort = $ENV:HttpPort
    $download_url = "http://$($httpIp):$($httpPort)/$iso_name"
} else {
    $download_url = "https://packages.vmware.com/tools/esx/5.5u3/windows/x64/$iso_name"
}

Write-Host "Downloading from $download_url to c:\windows\temp\$iso_name"
Execute-DownloadUrl -downloadUrl $download_url -downloadPath "c:\windows\temp\$iso_name"

Execute-Unzip -fileToUnzip "c:\windows\temp\$iso_name" -extractPath "c:\windows\temp\vmware"

Write-Host "Start installing vmware"
$process = Execute-Vmware -setupPath "c:\windows\temp\vmware\setup.exe"

if ($process.ExitCode -eq 0){
    Write-Host "Vmware installed"
    exit 0
} elseif ($process.ExitCode -eq 3010){
    Write-Host "Vmware installed - but reboot required"    
    exit 0
} else {
    Write-Error "Vmware install failed"
    exit $process.ExitCode
}