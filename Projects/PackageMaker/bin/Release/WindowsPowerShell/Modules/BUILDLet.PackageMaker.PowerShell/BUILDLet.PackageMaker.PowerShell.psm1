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
            SignTool.exe  (署名ツール) を実行します。

        .DESCRIPTION
            SignTool.exe  (署名ツール) を実行します。
            署名ツールはコマンド ライン ツールで、ファイルにデジタル署名を添付し、
			ファイルの署名を検証し、ファイルにタイム スタンプを付けます。

        .PARAMETER Command
            4 つのコマンド (catdb、sign、timestamp、または verify) のうちのいずれか 1 つを指定します。  

        .PARAMETER Options
            SignTool.exe へのオプションを指定します。

        .PARAMETER FilePath
            署名するファイルへのパスを指定します。

        .PARAMETER RetryCount
            SignTool.exe の終了コードが 0 以外だった場合にリトライする回数を指定します。
            既定の設定は 0 回です。

        .PARAMETER RetryInterval
            リトライする間隔を秒数で指定します。
			既定の設定は 0 秒です。

		.PARAMETER Pack
			FilePath パラメーターに複数のファイルが指定されている場合、Pack パラメーターで
			指定されたファイル数のファイルセットごとに SignTool.exe を複数回実行します。
			Pack パラメーターに 0 を指定すると、全てのファイルを対象に SignTool.exe を 1 回実行します。
			既定では 0 です。

        .PARAMETER PassThru
            標準出力ストリームへの出力結果を返します。
			既定では SignTool.exe の終了コードを返します。

        .PARAMETER BinPath
            SignTool.exe ファイルへのパスを指定します。
			指定されたパスに SignTool.exe が見つからなかった場合はエラーになります。
            このパラメーターが省略された場合は Windows SDK のデフォルトのインストール パスを検索します。
			Windows 10 SDK の 32 ビットバージョンの SignTool.exe (64 ビット OS の場合は 
			"C:\Program Files (x86)\Windows Kits\10\bin\x86\signtool.exe") が優先的に検索され、
			次に、その他のバージョンの Windows SDK の 32 ビットバージョンの SignTool.exe が優先されます。
			複数の Windows SDK がインストールされている環境等で、特定のバージョンの SignTool.exe を
			実行させたい場合は、実行させたい SignTool.exe のパスを指定してください。

        .INPUTS 
            System.String
            パイプを使用して、FilePath パラメーターを Invoke-SignTool コマンドレットに渡すことができます。

        .OUTPUTS
            System.Int32, System.String
            SignTool.exe の終了コードを返します。
            PassThru オプションが指定されたときは、標準出力ストリームへの出力結果を返します。

        .NOTES
            このコマンドを実行する PC に、あらかじめ SignTool.exe がインストールされている必要があります。
            SignTool.exe は Windows Software Development Kit (Windows SDK) に含まれています。

            既定の設定では、SignTool.exe の標準出力ストリームへの出力結果は警告メッセージ ストリームへリダイレクトされます。
            この出力を抑えたい場合は、警告メッセージ ストリームへの出力を $null へリダイレクト (3> $null) してください。

        .EXAMPLE
            Invoke-SignTool -Command 'sign' -Options @('/f C:\PFX\sign.pfx', '/p 12345678', '/t http://timestamp.verisign.com/scripts/timstamp.dll', '/v') -FilePath @('D:\Setup.exe', 'E:\Setup.exe') -PassThru -RetryCount 10 -RetryInterval 3
            証明書 C:\PFX\sign.pfx で、'D:\Setup.exe' および 'E:\Setup.exe' にコード署名をします。
			パスワードには 12345678 を指定しています。
			タイムスタンプサーバーに http://timestamp.verisign.com/scripts/timstamp.dll を指定しています。
			SignTool.exe の標準出力ストリームへの出力結果は、コンソールに出力されます。
			署名に失敗した場合は 3 秒間隔で10 回までリトライします。

        .LINK
            SignTool (Windows Drivers)
            https://msdn.microsoft.com/en-us/library/windows/hardware/ff551778.aspx

            SignTool.exe (署名ツール)
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
			if ($PSCmdlet.ShouldProcess($equivalent_command_line, "コマンドラインに相当するプロセス")) {

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
            デジタル署名のタイムスタンプを取得します。

        .DESCRIPTION
            SignTool.exe (署名ツール) を使って、指定されたファイルのデジタル署名のタイムスタンプを
			文字列として取得します。
            コマンドラインは 'signtool verify /pa /v <filename(s)>' です。

        .PARAMETER FilePath
            タイムスタンプを取得するファイルのパスを指定します。

        .PARAMETER BinPath
            SignTool.exe ファイルへのパスを指定します。
            このパラメーターは、そのまま Invoke-SignTool に渡されます。
			SignTool.exe が見つからなかった場合はエラーになります。

        .INPUTS
            System.String
            パイプを使用して、FilePath パラメーターを Get-AuthenticodeTimeStampString コマンドレットに
			渡すことができます。

        .OUTPUTS
            System.String
            デジタル署名のタイムスタンプを文字列として取得します。

        .NOTES
            このコマンドを実行する PC に、あらかじめ SignTool.exe がインストールされている必要があります。
            SignTool.exe は Windows Software Development Kit (Windows SDK) に含まれています。

        .EXAMPLE
            Get-AuthenticodeTimeStampString -FilePath 'D:\Setup.exe'
            'D:\Setup.exe' のデジタル署名のタイムスタンプを取得します。

        .EXAMPLE
            @('D:\Setup.exe', 'E:\Setup.exe') | Get-AuthenticodeTimeStampString
            'D:\Setup.exe' および 'E:\Setup.exe' のデジタル署名のタイムスタンプを取得します。
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
            ドライバー パッケージ用のカタログ ファイルを作成します。

        .DESCRIPTION
            Inf2Cat.exe を使って、指定されたドライバー パッケージ用のカタログ ファイルを作成します。

        .PARAMETER PackagePath
            カタログ ファイルを作成するドライバー パッケージの INF ファイルが格納されている
			ディレクトリのパスを指定します。

        .PARAMETER WindowsVersionList
            Inf2Cat.exe に /os: スイッチとともに渡す WindowsVersionList パラメーターを指定します。

        .PARAMETER NoCatalogFiles
            Inf2Cat.exe の /nocat スイッチを指定します。

        .PARAMETER PassThru
            標準出力ストリームへの出力結果を返します。
			既定では Inf2Cat.exe の終了コードを返します。

        .PARAMETER BinPath
            Inf2Cat.exe ファイルへのパスを指定します。
			指定されたパスに Inf2Cat.exe が見つからなかった場合はエラーになります。
            このパラメーターが省略された場合は WDK for Windows 10 のデフォルトのインストール パスを
			検索します。WDK for Windows 10 の Inf2Cat.exe (64 ビット OS の場合は 
			"C:\Program Files (x86)\Windows Kits\10\bin\x86\Inf2Cat.exe") が優先的に検索され、
			次に、その他のバージョンの WDK の Inf2Cat.exe が適用されます。
			複数の WDK がインストールされている環境等で、特定のバージョンの Inf2Cat.exe を
			実行させたい場合は、実行させたい Inf2Cat.exe のパスを指定してください。

        .INPUTS
            System.String
            パイプを使用して、PackagePath パラメーターを New-CatalogFile コマンドレットに
			渡すことができます。

        .OUTPUTS
            System.Int32, System.String
            Inf2Cat.exe の終了コードを返します。
            PassThru オプションが指定されたときは、標準出力ストリームへの出力結果を返します。

        .NOTES
            このコマンドを実行する PC に、あらかじめ Inf2Cat.exe がインストールされている必要が
			あります。Inf2Cat.exe は Windows Driver Kit (WDK) に含まれています。

            既定の設定では、Inf2Cat.exe の標準出力ストリームへの出力結果は警告メッセージ ストリーム
			へリダイレクトされます。この出力を抑えたい場合は、警告メッセージ ストリームへの出力を 
			$null へリダイレクト (3> $null) してください。

		.EXAMPLE
            New-CatalogFile -PackagePath 'D:\Drivers\x86' -WindowsVersionList 'Vista_X86,7_X86,8_X86,6_3_X86,10_X86,Server2008_X86'
            ドライバー パッケージ 'D:\Drivers\x86' に対して未署名のカタログ ファイルを作成します。

        .EXAMPLE
            New-CatalogFile -PackagePath 'D:\Drivers\x64' -WindowsVersionList 'Vista_X64,7_X64,8_X64,6_3_X64,10_X64,Server2008_X64,Server2008R2_X64,Server8_X64,Server6_3_X64,Server10_X64'
            ドライバー パッケージ 'D:\Drivers\x64' に対して未署名のカタログ ファイルを作成します。

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
		if ($PSCmdlet.ShouldProcess($equivalent_command_line, "コマンドラインに相当するプロセス")) {

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
            Rock Ridge 属性付きハイブリッド ISO9660 / JOLIET / HFS ファイルシステムイメージを
			作成します。

        .DESCRIPTION
            Cygwin および genisoimage.exe を使って、ISO イメージ ファイルを作成します。

        .PARAMETER Path
            ISO9660 ファイルシステムにコピーするルートディレクトリのパスを指定します。
            genisoimage.exe の 'pathspec' パラメーターに相当します。

        .PARAMETER DestinationPath
            作成した ISO イメージ ファイルを保存するパスを指定します。
            指定したパスが存在しない場合は、エラーになります。
			既定の設定は、カレントディレクトリです。

        .PARAMETER FileName
            書き込まれる ISO9660 ファイルシステムイメージのファイル名を指定します。
            既定では、Path パラメーターの値に、拡張子 '.iso' を付加したファイル名が設定されます。

        .PARAMETER Options
            genisoimage.exe に渡すオプション パラメーターを指定します。
            ここで指定できるオプションの詳しい説明は、genisoimage あるいは mkisofs コマンドの
			ヘルプを参照してください。

        .PARAMETER PassThru
            genisoimage.exe の警告メッセージ ストリームへの出力結果を、標準出力ストリームへ
			リダイレクトします。既定では genisoimage.exe の終了コードを返します。

        .PARAMETER Force
            出力先のパスに既にファイルが存在する場合に、そのファイルを上書きします。
            または、出力先のパスに既にディレクトリが存在する場合に、そのディレクトリを削除してから、
			出力ファイルを作成します。既定の設定では、出力先のパスに既にファイルまたはディレクトリが
			存在する場合はエラーになります。

        .PARAMETER BinPath
            genisoimage.exe ファイルへのパスを指定します。
			指定されたパスに genisoimage.exe が見つからなかった場合はエラーになります。
            このパラメーターが省略された場合は 32ビット バージョンの Cygwin のデフォルトの
			インストール パス ("C:\Cygwin\bin\genisoimage.exe") を優先的に検索され、次に、
			64 ビット バージョンの Cygwin のインストール パス ("C:\Cygwin64\bin\genisoimage.exe") を
			検索します。

        .INPUTS
            System.String
            パイプを使用して、Path パラメーターを New-ISOImageFile コマンドレットに
			渡すことができます。

        .OUTPUTS
            System.Int32, System.String
            genisoimage.exe の終了コードを返します。
            PassThru オプションが指定されたときは、標準出力ストリームへの出力結果を返します。

        .NOTES
            このコマンドを実行する PC に、あらかじめ Cygwin および genisoimage.exe が
			インストールされている必要があります。

            既定の設定では、genisoimage.exe の標準出力ストリームへの出力結果は
			標準エラーストリームへリダイレクトされます。この出力を抑えたい場合は、
			標準エラーストリームへの出力を $null へリダイレクト (3> $null) してください。

        .EXAMPLE
            New-ISOImageFile -Path C:\Input -DestinationPath C:\Release -FileName 'hoge.iso'
            'C:\Input' をルート ディレクトリとした ISO イメージ ファイル 'hoge.iso' を、
			フォルダー 'C:\Release' に作成します。

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
		if ($PSCmdlet.ShouldProcess($equivalent_command_line, "コマンドラインに相当するプロセス")) {

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
