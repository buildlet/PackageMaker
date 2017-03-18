PackageMaker Toolkit
====================

Version 2.0.1.0
---------------

概要
----
BUILDLet PackageMaker Toolkit は、ソフトウェアパッケージとその ISO イメージファイルを 
PowerShell スクリプトによって作成するためのツールキットです。  
BUILDLet PackageMaker Toolkit には、PowerShell モジュールと PowerShell ビルド スクリプト
を含むソフトウェアパッケージ作成のためのサンプル データが含まれます。

BUILDLet PackageMaker Toolkit をインストールすると、次のモジュールがインストールされます。

  1. BUILDLet PackageMaker Toolkit Version 2.0.1  
    (Sample Script Version 2.0.1.0 が含まれます。)

  2. BUILDLet PackageMaker PowerShell Module Version 2.0.1  
    (BUILDLet.PackageMaker.PowerShell Version 2.0.1.0)

  3. BUILDLet Utilities PowerShell Module Version 2.0.1  
    (BUILDLet.Utilities.PowerShell Version 2.0.1.0)


インストール方法
----------------
PackageMakerSetup.exe を実行してください。  


アンインストール方法
--------------------
コントロールパネルから次のプログラムを選択してアンインストールを実行してください。

  1. BUILDLet PackageMaker Toolkit
  2. BUILDLet Utilities PowerShell Module

PackageMaker Toolkit 本体をアンインストールすると、BUILDLet PackageMaker PowerShell 
Module (BUILDLet.PackageMaker.PowerShell) もアンインストールされます。  
BUILDLet Utilities PowerShell Module (BUILDLet.Utilities.PowerShell) はアンインストール
されないので、必要に応じて個別にアンインストールしてください。


動作環境
--------
BUILDLet.Utilities.PowerShell および BUILDLet.PackageMaker.PowerShell を実行するためには、
実行環境に次のソフトウェアがインストールされている必要があります。

  1. Windows Management Framework 4.0 (Windows PowerShell 4.0)
  2. Microsoft .NET Framework 4.5


BUILDLet.PackageMaker.PowerShell の全ての機能を使用するためには、実行環境に次のソフトウェアが
インストールされている必要があります。
([] 内に記載されているプログラムが必要です。)

  1. Windows Software Development Kit (SDK) for Windows 10  [SignTool.exe]
  2. Windows Driver Kit (WDK) for Windows 10  [Inf2Cat.exe]
  3. Cygwin  [genisoimage.exe]


### SignTool のインストールについて
SingTool は Windows Software Development Kit (SDK) for Windows 8.1 をインストールする際に、"Windows Software Development Kit"  （下図参照）を選択するとインストールされます。

![SignTool](/images/SignTool.png "SignTool")
  
### genisoimage のインストールについて
Cygwin をインストールする際に、genisoimage を選択します。（下図参照）

![genisoimage](/images/genisoimage.png "genisoimage")


Windows 10 Pro (1607) x64 および Windows 7 Ultimate Service Pack 1x64 で動作を確認しています。


使用準備
--------
下記の PowerShell コマンドを実行してモジュールをインポートしてください。

    Import-Module BUILDLet.PackageMaker.PowerShell

PowerShell モジュールは、32ビットOSの場合は %ProgramFiles%\WindowsPowerShell\Modules に保存されます。
64ビットOSの場合は %ProgramFiles%\WindowsPowerShell\Modules および %ProgramFiles(x86)%\WindowsPowerShell\Modules にインストールされます。
これらのパスは $env:PSModulePath に含まれているので、上記のコマンドを入力するだけでモジュールをインポートすることができます。  
インポートできないときは下記のコマンドを実行して BUILDLet.Utilities.PowerShell および BUILDLet.PackageMaker.PowerShell が表示されることを確認してください。

    Get-Module -ListAvailable


BUILDLet.PackageMaker.PowerShell をインポートするためには、BUILDLet.Utilities.PowerShell が事前にインポートされている必要があるため、BUILDLet.PackageMaker.PowerShell をインポートすると BUILDLet.Utilities.PowerShell も自動的にインポートされます。


使用方法
--------
BUILDLet PackageMaker Toolkit には、下記の PowerShell コマンド (Function および Cmdlet) 、変数、および、サンプルスクリプトを含むソフトウェアパッケージのサンプルが含まれます。


### コマンド (Function または Cmdlet)

BUILDLet.Utilities.PowerShell をインポートすると、以下のコマンド (Function または Cmdlet) がインポートされます。  
詳細は各コマンドのヘルプを参照してください。
( Cmdlet は、コマンドのみを入力するとコマンドの概要が表示されます。 )

#### Expand-ZipFile (Cmdlet)
  zip ファイルを解凍します。

#### New-ZipFile (Cmdlet)
  zip ファイルを作成します。

#### Get-HashValue (Cmdlet)
  指定されたハッシュ アルゴリズムを使用して、入力データのハッシュ値を計算します。

#### Get-HtmlString (Cmdlet)
  入力データから HTML 要素またはその属性の値を取得します。

#### Get-PrivateProfileString (Cmdlet)
  INI ファイル (初期化ファイル) から、指定したセクションとキーの組み合わせに対応する値を取得します。

#### Set-PrivateProfileString (Cmdlet)
  INI ファイル (初期化ファイル) の指定したセクションとキーの組み合わせに対応する値を更新または追加します。

#### Invoke-Process (Cmdlet)
  指定されたされたプロセスを開始します。

#### Send-MagicPacket (Cmdlet)
  指定された MAC アドレスのマジックパケットを送信します。

#### Get-AuthenticodeSignerName (Function)
  デジタル署名の署名者名を取得します。

#### Get-FileDescription (Function)
  ディスク上の物理ファイルの説明を取得します。

#### Get-FileVersion (Function)
  ディスク上の物理ファイルのファイルバージョンを取得します。

#### Get-FileVersionInfo (Function)
  ディスク上の物理ファイルのバージョン情報を取得します。

#### Get-ProductName (Function)
  ディスク上の物理ファイルの製品名を取得します。

#### Get-ProductVersion (Function)
  ディスク上の物理ファイルの製品バージョンを取得します。

#### New-DateString (Function)
  指定した時刻に対する日付を、指定した書式の文字列として取得します。

#### New-GUID (Function)
  GUID を生成します。

#### New-HR (Function)
  水平線を出力します。

#### Reset-Directory (Function)
  指定されたパスにディレクトリを作成します。


BUILDLet.PackageMaker.PowerShell をインポートすると、以下のコマンド (Function) がインポートされます。  
詳細は各コマンドのヘルプを参照してください。

#### Get-AuthenticodeTimeStamp (Function)
  デジタル署名のタイムスタンプを取得します。

#### Invoke-SignTool (Function)
  SignTool.exe  (署名ツール) を実行します。

#### New-CatFile (Function)
  ドライバー パッケージ用のカタログ ファイルを作成します。

#### New-IsoFile (Function)
  Rock Ridge 属性付きハイブリッド ISO9660 / JOLIET / HFS ファイルシステムイメージを作成します。




サンプルについて
----------------
PowerShell サンプルスクリプトを含むソフトウェアパッケージ作成のサンプルは、既定の設定では
32ビットOSの場合は %ProgramFiles%\BUILDLet PackageMaker Toolkit、
64ビットOSの場合は %ProgramFiles(x86)%\BUILDLet PackageMaker Toolkit にインストールされています。

SamplePackage.zip を任意のフォルダに解凍し、展開されたフォルダーで下記のコマンドを実行すると、
ソフトウェアパッケージのサンプル、および、そのISOイメージ ファイルが (再) 作成されます。

    .\Build.ps1


ライセンス
----------
このソフトウェアは MIT ライセンスの下で配布されます。  
[LICENCE](/LICENSE "LICENSE") を参照してください。


ソースコード
------------
プロジェクトをビルドするためには [WiX Toolset](http://wixtoolset.org/ "WiX Toolset") (Windows Installer XML toolset) が必要です。
また、PowerShell モジュール (BUILDLet.PackageMaker.PowerShell) の単体テストで [Pester](https://github.com/EWSoftware/SHFB "Pester") を使用しています。

BUILDLet.PowerShell.Utilities のソースコードは [buildlet/Utilities](https://github.com/buildlet/Utilities "buildlet/Utilities") からダウンロードしてください。


変更履歴
--------
### Version 1.2.1.0
**2015/11/15**  
Readme ファイルの誤記を訂正・更新。

### Version 1.2.0.0
**2015/11/15**  
サンプルパッケージを刷新。
PackageMaker Toolkit 本体をアンインストールすると、BUILDLet PackageMaker PowerShell Module 
(BUILDLet.PackageMaker.PowerShell) もアンインストールされるよう仕様変更。

### Version 1.1.2.0
**2015/07/05**  
BUILDLet.PowerShell.Utilities を BUILDLet.Utilities.PowerShell に変更。  
BUILDLet.PowerShell.PackageMaker を BUILDLet.PackageMaker.PowerShell に変更。  

### Version 1.1.1.0
**2015/06/08**  
BUILDLet.PowerShell.Utilities モジュールのバージョン誤りを修正・改善。

### Version 1.1.0.0
**2015/06/03**  
マイナーアップデート

### Version 1.0.7.0
**2015/05/29**  
1st リリース
