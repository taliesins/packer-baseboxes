
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
"@

$file | out-file -filepath $variablesPath