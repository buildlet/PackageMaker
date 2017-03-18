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

# Local Data Directory
$Script:dirpath_Local = '..\..\..\..\..\Local'

# Test File (FCIV.exe)
$Script:filename_FCIV_EXE = 'fciv.exe'
$Script:filepath_FCIV_EXE = $Script:dirpath_Local | Join-Path -ChildPath 'FCIV' | Join-Path -ChildPath $Script:filename_FCIV_EXE | Convert-Path


Describe "Get-AuthenticodeTimeStampString" {

	# Default Test (using 'FCIV.exe')
	$filename = $Script:filename_FCIV_EXE
	$filepath = $Script:filepath_FCIV_EXE
	$expected = 'Fri May 14 05:26:01 2004'
	Context "Authenticode Time Stamp of '$filename'" {

		# 'Get-AuthenticodeTimeStampString'
		It "Is '$expected'." { Get-AuthenticodeTimeStampString $filepath | Should Be $expected }
	}


	# Multiple File and Pipeline Test (using 'FCIV.exe' some times)
	$count = 3
	Context "Authenticode Time Stamp of Multiple Files (using '$filename' $count times, via Pipeline)" {

		$target_files = @()
		0..($count - 1) | % { $target_files += $filepath }

		for ($i = 0; $i -lt $target_files.Count; $i++) {

			$current = $i + 1

			# 'Get-AuthenticodeTimeStampString'
			It "Is '$expected'. ($current)" { Get-AuthenticodeTimeStampString $target_files[$i] | Should Be $expected }
		}
	}
}
