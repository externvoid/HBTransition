//
//  CanvasView.swift
//  Canvas
import UIKit

class CanvasView: UIView {
    //  ペンの色を指定する。
    var penColor:UIColor = UIColor.red
    
    //  ペンの太さを指定する。
    var penWidth:CGFloat = 3.0
    

    // MARK:- オフスクリーン保持用。✳️
    fileprivate var canvas:UIImage?

    //  画面表示用オフスクリーンへの描画。
    override func draw(_ rect: CGRect) {
        self.canvas?.draw(at: CGPoint.zero)  //  担当画面左上から等倍で描画する。
    }
    
    // 線の到達点を受け取り、canvasを更新する。
    func canvasImage(_ newPt:CGPoint) {
        //  オフスクリーン描画用CGContext作成。
        UIGraphicsBeginImageContextWithOptions(
            self.bounds.size,   //  CanvasView全体の矩形サイズを指定。
            true,               //  不透明に設定。
            1)                  //  Retina画面へ最適化はしない。

        //  古いオフスクリーンを今のオフスクリーンに再現。
        self.canvas?.draw(at: CGPoint.zero)
        
        //  線をpenColorの色にする。
        self.penColor.setStroke()
        
        //  線を引く。
        let context = UIGraphicsGetCurrentContext()         //  設定されているCGContextを取り出す。
        context?.setLineWidth(self.penWidth)       //  線の太さを指定する。
        context?.move(to: CGPoint(x: curtPt.x, y: curtPt.y))
        context?.addLine(to: CGPoint(x: newPt.x, y: newPt.y))
        context?.strokePath()
        
        //  canvasの交換。
        self.canvas = UIGraphicsGetImageFromCurrentImageContext() //  オフスクリーンを画像として取り出し。
        UIGraphicsEndImageContext()
    }

    //  指の現在位置を記憶。
    var curtPt = CGPoint.zero
    
    //  以下の4つのタッチイベント対応メソッドでは、主側UIViewにタッチイベントを伝えないようsuper側は呼び出さないようにした。
    //  主側UIViewにタッチイベントを伝えたい場合はsuper側を呼び出す。
    
    //  指が触れた。
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            curtPt = touch.location(in: self)
        }
    }
    
    //  指が触れたまま移動した。
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        strokeLine(touches as NSSet)
    }
    
    //  指が放れた。
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        strokeLine(touches as NSSet)
    }
    
    //  タッチイベント追跡がキャンセルされた。
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //  なにもしない。
    }
    
    //  curtPtで示される現在の指位置から、touchesに設定されている指の位置まで、オフスクリーンに線を描く。そして画面に反映させる。
    func strokeLine(_ touches: NSSet) {
        if let touch = touches.anyObject() as? UITouch {
            let newPt = touch.location(in: self)
            self.canvasImage(newPt)     //  オフスクリーンに線を描く。
            self.setNeedsDisplay()      //  画面に反映させる。
            self.curtPt = newPt         //  現在の位置を更新。
        }
    }

    //  画像設定、取り出し用。
    var image:UIImage? {
        set {
            //  受け取った画像がnilだった場合や、self.bounds.sizeより小さい場合、オフスクリーンのサイズはself.bounds.sizeを使うようにした。
            var size = self.bounds.size
            if let newImage = newValue {
                if (size.width < newImage.size.width) {
                    size.width = newImage.size.width
                }
                if (size.height < newImage.size.height) {
                    size.height = newImage.size.height
                }
            } else {
                if (size.width == 0) || (size.height == 0) {
                    //  受け取った画像がnilで、画面の矩形のサイズもゼロなのでcanvasをnilにするだけで終わる。
                    self.canvas = nil
                    return
                }
            }
            
            //  オフスクリーン描画用CGContext作成。
            UIGraphicsBeginImageContextWithOptions(
                size,   //  受け取った画像の矩形サイズまたはself.bounds.sizeを指定。
                true,   //  不透明に設定。
                1)      //  Retina画面へ最適化はしない。
            //  canvasの交換。
            newValue?.draw(at: CGPoint.zero)    //  画像を描画。
            self.canvas = UIGraphicsGetImageFromCurrentImageContext() //  オフスクリーンを画像として取り出し。
            UIGraphicsEndImageContext()
            self.setNeedsDisplay()      //  画面に反映させる。
        }
        get {
            return self.canvas
        }
    }
}
