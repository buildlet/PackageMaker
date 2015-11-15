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

<#
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
#>

####################################################################################################
##  Process
####################################################################################################
# Print Start Time Stamp
$Global:StartTime = Get-Date
"START: " + $Global:StartTime.ToString('yyyy/MM/dd hh:mm:ss')
""

# Required Modules
$required_modules = @(
    'BUILDLet.Utilities.PowerShell'
    'BUILDLet.PackageMaker.PowerShell'
)

# Import Required Modules
$required_modules | % {
    if ((Get-Module | Select-String ($module = $_)) -eq $null) {
        "Importing module '$module'..."
        Import-Module $module
    }
    else {
        "Required module '$module' is already imported."
    }
}
""
""
#>

<#
####################################################################################################
##  Finalize
####################################################################################################
# (None)
#>