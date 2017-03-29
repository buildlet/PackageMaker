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
	[ValidateSet('Readme', 'Inf2Cat', 'SignTool', 'GenISOImage', 'ReleaseNotes')]
	[string]$SingleOperation
)

####################################################################################################
##  Script Version
####################################################################################################
$ScriptVersion = '2.1.0.0'

####################################################################################################
##  Functions
####################################################################################################
# Clean Directory
Function Run-CleanDirectoryOperation
{
	Param(
		[Parameter(Position = 0)]
		[int]$Index = 0,

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
		[Parameter(Position = 0)]
		[int]$Index = 0,

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
		[Parameter(Position = 0)]
		[int]$Index = 0,

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
		[Parameter(Position = 0)]
		[int]$Index = 0,

		[Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
		[string]$Path,

		[Parameter(Mandatory = $true, Position = 2)]
		[string]$DestinationPath
	)

	Process {

		$i = $Index.ToString('D2')


		# Already Existence Check
		if (($Global:TempID -ne $null) `
			-or ($DestinationPath | Test-Path -PathType Leaf) `
			-or ($DestinationPath | Join-Path -ChildPath ($Path | Split-Path -Leaf) | Test-Path)) {

			# Publish TempID
			if ($Global:TempID -eq $null) { $Global:TempID = (New-Guid).Guid }

			# Check Destination is Directory / File
			if ($DestinationPath | Test-Path -PathType Container) {

				# Update Destination (Directory)
				$target_name = $Path | Split-Path -Leaf
				$target_name = [System.IO.Path]::GetFileNameWithoutExtension($target_name) + ".$Global:TempID" + [System.IO.Path]::GetExtension($target_name)
				$DestinationPath = $DestinationPath | Join-Path -ChildPath $target_name
			}
			else {

				# Update Destination (File)
				$target_name = $DestinationPath | Split-Path -Leaf
				$target_name = [System.IO.Path]::GetFileNameWithoutExtension($target_name) + ".$Global:TempID" + [System.IO.Path]::GetExtension($target_name)
				$DestinationPath = $DestinationPath | Split-Path -Parent | Join-Path -ChildPath $target_name
			}

			"[$i] Move: Destination is Changed into " + '"' + $DestinationPath + '"' | Write-Host -ForegroundColor Red
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
		[Parameter(Position = 0)]
		[int]$Index = 0,

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
		[Parameter()]
		[int]$Index = 0
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
		[Parameter()]
		[int]$Index = 0
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
		[Parameter()]
		[int]$Index = 0
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
		[Parameter()]
		[int]$Index = 0
	)

	Process {

		$i = $Index.ToString('D2')


		$papthspec = Get-PrivateProfileString -InputObject $Settings -Section 'GenISOImage' -Key 'SourceDirPath'
		$destination_dir = Get-PrivateProfileString -InputObject $Settings -Section 'GenISOImage' -Key 'DestinationDirPath'
		$filename = Get-PrivateProfileString -InputObject $Settings -Section 'GenISOImage' -Key 'FileName'
		"[$i] GenISOImage: " + '"' + $papthspec + '" -> "' + ($destination_dir | Join-Path -ChildPath $filename) + '"' | Write-Host -ForegroundColor Yellow


		# Check Already Existence of Output ISO File Name
		if (($Global:TempID -ne $null) -or ($destination_dir | Join-Path -ChildPath $filename | Test-Path)) {

			# Publish TempID
			if ($Global:TempID -eq $null) { $Global:TempID = (New-Guid).Guid }

			# Update Output ISO File Name
			$filename = [System.IO.Path]::GetFileNameWithoutExtension($filename) + ".$Global:TempID" + [System.IO.Path]::GetExtension($filename)
			"[$i] GenISOImage: Output File Name is Changed into '$filename'." | Write-Host -ForegroundColor Red
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


# Create Release Notes
Function Run-CreateReleaseNotesOperation
{
	Param(
		[Parameter()]
		[int]$Index = 0
	)

	Process {

		$i = $Index.ToString('D2')


		# Source & Destination File
		$src_filepath = Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'SourceFilePath'
		$dest_filepath = Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DestinationFilePath'
		$dest_filename = $dest_filepath | Split-Path -Leaf

		# Date
		$date_mark = Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'Data'

		# Project Information
		$project_name_mark = (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'ProjectName').Split(',')[0]
		$project_name = (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'ProjectName').Split(',')[1]
		$project_ver_mark = (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'ProjectVer').Split(',')[0]
		$project_ver = (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'ProjectVer').Split(',')[1]


		# Model(s)
		$model_html_content_base = Get-ContentBlock `
			-Path $src_filepath `
			-StartPattern (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'ModelBlock').Split(',')[0] `
			-EndPattern (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'ModelBlock').Split(',')[1] `
            -Encoding UTF8
        $model_html_content_base = $model_html_content_base -join "`r`n"
		$model_root_dirs = Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'ModelDirPath' | Convert-Path
		$model_name_mark = Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'ModelName'


		# Language(s)
		$lang_html_content_base = Get-ContentBlock `
			-Path $src_filepath `
			-StartPattern (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'LanguageBlock').Split(',')[0] `
			-EndPattern (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'LanguageBlock').Split(',')[1] `
            -Encoding UTF8
        $lang_html_content_base = $lang_html_content_base -join "`r`n"
		$lang_root_dirs = Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'LanguageDirPath' | Convert-Path
		$lang_name_mark = Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'LanguageName'


		# Driver(s)
		$driver_html_content_base = Get-ContentBlock `
			-Path $src_filepath `
			-StartPattern (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverBlock').Split(',')[0] `
			-EndPattern (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverBlock').Split(',')[1] `
            -Encoding UTF8
        $driver_html_content_base = $driver_html_content_base -join "`r`n"
		$driver_root_dirs = Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverDirPath' | Convert-Path
		$driver_name_mark = Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverName'

		# x86 / x64 (Driver Architecture)
		$driver_arch_html_content_base = Get-ContentBlock `
			-Path $src_filepath `
			-StartPattern (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverArchBlock').Split(',')[0] `
			-EndPattern (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverArchBlock').Split(',')[1] `
            -ExcludeStartLine `
            -ExcludeEndLine `
            -Encoding UTF8
        $driver_arch_html_content_base = $driver_arch_html_content_base -join "`r`n"
		$driver_arch_root_dirs = Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverArchDirPath' | Convert-Path
		$driver_arch_name_mark = Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverArchName'

		# Driver Date (INF)
		$driver_date_mark = (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverDate').Split(',')[0]
		$driver_date_inf_file = (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverDate').Split(',')[1]
		$driver_date_inf_section = (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverDate').Split(',')[2]
		$driver_date_inf_key = (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverDate').Split(',')[3]
		$driver_date_inf_value_index = (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverDate').Split(',')[4]

		# Driver Version (INF)
		$driver_ver_mark = (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverVer').Split(',')[0]
		$driver_ver_inf_file = (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverVer').Split(',')[1]
		$driver_ver_inf_section = (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverVer').Split(',')[2]
		$driver_ver_inf_key = (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverVer').Split(',')[3]
		$driver_ver_inf_value_index = (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverVer').Split(',')[4]

		# Driver Authenticode Signer Name (CAT)
		$driver_signer_name_mark = (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverSignerName').Split(',')[0]
		$driver_signer_name_file = (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverSignerName').Split(',')[1]

		# Driver Authenticode Signature Timestamp (CAT)
		$driver_sign_timestamp_mark = (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverSignatureTimeStamp').Split(',')[0]
		$driver_sign_timestamp_file = (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'DriverSignatureTimeStamp').Split(',')[1]


		# Restriction(s)
		$restrictions_mark = (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'Restrictions').Split(',')[0]
		$restrictions_content = Get-Content `
			-Path (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key 'Restrictions').Split(',')[1] `
			-Encoding UTF8 `
            -Raw


		# Update HTML Content
		# for Model(s)
		$model_html_content_updated = [string]::Empty
		$model_root_dirs | % {

			# Get Current Path & Directory of Current Model
			$current_model_dir_path = $current_path = $_
			$current_model_dir_name = $current_model_dir_path | Split-Path -Leaf


			# for Driver(s)
			$driver_html_content_updated = [string]::Empty
			$driver_root_dirs | ? { $_.Contains($current_model_dir_path) } | % {

				# Update Current Path & Get Directory of Current Driver
				$current_driver_dir_path = $current_path = $_
				$current_driver_dir_name = $current_driver_dir_path | Split-Path -Leaf


				# for Language(s)
				$lang_html_content_updated = [string]::Empty
				$lang_root_dirs | ? { $_.Contains($current_driver_dir_path) } | % {

					# Update Current Path & Get Directory of Current Language
					$current_lang_dir_path = $current_path = $_
					$current_lang_dir_name = $current_lang_dir_path | Split-Path -Leaf


					# for Architecture (x86 / x64)
					$driver_arch_html_content_updated = [string]::Empty
					$driver_arch_root_dirs | ? { $_.Contains($current_lang_dir_path) } | % {

						# Update Current Path & Get Directory of Current Architecture (x86 / x64)
						$current_driver_arch_dir_path = $current_path = $_
						$current_driver_arch_dir_name = $current_driver_arch_dir_path | Split-Path -Leaf


						# Driver Date (INF)
						$driver_date = (Get-PrivateProfileString `
							-Path ($current_path | Join-Path -ChildPath $driver_date_inf_file | Resolve-Path)[0].Path `
							-Section $driver_date_inf_section `
							-Key $driver_date_inf_key).Split(',')[$driver_date_inf_value_index]

						# Driver Version (INF)
						$driver_ver = (Get-PrivateProfileString `
							-Path ($current_path | Join-Path -ChildPath $driver_ver_inf_file | Resolve-Path)[0].Path `
							-Section $driver_ver_inf_section `
							-Key $driver_ver_inf_key).Split(',')[$driver_ver_inf_value_index]

						# Authenticode Signer Name (CAT)
						$driver_signer_name = Get-AuthenticodeSignerName -FilePath ($current_path | Join-Path -ChildPath $driver_signer_name_file | Resolve-Path)[0].Path

						# Authenticode Signature Timestamp (CAT)
						$driver_sign_timestamp = Get-AuthenticodeTimeStampString -FilePath ($current_path | Join-Path -ChildPath $driver_sign_timestamp_file | Resolve-Path)[0].Path


                        # Adjust CRLF
                        if (-not [string]::IsNullOrEmpty($driver_arch_html_content_updated)) { $driver_arch_html_content_updated += "`r`n" }

						# Update Driver Version (INF & CAT) HTML Content
						$driver_arch_html_content_updated += $driver_arch_html_content_base `
							-replace $driver_name_mark, (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key "DriverName/$current_driver_dir_name") `
							-replace $driver_arch_name_mark, (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key "DriverArchName/$current_driver_arch_dir_name") `
							-replace $driver_date_mark, $driver_date `
							-replace $driver_ver_mark, $driver_ver `
							-replace $driver_signer_name_mark, $driver_signer_name `
							-replace $driver_sign_timestamp_mark, $driver_sign_timestamp
					}

                    # Adjust CRLF
                    if (-not [string]::IsNullOrEmpty($lang_html_content_updated)) { $lang_html_content_updated += "`r`n" }

					# Append & Update Language HTML Content
					$lang_html_content_updated += $lang_html_content_base.Replace($driver_arch_html_content_base, $driver_arch_html_content_updated) `
						-replace $lang_name_mark, (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key "LanguageName/$current_lang_dir_name")
				}

                # Adjust CRLF
                if (-not [string]::IsNullOrEmpty($driver_html_content_updated)) { $driver_html_content_updated += "`r`n" }

				# Append & Update Driver HTML Content
				$driver_html_content_updated += $driver_html_content_base.Replace($lang_html_content_base, $lang_html_content_updated) `
					-replace $driver_name_mark, (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key "DriverName/$current_driver_dir_name")
			}

            # Adjust CRLF
            if (-not [string]::IsNullOrEmpty($model_html_content_updated)) { $model_html_content_updated += "`r`n" }

			# Append & Update Model HTML Content
			$model_html_content_updated += $model_html_content_base.Replace($driver_html_content_base, $driver_html_content_updated) `
				-replace $model_name_mark, (Get-PrivateProfileString -InputObject $Settings -Section 'ReleaseNotes' -Key "ModelName/$current_model_dir_name")
		}

		# Updated HTML Content
		$html_content_updated = (Get-Content -Path $src_filepath -Encoding UTF8 -Raw).Replace($model_html_content_base, $model_html_content_updated) `
			-replace $date_mark, (New-DateString -LCID 'en-US') `
			-replace $project_name_mark, $project_name `
			-replace $project_ver_mark, $project_ver `
			-replace $restrictions_mark, $restrictions_content


		# Check Output HTML File
		if (($Global:TempID -ne $null) -or ($dest_filepath | Test-Path)) {

			# Publish TempID
			if ($Global:TempID -eq $null) { $Global:TempID = (New-Guid).Guid }

			$dest_filename = [System.IO.Path]::GetFileNameWithoutExtension($dest_filename) + ".$Global:TempID" + [System.IO.Path]::GetExtension($dest_filename)
			$dest_filepath = $dest_filepath | Split-Path -Parent | Join-Path -ChildPath $dest_filename
			"[$i] Release Notes: Output File Name is Changed into '$dest_filename'." | Write-Host -ForegroundColor Red
		}


		# Write HTML Content to File
        $html_content_updated | Out-File $dest_filepath -Encoding utf8

		# Write Result
		if ($dest_filepath | Test-Path) { "[$i] Release Notes: '$dest_filename' is Successfully Created!" | Write-Host -ForegroundColor Green }
		else { "[$i] Release Notes: Failed to Create '$dest_filename'!" | Write-Error }
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
##  Variable(s)
####################################################################################################
#
$Global:TempID = $null

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


# Build Script Parameter Support
switch ($SingleOperation) {

	# Update Readme File(s)
	'Readme' { Run-UpdateReadmeOperation }

	# Run 'Inf2Cat.exe'
	'Inf2Cat' { Run-InvokeInf2CatOperation }

	# Run 'SignTool.exe'
	'SignTool' { Run-InvokeSignToolOperation }
				
	# Run 'genisomage.exe' (Cygwin)
	'GenISOImage' { Run-InvokeGenISOImageOperation }
				
	# Create Release Notes
	'ReleaseNotes' { Run-CreateReleaseNotesOperation }

	default {

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
				
						# Create Release Notes
						'ReleaseNotes' { Run-CreateReleaseNotesOperation -Index $index }

						# Default
						default { throw (New-Object -TypeName System.Management.Automation.PSNotSupportedException) }
					}
				}
			}
		}
	}
}

# END TIME
"END: " + ($EndTime = Get-Date).ToString('yyyy/MM/dd hh:mm:ss') + " (Elapsed Time: " + ($EndTime - $StartTime) + ")" | Write-Host -ForegroundColor Yellow
