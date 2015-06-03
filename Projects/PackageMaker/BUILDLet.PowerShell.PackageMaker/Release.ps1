@"
BUILDLet.PowerShell.PackageMaker Release Script
Copyright (C) 2015 Daiki Sakamoto

"@


# Unit Test (BUILDLet.PowerShell.PackageMakerTest)
Push-Location '..\BUILDLet.PowerShell.PackageMakerTest'
Invoke-Pester
Pop-Location


# Import Module(s)
Import-Module '..\..\..\Release\Utilities\BUILDLet.PowerShell.Utilities'
Import-Module '.\BUILDLet.PowerShell.PackageMaker.psd1'


# Check Sample Data
Push-Location '.\SampleData\SamplePackage'
New-HR
.\init.ps1
New-HR
.\build.ps1
New-HR
.\check.ps1
New-HR
Pop-Location



# Target PowerShell Module
$module_name = 'BUILDLet.PowerShell.PackageMaker'
$module_files = @(
    'BUILDLet.PowerShell.PackageMaker.psd1'
    'BUILDLet.PowerShell.PackageMaker.psm1'
)

# Sample Data
$sample_data = 'SamplePackage'
$sample_data_dir = Convert-Path -Path '.\SampleData\SamplePackage'

# Release Base Directory
$release_dir = Convert-Path -Path '..\..\..\Release\PackageMaker'



# Remove 'Work' Directory of Sample Data
if (Test-Path -Path ($work_dir = (Join-Path -Path $sample_data_dir -ChildPath 'Work'))) {
    Remove-Item -Path $work_dir -Recurse -Force
}
''
''



# Prepare Release Directory of PowerShell Module
$target_dir = (Join-Path -Path $release_dir -ChildPath $module_name)
if (-not (Test-Path -Path $target_dir)) { [void](New-Item -Path $target_dir -ItemType Directory) }

# Copy PowerShell Module
$module_files | % { Copy-Item -Path $_ -Destination $target_dir -Force }
"[RELEASE] $module_name -> " + (Convert-Path -Path $target_dir)



# Prepare to Zip Sample Data into Release Directory 
$target_path = Join-Path -Path $release_dir -ChildPath ($sample_data + '.zip')
if (Test-Path -Path $target_path) { Remove-Item -Path $target_path -Force }

# Zip Sample Data
$target_path = (New-ZipFile -Path $sample_data_dir -DestinationPath $release_dir -PassThru) | Convert-Path
"[RELEASE] " + (Split-Path -Path $target_path -Leaf) +  " -> " + (Split-Path -Path $target_path -Parent)
