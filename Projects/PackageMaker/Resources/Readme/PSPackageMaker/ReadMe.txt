BUILDLet PackageMaker PowerShell Module
=======================================

Version 2.x.0.0
---------------

概要
----

BUILDLet PackageMaker PowerShell Module は、ソフトウェアパッケージとその ISO イメージファイルを
作成するためのコマンドを含む PowerShell モジュールです。


インストール方法
----------------

PSPackageMakerSetup.exe を実行してください。


アンインストール方法
--------------------

コントロールパネルから次のプログラムを選択してアンインストールを実行してください。

  1. BUILDLet Utilities PowerShell Module


動作環境
--------

次のソフトウェアがインストールされている必要があります。

  1. Windows Management Framework 4.0 (Windows PowerShell 4.0)
  2. Microsoft .NET Framework 4.5
  3. BUILDLet Utilities PowerShell Module Version 2.0.1.0


全ての機能を使用するためには、次のソフトウェアがインストールされている必要があります。
([] 内に記載されているプログラムが必要です。)

  1. Windows Software Development Kit (SDK) for Windows 10  [SignTool.exe]
  2. Windows Driver Kit (WDK) for Windows 10  [Inf2Cat.exe]
  3. Cygwin  [genisoimage.exe]


Windows 10 Pro (1607) x64 および Windows 7 Ultimate Service Pack 1x64 で動作を確認しています。


使用準備
--------

次の PowerShell コマンドを実行してモジュールをインポートしてください。

    Import-Module BUILDLet.PackageMaker.PowerShell

BUILDLet.PackageMaker.PowerShell は、
32ビットOSの場合は %ProgramFiles%\WindowsPowerShell\Modules にインストールされます。
64ビットOSの場合は %ProgramFiles%\WindowsPowerShell\Modules および 
%ProgramFiles(x86)%\WindowsPowerShell\Modules の両方にインストールされます。  
これらのパスは $env:PSModulePath に含まれているので、このコマンドを入力すれば、
モジュールをインポートすることができます。

インポートできないときは、次のコマンドを実行して BUILDLet.PackageMaker.PowerShell が
表示されることを確認してください。

    Get-Module -ListAvailable


使用方法
--------

BUILDLet.PackageMaker.PowerShell をインポートすると、次のコマンド (Function) 
がインポートされます。詳細は各コマンドのヘルプを参照してください。

  1. Get-AuthenticodeTimeStamp (Function)  
     デジタル署名のタイムスタンプを取得します。

  2. Invoke-SignTool (Function)  
     SignTool.exe  (署名ツール) を実行します。

  3. New-CatalogFile (Function)  
     ドライバー パッケージ用のカタログ ファイルを作成します。

  4. New-ISOImageFile (Function)  
     Rock Ridge 属性付きハイブリッド ISO9660 / JOLIET / HFS ファイルシステムイメージを作成します。


ライセンス
----------

このソフトウェアは MIT ライセンスの下で配布されます。
License.txt を参照してください。


変更履歴
--------

* Version 2.x.0.0 (2017/00/00)  
  未定

* Version 2.0.1.0 (2017/03/18)  
  全ての Function を刷新しました。
