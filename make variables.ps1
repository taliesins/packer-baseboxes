
$variablesPath = 'windows\common\variables.ps1'
if (test-path $variablesPath){
	remove-item $variablesPath -Force
}

$file = @'

'@

$file | out-file -filepath $variablesPath