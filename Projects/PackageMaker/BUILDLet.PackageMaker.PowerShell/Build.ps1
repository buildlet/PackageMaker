# BUILDLet.PackageMaker.PowerShell Build Script
# Copyright (C) 2015 Daiki Sakamoto


# Release
@'
#################
##   RELEASE   ##
#################

'@
Import-Module '..\..\..\Release\Utilities\BUILDLet.Utilities.PowerShell'
.\Release.ps1
''
''
''

# Unit Test (BUILDLet.PackageMaker.PowerShellTest)
@'
###################
##   Unit Test   ##
###################

'@
Push-Location '..\BUILDLet.PackageMaker.PowerShellTest'
Invoke-Pester
Pop-Location
''
''
''

@'
###########################
##   Check Sample Data   ##
###########################

'@

# Import Module(s) for Check Sample Data
Import-Module '..\..\..\Release\Utilities\BUILDLet.Utilities.PowerShell'
Import-Module '.\BUILDLet.PackageMaker.PowerShell.psd1'

# Check Sample Data
Push-Location '.\SampleData\SamplePackage'
.\init.ps1
New-HR
.\build.ps1
New-HR
.\check.ps1
New-HR
Pop-Location
