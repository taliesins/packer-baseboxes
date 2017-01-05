
$CurrentPath = Split-Path -parent $MyInvocation.MyCommand.Definition

$variablesPath = "$CurrentPath\common\variables.ps1"
if (test-path $variablesPath){
	remove-item $variablesPath -Force
}

$WSUSServer = $ENV:WSUSServer

if (!$WSUSServer){
	if ($ENV:WsusServerName) {
		$protocol = 'http://'
		$port = '8530'
		if ($ENV:WsusServerPort) {
			$port = $ENV:WsusServerPort
			if ($port -eq '8531'){
				$protocol = 'https://'
			}
		}

		$WSUSServer = "$($protocol)$($ENV:WsusServerName):$($port)"
	}
}

$file = @"
`$WSUSServer = "$($WSUSServer)"
`$proxyServerAddress = "$($ENV:proxyServerAddress)"
`$proxyServerUsername = "$($ENV:proxyServerUsername)"
`$proxyServerPassword = "$($ENV:proxyServerPassword)"
`$httpIp = "$($ENV:httpIp)"
`$httpPort = "$($ENV:httpPort)"

if (`$ENV:WSUSServer) {
	`$WSUSServer = `$ENV:WSUSServer
}

if (`$ENV:proxyServerAddress) {
	`$proxyServerAddress = `$ENV:proxyServerAddress
}

if (`$ENV:proxyServerUsername) {
	`$proxyServerUsername = `$ENV:proxyServerUsername
}

if (`$ENV:proxyServerPassword) {
	`$proxyServerPassword = `$ENV:proxyServerPassword
}

if (`$ENV:httpIp) {
	`$httpIp = `$ENV:httpIp
}

if (`$ENV:httpPort) {
	`$httpPort = `$ENV:httpPort
}
"@

$file | out-file -filepath $variablesPath