<###############################################################################
 The MIT License (MIT)

 Copyright (c) 2017 Daiki Sakamoto

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

#
# This is a PowerShell Unit Test file.
# You need a unit test framework such as Pester to run PowerShell Unit tests. 
# You can download Pester from http://go.microsoft.com/fwlink/?LinkID=534084
#

# Deploy Target Module
. ($PSCommandPath | Split-Path -Parent | Join-Path -ChildPath '..\BUILDLet.PackageMaker.PowerShellModule' | Join-Path -ChildPath 'Deploy.ps1') > $null

# Initialize
. ($PSCommandPath | Split-Path -Parent | Join-Path -ChildPath 'Initialize.ps1') > $null


# TestData Directory
$Script:dirpath_TestData = '..\..\..\TestData'

# Sample Package
$Script:sample_package_name = 'package'
$Script:sample_package_src = $Script:dirpath_TestData | Join-Path -ChildPath $Script:sample_package_name | Convert-Path


Describe "New-CatalogFile" {

	# Default Test (Sign to Sample Package)
	for ($i = 0; $i -lt 2; $i++) {

		# Set Parameter(s)
		switch ($i) {

			# x86
			0 {
				$arch = 'x86'
				$package_dir_name = 'driver_x86'
				$windows_version_list = 'Vista_X86,7_X86,8_X86,6_3_X86,10_X86,Server2008_X86'
				$catalog_filename = 'Dummy.cat'
			}

			# x64
			1 {
				$arch = 'x64'
				$package_dir_name = 'driver_x64'
				$windows_version_list = 'Vista_X64,7_X64,8_X64,6_3_X64,10_X64,Server2008_X64,Server2008R2_X64,Server8_X64,Server6_3_X64,Server10_X64'
				$catalog_filename = 'Dummy.cat'
			}
		}

		
		Context "Catalog File for Sample Package '$catalog_filename' for Driver Package '$package_dir_name' ($arch)" {

			$package_dir_path = Get-Location | Join-Path -ChildPath $package_dir_name

			# Clean Target Directory
			if ($package_dir_path | Test-Path) { $package_dir_path | Get-ChildItem | Remove-Item -Recurse -Force }
			else { New-Item -Path $package_dir_path -ItemType Directory -Force }

			# Copy Sample Package
			$Script:sample_package_src | Get-ChildItem | Copy-Item -Destination $package_dir_path -Force


			It "Is successfully created." {

				# 'New-CatalogFile'
				New-CatalogFile $package_dir_path -WindowsVersionList $windows_version_list | Should Be 0

				# Check Catalog File Existence
				$package_dir_path | Join-Path -ChildPath 'Dummy.cat' | Test-Path -PathType Leaf | Should Be $true
			}
		}
	}
}
