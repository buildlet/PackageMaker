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
# $args[0]
# Ex) '.\Work\SAMPLE\Readme\*\Readme.txt'
$i = 0
($readme_files = Convert-Path -Path $args[0]) | % {
    $i++
    "Input File ($i) = '$_'"
    if (-not (Test-Path -Path $_ -PathType Leaf)) { throw New-Object System.IO.FileNotFoundException }
}

# Update Texts
# $args[1]
# Ex) @{ '__VERSION__' = '1.2.3.4' }
$i = 0
($update_texts = $args[1]).Keys | % {
    $i++
    $text = $update_texts[$_]
    "Update Text ($i) $_ = '$text'"
}
""

# Update Readme File(s)
"Updating Readme File(s)..."
$i = 0
$readme_files | % {
    
    $i++
    $readme_file = $_
    $filename = Split-Path -Path $readme_file -Leaf

    # Get Readme Language
    $readme_lang = $Global:Settings['README\LCID'][$readme_file.Split([System.IO.Path]::DirectorySeparatorChar)[-2]]
    if ($readme_lang -eq $null) { throw New-Object System.Management.Automation.JobFailedException }

    # Get Content of Readme
    $content = Get-Content -Path $readme_file -Encoding UTF8

    # Update Date of Readme
    $content = $content -replace '__DATE__', (New-DateString -LCID $readme_lang)

    # Update Content of Readme
    $update_texts.Keys | % {
        $content = $content -replace $_, $update_texts[$_]
    }

    # Update Readme File

    # BOM is added automatically by the following code.
    # Out-File -FilePath $readme_file -InputObject $content -Encoding utf8 -Force
    
    # for UTF-8 Encoding without BOM
    [System.IO.File]::WriteAllLines($readme_file, $content, (New-Object System.Text.UTF8Encoding($false)))

    "($i) '$filename' ($readme_lang) has been updated."
}
"Readme File(s) have been updated."
""
""
#>

####################################################################################################
##  Finalize
####################################################################################################
# (None)
