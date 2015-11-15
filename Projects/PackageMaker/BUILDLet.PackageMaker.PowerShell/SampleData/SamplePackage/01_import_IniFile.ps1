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
# Setting Items in INI File
$Global:Settings = @{

    # [Project]
    'Project' = @{
        'Name'    = $null
        'Version' = $null
    }

    # [Operation]
    'Operation' = @{
        'Inf2Cat' = $null
        'Sign'    = $null
    }

    # [Source]
    'Source' = @{
        'Package'       = $null
        'PackageName'   = $null
        'README'        = $null
        'AUTORUN'       = $null
        'DiscIcon'      = $null
        'TestDirectory' = $null
    }

    # [Destination]
    'Destination' = @{
        'ReleaseDirectory'     = $null
        'WorkingDirectory'     = $null
        'RootDirectoryName'    = $null
        'ProductDirectoryName' = $null
    }

    # [Inf2Cat]
    'Inf2Cat' = @{
        'PackagePath' = $null
        'WindowsVersionList_X86' = $null
        'WindowsVersionList_X64' = $null
    }

    # [SignTool]
    'SignTool' = @{
        'FILENAME' = $null
    }

    # [README\DriverVer]
    'README\DriverVer' = @{
        'X86' = $null
        'X64' = $null
    }

    # [Readme\LCID]
    'README\LCID' = @{
        'en' = $null
        'ja' = $null
    }

    # [ISO]
    'GENISOIMAGE' = @{
        'FileName' = $null
        'Option01' = $null
        'Option02' = $null
        'Option03' = $null
        'Option04' = $null
        'Option05' = $null
        'Option06' = $null
        'Option07' = $null
        'Option08' = $null
        'Option09' = $null
        'Option10' = $null
        'Option11' = $null
        'Option12' = $null
        'Option13' = $null
        'Option14' = $null
        'Option15' = $null
        'Option16' = $null
        'Option17' = $null
        'Option18' = $null
        'Option19' = $null
    }

    # [ReleaseNotes]
    'ReleaseNotes' = @{
        'BaseHTML'    = $null
        'Destination' = $null
    }

    # [ReleaseNotes\Model]
    'ReleaseNotes\Model' = @{
        'BaseHTML' = $null
        'Model1'   = $null
        'Model2'   = $null
        'Model3'   = $null
        'Model4'   = $null
        'Model5'   = $null
        'Model6'   = $null
        'Model7'   = $null
        'Model8'   = $null
        'Model9'   = $null
    }

    # [ReleaseNotes\Language]
    'ReleaseNotes\Language' = @{
        'BaseHTML'    = $null
        'en' = $null
        'ja' = $null
    }

    # [ReleaseNotes\Driver]
    'ReleaseNotes\Driver' = @{
        'BaseHTML' = $null
        'Driver1'  = $null
        'Driver2'  = $null
        'Driver3'  = $null
        'Driver4'  = $null
        'Driver5'  = $null
        'Driver6'  = $null
        'Driver7'  = $null
        'Driver8'  = $null
        'Driver9'  = $null
    }

    # [ReleaseNotes\Limitation]
    'ReleaseNotes\Limitation' = @{
        'BaseHTML'    = $null
    }
}

####################################################################################################
##  Process
####################################################################################################
# Get Input File (INI File)
# Ex) .\sample.ini
$ini_file = $args[0]

# Validate
if (-not (Test-Path -Path $ini_file)) { throw New-Object System.IO.FileNotFoundException }
# if (([string]$ini_file).Split('.')[-1] -ne 'ini') { throw New-Object System.IO.FileFormatException }
"Input File = '$ini_file'"

$filename = Split-Path -Path $ini_file -Leaf

# Import INI File
"Importing INI File '$filename'..."
""
"[Section][Key] = Value"
"--------------------------------"
$Global:Settings.Keys | Sort-Object | % {
    $section = $_

    # Copy Array ($Settings[$section].Keys -> $keys)
    $keys = New-Object System.Object[] $Global:Settings[$section].Keys.Count
    $Global:Settings[$section].Keys.CopyTo($keys, 0)
    
    $keys | Sort-Object | % {
        $key = $_
        "[$section][$key] = " + 
        ($Global:Settings[$section][$key] = Get-PrivateProfileString -Path $ini_file -Section $section -Key $key)
    }
}
""
"INI File has been imported."
""
""
#>

####################################################################################################
##  Finalize
####################################################################################################
# (None)
