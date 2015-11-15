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
# Ex) '.\Work\SAMPLE\Products\*\Printers\*\*'
$i = 0
($package_dirs = Convert-Path -Path $args[0]) | % {
    $i++
    "Input Directories ($i) = '$_'"
    if (-not (Test-Path -Path $_ -PathType Container)) { throw New-Object System.IO.DirectoryNotFoundException }
}

# WindowsVersionList parameter of Inf2Cat.exe (x86 / x64)
# Ex) 'Vista_X86,7_X86,8_X86,6_3_X86,Server2008_X86'
# Ex) 'Vista_X64,7_X64,8_X64,6_3_X64,Server2008_X64,Server2008R2_X64,Server8_X64,Server6_3_X64'
$inf2cat_WindowsVersionList_x86 = $args[1]
$inf2cat_WindowsVersionList_x64 = $args[2]
"WindowsVersionList parameter of Inf2Cat.exe (x86) = '$inf2cat_WindowsVersionList_x86'"
"WindowsVersionList parameter of Inf2Cat.exe (x64) = '$inf2cat_WindowsVersionList_x64'"
""
""

# Renew CAT File(s)
"Renewing CAT File(s)..."
$i = 0
$package_dirs | % {
    
    $i++

    # x86 or x64
    $package_path = $_
    "($i) Renewing CAT File(s) in '$package_path'..."
    switch ($package_path.Split([System.IO.Path]::DirectorySeparatorChar)[-1])
    {
        # Renew CAT File(s)
        'x86' { $result = (New-CatFile -PackagePath $package_path -WindowsVersionList $inf2cat_WindowsVersionList_x86) }
        'x64' { $result = (New-CatFile -PackagePath $package_path -WindowsVersionList $inf2cat_WindowsVersionList_x64) }
    }

    # Validate
    if ($result -ne 0) { throw New-Object System.Management.Automation.ApplicationFailedException }
    "($i) CAT File(s) in '$package_path' have been renewed."
    ""
}
"CAT File(s) have been renewed."
""
""
#>

####################################################################################################
##  Finalize
####################################################################################################
# (None)
