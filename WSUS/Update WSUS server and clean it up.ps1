$ErrorActionPreference = 'Stop'

$CurrentPath = Split-Path -parent $MyInvocation.MyCommand.Definition
Push-Location $CurrentPath

try {
	$WsusServer = Get-WsusServer
} catch {
	Write-Host "Is this user member of WSUS Administrator group"
	throw $_
}

Import-Module .\PSWsusSpringClean.psm1


Invoke-WsusSpringClean -SynchroniseServer -DeclineItaniumUpdates -DeclinePrereleaseUpdates -DeclineCategoriesInclude @('Superseded','Pre-release') 

Pop-Location