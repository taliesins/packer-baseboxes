$ErrorActionPreference = "Stop"
<#
.SYNOPSIS
	Updates an offline WIM or VHDX from WSUS contents.
.DESCRIPTION
	Updates an offline WIM or VHDX from WSUS contents.
	Can update one or all indexes in a WIM.
	By default, stores a log file next to the file to be updated. On subsequent runs against that file, it will not apply any items previously applied.
.PARAMETER Path
	The path to the WIM or VHDX to be updated.
.PARAMETER Index
	For WIM files only, selects which contained image will be updated. Enter -1 to update all.
	If not specified in a non-interactive session, ALL will be updated.
	If not specified in an interactive session, you will be prompted.
	If supplied with a VHDX file, will be ignored.
.PARAMETER Images
	An array of hash tables that contain the images to be updated.
	Entries must be in the format: @{'Path' = 'c:\imagepath\imagefilename'; 'Index' = 4 }
	The index item does not need to be present for .vhdx files and will be ignored.
.PARAMETER WsusServerName
	A resolvable name or IP address of the computer that runs WSUS.
	Uses the local system by default.
.PARAMETER WsusServerPort
	The port that WSUS responds on. Defaults to 8530.
	Ignored when WsusServerName is not specified.
.PARAMETER $WsusUsesSSL
	Flag if you should connect to WSUS using SSL. Default is to not use SSL.
	Ignored when WsusServerName is not specified.
.PARAMETER WsusContentFolder
	The path of the WSUS system's WsusContent folder. Must be resolvable and accessible from the location that the script is executed.
.PARAMETER TargetProduct
	The target product(s) to limit available product updates to. Use Get-WsusProduct on your WSUS server for a list of available products.
	The default is 'Windows Server 2012 R2' (will also apply to Hyper-V Server 2012 R2).
	Use an empty string or array to select all products. WARNING: This will take an EXTREMELY long time if you have many products on your WSUS server.
.PARAMETER MinimumPatchAgeInDays
	The minimum number of days since a patch appeared on the WSUS host before it can be applied. Default is 0.
.PARAMETER OfflineMountFolder
	The temporary mount location for the WIM/VHDX. If this folder does not exist, it will be created. If this folder exists and is not empty, execution will halt.
	The location will not be removed at the end of execution, but it will be empty.
	The default is \Offline on the system volume.
.PARAMETER IgnoreDeclinedStatus
	If specified, updates that appear as both Approved and Declined will be applied (meaning the update is approved in at least one location even though it is declined in another).
	If not specified, an update that is declined anywhere on the WSUS host will be not be applied.
.NOTES
	Written by Eric Siron
	(c) 2016 Altaro Software
	Version 1.4a. September 14th, 2016

	- 1.4 -
	-------
	* .a: Typos
	* Image logging mechanism reworked to include more information.

	- 1.3 -
	-------
	* Patch log will no longer contain duplicates.
	* An empty patch list will bypass the mount/unmount process.
	* Clarified some error messages.
	* Discrepancy between documentation and configuration for "MinimumPatchAgeInDays". Documentation said default of 0, script said 30. Both are now 0.

	- 1.2 -
	-------
	* Corrected behavior when a single VHDX is submitted (for real this time)
	* Adjusted matching pattern for previous patches

	- 1.1 -
	-------
	* Corrected variable naming mismatch for MinimumPatchAgeInDays
	* Corrected behavior when a single VHDX is submitted
.EXAMPLE
	Update-WindowsImage.ps1 -Path D:\Templates\w2k12r2template.vhdx -WsusContentFolder 'D:\WSUS\WsusContent'
	
	Updates the specified VHDX using the local WSUS server.

.EXAMPLE
	Update-WindowsImage.ps1 -Path D:\FromISO\2k12r2\install.wim -Index -1 -WsusContentFolder 'D:\WSUS\WsusContent'

	Updates the first image within the specified WIM using the local WSUS server.

.EXAMPLE
	$Images = @(
		@{'Path'='D:\FromISO\w2k12r2\install.wim'; 'Index' = 1},
		@('Path'='D:\FromISO\w2k12r2\install.wim'; 'Index' = 2),
		@{'Path'='D:\Templates\w2k12r2.vhdx'},
		@{'Path'='D:\FromISO\hs2k12r2\install.wim'; 'Index' = 1}
	)
	Update-WindowsImages -Images $Images -WsusContentFolder 'D:\WSUS\WsusContent'

	Updates all of the specified images using the local WSUS server.

.EXAMPLE
	Update-WindowsImage.ps1 -Path '\\storage.domain.local\Templates\w2k12r2template.vhdx' -WsusServerName 'wsus.domain.local' -WsusContentFolder '\\wsus.domain.local\d$\WSUS\WsusContent'

	Updates the specified remote image using the specified remote WSUS server, which is running on port 8530.
#>
#requires -RunAsAdministrator
#requires -Version 4
#requires -Modules Dism, UpdateServices

function Update-WindowsImage						#Uncomment this line to use this script dot-sourced or in a profile. Also the next line and the very last line.
{															#uncomment this line to use this script dot-sourced or in a profile. Also the previous line and the very last line.
	[CmdletBinding(DefaultParameterSetName='Single Item')]
	Param(
		[Alias('ImagePath')]
		[ValidateNotNullOrEmpty()]
		[Parameter(Mandatory=$true, ParameterSetName='Single Item', Position=1)]
		[String]$Path,

		[Parameter(ParameterSetName='Single Item', Position=2)]
		[Int]$Index,

		[Parameter(Mandatory=$true, ParameterSetName='Multiple Items', Position=1)]
		[Array]$Images,
	
		[Parameter()]
		[String]$WsusServerName,

		[Alias('Port')]
		[Parameter()]
		[UInt16]$WsusServerPort = 8530,

		[Alias('SSL', 'WithSSL')]
		[Parameter()]
		[Switch]$WsusUsesSSL,

		[Parameter(Mandatory=$true)]
		[String]$WsusContentFolder,

		[Parameter()]
		[String[]]$TargetProduct = @('Windows Server 2012 R2'),

		[Parameter()]
		[UInt16]$MinimumPatchAgeInDays = 0,

		[Parameter()]
		[String]$OfflineMountFolder = "$env:SystemDrive\Offline",

		[Parameter()]
		[Switch]$IgnoreDeclinedStatus
	)

	Write-Progress -Activity 'Validating environment' -Status 'Checking image information' -PercentComplete 25
	$ImageList = @()
	if($PSCmdlet.ParameterSetName -eq 'Single Item')
	{
		try
		{
			$WindowsImage = Get-WindowsImage -ImagePath $Path -ErrorAction Stop
		}
		catch
		{
			throw('Specified image file "{0}" is not valid' -f $Path)
		}
		if(Test-Path -Path $Path)
		{
			$SelectedIndexes = @()
			if($Path -imatch 'wim$')
			{
				if(-not $Index -or -not ($WindowsImage.ImageIndex -contains $Index))
				{
					if([Environment]::UserInteractive)
					{
						$ValidOptions = @(-1)
						$CurrentSelection = -999
						while($ValidOptions -notcontains $CurrentSelection)
						{
							Write-Host -Object 'You must specify an index in the image to apply updates to. Choose one of the following' -ForegroundColor Cyan -BackgroundColor DarkMagenta
							Write-Host -Object '-1: Update All (this will take an EXTREMELY long time'
							$WindowsImage | foreach {
								$ValidOptions += $_.ImageIndex
								Write-Host -Object "$($_.ImageIndex): $($_.ImageName)"
							}
							Write-Host
							$CurrentSelection = Read-Host -Prompt 'Enter a numerical selection from above list or [CTRL+C] to cancel.'
							if($CurrentSelection = -1)
							{
								foreach($Option in $ValidOptions)
								{
									if($Option -gt 0)
									{
										$SelectedIndexes += $Option
									}
								}
							}
							else
							{
								$SelectedIndexes = @($CurrentSelection)
							}
						}
					}
					else
					{
						throw('No index was selected for "{0}" or the index is invalid' -f $Path)
					}
				}
				else
				{
					$SelectedIndexes += $Index
				}
			}
			else
			{
				$SelectedIndexes += 1
			}
			$SelectedIndexes | foreach {
				$ImageList += @{'Path' = $Path; 'Index' = $_ }
			}
		}
	}
	else
	{
		foreach($SpecifiedImage in $Images)
		{
			try
			{
				$Index = 1
				if($SpecifiedImage.Path -imatch 'wim$')
				{
					$Index = $SpecifiedImage.Index
				}
				$WindowsImage = Get-WindowsImage -ImagePath $SpecifiedImage.Path -Index $Index -ErrorAction Stop
				$ImageList += @{'Path' = $SpecifiedImage.Path; 'Index' = $Index}
			}
			catch
			{
				Write-Warning -Message ('Invalid file({0}) or index ({1}) specified. This entry will be ignored.' -f $SpecifiedImage.Path, $SpecifiedImage.Index)
			}
		}
	}

	Write-Progress -Activity 'Validating environment' -Status 'Verifying WSUS server' -PercentComplete 50
	$GetWsusServerParameters = @{}
	if(-not [String]::IsNullOrEmpty($WsusServerName))
	{
		$GetWsusServerParameters.Add('Name', $WsusServerName)
		$GetWsusServerParameters.Add('PortNumber', $WsusServerPort)
		$GetWsusServerParameters.Add('UseSsl', $WsusUsesSSL)
	}
	try
	{
		$WsusServer = Get-WsusServer @GetWsusServerParameters -ErrorAction Stop
	}
	catch
	{
		throw("Unable to contact the specified WSUS host`r`n$($_.Message)")
	}

	Write-Progress -Activity 'Validating environment' -Status 'Verifying WSUS content folder' -PercentComplete 75
	try
	{
		if(-not (Get-ChildItem -Path $WsusContentFolder -Directory -ErrorAction Stop | sort | foreach { if($_.Name -match '^[A-Z0-9]{2}$') { $true } } ))
		{
			throw('Folder exists but does not contain any of the expected content sub-folders.')
		}
	}
	catch
	{
		throw("Specified WSUS content folder cannot be reached or does not contain expected content files")
	}

	Write-Progress -Activity 'Validating environment' -Status 'Verifying offline mount folder' -PercentComplete 99
	if(Test-Path -Path $OfflineMountFolder)
	{
		if(Get-ChildItem -Path $OfflineMountFolder)
		{
			throw("$OfflineMountFolder is not empty.")
		}
	}
	else
	{
		try
		{
			New-Item -Path $OfflineMountFolder -ItemType Directory -ErrorAction Stop	
		}
		catch
		{
			throw("Unable to locate or create $OfflineMountFolder")
		}
	}
	Write-Progress -Activity 'Validating environment' -Completed

	Write-Progress -Activity 'Loading updates' -Status 'Scanning for applicable updates' -PercentComplete -1
	$WSUSUpdates = Get-WsusUpdate -UpdateServer $WsusServer -Approval Approved |
		where { -not $_.Update.IsSuperseded -and ($IgnoreDeclinedStatus -or -not $_.Update.IsDeclined) -and (Compare-Object -DifferenceObject $_.Products -ReferenceObject $TargetProduct -ExcludeDifferent -IncludeEqual) -and $_.Update.ArrivalDate.ToLocalTime().AddDays($MinimumPatchAgeInDays) -le [datetime]::Now }


	$UpdateFiles = @()
	$CurrentFile = 0
	foreach ($WSUSUpdate in $WSUSUpdates)
	{
		$CurrentFile += 1
		$CurrentFilePercent = 100 - ((($WSUSUpdates.Count - $CurrentFile) / $WSUSUpdates.Count) * 100)
		Write-Progress -Activity 'Loading updates' -Status 'Finding downloaded files for selected updates' -CurrentOperation "Checking $($WSUSUpdate.Update.Title)" -PercentComplete $CurrentFilePercent
		$WSUSUpdate.Update.GetInstallableItems().Files | foreach {
			if ($_.Type -eq [Microsoft.UpdateServices.Administration.FileType]::SelfContained -and ($_.FileUri -match '.[cab|msu]$'))
			{
				$LocalFileName = ($_.FileUri -replace '.*/Content', $WsusContentFolder) -replace '/', '\'

                if(!(Test-Path -Path $LocalFileName)){
                    (New-Object System.Net.WebClient).DownloadFile($_.OriginUri, $LocalFileName )
                }

				if(Test-Path -Path $LocalFileName)
				{
					$UpdateFiles += @{'Path' = $LocalFileName; 'Title' = $WSUSUpdate.Update.Title }
				}
			}
		}
	}

	if($UpdateFiles.Count -gt 0)
	{
	    Write-Progress -Activity 'Loading updates' -Completed

	    foreach ($ImageToUpdate in $ImageList)
	    {
		    $TargetRoot = Split-Path -Path $ImageToUpdate.Path
		    $TargetFileName = Split-Path -Path $ImageToUpdate.Path -Leaf
		    $LogFile = Join-Path -Path $TargetRoot -ChildPath "$TargetFileName.wulog.txt"
		    $CurrentImageLog = @()
		    if(Test-Path -Path $LogFile)
		    {
			    $PermanentLog = Get-Content -Path $LogFile
		    }
		    try
		    {
			    $Test = $PermanentLog.Count
		    }
		    catch
		    {
			    $PermanentLog = @()
		    }

		    $PermanentLog += ('------- Patch Cycle Initiated {0} -------' -f (Get-Date))
		    try
		    {
			    # the Mount-WindowsImage cmdlet has its own progress display
			    $OutNull = Mount-WindowsImage -ImagePath $ImageToUpdate.Path -Index $ImageToUpdate.Index -Path $OfflineMountFolder -ErrorAction Stop
		    }
		    catch
		    {
			    $CurrentMessage = "Could not mount $($ImageToUpdate.Path)`r`n$($_.Message)"
			    Write-Error -Message $CurrentMessage
			    $PermanentLog += $CurrentMessage
			    break
		    }
			try
			{
				$CurrentFile = 0
				foreach($UpdateFile in $UpdateFiles)
				{
					$CurrentFile += 1
					$CurrentFilePercent = 100 - ((($UpdateFiles.Count - $CurrentFile) / $UpdateFiles.Count) * 100)
					if(-not ("$($ImageToUpdate.Index):$($UpdateFile.Title)" -in $PermanentLog))
					{
						Write-Progress -Activity 'Updating image' -CurrentOperation "Applying $($UpdateFile.Title)" -Status "Applying images to $($ImageToUpdate.Path)" -PercentComplete $CurrentFilePercent
						try
						{
							$OutNull = Add-WindowsPackage -PackagePath $UpdateFile.Path -Path $OfflineMountFolder -ErrorAction Stop
							$CurrentImageLog += "$($ImageToUpdate.Index):$($UpdateFile.Title)`r`n"
						}
						catch
						{
							# Add-WindowsPackage will write a warning, we're just ensuring that we don't write an unsuccessful patch to the log
						}
					}
				}
				Write-Progress -Activity 'Updating image' -Completed
			}
			finally 
			{
				try
				{
					$OutNull = Dismount-WindowsImage -Path $OfflineMountFolder -Save -ErrorAction Stop
				}
				catch
				{
					$CurrentMessage = "Unable to save changes to $($ImageToUpdate.Path): $($_.Message)"
					Write-Error -Message $CurrentMessage
					$CurrentImageLog = @("$CurrentMessage`r`n") #note the re-assignment; the updates will not be logged because they never really happened
					$OutNull = Dismount-WindowsImage -Path $OfflineMountFolder -Discard
				}
			}

		    $PermanentLog = $PermanentLog | select -Unique
		    $PermanentLog += $CurrentImageLog
		    $PermanentLog += ('------- Patch Cycle Completed {0} -------' -f (Get-Date))
		    Set-Content -Path $LogFile -Value $PermanentLog 
	    }
    } else {
        Write-Progress -Activity 'No updates to apply' -Completed
    }
}															#uncomment this line to use this script dot-sourced or in a profile. Also the function definition lines at the beginning.

$OsName = '9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9'
$TargetPath = 'Windows Server 2012 R2'
$WsusContentFolder = 'E:\WSUS\WsusContent'
$WsusServerName = 'localhost'
$WsusServerPort = 8530

if ($ENV:WsusContentFolder){
	$WsusContentFolder = $ENV:WsusContentFolder
}

if ($ENV:WsusServerName){
	$WsusServerName = $ENV:WsusServerName
}

if ($ENV:WsusServerPort){
	$WsusServerPort = $ENV:WsusServerPort
}

$IsoPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("..\$OsName")
$OfflineMountFolder = $IsoPath + "_Slipstream"
$WimPath = join-path $IsoPath 'sources\install.wim'

$Images = @(
	@{'Path'=$WimPath; 'Index' = 1}
	@{'Path'=$WimPath; 'Index' = 2}
)

if (!(Test-Path $WsusContentFolder)) {
	for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
	{  
		$WsusContentFolder = [char]$c + ':\WSUS\WsusContent'

		if (test-path $WsusContentFolder) {
			break
		}
	}
}

Update-WindowsImage -Images $Images -TargetProduct $TargetPath -WsusContentFolder $WsusContentFolder -WsusServerName $WsusServerName -WsusServerPort $WsusServerPort -OfflineMountFolder $OfflineMountFolder