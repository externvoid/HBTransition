
# 2017/03/24Fr
Subject Grasp
---
[1] 2枚目からStartすると原点から開始しない。->Start時、line, arをReset
[2] 一覧から選択したら、拡大表示 -> getScreenShot()のcallをcomment out
[3] Index out of range -> cntの初期化@Start

Additional Functions
---
[1]Slide In

# 2017/03/23Th
[1] ViewController#loadToolBar
 
UIBarButtonItemのインスタンスはプロパティである必要があるのか？
プロパティーへのアクセス箇所を調査する。だれもアクセスしていないなら、プロパティである必要無し。

ajustToolBarButtonsでenable/disableしていた。changeStateOfBarButtonsって名前が適当？

[2] polygonal-lineの描画はどうあるべきか？
安1：update毎にbitmapを作成、新規に原点からpolygonal-lineを描画 <- adopt

安2：Stopでキャンバスを保存、draw(_:)ではキャンバスを復元
