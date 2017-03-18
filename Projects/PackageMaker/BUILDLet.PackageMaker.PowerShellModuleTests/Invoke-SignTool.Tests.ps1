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

# Test File(Exit999.exe)
$Script:filename_Exit999_EXE = 'exit999.exe'
$Script:filepath_Exit999_EXE = $Script:dirpath_TestData | Join-Path -ChildPath $Script:filename_Exit999_EXE | Convert-Path


Describe "Invoke-SignTool" {

	# 'FCIV.exe':
	#  File Name & File Path
	$filename = $Script:filename_FCIV_EXE
	$filepath = $Script:filepath_FCIV_EXE

	#  Expected Output & Exit Code
	$expected_code = 0
	$expected_output = @(
		"File: " + $Script:filepath_FCIV_EXE
		"Index  Algorithm  Timestamp    "
		"========================================"
		"0      sha1       Authenticode "
		""
		"Successfully verified: " + $Script:filepath_FCIV_EXE
		""
	)
	$expected_output2 = @(
		"File: " + $Script:filepath_FCIV_EXE
		"Index==Algorithm==Timestamp===="
		"========================================"
		"0      sha1       Authenticode "
		""
		"Successfully verified: " + $Script:filepath_FCIV_EXE
		""
	)


	# Default Test (Check Digital Signature of 'FCIV.exe')
	Context "Catalog Signature of '$filename' (FCIV: File Checksum Integrity Verifier)" {

		# Output Stream (Warning Message Stream & Pipeline)
		$output_stream_text = @(
			"Warning Message Stream"
			"Pipeline (by 'PassThru' Parameter)"
		)
		
		for ($i = 0; $i -lt $output_stream_text.Count; $i++) {

			$stream = $output_stream_text[$i]
			It "Is Successfully Verified. (Output: $stream)" {

				switch ($i) {
					
					# Warning
					0 {
						# 'Invoke-SignTool'
						$actual_code = Invoke-SignTool -Command verify -Options '/pa' -FilePath $filepath -WarningVariable actual_output

						# Check Return Code (ONLY NOT PassThru)
						$actual_code | Should Be $expected_code
					}

					# Pipeline (PassThru)
					1 {
						# 'Invoke-SignTool'
						$actual_output = Invoke-SignTool -Command verify -Options '/pa' -FilePath $filepath -PassThru
					}
				}

				# Check Line Number of Output
				$actual_output.Count | Should Be $expected_output.Count

				# Check Output
				for ($j = 0; $j -lt $expected_output.Count; $j++) {

					# Check Each Line of Output
					$actual_output[$j] | Should Be $expected_output[$j]
				}
			}
		}
	}


	# 'Pack' Parameter Test
	Context "Catalog Signature of Multiple Files (using '$filename' many times)" {

		$input_files = @()
		0..2 | % { $input_files += $filepath }

		# 'Pack' Parameter
		for ($pack = 0; $pack -lt 5; $pack++) {


			# Expected Count
			if ($pack -eq 0) {

				# 'Pack' Parameter = 0
				$expected_total_count = 1
			}
			else {

				# 'Pack' Parameter = 1..N
				$expected_total_count = [math]::Floor($input_files.Count / $pack)
				if (($input_files.Count % $pack) -ne 0) { $expected_total_count++ }
			}


			# Initialize: Expected Warning Output & Count
			$expected_outputs = @()
			$current = 0

			# 'Invoke-SignTool'
			Invoke-SignTool -Command verify -Options '/pa' -FilePath $input_files -Pack $pack -WarningVariable warning | % {

				# Actual Exit Code
				$actual_code = $_

				# Expected Warning Output (Update)
				$expected_outputs += $expected_output
				if ($pack -eq 0) {

					# 'Pack' Parameter = 0
					2..$input_files.Count | % { $expected_outputs += $expected_output2 }
				}
				else {

					# 'Pack' Parameter = 1..N
					for ($i = 1; $i -lt $pack; $i++) {
						if ((($pack * $current) + $i) -lt $input_files.Count) { $expected_outputs += $expected_output2 }
					}
				}


				$expected_lines = $expected_outputs.Count
				$expected_count = $current + 1

				It "Is Successfully Verified ('Pack' Parameter=$pack, $expected_count/$expected_total_count, Exit Code=$actual_code, Warning Output: $expected_lines Lines)" {

					# Check Return Code
					$actual_code | Should Be $expected_code

					# Check Line Number of Warning Output
					$warning.Count | Should Be $expected_outputs.Count

					# Check Output
					for ($i = 0; $i -lt $expected_outputs.Count; $i++) {

						# Check Each Line of Output
						$warning[$i] | Should Be $expected_outputs[$i]
					}
				}

				# Count-up
				$current++
			}
		}		
	}
}
