$CurrentPath = Split-Path -parent $MyInvocation.MyCommand.Definition
Push-Location $CurrentPath

Import-Module .\PSWsusSpringClean.psm1
Invoke-WsusSpringClean -SynchroniseServer -DeclineItaniumUpdates -DeclineUnneededUpdates -DeclineCategoriesInclude @('Superseded','Pre-release') 

Pop-Location