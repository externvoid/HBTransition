# 2017/03/23Th
[1] ViewController#loadToolBar
 
UIBarButtonItemのインスタンスはプロパティである必要があるのか？
プロパティーへのアクセス箇所を調査する。だれもアクセスしていないなら、プロパティである必要無し。

ajustToolBarButtonsでenable/disableしていた。changeStateOfBarButtonsって名前が適当？

[2] polygonal-lineの描画はどうあるべきか？
安1：update毎にbitmapを作成、新規に原点からpolygonal-lineを描画

安2：Stopでキャンバスを保存、draw(_:)ではキャンバスを復元
