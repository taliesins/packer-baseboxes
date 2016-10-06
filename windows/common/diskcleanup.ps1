$ProgressPreference="SilentlyContinue"

for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
    $variablePath = [char]$c + ':\variables.ps1'

    if (test-path $variablePath) {
        . $variablePath
        break
    }
}

#http://gregramsey.net
#more info here:
#http://support.microsoft.com/kb/253597

Add-WindowsFeature -Name Desktop-Experience

#ensure we're running on windows 8.1 first
if ((Get-CimInstance win32_operatingsystem).version -eq '6.3.9600') {

    #Capture current free disk space on Drive C
    $FreespaceBefore = (Get-WmiObject win32_logicaldisk -filter "DeviceID='$($env:SystemDrive)'" | select Freespace).FreeSpace/1GB

    #Set StateFlags0012 setting for each item in Windows 8.1 disk cleanup utility
    if  (-not (get-itemproperty -path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders' -name StateFlags0012 -ErrorAction SilentlyContinue)) {
        set-itemproperty -path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\BranchCache' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Memory Dump Files' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Service Pack Cleanup' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Setup Log Files' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error memory dump files' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error minidump files' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Upgrade Discarded Files' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\User file versions' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Defender' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Archive Files' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Queue Files' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Archive Files' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Queue Files' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows ESD installation files' -name StateFlags0012 -type DWORD -Value 2
        set-itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files' -name StateFlags0012 -type DWORD -Value 2
    }

    cleanmgr /sagerun:12

    do {
        "waiting for cleanmgr to complete. . ."
        start-sleep 5
    } while ((get-wmiobject win32_process | where-object {$_.processname -eq 'cleanmgr.exe'} | measure).count)

    $FreespaceAfter = (Get-WmiObject win32_logicaldisk -filter "DeviceID='C:'" | select Freespace).FreeSpace/1GB

    "Free Space Before: {0}" -f $FreespaceBefore
    "Free Space After: {0}" -f $FreespaceAfter
}

@('Desktop-Experience',
  'InkAndHandwritingServices',
  'Server-Media-Foundation',
  'Powershell-ISE') | Remove-WindowsFeature