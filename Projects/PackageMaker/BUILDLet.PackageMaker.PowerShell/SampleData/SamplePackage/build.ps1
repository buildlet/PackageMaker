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
$title     = "BUILDLet PackageMaker Toolkit Sample Script"
$copyright = "Copyright (C) 2015 Daiki Sakamoto All rights reserved."
$version   = '1.2.0.0'

"$title Version $version"
$copyright
""
""

####################################################################################################
##  Settings
####################################################################################################
# Verbose
$VerbosePreference = 'SilentlyContinue'

# Debug
$DebugPreference = 'SilentlyContinue'

# Error Action
$ErrorActionPreference = 'Stop'


####################################################################################################
##  Definition
####################################################################################################
# (None)


####################################################################################################
##  Initialize
####################################################################################################

# Print Start Time Stamp / Import Required Module(s)
##################
##  Initialize  ##
##################
.\00_initialize.ps1


#######################
##  Import INI File  ##
#######################
.\01_import_IniFile.ps1 .\sample.ini


# Initialize Working Directory
$work_dir = $Settings['Destination']['WorkingDirectory']
Reset-Directory -Path $work_dir -Force
"Working Directory has been initialized."
"('$work_dir')"
""

# Initialize Release Directory
$release_dir = $Settings['Destination']['ReleaseDirectory']
Reset-Directory -Path $release_dir -Force
"Release Directory has been initialized."
"('$release_dir')"
""
""
#>

####################################################################################################
##  Process
####################################################################################################
$package_src      = $Settings['Source']['Package']
$root_dir_name    = $Settings['Destination']['RootDirectoryName']
$product_dir_name = $Settings['Destination']['ProductDirectoryName']


# Extract or Copy Package
if ($package_src.Split(',')[0].Split('.')[-1] -eq 'zip') {

    ##### Unzip Package Source #####
    
    # Set Zip File Source and Pakage Source Name    
    $zip_src_file = $package_src.Split(',')[0]
    $package_name = $package_src.Split(',')[1]
    "Zip File Source     = '$zip_src_file'"
    "Package Source Name = '$package_name'"
    ""

    # Extract Package Source into Working Directory
    "Extracting Package Source '$zip_src_file'..."
    $zip_dest_dir      = Expand-ZipFile -Path $zip_src_file -DestinationPath $work_dir -Force -PassThru
    $zip_dest_dir_name = Split-Path -Path $zip_dest_dir -Leaf

    # Validate
    if (-not (Test-Path -Path $zip_dest_dir -PathType Container)) { throw "Package Source has not extracted properly." }
    "Package Source has been extracted into Working Directory."
    "('$zip_src_file' -> '$zip_dest_dir')"
    ""

    # Validate
    if (-not ($zip_dest_dir | Join-Path -ChildPath $package_name | Test-Path -PathType Container)) { throw "Package Name is not properly." }

    # Validate
    if ($zip_dest_dir_name -eq $root_dir_name) { throw "Package Name and Root Directory Name is the same." }

    # Create Root Directory
    $root_dir = New-Item -Path (Join-Path -Path $work_dir -ChildPath $root_dir_name) -ItemType Directory
    "Root Directory has been created."
    "('$root_dir')"
    ""

    # Move Package into Root Directory
    $src_dir       = Join-Path -Path $zip_dest_dir -ChildPath $package_name
    $src_dir_name  = Split-Path -Path $src_dir -Leaf
    $dest_dir      = Move-Item -Path $src_dir -Destination $root_dir -Force -PassThru
    $dest_dir_name = Split-Path -Path $dest_dir -Leaf 
    "Package has been moved into Root Directory."
    "('$src_dir' -> '$dest_dir')"
    ""
}
else {

    ##### Copy Package #####

    # Create Root Directory
    $root_dir = New-Item -Path (Join-Path -Path $work_dir -ChildPath $root_dir_name) -ItemType Directory
    "Root Directory has been created."
    "('$root_dir')"
    ""

    # Copy Package into Working Directory
    "Copying Package '$package_src'..."
    Copy-Item -Path $package_src -Destination $root_dir -Recurse -Force
    $dest_dir      = Join-Path -Path $root_dir -ChildPath (Split-Path -Path $package_src -Leaf)
    $dest_dir_name = Split-Path -Path $dest_dir -Leaf

    # Validate
    if (-not (Test-Path -Path $dest_dir -PathType Container)) { throw "Package has not copied properly." }
    "Package has been copied into Working Directory."
    "('$package_src' -> '$dest_dir')"
    ""
}
#>


# Check Product Directory Name
if ($dest_dir_name -ne $product_dir_name) {

    # Rename Product Directory
    Rename-Item -Path $dest_dir -NewName $product_dir_name -Force
    "Product Directory has been renamed."
    "('$dest_dir' -> '$product_dir_name')"
    ""
}
""
#>



# Copy Readme File(s)
$readme_src_dir = $Settings['Source']['README']
$readme_dest_dir = Copy-Item -Path $readme_src_dir -Destination $root_dir -Recurse -Force -PassThru

"Copying Readme File(s)..."
$i = 0
$readme_dest_dir | ? { $_ -is [System.IO.FileInfo] } | % {
    $i++
    "Readme File ($i) = '$_'"
}
"Readme File(s) have been copied."
""
#>



# Copy AUTORUN.INF File
$autorun_file_src = $Settings['Source']['AUTORUN']
$autorun_file = Copy-Item -Path $autorun_file_src -Destination $root_dir -Force -PassThru
"AUTORUN.INF has been copied."
"('$autorun_file_src' -> '$autorun_file')"
""
#>



# Copy Disc Icon File
$icon_file_src = $Settings['Source']['DiscIcon']
$icon_file = Copy-Item -Path $icon_file_src -Destination $root_dir -Force -PassThru
"Disc Icon File has been copied."
"('$icon_file_src' -> '$icon_file')"
""
#>



# Copy Additional Directory
$test_dir_src = $Settings['Source']['TestDirectory']
$test_dir_name = Split-Path -Path $test_dir_src -Leaf
Copy-Item -Path $test_dir_src -Destination $root_dir -Recurse -Force
$test_dir = Join-Path -Path $root_dir -ChildPath $test_dir_name

# Validate
if (-not (Test-Path -Path $test_dir)) { throw New-Object System.Management.Automation.JobFailedException }
"Directory '$test_dir_name' has been copied."
"('$test_dir_src' -> '$test_dir')"
""
""
#>



##### Renew CAT File(s) ######

if ($Settings['Operation']['Inf2Cat'] -eq 'TRUE') {

    #########################
    ##  Renew CAT File(s)  ##
    #########################
    .\02_renew_CatFile.ps1 `
        (Join-Path -Path $root_dir -ChildPath $Settings['Inf2Cat']['PackagePath']) `
        $Settings['Inf2Cat']['WindowsVersionList_X86'] `
        $Settings['Inf2Cat']['WindowsVersionList_X64']
}
#>



##### Sign to File(s) #####

if ($Settings['Operation']['Sign'] -eq 'TRUE') {

    ###########################
    ##  Sign to CAT File(s)  ##
    ###########################
    .\03_sign_to_File.ps1 (Join-Path -Path $root_dir -ChildPath $Settings['SignTool']['FILENAME']) `
}
#>



##### Update Readme File(s) #####

# Get DvierVer from INF File (x86)
$inf_DriverVer_x86 = Get-PrivateProfileString `
    -Path (Join-Path -Path $root_dir -ChildPath $Settings['README\DriverVer']['X86']) `
    -Section 'Version' `
    -Key 'DriverVer' `

# Get DvierVer from INF File (x64)
$inf_DriverVer_x64 = Get-PrivateProfileString `
    -Path (Join-Path -Path $root_dir -ChildPath $Settings['README\DriverVer']['X64']) `
    -Section 'Version' `
    -Key 'DriverVer' `

# Update Content of Readme File
$readme_update_texts = @{
    '__PROJECT_VERSION__'    = $Settings['Project']['Version']
    '__X86_DRIVER_VERSION__' = $inf_DriverVer_x86.Split(',')[1]
    '__X64_DRIVER_VERSION__' = $inf_DriverVer_x64.Split(',')[1]
}

############################
##  Update Readme File(s) ##
############################
.\04_update_ReadmeFile.ps1 ($root_dir | Join-Path -ChildPath 'Readme\*\Readme.txt') $readme_update_texts
#>



# Move Root Directory from Working Directory into Release Directory
"Moving Root Directory..."
$root_dir = Move-Item -Path $root_dir -Destination $release_dir -Force -PassThru
"Root Directory has been moved from Working Directory into Release Directory."
"('$root_dir')"
""
""
#>



##### Generate ISO Image File #####

# Set options of GenIsoImage.exe
"Initializing options of genisoimage.exe..."
$iso_options = [string]::Empty
$i = 0
$Settings['GENISOIMAGE'].Keys | Sort-Object | ? { ($_ -like 'Option*') -and ($Settings['GENISOIMAGE'][$_] -ne $null) } | % {
    $i++
    $opt = $Settings['GENISOIMAGE'][$_]
    "Option ($i) '$_' = '$opt'"

    if ($iso_options -ne [string]::Empty) { $iso_options += ' ' }
    $iso_options += $opt
}
"Options of genisoimage.exe = '$iso_options'"

$iso_filename = $Settings['GENISOIMAGE']['FileName']
"ISO File Name = '$iso_filename'"
""

# Generate ISO Image File
"Generating ISO Image File..."
$result = (New-IsoFile -Path $root_dir -DestinationPath $release_dir -FileName $iso_filename -Options $iso_options)

# Validate
if ($result -ne 0) { throw New-Object System.Management.Automation.ApplicationFailedException }
"ISO Image File '$iso_filename' has been generated."
""
""
#>



##### Create Release Notes #####

############################
##  Create Release Notes  ##
############################
.\11_create_ReleaseNotes.ps1 `
    $root_dir `
    (Join-Path -Path $release_dir -ChildPath $Global:Settings['ReleaseNotes']['Destination'])
#>

####################################################################################################
##  Finalize
####################################################################################################

# Print End Time Stamp and Elapsed Time
################
##  Finalize  ##
################
.\99_finalize.ps1
