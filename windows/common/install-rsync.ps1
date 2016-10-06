$ProgressPreference="SilentlyContinue"
$ErrorActionPreference = "Stop"

$ScriptDirectory = Split-Path $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDirectory variables.ps1)

$version = '3.1.1-1'
$rsync_file_name = "rsync-$version.tar"
$rsync_tar_file_name = "$rsync_file_name.xz"

if ($ENV:HttpIp){
    $httpIp = $ENV:HttpIp
    $httpPort = $ENV:HttpPort
    $download_url = "http://$($httpIp):$($httpPort)/$rsync_tar_file_name"
} else {
    $download_url = "http://mirrors.kernel.org/sourceware/cygwin/x86_64/release/rsync/$rsync_tar_file_name"
}


(New-Object System.Net.WebClient).DownloadFile($download_url, "c:\windows\temp\$rsync_tar_file_name")
&"c:\7-zip\7z.exe" x "c:\windows\temp\$rsync_tar_file_name" -oc:\windows\temp -aoa | Out-Host
&"c:\7-zip\7z.exe" x "c:\windows\temp\$rsync_file_name" -oc:\windows\temp\rsync -aoa | Out-Host

Copy-Item c:\windows\temp\rsync\usr\bin\rsync.exe "C:\Program Files\OpenSSH\bin\rsync.exe" -Force

Write-Host "make symlink for c:/vagrant share"
&cmd /c mklink /D "C:\Program Files\OpenSSH\vagrant" "C:\vagrant"