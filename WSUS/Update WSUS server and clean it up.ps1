ipmo $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(".\PSWsusSpringClean.psm1")

Invoke-WsusSpringClean -SynchroniseServer -DeclineItaniumUpdates -DeclineUnneededUpdates -DeclineCategoriesInclude @('Superseded','Pre-release') 
