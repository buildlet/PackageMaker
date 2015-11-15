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
# Get Root Source Directory
# Ex) .\Release\SAMPLE\Products
$root_dir = $args[0]
if (-not (Test-Path -Path $root_dir -PathType Container)) { throw New-Object System.IO.DirectoryNotFoundException }
"Root Directory of Source = '$root_dir'"

# Get Output HTML File Path
$html_output_file_path = $args[1]
$html_output_file_name = Split-Path -Path $html_output_file_path -Leaf
"HTML Output File Name = '$html_output_file_path'"
""


# Get HTML Base file and Additional files for Model, Language and Limitation

# HTML Base File (Main)
$html_base_file = $Global:Settings['ReleaseNotes']['BaseHTML']
if (-not (Test-Path -Path $html_base_file -PathType Leaf)) { throw New-Object System.IO.FileNotFoundException }

# HTML Base File of Model
$html_base_file_model = $Global:Settings['ReleaseNotes\Model']['BaseHTML']
if (-not (Test-Path -Path $html_base_file_model -PathType Leaf)) { throw New-Object System.IO.FileNotFoundException }

# HTML Base File of Language
$html_base_file_lang = $Global:Settings['ReleaseNotes\Language']['BaseHTML']
if (-not (Test-Path -Path $html_base_file_lang -PathType Leaf)) { throw New-Object System.IO.FileNotFoundException }

# HTML Base File of Driver
$html_base_file_driver = $Global:Settings['ReleaseNotes\Driver']['BaseHTML']
if (-not (Test-Path -Path $html_base_file_driver -PathType Leaf)) { throw New-Object System.IO.FileNotFoundException }

# HTML Base File for Limitation
$html_base_file_limt = $Global:Settings['ReleaseNotes\Limitation']['BaseHTML']
if (-not (Test-Path -Path $html_base_file_limt -PathType Leaf)) { throw New-Object System.IO.FileNotFoundException }

# Print
"HTML Base File               = '$html_base_file'"
"HTML Base File of Model      = '$html_base_file_model'"
"HTML Base File of Language   = '$html_base_file_lang'"
"HTML Base File of Driver     = '$html_base_file_driver'"
"HTML Base File of Limitation = '$html_base_file_limt'"
""


# Get content of HTML Base File
$html_content = @()
$html_base_content = Get-Content -Path $html_base_file
$html_base_content = $html_base_content `
    -replace '__DATE__', (New-DateString -LCID 'en-US') `
    -replace '__PROJECT_NAME__', $Global:Settings['Project']['Name'] `
    -replace '__PROJECT_VERSION__', $Global:Settings['Project']['Version']



# Model Information
$model_info = @()

# for Models
$Global:Settings['ReleaseNotes\Model'].Keys | Sort-Object | ? {
    ($_ -like 'Model*') -and ($Global:Settings['ReleaseNotes\Model'][$_] -ne $null)
} | % {

    # for each Model

    # Get Model Name and Directory
    $model_name = ([string]$Global:Settings['ReleaseNotes\Model'][$_]).Split(',')[1]
    $model_dir = Join-Path -Path $root_dir -ChildPath ([string]$Global:Settings['ReleaseNotes\Model'][$_]).Split(',')[0]
    $model_dir_name = Split-Path -Path $model_dir -Leaf

    # Validate
    if (-not (Test-Path -Path $model_dir -PathType Container)) { throw New-Object System.IO.DirectoryNotFoundException }
    "Model Nmae      = '$model_name'"
    "Model Directory = '$model_dir'"
    ""

    # Get content of HTML Base File of Model
    $html_content_model = @()
    $html_base_content_model = Get-Content -Path $html_base_file_model
    $html_base_content_model = $html_base_content_model -replace '__MODEL__', $model_name `



    # Language Information
    $lang_info = @()
    
    # for Languages
    $Global:Settings['ReleaseNotes\Language'].Keys | Sort-Object | ? {
        ($_ -ne 'BaseHTML') -and ($Global:Settings['ReleaseNotes\Language'][$_] -ne $null)
    } | % {
        
        # for each Language

        # Get Language Directory
        $lang = $Global:Settings['ReleaseNotes\Language'][$_]
        $lang_dir_name = $_
        $lang_dir = Join-Path -Path $model_dir -ChildPath $lang_dir_name

        # Validate
        if (-not (Test-Path -Path $lang_dir -PathType Container)) { throw New-Object System.IO.DirectoryNotFoundException }
        "Language           = '$lang'"
        "Language Directory = '$lang_dir'"
        ""

        # Get content of HTML Base File of Language
        $html_content_lang = @()
        $html_base_content_lang = Get-Content -Path $html_base_file_lang
        $html_base_content_lang = $html_base_content_lang -replace '__LANGUAGE__', $lang



        # Driver Information
        $driver_info = [string[]]@()

        # for Drivers
        $Global:Settings['ReleaseNotes\Driver'].Keys | Sort-Object | ? {
            ($_ -like 'Driver*') -and ($Global:Settings['ReleaseNotes\Driver'][$_] -ne $null)
        } | % {
            
            # for each Driver

            # Get Directory
            $os_dir_name = ([string]$Global:Settings['ReleaseNotes\Driver'][$_]).Split(',')[0]
            $os_dir = Join-Path -Path $lang_dir -ChildPath $os_dir_name

            # Get INF File
            $inf_file_name = ([string]$Global:Settings['ReleaseNotes\Driver'][$_]).Split(',')[1]
            $inf_file_path = Join-Path -Path $os_dir -ChildPath $inf_file_name

            # Get Driver Name
            $driver_name = ([string]$Global:Settings['ReleaseNotes\Driver'][$_]).Split(',')[2]

            # Validate
            if (-not (Test-Path -Path $os_dir -PathType Container)) { throw New-Object System.IO.DirectoryNotFoundException }
            if (-not (Test-Path -Path $inf_file_path -PathType Leaf)) { throw New-Object System.IO.DirectoryNotFoundException }
            "Driver Name      = '$driver_name'"
            "Driver Directory = '$os_dir'"
            "INF File Name    = '$inf_file_name'"


            # Get Driver Version
            $inf_DriverVer = Get-PrivateProfileString -Path $inf_file_path -Section 'Version' -Key 'DriverVer'
            $driver_date    = $inf_DriverVer.Split(',')[0]
            $driver_version = $inf_DriverVer.Split(',')[1]
            "Driver Date    = '$driver_date'"
            "Driver Version = '$driver_version'"


            # Get CAT File Name / Path
            $cat_file_name = Get-PrivateProfileString -Path $inf_file_path -Section 'Version' -Key 'CatalogFile'
            $cat_file_path = Join-Path -Path $os_dir -ChildPath $cat_file_name

            # Validate
            if (-not (Test-Path $cat_file_path)) { throw New-Object System.IO.DirectoryNotFoundException }
            "CAT File = '$cat_file_path'"


            # Get Authenticode Signer Name
            $signer = Get-AuthenticodeSignerName -FilePath $cat_file_path
            "Authenticode Signer Name = '$signer'"

            # Get Authenticode Time Stamp
            $timestamp = Get-AuthenticodeTimeStamp -FilePath $cat_file_path
            "Authenticode Timestamp = '$timestamp'"
            ""


            # Get content of HTML Base File of Driver
            $html_base_content_driver = Get-Content -Path $html_base_file_driver

            # Update HTML content of Driver
            $html_base_content_driver = $html_base_content_driver `
                -replace '__OS__', $os_dir_name `
                -replace '__DRIVER_NAME__', $driver_name `
                -replace '__DRIVER_VERSION__', $driver_version `
                -replace '__DRIVER_DATE__', $driver_date `
                -replace '__SIGNER_NAME__', $signer `
                -replace '__SIGNATURE_TIMESTAMP__', $timestamp

            # Update Driver Information
            $html_base_content_driver | % { $driver_info += $_ }
        }


        # Update HTML content of Language
        $html_base_content_lang | % {
            if (([string]$_).Trim() -eq '__DRIVER_INFO__') {
                $driver_info | % { $html_content_lang += $_ }
            }
            else { $html_content_lang += $_ }
        }

        # Update Language Information
        $html_content_lang | % { $lang_info += $_ }
    }

    
    # Update HTML content of Model
    $html_base_content_model | % {
        if (([string]$_).Trim() -eq '__LANGUAGES__') {
            $lang_info | % { $html_content_model += $_ }
        }
        else { $html_content_model += $_ }
    }

    # Update Model Information
    $html_content_model | % { $model_info += $_ }
}


# Get content of HTML Base File of Limitation
$html_content_limit = Get-Content -Path $html_base_file_limt
$html_content_limit = $html_content_limit `
    -replace '__LIMITATIONS__', '<p>There might be some limitations.</p>'


# Update HTML content of Release Notes
$html_base_content | % {
    if (([string]$_).Trim() -eq '__MODELS__') {
        $model_info | % { $html_content += $_ }
    }
    elseif (([string]$_).Trim() -eq '__LIMITATION__') {
        $html_content_limit | % { $html_content += $_ }
    }
    else { $html_content += $_ }
}



# Output to File
Out-File -FilePath $html_output_file_path -InputObject $html_content -Encoding utf8 -Force
"Release Notes '$html_output_file_name' has been created."
"('$html_output_file_path')"
""
""
#>

####################################################################################################
##  Finalize
####################################################################################################
# (None)
