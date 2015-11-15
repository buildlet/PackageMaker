<###############################################################################
 The MIT License (MIT)

 Copyright (c) 2015 Daiki Sakamoto

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
$version = '1.2.0.0'
"[" + $MyInvocation.MyCommand.Name + "] (Version $version)"

####################################################################################################
##  Settings
####################################################################################################
# (None)

####################################################################################################
##  Initialize
####################################################################################################
# (None)

####################################################################################################
##  Definition
####################################################################################################
# (None)

####################################################################################################
##  Process
####################################################################################################
# Get Input File Path
# Ex) '.\Work\SAMPLE\Products\*\Printers\*\*\*.CAT'
$i = 0
($input_files = Convert-Path -Path $args[0]) | % {
    $i++
    "Input File ($i) = '$_'"
    if (-not (Test-Path -Path $_ -PathType Leaf)) { throw New-Object System.IO.FileNotFoundException }
}
""


# Sign to Input File(s)
"Code Signing to Input File(s)..."
""

# Invoke SignTool.exe
$result = Invoke-SignTool -Command sign -Options '/f .\sample.pfx', "/t $TimeStampServerURL", '/v' -FilePath $input_files

# Validate
if ($result -ne 0) { throw New-Object System.Management.Automation.JobFailedException }
""
"Code Signing has finished."
""
""
#>

####################################################################################################
##  Finalize
####################################################################################################
# (None)
