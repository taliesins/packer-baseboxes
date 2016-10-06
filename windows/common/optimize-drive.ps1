for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
	$drive = [char]$c + ':'
	$variablePath = join-path $drive 'variables.ps1'

	if (test-path $variablePath) {
		. $variablePath
		break
	}
}

Optimize-Volume -DriveLetter $($env:SystemDrive)[0] -Verbose