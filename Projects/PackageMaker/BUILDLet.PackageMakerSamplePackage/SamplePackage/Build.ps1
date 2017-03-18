<###############################################################################
 The MIT License (MIT)

 Copyright (c) 2015-2017 Daiki Sakamoto

 Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
################################################################################>


####################################################################################################
##  Parameters
####################################################################################################
Param(
    [Parameter()]
	[string]$SettingFile = (Get-Location | Get-ChildItem | ? { $_ -like '*.ini' } )[0].FullName,

    [Parameter()]
    [ValidateSet('Model1', 'Model2')]
	[ValidateScript({ throw New-Object -TypeName System.NotImplementedException })]
	[string]$Inf2Cat,

    [Parameter()]
    [ValidateSet('Model1', 'Model2')]
	[ValidateScript({ throw New-Object -TypeName System.NotImplementedException })]
	[string]$Sign,

    [Parameter()]
	[ValidateScript({ throw New-Object -TypeName System.NotImplementedException })]
	[switch]$Readme,

    [Parameter()]
	[ValidateScript({ throw New-Object -TypeName System.NotImplementedException })]
	[switch]$ISOImage,

    [Parameter()]
	[ValidateScript({ throw New-Object -TypeName System.NotImplementedException })]
	[switch]$ReleaseNotes
)

####################################################################################################
##  Script Version
####################################################################################################
$ScriptVersion = '2.0.1.0'

####################################################################################################
##  Functions
####################################################################################################
# Clean Directory
Function Run-CleanDirectoryOperation
{
	Param(
		[Parameter(Mandatory = $true, Position = 0)]
		[int]$Index,

		[Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
		[string]$Path
	)

	Process {

		$i = $Index.ToString('D2')

		# New-Directory & Output
		"[$i] Clean Directory: " + '"' + ($Path | New-Directory -Clean -Force -PassThru) + '"' | Write-Host -ForegroundColor Yellow
	}
}


# Create Directory, if NOT exists
Function Run-OverwriteDirectoryOperation
{
	Param(
		[Parameter(Mandatory = $true, Position = 0)]
		[int]$Index,

		[Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
		[string]$Path
	)

	Process {

		$i = $Index.ToString('D2')

		if ($Path | Test-Path) {
			"[$i] Already Exists: " + '"' + (Convert-Path -Path $Path) + '"' | Write-Host -ForegroundColor Red
		}
		else {
			"[$i] Create Directory: " + '"' + ($Path | New-Directory -Clean -Force -PassThru) + '"' | Write-Host -ForegroundColor Yellow
		}
	}
}


# Copy File OR Directory
Function Run-CopyItemOperation
{
	Param(
		[Parameter(Mandatory = $true, Position = 0)]
		[int]$Index,

		[Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
		[string]$Path,

		[Parameter(Mandatory = $true, Position = 2)]
		[string]$DestinationPath
	)

	Process {

		$i = $Index.ToString('D2')

		# Copy
		Copy-Item -Path $Path -Destination $DestinationPath -Recurse -Force

		# Output
		"[$i] Copy From: " + '"' + (Convert-Path -Path $Path) + '"' | Write-Host -ForegroundColor Yellow
		'            To: "' + (Convert-Path -Path $DestinationPath) + '"' | Write-Host -ForegroundColor Yellow
	}
}
	

# Move File OR Directory
Function Run-MoveItemOperation
{
	Param(
		[Parameter(Mandatory = $true, Position = 0)]
		[int]$Index,

		[Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
		[string]$Path,

		[Parameter(Mandatory = $true, Position = 2)]
		[string]$DestinationPath
	)

	Process {

		$i = $Index.ToString('D2')

		# If Exists, Append GUID
		if ($DestinationPath | Join-Path -ChildPath ($Path | Split-Path -Leaf) | Test-Path) {
			"[$i] Move: Destination is Changed into " + '"' + ($DestinationPath += (New-Guid).Guid) + '"' | Write-Host -ForegroundColor Red
		}

		# Move & Output
		"[$i] Move From: " + '"' + (Convert-Path -Path $Path) + '"' | Write-Host -ForegroundColor Yellow
		'            To: "' + (Move-Item -Path $Path -Destination $DestinationPath -Force -PassThru) + '"' | Write-Host -ForegroundColor Yellow
	}
}


# Expand (Unzip) ZIP File
Function Run-ExpandZipFileOperation
{
	Param(
		[Parameter(Mandatory = $true, Position = 0)]
		[int]$Index,

		[Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
		[string]$Path,

		[Parameter(Mandatory = $true, Position = 2)]
		[string]$DestinationPath
	)

	Process {

		$i = $Index.ToString('D2')

		# Expand-ZipFile & Output
		"[$i] Source ZIP File: " + '"' + (Convert-Path -Path $Path) + '"' | Write-Host -ForegroundColor Yellow
		'           Expand To: "' + (Expand-ZipFile -Path $Path -DestinationPath $DestinationPath -Force) + '"' | Write-Host -ForegroundColor Yellow
	}
}


# Update Readme File(s)
Function Run-UpdateReadmeOperation
{
	Param(
		[Parameter(Mandatory = $true)]
		[int]$Index
	)

	Begin {

		# Get LICDs (from INI File)
		$lcids = @()
		Get-PrivateProfileString -InputObject $Settings -Section 'Readme' | ? { $_.Key -like 'LCID/*' } | % { $lcids += $_ }
	}

	Process {

		$i = $Index.ToString('D2')

		Get-PrivateProfileString -InputObject $Settings -Section 'Readme' -Key 'Path' | Convert-Path | % {

			$filepath = $_
			$lang = $_ | Split-Path -Parent | Split-Path -Leaf
			$lcid = [string]::Empty
			$lcids | % {
				if ($_.Key.Split('/')[1] -eq $lang) { $lcid = $_.Value }
			}
			if ([string]::IsNullOrEmpty($lcid)) { throw }

			# Data
			$date_mark = (Get-PrivateProfileString -InputObject $Settings -Section 'Readme' -Key 'Date').Split(',')[0]
			$date = New-DateString -LCID $lcid
			"[$i] Readme ($lang): Date = '$date_mark' -> '$date'" | Write-Host -ForegroundColor Yellow

			# Copyright Update Year
			$copyright_year_mark = (Get-PrivateProfileString -InputObject $Settings -Section 'Readme' -Key 'CopyrightYear').Split(',')[0]
			$copyright_year = (Get-PrivateProfileString -InputObject $Settings -Section 'Readme' -Key 'CopyrightYear').Split(',')[1]
			"[$i] Readme ($lang): Copyright Year = '$copyright_year_mark' -> '$copyright_year'" | Write-Host -ForegroundColor Yellow

			# Project Version
			$project_ver_mark = (Get-PrivateProfileString -InputObject $Settings -Section 'Readme' -Key 'ProjectVer').Split(',')[0]
			$project_ver = (Get-PrivateProfileString -InputObject $Settings -Section 'Readme' -Key 'ProjectVer').Split(',')[1]
			"[$i] Readme ($lang): Project Version = '$project_ver_mark' -> '$project_ver'" | Write-Host -ForegroundColor Yellow

			# Driver Version (x86 & x64)
			@('x86', 'x64') | % {
				$driver_ver_mark = (Get-PrivateProfileString -InputObject $Settings -Section 'Readme' -Key "DriverVer/$_").Split(',')[0]
				$driver_ver_inf = Get-PrivateProfileString `
					-Path ($inf_filepath = (Get-PrivateProfileString -InputObject $Settings -Section 'Readme' -Key "DriverVer/$_").Split(',')[1]) `
					-Section (Get-PrivateProfileString -InputObject $Settings -Section 'Readme' -Key "DriverVer/$_").Split(',')[2] `
					-Key (Get-PrivateProfileString -InputObject $Settings -Section 'Readme' -Key "DriverVer/$_").Split(',')[3]
				$driver_ver = $driver_ver_inf.Split(',')[[int]::Parse((Get-PrivateProfileString -InputObject $Settings -Section 'Readme' -Key "DriverVer/$_").Split(',')[4])]

				$inf_filename = $inf_filepath | Split-Path -Leaf
				"[$i] Readme ($lang): Driver Version ($_) = '$driver_ver_mark' -> '$driver_ver' ('DriverVer' ($_) in '$inf_filename' = '$driver_ver_inf')" | Write-Host -ForegroundColor Yellow

				switch ($_) {
					'x86' {
						$driver_ver_x86_mark = $driver_ver_mark
						$driver_ver_x86 = $driver_ver
					}

					'x64' {
						$driver_ver_x64_mark = $driver_ver_mark
						$driver_ver_x64 = $driver_ver
					}
				}
			}

			# Overwrite Readme File
			$updated_content = (Get-Content -Path $filepath -Encoding UTF8) `
				-replace $date_mark, $date `
				-replace $copyright_year_mark, $copyright_year `
				-replace $project_ver_mark, $project_ver `
				-replace $driver_ver_x86_mark, $driver_ver_x86 `
				-replace $driver_ver_x64_mark, $driver_ver_x64
			$updated_content | Out-File -FilePath $filepath -Encoding utf8
			"[$i] Readme ($lang): Update " + '"' + $filepath + '"' | Write-Host -ForegroundColor Yellow
		}
	}
}


# Run 'Inf2Cat.exe'
Function Run-InvokeInf2CatOperation
{
	Param(
		[Parameter(Mandatory = $true)]
		[int]$Index
	)

	Process {

		$i = $Index.ToString('D2')
		$current = 0

		@('x86', 'x64') | % {

			# 'x86' or 'x64'
			$arch = $_

			# Windows Version List
			$windows_ver_list = Get-PrivateProfileString -InputObject $Settings -Section 'Inf2Cat' -Key "WindowsVersionList/$arch"
			"[$i] Inf2Cat: WindowsVersionList ($arch) = '$windows_ver_list'" | Write-Host -ForegroundColor Yellow

			(Get-PrivateProfileString -InputObject $Settings -Section 'Inf2Cat' -Key "PackagePath/$arch").Split(',') | % {
				$_ | Convert-Path | % {

					$package_path = $_
					"[$i] Inf2Cat: PackagePath = '$package_path'" | Write-Host -ForegroundColor Yellow

					# Invoke 'Inf2Cat.exe'
					$result = New-CatalogFile -PackagePath $package_path -WindowsVersionList $windows_ver_list

					# Count Increment
					$current++

					# Write Result
					if ($result -eq 0) { "[$i] Inf2Cat ($current): Success! ('$windows_ver_list')" | Write-Host -ForegroundColor Green }
					else { "[$i] Inf2Cat ($current): Fail! ('$windows_ver_list')" | Write-Error }
				}
			}
		}
	}
}


# Run 'SignTool.exe'
Function Run-InvokeSignToolOperation
{
	Param(
		[Parameter(Mandatory = $true)]
		[int]$Index
	)

	Process {

		$i = $Index.ToString('D2')
		$current = 0

		# Retry Count, Retry Interval and Pack
		$retry_count = Get-PrivateProfileString -InputObject $Settings -Section 'SignTool' -Key "RetryCount"
		$retry_interval = Get-PrivateProfileString -InputObject $Settings -Section 'SignTool' -Key "RetryInterval"
		$pack = Get-PrivateProfileString -InputObject $Settings -Section 'SignTool' -Key "Pack"
		"[$i] SignTool: Retry Count = $retry_count" | Write-Host -ForegroundColor Yellow
		"[$i] SignTool: Retry Interval = $retry_interval" | Write-Host -ForegroundColor Yellow
		"[$i] SignTool: Pack = $pack" | Write-Host -ForegroundColor Yellow

		@('Model1', 'Model2') | % {

			# 'Model1' or 'Model2'
			$model = $_
			
			# Options
			$options = @(
				'/f "' + (Get-PrivateProfileString -InputObject $Settings -Section 'SignTool' -Key "PFX") + '"',
				'/t ' + (Get-PrivateProfileString -InputObject $Settings -Section 'SignTool' -Key "TimeStampServerURL"),
				'/v'
			)

			# FilePath
			$filepath = (Get-PrivateProfileString -InputObject $Settings -Section 'SignTool' -Key "FilePath/$model").Split(',') | % { $_ | Convert-Path }
			"[$i] SignTool: FilePath" | Write-Host -ForegroundColor Yellow
			$filepath | % { '     "' + $_ + '"' | Write-Host -ForegroundColor Yellow }

			# Invoke 'SignTool.exe'
			Invoke-SignTool -Command sign -Options $options -FilePath $filepath -RetryCount $retry_count -RetryInterval $retry_interval -Pack $pack | % {

				# Count Increment
				$current++

				# Write Result
				if ($_ -eq 0) { "[$i] SignTool ($current): Success!" | Write-Host -ForegroundColor Green }
				else { "[$i] SignTool ($current): Fail!" | Write-Error }
			}
		}
	}
}


# Run 'genisomage.exe' (Cygwin)
Function Run-InvokeGenISOImageOperation
{
	Param(
		[Parameter(Mandatory = $true)]
		[int]$Index
	)

	Process {

		$i = $Index.ToString('D2')


		$papthspec = Get-PrivateProfileString -InputObject $Settings -Section 'GenISOImage' -Key 'Path'
		$destination_dir = Get-PrivateProfileString -InputObject $Settings -Section 'GenISOImage' -Key 'DestinationPath'
		$filename = Get-PrivateProfileString -InputObject $Settings -Section 'GenISOImage' -Key 'FileName'
		"[$i] GenISOImage: " + '"' + $papthspec + '" -> "' + ($destination_dir | Join-Path -ChildPath $filename) + '"' | Write-Host -ForegroundColor Yellow

		# Update ISO File Name (if already exists)
		if ($destination_dir | Join-Path -ChildPath $filename | Test-Path) {
			$filename = (New-Guid).Guid + '.iso'
			"[$i] GenISOImage: File Name is Changed into '$filename'." | Write-Host -ForegroundColor Red
		}

		# Options
		$options_ini_section = Get-PrivateProfileString -InputObject $Settings -Section 'GenISOImage/Options'
		$options = @()
		for ($j = 0; $j -lt $options_ini_section.Count; $j++) {
			$options_ini_section | ? { [int]::Parse($_.Key) -eq ($j + 1) } | % { $options += $_.Value }
		}


		# Invoke 'genisomage.exe'
		$result = New-ISOImageFile -Path $papthspec -DestinationPath $destination_dir -FileName $filename -Options $options -Force

		# Write Result
		if ($result -eq 0) { "[$i] GenISOImage: '$filename' is Successfully Created!" | Write-Host -ForegroundColor Green }
		else { "[$i] GenISOImage : Failed to Create '$filename'!" | Write-Error }
	}
}

####################################################################################################
##  Required Modules
####################################################################################################
$RequiredModules = @(
    'BUILDLet.Utilities.PowerShell'
    'BUILDLet.PackageMaker.PowerShell'
)

####################################################################################################
##  Preferences
####################################################################################################
# ErrorActionPreference
$Global:ErrorActionPreference = 'Stop'

####################################################################################################
##  Process
####################################################################################################
@"
****************************************
 BUILDLet PackageMaker Toolkit
 Sample Package Build Script
                        Version $ScriptVersion
 Copyright (C) 2015-2017 Daiki Sakamoto
****************************************
"@ | Write-Host -ForegroundColor Green

# START TIME
"START: " + ($StartTime = Get-Date).ToString('yyyy/MM/dd hh:mm:ss') | Write-Host -ForegroundColor Yellow


# Import Required Module(s)
$RequiredModules | % {
	if ((Get-Module -Name $_) -eq $null) { Import-Module -Name $_ }
}


# Get Updated (String Token Replaced) INI File Content
$Settings = @()
Get-Content -Path $SettingFile | % {
	$line = $_
	Get-PrivateProfileString -Path $SettingFile -Section 'Strings' | % { $line = $line -replace ('%' + $_.Key + '%'), $_.Value }
	$Settings += $line
}

# Get 'Operation' Section in INI File
$operations = Get-PrivateProfileString -InputObject $Settings -Section 'Operation'

# Get Count of 'Operation'
$count = 0
$operations | % {
	if ([int]::Parse($_.Key) -gt $count) { $count = [int]::Parse($_.Key) }
}

# For Each 'Operation'
for ($i = 0; $i -lt $count; $i++) {
	$operations | % {
		$key = $_.Key
		$value = $_.Value
		$index = $i + 1
		if ([int]::Parse($key) -eq $index) {

			switch ($value.Split(',')[0]) {
	
				# Clean Directory
				'Clean' { Run-CleanDirectoryOperation -Index $index -Path $value.Split(',')[1] }
	
				# Create Directory, if NOT exists
				'Overwrite' { Run-OverwriteDirectoryOperation -Index $index -Path $value.Split(',')[1] }
	
				# Copy File OR Directory
				'Copy' { Run-CopyItemOperation -Index $index -Path $value.Split(',')[1] -DestinationPath $value.Split(',')[2] }
	
				# Move File OR Directory
				'Move' { Run-MoveItemOperation -Index $index -Path $value.Split(',')[1] -DestinationPath $value.Split(',')[2] }
	
				# Expand (Unzip) ZIP File
				'Expand' { Run-ExpandZipFileOperation -Index $index -Path $value.Split(',')[1] -DestinationPath $value.Split(',')[2] }
				
				# Update Readme File(s)
				'Readme' { Run-UpdateReadmeOperation -Index $index }

				# Run 'Inf2Cat.exe'
				'Inf2Cat' { Run-InvokeInf2CatOperation -Index $index }

				# Run 'SignTool.exe'
				'SignTool' { Run-InvokeSignToolOperation -Index $index }
				
				# Run 'genisomage.exe' (Cygwin)
				'GenISOImage' { Run-InvokeGenISOImageOperation -Index $index }

				# Default
				default { throw (New-Object -TypeName System.Management.Automation.PSNotSupportedException) }
			}
		}
	}
}

# END TIME
"END: " + ($EndTime = Get-Date).ToString('yyyy/MM/dd hh:mm:ss') + " (Elapsed Time: " + ($EndTime - $StartTime) + ")" | Write-Host -ForegroundColor Yellow
