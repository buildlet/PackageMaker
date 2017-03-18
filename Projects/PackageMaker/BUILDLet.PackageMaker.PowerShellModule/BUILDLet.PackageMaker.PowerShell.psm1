<###############################################################################
 The MIT License (MIT)

 Copyright (c) 2015-2017 Daiki Sakamoto

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

####################################################################################################
Function Invoke-SignTool
{
    <#
        .SYNOPSIS
            SignTool.exe  (�����c�[��) �����s���܂��B

        .DESCRIPTION
            SignTool.exe  (�����c�[��) �����s���܂��B
            �����c�[���̓R�}���h ���C�� �c�[���ŁA�t�@�C���Ƀf�W�^��������Y�t���A
			�t�@�C���̏��������؂��A�t�@�C���Ƀ^�C�� �X�^���v��t���܂��B

        .PARAMETER Command
            4 �̃R�}���h (catdb�Asign�Atimestamp�A�܂��� verify) �̂����̂����ꂩ 1 ���w�肵�܂��B  

        .PARAMETER Options
            SignTool.exe �ւ̃I�v�V�������w�肵�܂��B

        .PARAMETER FilePath
            ��������t�@�C���ւ̃p�X���w�肵�܂��B

        .PARAMETER RetryCount
            SignTool.exe �̏I���R�[�h�� 0 �ȊO�������ꍇ�Ƀ��g���C����񐔂��w�肵�܂��B
            ����̐ݒ�� 0 ��ł��B

        .PARAMETER RetryInterval
            ���g���C����Ԋu��b���Ŏw�肵�܂��B
			����̐ݒ�� 0 �b�ł��B

		.PARAMETER Pack
			FilePath �p�����[�^�[�ɕ����̃t�@�C�����w�肳��Ă���ꍇ�APack �p�����[�^�[��
			�w�肳�ꂽ�t�@�C�����̃t�@�C���Z�b�g���Ƃ� SignTool.exe �𕡐�����s���܂��B
			Pack �p�����[�^�[�� 0 ���w�肷��ƁA�S�Ẵt�@�C����Ώۂ� SignTool.exe �� 1 ����s���܂��B
			����ł� 0 �ł��B

        .PARAMETER PassThru
            �W���o�̓X�g���[���ւ̏o�͌��ʂ�Ԃ��܂��B
			����ł� SignTool.exe �̏I���R�[�h��Ԃ��܂��B

        .PARAMETER BinPath
            SignTool.exe �t�@�C���ւ̃p�X���w�肵�܂��B
			�w�肳�ꂽ�p�X�� SignTool.exe ��������Ȃ������ꍇ�̓G���[�ɂȂ�܂��B
            ���̃p�����[�^�[���ȗ����ꂽ�ꍇ�� Windows SDK �̃f�t�H���g�̃C���X�g�[�� �p�X���������܂��B
			Windows 10 SDK �� 32 �r�b�g�o�[�W������ SignTool.exe (64 �r�b�g OS �̏ꍇ�� 
			"C:\Program Files (x86)\Windows Kits\10\bin\x86\signtool.exe") ���D��I�Ɍ�������A
			���ɁA���̑��̃o�[�W������ Windows SDK �� 32 �r�b�g�o�[�W������ SignTool.exe ���D�悳��܂��B
			������ Windows SDK ���C���X�g�[������Ă�������ŁA����̃o�[�W������ SignTool.exe ��
			���s���������ꍇ�́A���s�������� SignTool.exe �̃p�X���w�肵�Ă��������B

        .INPUTS 
            System.String
            �p�C�v���g�p���āAFilePath �p�����[�^�[�� Invoke-SignTool �R�}���h���b�g�ɓn�����Ƃ��ł��܂��B

        .OUTPUTS
            System.Int32, System.String
            SignTool.exe �̏I���R�[�h��Ԃ��܂��B
            PassThru �I�v�V�������w�肳�ꂽ�Ƃ��́A�W���o�̓X�g���[���ւ̏o�͌��ʂ�Ԃ��܂��B

        .NOTES
            ���̃R�}���h�����s���� PC �ɁA���炩���� SignTool.exe ���C���X�g�[������Ă���K�v������܂��B
            SignTool.exe �� Windows Software Development Kit (Windows SDK) �Ɋ܂܂�Ă��܂��B

            ����̐ݒ�ł́ASignTool.exe �̕W���o�̓X�g���[���ւ̏o�͌��ʂ͌x�����b�Z�[�W �X�g���[���փ��_�C���N�g����܂��B
            ���̏o�͂�}�������ꍇ�́A�x�����b�Z�[�W �X�g���[���ւ̏o�͂� $null �փ��_�C���N�g (3> $null) ���Ă��������B

        .EXAMPLE
            Invoke-SignTool -Command 'sign' -Options @('/f C:\PFX\sign.pfx', '/p 12345678', '/t http://timestamp.verisign.com/scripts/timstamp.dll', '/v') -FilePath @('D:\Setup.exe', 'E:\Setup.exe') -PassThru -RetryCount 10 -RetryInterval 3
            �ؖ��� C:\PFX\sign.pfx �ŁA'D:\Setup.exe' ����� 'E:\Setup.exe' �ɃR�[�h���������܂��B
			�p�X���[�h�ɂ� 12345678 ���w�肵�Ă��܂��B
			�^�C���X�^���v�T�[�o�[�� http://timestamp.verisign.com/scripts/timstamp.dll ���w�肵�Ă��܂��B
			SignTool.exe �̕W���o�̓X�g���[���ւ̏o�͌��ʂ́A�R���\�[���ɏo�͂���܂��B
			�����Ɏ��s�����ꍇ�� 3 �b�Ԋu��10 ��܂Ń��g���C���܂��B

        .LINK
            SignTool (Windows Drivers)
            https://msdn.microsoft.com/en-us/library/windows/hardware/ff551778.aspx

            SignTool.exe (�����c�[��)
            https://msdn.microsoft.com/ja-jp/library/8s9b9yaz.aspx
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('catdb', 'sign', 'timestamp', 'verify')]
        [string]$Command,
        
        [Parameter(Mandatory = $true, Position = 1)]
        [string[]]$Options,
        
        [Parameter(Mandatory = $true, Position = 2, ValueFromPipeline = $true)]
        [ValidateScript({
            $_ | % { $_ | Resolve-Path } | % {
                if (-not ($_ | Test-Path -PathType Leaf)) { throw (New-Object -TypeName System.IO.FileNotFoundException) }
            }
            return $true
        })]
        [string[]]$FilePath,

        [Parameter()]
		[int]$RetryCount = 0,

        [Parameter()]
		[int]$RetryInterval = 0,

        [Parameter()]
		[int]$Pack = 0,

        [Parameter()]
		[switch]$PassThru,

        [Parameter()]
        [ValidateScript({ ($_ | Test-Path -PathType Leaf) -and (($_ | Split-Path -Leaf).ToUpper() -eq 'SIGNTOOL.EXE') })]
        [string]$BinPath
    )


    # Pre-Processing Tasks
    Begin {

		# for $FilePath
        [string[]]$paths = @()


		# Set Default $BinPath
		if ([string]::IsNullOrEmpty($BinPath)) {

			$bin_target = 'C:\Program Files*\Windows Kits\*\bin\x??\signtool.exe' | Resolve-Path

			# Validation
			if ($bin_target.Count -lt 1) {

				# System.IO.FileNotFoundException
				Write-Error -Exception (New-Object -TypeName System.IO.FileNotFoundException -ArgumentList "'SignTool.exe' is not found.")
			}

			# Debug Output
			"The following path(s) of 'SignTool.exe' (for x86 or x64) is found." | Write-Verbose
			$bin_target | % { $_.Path | Write-Verbose }


			# Search $BinPath of 'SignTool.exe'
			for ($i = 0; $i -lt $bin_target.Count; $i++) {

				if ($bin_target[$i].Path -match '10\\bin\\x86') { $BinPath = $bin_target[$i].Path; break }
				elseif ($bin_target[$i].Path -match 'bin\\x86') { $BinPath = $bin_target[$i].Path; break }
			}
			if ([string]::IsNullOrEmpty($BinPath)) { $BinPath = $bin_target[0].Path }

			# Verbose Output
			"'$BinPath' is selected." | Write-Verbose
		}
    }


    # Input Processing Tasks
    Process {

		# for $FilePath
        $FilePath | ? { Test-Path -Path $_ -PathType Leaf } | % { $_ | Convert-Path } | % { $paths += $_ }
    }


    # Post-Processing Tasks
    End {

        # Validation
        if ($paths -eq $null) { throw (New-Object -TypeName System.IO.FileNotFoundException) }


		# Packing File Number / Packing Count
		if ($Pack -gt 0) {
			$pack_file_num = $Pack
			$pack_count = [math]::Floor($paths.Count / $Pack)
			if (($paths.Count % $Pack) -ne 0) { $pack_count++ }
		}
		else {
			$pack_file_num = $paths.Count
			$pack_count = 1
		}


		# Pack to File Set(s)
		$filesets = @()
		for ($i = 0; $i -lt $pack_count; $i++) {

			# Construct <filename(s)> argument for signtool.exe
			[string]$filenames = [string]::Empty
			for ($j = 0; $j -lt $pack_file_num; $j++) {
				if ((($pack_file_num * $i) + $j) -lt $paths.Count) { $filenames += ('"' + $paths[($pack_file_num * $i) + $j] + '" ') }
			}
			$filenames = $filenames.Trim()

			# Append <filename(s)> argument to File Set(s)
			$filesets += $filenames
		}


		# For Each File Set(s)
		for ($i = 0; $i -lt $filesets.Count; $i++) {

			# Construct ArgumentList
			[string[]]$arguments = @($Command)
			$Options | % { $arguments += $_ }
			$arguments += $filesets[$i]


			# Construct Command Line for Should Process Message
			$equivalent_command_line = ('"' + $BinPath + '"')
			$arguments | % { $equivalent_command_line += (' ' + $_) }

			# Should Process
			if ($PSCmdlet.ShouldProcess($equivalent_command_line, "�R�}���h���C���ɑ�������v���Z�X")) {

				# Invoke 'SignTool.exe' Process
				if ($PassThru)
				{
					Invoke-Process -FilePath $BinPath -ArgumentList $arguments -RetryCount $RetryCount -RetryInterval $RetryInterval -PassThru 4> $null
				}
				else
				{
					Invoke-Process -FilePath $BinPath -ArgumentList $arguments -RetryCount $RetryCount -RetryInterval $RetryInterval -RedirectStandardOutputToWarning 4> $null
				}
			}
		}
    }
}

####################################################################################################
Function Get-AuthenticodeTimeStampString
{
    <#
        .SYNOPSIS
            �f�W�^�������̃^�C���X�^���v���擾���܂��B

        .DESCRIPTION
            SignTool.exe (�����c�[��) ���g���āA�w�肳�ꂽ�t�@�C���̃f�W�^�������̃^�C���X�^���v��
			������Ƃ��Ď擾���܂��B
            �R�}���h���C���� 'signtool verify /pa /v <filename(s)>' �ł��B

        .PARAMETER FilePath
            �^�C���X�^���v���擾����t�@�C���̃p�X���w�肵�܂��B

        .PARAMETER BinPath
            SignTool.exe �t�@�C���ւ̃p�X���w�肵�܂��B
            ���̃p�����[�^�[�́A���̂܂� Invoke-SignTool �ɓn����܂��B
			SignTool.exe ��������Ȃ������ꍇ�̓G���[�ɂȂ�܂��B

        .INPUTS
            System.String
            �p�C�v���g�p���āAFilePath �p�����[�^�[�� Get-AuthenticodeTimeStampString �R�}���h���b�g��
			�n�����Ƃ��ł��܂��B

        .OUTPUTS
            System.String
            �f�W�^�������̃^�C���X�^���v�𕶎���Ƃ��Ď擾���܂��B

        .NOTES
            ���̃R�}���h�����s���� PC �ɁA���炩���� SignTool.exe ���C���X�g�[������Ă���K�v������܂��B
            SignTool.exe �� Windows Software Development Kit (Windows SDK) �Ɋ܂܂�Ă��܂��B

        .EXAMPLE
            Get-AuthenticodeTimeStampString -FilePath 'D:\Setup.exe'
            'D:\Setup.exe' �̃f�W�^�������̃^�C���X�^���v���擾���܂��B

        .EXAMPLE
            @('D:\Setup.exe', 'E:\Setup.exe') | Get-AuthenticodeTimeStampString
            'D:\Setup.exe' ����� 'E:\Setup.exe' �̃f�W�^�������̃^�C���X�^���v���擾���܂��B
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[string[]]$FilePath,

        [Parameter()]
		[string]$BinPath
    )


    # Pre-Processing Tasks
    Begin {

		# for $FilePath
        [string[]]$paths = @()
    }


    # Input Processing Tasks
    Process {

		# for $FilePath
        $FilePath | ? { Test-Path -Path $_ -PathType Leaf } | % { $_ | Resolve-Path } | % { $paths += $_ }
    }


    # Post-Processing Tasks
    End {

        # Invoke 'SignTool.exe' Process
		if ([string]::IsNullOrEmpty($BinPath)) {
			$output = Invoke-SignTool -Command verify -Options '/pa','/v' -FilePath $paths -PassThru
		}
		else {
			$output = Invoke-SignTool -Command verify -Options '/pa','/v' -FilePath $paths -BinPath $BinPath -PassThru
		}

        # Validation (for Debug)
        if ($output -eq $null) { throw (New-Object -TypeName System.Management.Automation.ApplicationFailedException) }

        # Verbose Output
        $output | Write-Verbose


		# 'Select-String'
        [string[]]$result = @()
        $output | Select-String -Pattern ($pattern = 'The signature is timestamped: ') | % { $result += ([string]$_).Substring($pattern.Length) }

        # Validation (for Debug)
        $result | % {
            if ([string]::IsNullOrEmpty($_)) { throw (New-Object -TypeName System.Management.Automation.JobFailedException) }
        }


		# RETURN
        return $result
    }
}

####################################################################################################
Function New-CatalogFile
{
    <#
        .SYNOPSIS
            �h���C�o�[ �p�b�P�[�W�p�̃J�^���O �t�@�C�����쐬���܂��B

        .DESCRIPTION
            Inf2Cat.exe ���g���āA�w�肳�ꂽ�h���C�o�[ �p�b�P�[�W�p�̃J�^���O �t�@�C�����쐬���܂��B

        .PARAMETER PackagePath
            �J�^���O �t�@�C�����쐬����h���C�o�[ �p�b�P�[�W�� INF �t�@�C�����i�[����Ă���
			�f�B���N�g���̃p�X���w�肵�܂��B

        .PARAMETER WindowsVersionList
            Inf2Cat.exe �� /os: �X�C�b�`�ƂƂ��ɓn�� WindowsVersionList �p�����[�^�[���w�肵�܂��B

        .PARAMETER NoCatalogFiles
            Inf2Cat.exe �� /nocat �X�C�b�`���w�肵�܂��B

        .PARAMETER PassThru
            �W���o�̓X�g���[���ւ̏o�͌��ʂ�Ԃ��܂��B
			����ł� Inf2Cat.exe �̏I���R�[�h��Ԃ��܂��B

        .PARAMETER BinPath
            Inf2Cat.exe �t�@�C���ւ̃p�X���w�肵�܂��B
			�w�肳�ꂽ�p�X�� Inf2Cat.exe ��������Ȃ������ꍇ�̓G���[�ɂȂ�܂��B
            ���̃p�����[�^�[���ȗ����ꂽ�ꍇ�� WDK for Windows 10 �̃f�t�H���g�̃C���X�g�[�� �p�X��
			�������܂��BWDK for Windows 10 �� Inf2Cat.exe (64 �r�b�g OS �̏ꍇ�� 
			"C:\Program Files (x86)\Windows Kits\10\bin\x86\Inf2Cat.exe") ���D��I�Ɍ�������A
			���ɁA���̑��̃o�[�W������ WDK �� Inf2Cat.exe ���K�p����܂��B
			������ WDK ���C���X�g�[������Ă�������ŁA����̃o�[�W������ Inf2Cat.exe ��
			���s���������ꍇ�́A���s�������� Inf2Cat.exe �̃p�X���w�肵�Ă��������B

        .INPUTS
            System.String
            �p�C�v���g�p���āAPackagePath �p�����[�^�[�� New-CatalogFile �R�}���h���b�g��
			�n�����Ƃ��ł��܂��B

        .OUTPUTS
            System.Int32, System.String
            Inf2Cat.exe �̏I���R�[�h��Ԃ��܂��B
            PassThru �I�v�V�������w�肳�ꂽ�Ƃ��́A�W���o�̓X�g���[���ւ̏o�͌��ʂ�Ԃ��܂��B

        .NOTES
            ���̃R�}���h�����s���� PC �ɁA���炩���� Inf2Cat.exe ���C���X�g�[������Ă���K�v��
			����܂��BInf2Cat.exe �� Windows Driver Kit (WDK) �Ɋ܂܂�Ă��܂��B

            ����̐ݒ�ł́AInf2Cat.exe �̕W���o�̓X�g���[���ւ̏o�͌��ʂ͌x�����b�Z�[�W �X�g���[��
			�փ��_�C���N�g����܂��B���̏o�͂�}�������ꍇ�́A�x�����b�Z�[�W �X�g���[���ւ̏o�͂� 
			$null �փ��_�C���N�g (3> $null) ���Ă��������B

		.EXAMPLE
            New-CatalogFile -PackagePath 'D:\Drivers\x86' -WindowsVersionList 'Vista_X86,7_X86,8_X86,6_3_X86,10_X86,Server2008_X86'
            �h���C�o�[ �p�b�P�[�W 'D:\Drivers\x86' �ɑ΂��Ė������̃J�^���O �t�@�C�����쐬���܂��B

        .EXAMPLE
            New-CatalogFile -PackagePath 'D:\Drivers\x64' -WindowsVersionList 'Vista_X64,7_X64,8_X64,6_3_X64,10_X64,Server2008_X64,Server2008R2_X64,Server8_X64,Server6_3_X64,Server10_X64'
            �h���C�o�[ �p�b�P�[�W 'D:\Drivers\x64' �ɑ΂��Ė������̃J�^���O �t�@�C�����쐬���܂��B

        .LINK
            Inf2Cat (Windows Drivers)
            https://msdn.microsoft.com/en-us/library/windows/hardware/ff547089.aspx
    #>


    [CmdletBinding(SupportsShouldProcess = $true)]
    Param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateScript({ Test-Path -Path $_ -PathType Container })]
        [string]$PackagePath,

        [Parameter(Mandatory = $true, Position = 1)]
		[string]$WindowsVersionList,

        [Parameter()]
		[switch]$NoCatalogFiles,

        [Parameter()]
		[switch]$PassThru,

        [Parameter()]
        [ValidateScript({ ($_ | Test-Path -PathType Leaf) -and (($_ | Split-Path -Leaf).ToUpper() -eq 'INF2CAT.EXE') })]
        [string]$BinPath
    )


    Process {

		# Set Default $BinPath
		if ([string]::IsNullOrEmpty($BinPath)) {

			$bin_target = 'C:\Program Files*\Windows Kits\*\bin\x??\Inf2Cat.exe' | Resolve-Path

			# Validation
			if ($bin_target.Count -lt 1) {

				# System.IO.FileNotFoundException
				Write-Error -Exception (New-Object -TypeName System.IO.FileNotFoundException -ArgumentList "'Inf2Cat.exe' is not found.")
			}

			# Verbose Output
			"The following path(s) of 'Inf2Cat.exe' is found." | Write-Verbose
			$bin_target | % { $_.Path | Write-Verbose }


			# Search $BinPath of 'SignTool.exe'
			for ($i = 0; $i -lt $bin_target.Count; $i++) {

				if ($bin_target[$i].Path -match '10\\bin\\x86') { $BinPath = $bin_target[$i].Path; break }
				elseif ($bin_target[$i].Path -match 'bin\\x86') { $BinPath = $bin_target[$i].Path; break }
			}
			if ([string]::IsNullOrEmpty($BinPath)) { $BinPath = $bin_target[0].Path }

			# Verbose Output
			"'$BinPath' is selected." | Write-Verbose
		}


        # Construct arguments for 'Inf2Cat.exe'
        [string[]]$arguments = @()
        $arguments += "/driver:`"$PackagePath`""
        $arguments += "/os:$WindowsVersionList"
        if ($NoCatalogFiles) { $arguments += '/nocat' }
        if ($VerbosePreference -ne 'SilentlyContinue') { $arguments += '/verbose' }


		# Construct Command Line for Should Process Message
		$equivalent_command_line = ('"' + $BinPath + '"')
		$arguments | % { $equivalent_command_line += (' ' + $_) }

		# Should Process
		if ($PSCmdlet.ShouldProcess($equivalent_command_line, "�R�}���h���C���ɑ�������v���Z�X")) {

			# Invoke 'Inf2Cat.exe' Process
			if ($PassThru) {
				Invoke-Process -FilePath $BinPath -ArgumentList $arguments -PassThru 4> $null
			}
			else {
				Invoke-Process -FilePath $BinPath -ArgumentList $arguments -RedirectStandardOutputToWarning 4> $null
			}
		}
    }
}

####################################################################################################
Function New-ISOImageFile
{
    <#
        .SYNOPSIS
            Rock Ridge �����t���n�C�u���b�h ISO9660 / JOLIET / HFS �t�@�C���V�X�e���C���[�W��
			�쐬���܂��B

        .DESCRIPTION
            Cygwin ����� genisoimage.exe ���g���āAISO �C���[�W �t�@�C�����쐬���܂��B

        .PARAMETER Path
            ISO9660 �t�@�C���V�X�e���ɃR�s�[���郋�[�g�f�B���N�g���̃p�X���w�肵�܂��B
            genisoimage.exe �� 'pathspec' �p�����[�^�[�ɑ������܂��B

        .PARAMETER DestinationPath
            �쐬���� ISO �C���[�W �t�@�C����ۑ�����p�X���w�肵�܂��B
            �w�肵���p�X�����݂��Ȃ��ꍇ�́A�G���[�ɂȂ�܂��B
			����̐ݒ�́A�J�����g�f�B���N�g���ł��B

        .PARAMETER FileName
            �������܂�� ISO9660 �t�@�C���V�X�e���C���[�W�̃t�@�C�������w�肵�܂��B
            ����ł́APath �p�����[�^�[�̒l�ɁA�g���q '.iso' ��t�������t�@�C�������ݒ肳��܂��B

        .PARAMETER Options
            genisoimage.exe �ɓn���I�v�V���� �p�����[�^�[���w�肵�܂��B
            �����Ŏw��ł���I�v�V�����̏ڂ��������́Agenisoimage ���邢�� mkisofs �R�}���h��
			�w���v���Q�Ƃ��Ă��������B

        .PARAMETER PassThru
            genisoimage.exe �̌x�����b�Z�[�W �X�g���[���ւ̏o�͌��ʂ��A�W���o�̓X�g���[����
			���_�C���N�g���܂��B����ł� genisoimage.exe �̏I���R�[�h��Ԃ��܂��B

        .PARAMETER Force
            �o�͐�̃p�X�Ɋ��Ƀt�@�C�������݂���ꍇ�ɁA���̃t�@�C�����㏑�����܂��B
            �܂��́A�o�͐�̃p�X�Ɋ��Ƀf�B���N�g�������݂���ꍇ�ɁA���̃f�B���N�g�����폜���Ă���A
			�o�̓t�@�C�����쐬���܂��B����̐ݒ�ł́A�o�͐�̃p�X�Ɋ��Ƀt�@�C���܂��̓f�B���N�g����
			���݂���ꍇ�̓G���[�ɂȂ�܂��B

        .PARAMETER BinPath
            genisoimage.exe �t�@�C���ւ̃p�X���w�肵�܂��B
			�w�肳�ꂽ�p�X�� genisoimage.exe ��������Ȃ������ꍇ�̓G���[�ɂȂ�܂��B
            ���̃p�����[�^�[���ȗ����ꂽ�ꍇ�� 32�r�b�g �o�[�W������ Cygwin �̃f�t�H���g��
			�C���X�g�[�� �p�X ("C:\Cygwin\bin\genisoimage.exe") ��D��I�Ɍ�������A���ɁA
			64 �r�b�g �o�[�W������ Cygwin �̃C���X�g�[�� �p�X ("C:\Cygwin64\bin\genisoimage.exe") ��
			�������܂��B

        .INPUTS
            System.String
            �p�C�v���g�p���āAPath �p�����[�^�[�� New-ISOImageFile �R�}���h���b�g��
			�n�����Ƃ��ł��܂��B

        .OUTPUTS
            System.Int32, System.String
            genisoimage.exe �̏I���R�[�h��Ԃ��܂��B
            PassThru �I�v�V�������w�肳�ꂽ�Ƃ��́A�W���o�̓X�g���[���ւ̏o�͌��ʂ�Ԃ��܂��B

        .NOTES
            ���̃R�}���h�����s���� PC �ɁA���炩���� Cygwin ����� genisoimage.exe ��
			�C���X�g�[������Ă���K�v������܂��B

            ����̐ݒ�ł́Agenisoimage.exe �̕W���o�̓X�g���[���ւ̏o�͌��ʂ�
			�W���G���[�X�g���[���փ��_�C���N�g����܂��B���̏o�͂�}�������ꍇ�́A
			�W���G���[�X�g���[���ւ̏o�͂� $null �փ��_�C���N�g (3> $null) ���Ă��������B

        .EXAMPLE
            New-ISOImageFile -Path C:\Input -DestinationPath C:\Release -FileName 'hoge.iso'
            'C:\Input' �����[�g �f�B���N�g���Ƃ��� ISO �C���[�W �t�@�C�� 'hoge.iso' ���A
			�t�H���_�[ 'C:\Release' �ɍ쐬���܂��B

        .EXAMPLE
            New-ISOImageFile -Path C:\Input -DestinationPath C:\Release -FileName 'hoge.iso' -Options @(
				'-input-charset utf-8'
				'-output-charset utf-8'
				'-rational-rock'
				'-joliet'
				'-joliet-long'
				'-jcharset utf-8'
				'-pad'
			)

        .LINK
            Cygwin
            http://www.cygwin.com/
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    Param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateScript({ Test-Path -Path $_ -PathType Container })]
        [string]$Path,

        [Parameter(Position = 1)]
        [ValidateScript({ Test-Path -Path $_ -PathType Container })]
        [string]$DestinationPath = (Get-Location).Path,

        [Parameter(Position = 2)]
		[string]$FileName = (($Path | Split-Path -Leaf) + '.iso'),

        [Parameter()]
		[string[]]$Options,

        [Parameter()]
		[switch]$PassThru,

        [Parameter()]
		[switch]$Force,

        [Parameter()]
        [ValidateScript({ ($_ | Test-Path -PathType Leaf) -and (($_ | Split-Path -Leaf).ToUpper() -eq 'GENISOIMAGE.EXE') })]
        [string]$BinPath
    )


    # Input Processing Tasks
    Process {

		# Set Default $BinPath
		if ([string]::IsNullOrEmpty($BinPath)) {

			if (-not ($BinPath = 'C:\Cygwin\bin\genisoimage.exe') | Test-Path) {
				if (-not ($BinPath = 'C:\Cygwin64\bin\genisoimage.exe') | Test-Path) {

					# System.IO.FileNotFoundException
					Write-Error -Exception (New-Object -TypeName System.IO.FileNotFoundException -ArgumentList "'genisoimage.exe' is not found.")
				}
			}

			# Verbose Output
			"'$BinPath' is selected." | Write-Verbose
		}


        # Set and Validate $output_path
        if (($output_path = $DestinationPath | Join-Path -ChildPath $FileName) | Test-Path ) {
            if ($Force) { Remove-Item $output_path -Force -Recurse }
            else { throw New-Object System.IO.IOException }
        }


        # Construct ArgumentList
        [string[]]$arguments = @()
        $Options | ? { -not [string]::IsNullOrEmpty($_) } | % { $arguments += $_ }
        $arguments += ('-output "' + $output_path + '"')
        $arguments += ('"' + $Path + '"')


		# Construct Command Line for Should Process Message
		$equivalent_command_line = ('"' + $BinPath + '"')
		$arguments | % { $equivalent_command_line += (' ' + $_) }

		# Should Process
		if ($PSCmdlet.ShouldProcess($equivalent_command_line, "�R�}���h���C���ɑ�������v���Z�X")) {

			# Invoke 'genisoimage.exe' Process
			if ($PassThru)
			{
				Invoke-Process -FilePath $BinPath -ArgumentList $arguments -PassThru -RedirectStandardErrorToOutput 4> $null
			}
			else
			{
				Invoke-Process -FilePath $BinPath -ArgumentList $arguments 4> $null
			}
		}
    }
}

####################################################################################################
Export-ModuleMember -Function *
