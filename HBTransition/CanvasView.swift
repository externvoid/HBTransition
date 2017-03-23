//
//  CanvasView.swift
//  Canvas
import UIKit
import Darwin
struct Step {
  var accm: Int = 60, ix: CGFloat = 5.0
  static let endPoint: CGFloat = 300.0
  
  static var step0 = {() -> Step in let s = 60, t = endPoint/CGFloat(s)
    return Step(accm: s, ix: t)}()
  static var step1 = {() -> Step in let s = 120, t = endPoint/CGFloat(s)
    return Step(accm: s, ix: t)}()
  static var step2 = {() -> Step in let s = 240, t = endPoint/CGFloat(s)
    return Step(accm: s, ix: t)}()
  static var step3 = {() -> Step in let s = 480, t = endPoint/CGFloat(s)
    return Step(accm: s, ix: t)}()
  static var step4 = {() -> Step in let s = 960, t = endPoint/CGFloat(s)
    return Step(accm: s, ix: t)}()
}

class CanvasView: UIView {
  var penColor:UIColor = UIColor.red //  ペンの色を指定する。
  var penWidth:CGFloat = 5.0 //  ペンの太さを指定する。
  fileprivate var canvas:UIImage? // MARK:- オフスクリーン保持用。✳️
  let line = UIBezierPath()
  var ar: [Int] = []
  let string = "Heart Beat Transition"
  var ix: CGFloat = 0.0
  var cnt: Int = 0
  var idx_s: Int = 0 //step index
  let step = [Step.step0, Step.step1, Step.step2, Step.step3, Step.step4]
  var tm: Timer!
  var ctx: CGContext!
  //  画面表示用オフスクリーンへの描画。
  override func draw(_ rect: CGRect) {
    ctx = UIGraphicsGetCurrentContext()
    self.canvas?.draw(at: CGPoint.zero)  //  担当画面左上から等倍で描画する。
//    line.stroke()
//    self.beatDraw()
  }
  
  func startHB() {
    print("OK")
    tm = Timer(timeInterval: 0.2, target: self,
               selector: #selector(CanvasView.update(tm:)), userInfo: nil, repeats: true)
    RunLoop.current.add(tm, forMode: .defaultRunLoopMode)
    line.move(to: CGPoint(x: 0, y: 165))
    ar.removeAll()
  }
  func stopHB() {
    print("NG")
    tm?.invalidate()
    ar.removeAll()
    line.removeAllPoints()
    self.canvas = getScreenShot()
  }
 
  // MARK:- 描画
  // 擬似HBでグラフを描画
  func update(tm: Timer) {
    UIGraphicsBeginImageContextWithOptions(
        self.bounds.size,   //  CanvasView全体の矩形サイズを指定。
        true,               //  不透明に設定。
        1)                  //  Retina画面へ最適化はしない。
    self.canvas?.draw(at: CGPoint.zero) //  古いオフスクリーンを今のオフスクリーンに再現。
    self.penColor.setStroke() //  線をpenColorの色にする。
    
    idx_s = cnt2step(cnt)
    let iy: Int = rnd(30) + 150
    ar.append(iy)
    
    if [60, 120, 240, 480, 960].contains(where:{ $0 == cnt}) {
      line.lineWidth = step[idx_s].ix
      line.removeAllPoints()
      line.move(to: CGPoint(x: 0, y: 165))
      ix = 0.0
      //      var ix: CGFloat = 0.0
      Array(0..<cnt).forEach {iy in
        line.addLine(to: CGPoint(x: ix,
                                            y: CGFloat(ar[iy])))
        ix += step[idx_s].ix
      }
    }
    line.addLine(to: CGPoint(x: ix, y: CGFloat(iy)))
    ix += step[idx_s].ix
    cnt += 1
    line.stroke()
//    line.removeAllPoints()
    makeCaption()
    self.canvas = UIGraphicsGetImageFromCurrentImageContext() // オフスクリーンを画像として取り出し。
    if cnt > 960 {
      //      self.transform = CGAffineTransform(scaleX: 0.5, y: 1.0)
      tm.invalidate()
    } else { print("cnt =", cnt) }
    
    UIGraphicsEndImageContext()
  }
  
  func cnt2step(_ cnt: Int) -> Int {
    //    defer{cnt += 1}
    switch cnt {
    case  0...59 as ClosedRange: return 0
    case  60...119 as ClosedRange: return 1
    case  120...239 as ClosedRange: return 2
    case  240...479 as ClosedRange: return 3
    case  480...959 as ClosedRange: return 4
    default: return 4
    }
  }
  
  func beatDraw() {
//  オフスクリーン描画用CGContext作成。
    UIGraphicsBeginImageContextWithOptions(
        self.bounds.size,   //  CanvasView全体の矩形サイズを指定。
        true,               //  不透明に設定。
        1)                  //  Retina画面へ最適化はしない。
    self.canvas?.draw(at: CGPoint.zero) //  古いオフスクリーンを今のオフスクリーンに再現。
    self.penColor.setStroke() //  線をpenColorの色にする。
// test code erasable
    line.lineWidth = 5.0
    line.move(to:CGPoint(x:10, y: Int(arc4random_uniform(100) + 100)))
    line.addLine(to:CGPoint(x: 30, y: Int(arc4random_uniform(100) + 100)))
    line.addLine(to:CGPoint(x: 50, y: Int(arc4random_uniform(100) + 100)))
    line.addLine(to:CGPoint(x: 70, y: Int(arc4random_uniform(100) + 100)))
    line.addLine(to:CGPoint(x: 90, y: Int(arc4random_uniform(100) + 100)))
    line.addLine(to:CGPoint(x: 110, y: Int(arc4random_uniform(100) + 100)))
    self.penColor.setStroke()
    line.stroke()
    line.removeAllPoints()
    makeCaption()
    self.canvas = UIGraphicsGetImageFromCurrentImageContext() // オフスクリーンを画像として取り出し。
    self.setNeedsDisplay()
  }
  // 線の到達点を受け取り、canvasを更新する。
  func canvasImage(_ newPt:CGPoint) {
      //  オフスクリーン描画用CGContext作成。
      UIGraphicsBeginImageContextWithOptions(
          self.bounds.size,   //  CanvasView全体の矩形サイズを指定。
          true,               //  不透明に設定。
          1)                  //  Retina画面へ最適化はしない。
      self.canvas?.draw(at: CGPoint.zero) //  古いオフスクリーンを今のオフスクリーンに再現。
      self.penColor.setStroke() //  線をpenColorの色にする。
    //  線を引く。
    let context = UIGraphicsGetCurrentContext()         //  設定されているCGContextを取り出す。
    context?.setLineWidth(self.penWidth)       //  線の太さを指定する。
    context?.move(to: CGPoint(x: curtPt.x, y: curtPt.y))
    context?.addLine(to: CGPoint(x: newPt.x, y: newPt.y))
    context?.strokePath()
    //  canvasの交換。
    self.canvas = UIGraphicsGetImageFromCurrentImageContext() // オフスクリーンを画像として取り出し。
    UIGraphicsEndImageContext()
  }

  //  指の現在位置を記憶。
  var curtPt = CGPoint.zero
  //  以下の4つのタッチイベント対応メソッドでは、主側UIViewにタッチイベントを伝えないよう
  //  super側は呼び出さないようにした。主側UIViewにタッチイベントを伝えたい場合はsuper側を呼び出す。
  //  指が触れた。
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      if let touch = touches.first { curtPt = touch.location(in: self) }
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
  } //  なにもしない。
  //  curtPtで示される現在の指位置から、touchesに設定される指の位置まで、オフスクリーンに線を描く。そして画面に反映。
  func strokeLine(_ touches: NSSet) {
      if let touch = touches.anyObject() as? UITouch {
          let newPt = touch.location(in: self)
          self.canvasImage(newPt)     //  オフスクリーンに線を描く。
          self.setNeedsDisplay()      //  画面に反映させる。
          self.curtPt = newPt         //  現在の位置を更新。
      }
  }
  //  画像設定、取り出し用。
  var image:UIImage? { //newValueが来た時の処理
    set {
    //  受け取った画像がnilだった場合や、self.bounds.sizeより小さい場合、オフスクリーンのサイズは
      var size = self.bounds.size //  self.bounds.sizeを使うようにした。
      if let newImage = newValue {
          if (size.width < newImage.size.width) { size.width = newImage.size.width }
          if (size.height < newImage.size.height) { size.height = newImage.size.height }
      } else { //  受け取った画像がnilで、画面の矩形のサイズもゼロなのでcanvasをnilにするだけで終わる。
        if (size.width == 0) || (size.height == 0) { self.canvas = nil; return }
      }
      //  オフスクリーン描画用CGContext作成。
      UIGraphicsBeginImageContextWithOptions(
          size,   //  受け取った画像の矩形サイズまたはself.bounds.sizeを指定。
          true,   //  不透明に設定。
          1)      //  Retina画面へ最適化はしない。
      //  canvasの交換。
      newValue?.draw(at: CGPoint.zero)    //  画像を描画。
      self.canvas = UIGraphicsGetImageFromCurrentImageContext() //オフスクリーンを画像として
      UIGraphicsEndImageContext()                           //取り出し。
      self.setNeedsDisplay()      //  画面に反映させる。
    }
    get { return self.canvas }
  }
  func makeCaption() {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    let attrs = [NSFontAttributeName: UIFont(name: "Hiragino Sans", size: 24)!,
//    let attrs = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 24)!,
                 NSParagraphStyleAttributeName: paragraphStyle,
                 NSForegroundColorAttributeName: UIColor.blue]
    let fmt: DateFormatter = DateFormatter()
    fmt.dateFormat = "yyyy年MM月dd日 \nHH時mm分ss秒"
    let t = fmt.string(from: Date())
    (string + "\n" + t)
      .draw(with: CGRect(x: 12, y: 12, width: 400, height: 200),
                             options: .usesLineFragmentOrigin,
                             attributes: attrs, context: nil)
    
  }
  func getScreenShot() -> UIImage {
    let rect = self.bounds
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    let ctx: CGContext = UIGraphicsGetCurrentContext()!
    self.layer.render(in: ctx)
    let capturedImage : UIImage! = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return capturedImage
  }
  
  func rnd(_ upper: UInt32) -> Int { // 0..<upperまで半数発生、upper含まず
    return  Int(arc4random_uniform(upper))
  }
}
