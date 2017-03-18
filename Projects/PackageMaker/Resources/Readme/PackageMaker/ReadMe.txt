BUILDLet PackageMaker Toolkit
=============================

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
インストールウィザードの終了画面で Launch ボタンをクリックすると、この Readme が表示されます。


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


Windows 10 Pro (1607) x64 および Windows 7 Ultimate Service Pack 1x64 で動作を確認しています。


使用準備
--------

特に必要ありません。


使用方法
--------

BUILDLet Utilities PowerShell Module (BUILDLet.Utilities.PowerShell) および 
BUILDLet PackageMaker PowerShell Module (BUILDLet.PackageMaker.PowerShell) に含まれる
コマンド (Cmdlet および Function) については、各コマンドのヘルプを参照してください。  
一部のコマンドは、コマンドのみを入力するとコマンドの概要が表示されます。


サンプルについて
----------------

PowerShell ビルド スクリプトを含むソフトウェアパッケージ作成のためのサンプル データは、既定では、
32ビットOSの場合は %ProgramFiles%\BUILDLet PackageMaker Toolkit にインストールされます。  
64ビットOSの場合は %ProgramFiles(x86)%\BUILDLet PackageMaker Toolkit にインストールされます。

SamplePackage.zip を任意のフォルダに解凍し、展開されたフォルダーで下記のコマンドを実行すると、
ソフトウェアパッケージのサンプル、および、その ISO イメージ ファイルを作成します。

    .\Build.ps1


ライセンス
----------

このソフトウェアは MIT ライセンスの下で配布されます。
License.txt を参照してください。


変更履歴
--------

* Version 2.0.1.0 (2017/03/18)  
  PowerShell モジュール、および、サンプル データを含む全てを刷新しました。
  Version 1.x との互換性はありません。

* Version 1.2.1.0 (2015/11/15)  
  Readme ファイルの誤記を訂正・更新。
  
* Version 1.2.0.0 (2015/11/15)  
  サンプルパッケージを刷新。  
  PackageMaker Toolkit 本体をアンインストールすると、BUILDLet PackageMaker PowerShell Module 
  (BUILDLet.PackageMaker.PowerShell) もアンインストールされるよう仕様変更。

* Version 1.1.3.0 (2015/07/20)  
  マイナーアップデート。
  インストーラーのアイコン画像の微修正。  
  Readme の誤記を訂正。 (2015/07/07)

* Version 1.1.2.0 (2015/07/04)  
  マイナーアップデート。
  BUILDLet Utility PowerShell Module の名前が BUILDLet.PowerShell.Utilities から 
  BUILDLet.Utilities .PowerShell に変更。
  
* Version 1.1.1.0 (2015/06/05)  
  マイナーアップデート。
  BUILDLet.PowerShell.Utilities モジュールのバージョン誤りを修正・改善。

* Version 1.1.0.0 (2015/06/02)  
  マイナーアップデート。
  Readme ファイルを更新。
* Version 1.0.8.0 (2015/05/29)  
  Readme ファイルを更新。

* Version 1.0.7.0 (2015/05/27)  
  初版
