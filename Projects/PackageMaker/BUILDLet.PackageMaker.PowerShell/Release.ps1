@'
BUILDLet.PackageMaker.PowerShell Release Script
Copyright (C) 2015 Daiki Sakamoto All rights reserved.

'@

# Error Action
$ErrorActionPreference = 'Stop'

# Target PowerShell Module
$module_name = 'BUILDLet.PackageMaker.PowerShell'
$module_files = @(
    'BUILDLet.PackageMaker.PowerShell.psd1'
    'BUILDLet.PackageMaker.PowerShell.psm1'
)

# Sample Package
$sample_package_name = 'SamplePackage'
$sample_package_dir = Convert-Path -Path '.\SampleData\SamplePackage'

# Release Base Directory
$release_base_dir = Convert-Path -Path '..\..\..\Release\PackageMaker'



<# Remove 'Work' Directory of Sample Data
if (Test-Path -Path ($sample_package_work_dir = (Join-Path -Path $sample_package_dir -ChildPath 'Work'))) {
    Remove-Item -Path $sample_package_work_dir -Recurse -Force
}
#>

# Prepare Release Directory of PowerShell Module
$target_dir = (Join-Path -Path $release_base_dir -ChildPath $module_name)
if (-not (Test-Path -Path $target_dir)) { [void](New-Item -Path $target_dir -ItemType Directory) }

# Copy PowerShell Module
$module_files | % { '.' | Join-Path -ChildPath $_ | Copy-Item -Destination $target_dir -Force }
"[RELEASE] $module_name -> " + (Convert-Path -Path $target_dir)



# Prepare to Zip Sample Data into Release Directory 
$zip_file_path = Join-Path -Path $release_base_dir -ChildPath ($sample_package_name + '.zip')
if (Test-Path -Path $zip_file_path) { Remove-Item -Path $zip_file_path -Force }

# Import module for New-ZipFile Cmdlet
Import-Module '..\..\..\Release\Utilities\BUILDLet.Utilities.PowerShell'

# Zip Sample Data
$zip_file_path = (New-ZipFile -Path $sample_package_dir -DestinationPath $release_base_dir -PassThru) | Convert-Path
"[RELEASE] " + (Split-Path -Path $zip_file_path -Leaf) +  " -> " + (Split-Path -Path $zip_file_path -Parent)
