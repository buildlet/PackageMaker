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

# Test Target Directory
$Script:root_dir_name = 'RootDirectory'
$Script:root_dir_path = $Script:dirpath_TestData | Join-Path -ChildPath $Script:root_dir_name


Describe "New-ISOImageFile" {

	# Default Test
	Context "ISO Image File (Default)" {

		$target_dir_name = $Script:root_dir_name
		It "Is Created from '$target_dir_name' Directory." {
		
			# Parameter of 'New-ISOImageFile'
			$papthspec = $Script:root_dir_path
			$options = @(
				'-input-charset utf-8'
				'-output-charset utf-8'
				'-rational-rock'
				'-joliet'
				'-joliet-long'
				'-jcharset utf-8'
				'-pad')
			$options += '-volid ISO-TEST'

			# Expected
			$expected_codde = 0
			$expected_filepath = Get-Location | Join-Path -ChildPath ($target_dir_name + ".iso")


			# 'New-ISOImageFile'
			$actual_code = New-ISOImageFile -Path $papthspec -Options $options -Force

			# Check Exit Code
			$actual_code | Should Be $expected_codde

			# Check Output File Existence
			$expected_filepath | Test-Path -PathType Leaf | Should Be $true
		}
	}

}
