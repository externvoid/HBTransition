//
//  Pallet.swift
//  Pallet
//
//  Created by kunii on 2014/11/22.
//  Copyright (c) 2014年 國居貴浩. All rights reserved.
//

import UIKit

class Pallet: UIControl {

    //  選択中の色パッチを示す。
    fileprivate var selectedLayer:CALayer?  //  非公開にする。
    
    //  指定イニシャライザをオーバーライド。
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //  7つの色パッチ（CALayer）を作成し自身の子供にする。
        var r = CGRect(x: 0, y: 0, width: 44, height: 44)
        for i in 0 ..< 7 {
            let bt = CALayer()  //  CALayerに-initWithFrame:がないのでそのまま作成。
            bt.frame = r    //  作成後にframeを設定する。

            //  色相を変化させた色の設定。
            let color = UIColor(hue:CGFloat(i) / 7.0, saturation:1.0, brightness:1.0, alpha:1.0)
            bt.backgroundColor = color.cgColor

            self.layer.addSublayer(bt)

            //  次の位置を計算。
            r = r.offsetBy(dx: 0, dy: r.size.height)
        }

        //  インジケータの矩形設定。一番最後の色パッチの1つ下に位置させる。枠線の幅分広げてもおく。
        self.indicator.frame = r.insetBy(dx: -3, dy: -3)
        self.indicator.borderWidth = 3
        self.layer.addSublayer(self.indicator)
        
        //  一番最初の色パッチを選択しておく。
        self.selectedLayer = self.layer.sublayers!.first // as CALayer
        self.indicator.position = self.selectedLayer!.position
        
        //  影付けなどで装飾する。
        self.indicator.borderColor = UIColor.white.cgColor
        self.indicator.shadowOpacity = 1
        self.indicator.shadowOffset = CGSize.zero
//        self.indicator.shouldRasterize = true
    }
    
    //  NSCodingプロトコル側の特命イニシャライザをオーバーライド。
    required init(coder aDecoder: NSCoder) {
        //  現時点では致命的エラーにする。
        fatalError("init(coder:) has not been implemented")
    }

    //  引数にselectedLayerと異なるCALayerが指定されたら、selectedLayerを指定されたCALayerにしてからUIControlEvents.ValueChangedを送る。
    //  selectedLayerを変更した場合はtrueを返す。
    fileprivate func selectLayer(_ layer:CALayer?) -> Bool {
        if (layer == nil) {                  //  nilは指定できないようにする。
            return false
        }
        if (self.selectedLayer != layer) {    //  選択中の色パッチCALayerとタッチされた色パッチCALayerが異なる。
            self.selectedLayer?.opacity = 1.0  //  元に戻す。
            self.selectedLayer = layer        //  新しい色パッチCALayerを設定する。
            self.selectedLayer?.opacity = 0.5  //  ハイライトする。
            self.showIndicator()            //  新しい色パッチの位置にインジケータを表示する。
            self.sendActions(for: UIControlEvents.valueChanged)
            return true
        }
        return false
    }

    //  指追跡開始。
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let view = self.hitLayer(touch)
        if (self.selectLayer(view) == false) {
            //  selectedLayerが変更されなかった場合、opacityはこちらで設定する。
            self.selectedLayer?.opacity = 0.5
            self.showIndicator()            //  新しい色パッチの位置にインジケータを表示する。
        }
        return super.beginTracking(touch, with: event)
    }
    
    //  指追跡継続。
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let view = self.hitLayer(touch)
        self.selectLayer(view)
        return super.continueTracking(touch, with: event)
    }
    
    //  指追跡終了。
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        self.selectedLayer?.opacity = 1.0  //  元に戻す。
        return super.endTracking(touch, with: event)
    }
    
    //  指追跡キャンセル。
    override func cancelTracking(with event: UIEvent?) {
        self.selectedLayer?.opacity = 1.0  //  元に戻す。
        return super.cancelTracking(with: event)
    }
    
    //  タッチされた色パッチCALayerを調べて戻す。
    fileprivate func hitLayer(_ touch: UITouch) -> CALayer? {
        var location = touch.location(in: self)
        //  CALayerの-hitTest:に渡す座標は、親側CALayerのローカル座標にする必要があるのでコンバートする。
        location = self.layer.convert(location, to: self.layer.superlayer)
        let hitLayer:CALayer? = self.layer.hitTest(location)
        if (hitLayer == self.layer) {  //  自分自身は色パッチではない。
            return nil  //  見つからないのでnilを戻す。
        }
        return hitLayer
    }
    
    //  現在、選択中の色をUIColorとして示す。未選択時はnilを示す。
    var selectedColor:UIColor? {
        set {
            //  selectedLayerの背景色も連動させる。
            self.selectedLayer?.backgroundColor = newValue?.cgColor
        }
        get {
            if let color = self.selectedLayer?.backgroundColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
    }

    //  インジケータ用クラス定義。
    fileprivate class IndicatorLayer : CALayer {
        //  -hitTest:に反応させないようにする。
        override func contains(_ p: CGPoint) -> Bool {
            return false
        }
    }
    //  インジケータ。
    fileprivate let indicator = IndicatorLayer()

    //  インジケータをselectedLayerの位置に表示する。
    fileprivate func showIndicator() {
        if let layer = self.selectedLayer {
            self.indicator.position = layer.position
        }
    }
    
    //  Pallet用引数無しイニシャライザ。(0, 0, 44, 308)の大きさで自分の-initWithFrame:を呼び出させる。
    convenience init() {
        self.init(frame:CGRect(x: 0, y: 0, width: 44, height: 308))
    }
}
