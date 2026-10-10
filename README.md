# Etupirka

## 📝 本フォークについて / About This Fork / 关于本分支

本リポジトリは **Etupirka の多言語移植版（フォーク）** です。  
オリジナルの日本語インターフェースを**簡体字中国語**と**英語**に翻訳し、多言語対応を**実装を進めています**。
また、列ヘッダーに関するいくつかのバグを修正しました。

This repository is a **multilingual port (fork) of Etupirka**.  
The original Japanese interface **is being translated** into **Simplified Chinese** and **English** to support multiple languages. 
Also fixed several bugs related to column headers.

本仓库是 **Etupirka 的多语言移植版（Fork）**。  
将原始日文界面翻译为**简体中文**和**英文**的工作，以实现多语言支持。
并修复了若干列头相关的 bug。

| | | |
| :--- | :--- | :--- |
| **オリジナル / Original / 原作** | [Arisin/Etupirka](https://github.com/Arisin/Etupirka) | MIT License |
| **翻訳作業 / Translation / 翻译内容** | 日本語 → 简体中文 / English | |
| **翻訳者 / Translator / 译者** | [zly3070](https://github.com/zly3070) | |
| **年 / Year / 年份** | 2026 | |
| **ステータス / Status / 状态** | 作業中 / Work in progress / 开发中 | |

## 概要
エロゲのプレイ時間を統計するツールです。


![](http://i.imgur.com/upkcS2e.png)

## ダウンロード

[Github](https://github.com/Aixile/Etupirka/releases "https://github.com/Aixile/Etupirka/releases")

#### 0.6.0
- Remove the dependency on the server
- Support using Google Cache for online database

#### 0.5.8
- Stop Etupirka from burning the CPU
- Fix online game data parsing

#### 0.5.7
- 不具合修正: クラッシュを修正

#### 0.5.6
- 不具合修正: ソフト電池DRMのサポートを修正
- 機能追加: 編集距離でゲーム名を予測する機能を追加

## 使い方

### エントリーを追加する
- まずゲームを起動します
- ファイル→プロセスから追加

![](http://i.imgur.com/sSZoDEm.png)

- ゲームプロセスを選択する

![](http://i.imgur.com/LCg9JbT.png)

- エントリーを選択して→設定→ゲーム設定

![](http://i.imgur.com/lWmqFa0.png)

- ErogameScapeのゲームIDを入力してゲーム情報を自動更新（例えば [http://erogamescape.dyndns.org/~ap2/ero/toukei_kaiseki/game.php?game=4529](http://erogamescape.dyndns.org/~ap2/ero/toukei_kaiseki/game.php?game=4529) の場合、ゲームIDは4529）


![](http://i.imgur.com/EgwoVnz.png) ![](http://i.imgur.com/uz8PaPR.png)

- これで自動的にゲーム状態を監視するようになります。**ウィンドウがアクティブではない時はカウントしません**


![](http://i.imgur.com/8UQCxx9.png)

### プレイタイム統計を見る
週間や月別などのプレイ時間やゲームごとのプレイ時間を確認することもできます。


![](http://i.imgur.com/XqKcN4n.png) ![](http://i.imgur.com/1A5EK0D.png)


ダブルクリックすると詳しい情報が表示されます。


![](http://i.imgur.com/GQlg57S.png)


### オフラインデータベースを更新する
デフォルトではエロスケをキャッシュしたオフラインデータベースから情報を取得するため、**最新のエロスケ情報を取得するには手動でオフラインデータベースを更新してください**（おそらく月に一回で十分）




## 動作環境
**Windows Vista/7/8/10**（XPは対象外）

**.NET Framework 4.6が必要です**

## Licence
This program is under the MIT license.
