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
@"
****************************************
 BUILDLet PackageMaker Toolkit
 Sample Package Data Packaging Script
                        Version 2.0.1.0
 Copyright (C) 2015-2017 Daiki Sakamoto
****************************************
"@ | Write-Host -ForegroundColor Green


# Sample Package
$package_dir_name = 'SamplePackage'
$package_dir_path = Get-Location | Join-Path -ChildPath $package_dir_name

# Compress Sample Package(s)
@('Debug', 'Release') | % {

	$build_config = $_

	$dest_dir_path = $PSCommandPath | Split-Path -Parent `
		| Join-Path -ChildPath '..\bin' `
		| Join-Path -ChildPath $build_config

	# Create Target Directory (if NOT Exists)
	if (-not ($dest_dir_path | Test-Path)) { New-Item -Path $dest_dir_path -ItemType Directory -Force > $null }


	$dest_zip_filename = $package_dir_name + '.zip'
	$dest_zip_filepath = $dest_dir_path | Join-Path -ChildPath $dest_zip_filename

	# Compress Sample Package
	Compress-Archive -Path $package_dir_path -DestinationPath $dest_zip_filepath -Force

	"Compress '$package_dir_name' Sample Package -> '$dest_zip_filepath'." | Write-Host -ForegroundColor Yellow
}
