
$variablesPath = 'windows\common\variables.ps1'
if (test-path $variablesPath){
	remove-item $variablesPath -Force
}

$file = @"
`$WSUSServer = "$($ENV:WSUSServer)"
`$proxyServerAddress = "$($ENV:proxyServerAddress)"
`$proxyServerUsername = $("$ENV:proxyServerUsername)"
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