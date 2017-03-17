//
//  ThumbnailView.swift
//  Thumbnail
//
//  Created by kunii on 2014/11/27.
//  Copyright (c) 2014年 國居貴浩. All rights reserved.
//

import UIKit

class ThumbnailView: UIScrollView {

    //  画像ファイルNSURLの配列。設定すると配列要素数分のサムネイル画像を画面にタイル状に表示される。
    var thumbnails:[URL]? {
        didSet {
            //  無条件に最更新させる。oldValueと比較して内容が異なる時だけ呼び出すのがベストだが、ここでは省略。
            self.reloadData()
        }
    }
    
    //  thumbnailsプロパティに合わせて、画面にサムネイル画像をタイル状に表示する。
    func reloadData() {
        //  　まず、自身に貼付けられているサムネイル画面を、すべて取り外す。
        for view in self.subviews {
            view.removeFromSuperview()
        }
        //  -reloadDataでは画像を読み込まない。
        self.setThumbnaileInfo()    //  サムネイル画面の情報を準備。
    }

    //  imageで渡した画像をsizeで指定されるサイズにスケーリングしたUIImageを作り戻す。
    func resizeImage(_ image:UIImage, size:CGSize) -> UIImage? {
        //  指定されたサイズのオフスクリーン作成。
        UIGraphicsBeginImageContext(size)
        
        //  オフスクリーンいっぱいにimageを描画。
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        //  オフスクリーンからUIImage作成。
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }

    //  デリゲート
    weak var thumbnailDelegate:ThumbnailViewDelegate?

    //  選択されているサムネイル
    fileprivate var selectedView:UIView!

    //  指が触れた。
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.selectImage(touches, event: event!)
    }
    
    //  指が移動した。
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        self.selectImage(touches, event:event!)
    }

    //  指が放された。
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.selectImage(touches, event:event!)
        if (self.selectedView != nil) {
            //  選択しているサムネイル画面があればデリゲートに通知する。
            self.thumbnailDelegate?.thumbnailView(self, didSelectIndex:self.selectedView.tag - 1)  //  tagは1から始まっているので-1する。
        }
        //  選択しているサムネイル画面の解除。
        self.selectedView?.alpha = 1.0
        self.selectedView = nil
    }
    
    //  指追跡がキャンセルされた。
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        //  選択しているサムネイル画面の解除。
        self.selectedView?.alpha = 1.0
        self.selectedView = nil
    }

    //  タッチされた画像の選択。
    fileprivate func selectImage(_ touches: Set<UITouch>, event: UIEvent) {
        //  タッチされているサムネイル画面を検索。
        var thumbView:UIView? = nil      //  nilの代入は必要ないが、見つからない場合、nilにするという意思表示として記述した。
        if let touch = touches.first {
            let pt = touch.location(in: self)
            thumbView = self.hitTest(pt, with:event)
            if (thumbView == self) {     //  selfはサムネイル画面ではないのでnilにする。
                thumbView = nil
            }
        }
        /*
        　selectedViewとthumbViewが異なる場合、selectedViewをthumbViewに更新する。
        古いselectedViewの透明度を元に戻し、新しいselectedViewの透明度を50%にする。
        透明度の変更はselectedViewが無効かどうかのチェック付きでおこなう。
        */
        if (self.selectedView != thumbView) {
            self.selectedView?.alpha = 1.0
            self.selectedView = thumbView
            self.selectedView?.alpha = 0.5
        }
    }
    
    //  サムネイルが横に並ぶ数。
    fileprivate var rowCount:Int = 0
    
    //  サムネイル1つの大きさ。
    fileprivate var thumbnaileSize = CGSize.zero
    
    //  indexで指定されるサムネイルの矩形を戻す。
    fileprivate func thumbnailViewFrame(_ index:Int) -> CGRect {
        //  -reloadDataで計算された値を使う。
        let v = index / self.rowCount
        let h = index % self.rowCount
        return CGRect(x: CGFloat(h) * self.thumbnaileSize.width, y: CGFloat(v) * self.thumbnaileSize.height, width: self.thumbnaileSize.width, height: self.thumbnaileSize.height)
    }
    
    //  画面配置。
    override func layoutSubviews() {
        super.layoutSubviews()
        if (self.thumbnails == nil) {
            return
        }
        if (self.contentSize.width != self.bounds.size.width) {
            //  現在の左上にあるサムネイル画面のインディックスを計算。
            let topleftIndex = (self.contentOffset.y == 0)
                ? 0 //  self.contentOffset.yが0の時は、self.thumbnaileSize未設定時の場合も考え計算しない。
                : Int(self.contentOffset.y / self.thumbnaileSize.height) * self.rowCount
            self.setThumbnaileInfo()    //  サムネイル画面の情報を準備。
            //  topleftIndexに基づいてself.contentOffset.yを再設定。
            let y = CGFloat(topleftIndex / self.rowCount) * self.thumbnaileSize.height
            self.contentOffset = CGPoint(x:contentOffset.x, y:y)
        }
        let visibleFrame = CGRect(x: self.contentOffset.x, y: self.contentOffset.y, width: self.bounds.size.width, height: self.bounds.size.height)
        
        //  これより外は表示画面外とみなす矩形。縦について表示画面より外側に800ポイント分余裕を持たせている。
        let marginFrame = visibleFrame.insetBy(dx: 0, dy: -800)
        
        //  tagプロパティ用の番号初期化。
        var imageIndex = 0
        
        for url in self.thumbnails! {
            //  thumbnailsに収納された全NSURLを取り出すループ。
            let frame = self.thumbnailViewFrame(imageIndex)
            if visibleFrame.intersects(frame) { //  画面に見えている。
                var imageview:UIImageView! = self.viewWithTag(imageIndex + 1) as? UIImageView
                //  すでにUIImageViewとして貼られているならnil以外となる。
                if (imageview == nil) {
                    //  サムネイル画面を1つ追加。
                    imageview = UIImageView(frame:frame)
                    //  UIImageViewは初期状態ではfalseになっているので、そのままだと-hitTest:で見つけられない。
                    imageview.isUserInteractionEnabled = true
                    //  サムネイルのインディックスを決定するために設定。
                    imageview.tag = imageIndex + 1
                    //  画像ファイルを読み込んでリサイズして設定。
                    if let data = try? Data(contentsOf: url) {
                        if let image = UIImage(data: data) {
                            //  iPadの場合、サムネイルサイズを 0.8倍する。
                            var size = frame.size
                            if (self.traitCollection.userInterfaceIdiom == .pad) {
                                size.height *= 0.8
                                size.width *= 0.8
                            }
                            imageview.contentMode = .center     //  等倍で中央配置。
                            imageview.image = resizeImage(image, size:size)   //  リサイズ
                        }
                    }
                    self.addSubview(imageview)
                } else {
                    imageview.frame = frame
                }
            } else {                            //  画面外。
                //  marginFrame外になったら取り外す。
                if (marginFrame.intersects(frame) == false) {
                    let imageview = self.viewWithTag(imageIndex + 1) as? UIImageView
                    imageview?.removeFromSuperview()
                }
            }
            imageIndex += 1
        }
    }
    
    //  サムネイル画面の情報を準備。
    fileprivate func setThumbnaileInfo() {
        //  縦横短い方の辺の長さを3で割ってサムネイルサイズを決定する。
        self.thumbnaileSize = self.bounds.size
        let divCount:CGFloat = (self.traitCollection.userInterfaceIdiom == .pad) ? 4 : 3
        let length = min(self.thumbnaileSize.width, self.thumbnaileSize.height) / divCount
        self.thumbnaileSize.width = length
        self.thumbnaileSize.height = length
        
        //  1行のサムネイル数の計算。
        self.rowCount = Int(self.bounds.size.width) / Int(thumbnaileSize.width)
        
        //  URL配列があるなら、全体の矩形を計算しcontentSizeプロパティを設定。
        if let thumbs = self.thumbnails {
            let vCount = (thumbs.count + self.rowCount - 1) / self.rowCount
            self.contentSize = CGSize(width: self.bounds.size.width, height: CGFloat(vCount) * thumbnaileSize.height)
        }
    }
}

//  ThumbnailViewデリゲート
@objc protocol ThumbnailViewDelegate : NSObjectProtocol {
    //  タップされたサムネイルのインディックスを通知する。
    func thumbnailView(_ thumbnailView:ThumbnailView, didSelectIndex:Int)
}
