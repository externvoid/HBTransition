//
//  ViewController.swift
//  HBTransition
//
//  Created by kunii on 2014/11/24.
//  Copyright (c) 2014年 國居貴浩. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ExtendablePalletViewDelegate, ThumbnailViewControllerDelegate {

    fileprivate var canvasView:CanvasView!
    
    override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view, typically from a nib.

      //  キャンバスを作成しself.viewの子供にする。
      self.canvasView = CanvasView(frame: self.view.bounds)
      self.canvasView.backgroundColor = UIColor.white
      self.view.addSubview(self.canvasView)
      if let _ = self.documents {
//        if (self.documents != nil) {
            //  落書きの設定。
        self.canvasView.image = self.documents.loadImageAtIndex(self.curtImageIndex)
      }

      //  ツールバーの準備。
      self.loadToolbar()
      self.adjustToolbarButtons()

      //  slideInViewのself.viewへの子登録。
      self.loadSlideInView()
      self.canvasView.penColor = self.slideInView.palletView.selectedColor!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //  self.viewの配置が完了した
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //  ステータスバーの高さを考慮する。
        var height = self.topLayoutGuide.length
        
        //  ツールバーの配置。
        var frame = self.view.bounds
        frame.origin.y += height
        frame.size.height = 44
        self.toolBar.frame = frame
        height += frame.size.height

        //  キャンバスの矩形は全体から右のパレットをはぶいた大きさにする。
        frame = self.view.bounds
        frame.origin.y += height
        frame.size.height -= height
        frame.size.width -= self.slideInView.compactWidth    //  パレット分縮める。
        self.canvasView.frame = frame
        self.canvasView.setNeedsDisplay()
        
        //  self.view上での位置をずらす。
        self.slideInView.frame = self.slideInViewFrame(self.slideInViewFullOpend)
    }

    //  パレットが選択された。
    func penColorChange(_ pallet:Pallet) {
        if let color = pallet.selectedColor {
            self.canvasView.penColor = color
        }
    }

    //  落書きを読み込み。
    func load() {
        if (self.documents == nil) {
            self.documents = Documents()
            if (self.documents.count == 0) {
              _ = self.documents.addImage()
            }
            self.curtImageIndex = 0
            if (self.canvasView != nil) {
                self.canvasView.image = self.documents.loadImageAtIndex(self.curtImageIndex)
            }
            self.adjustToolbarButtons()
        }
    }
    
    //  現在の落書きを保存。
    func save() {
        if (self.documents != nil) {
            self.documents.saveImage(self.canvasView.image, atIndex: self.curtImageIndex)
        }
    }

    //  落書き帳。
    fileprivate var documents:Documents!

    //  現在の落書きのインディックス。
    fileprivate var curtImageIndex:Int = 0
    
    //  ツールバー。
    fileprivate var toolBar:UIToolbar!
    
    //  前ページに移動するボタンアイテム。
    fileprivate var rewinditem:UIBarButtonItem!
    
    //  次のページに移動するボタンアイテム。
    fileprivate var forwarditem:UIBarButtonItem!

    //  ツールバーのself.viewへの子登録。
    fileprivate func loadToolbar() {
        //  ツールバーの作成と貼付け。
        self.toolBar = UIToolbar(frame:CGRect(x: 20, y: 50, width: 200, height: 50))
        self.view.addSubview(self.toolBar)
        
        //  Newボタンをツールバーに追加。ターゲットに自身をアクションに-addCanvasメソッドを指定する。
        let saveitem = UIBarButtonItem(title: "New", style: .plain, target:self, action:#selector(ViewController.addCanvas))
        saveitem.tag = 1
        
        //  巻き戻しボタンを作成。
        self.rewinditem = UIBarButtonItem(barButtonSystemItem:.rewind, target:self, action:#selector(ViewController.changeCanvasImage(_:)))
        self.rewinditem.tag = 2
        
        //  早送りボタンを作成。
        self.forwarditem = UIBarButtonItem(barButtonSystemItem:.fastForward, target:self, action:#selector(ViewController.changeCanvasImage(_:)))
        self.forwarditem.tag = 3
        
        //  自動調整幅
        let flexspace = UIBarButtonItem(barButtonSystemItem:.flexibleSpace, target:nil, action:nil)
        
        //  固定幅
        let fixspace = UIBarButtonItem(barButtonSystemItem:.fixedSpace, target:nil, action:nil)
        fixspace.width = 30

        //  アクションボタンをツールバーに追加。ターゲットに自身をアクションに-saveメソッドを指定する。
        let actionitem = UIBarButtonItem(barButtonSystemItem:.action, target:self, action:#selector(ViewController.showActionMenu(_:)))
        saveitem.tag = 4 // probably mistake. actionitem.tag = 4
        //
      let startitem = UIBarButtonItem(title: "Start", style: .plain, target:self, action:#selector(ViewController.startHB))
      let stopitem = UIBarButtonItem(title: "Stop", style: .plain, target:self, action:#selector(ViewController.stopHB))
        //  New・アクション間固定幅
        let new_ActionSpace = UIBarButtonItem(barButtonSystemItem:.fixedSpace, target:nil, action:nil)
        new_ActionSpace.width = 50
        
        //  5つのアイテムをツールバに登録。
        toolBar.items = [saveitem, new_ActionSpace, actionitem, fixspace, startitem, fixspace, stopitem, flexspace, self.rewinditem, fixspace, self.forwarditem]
    }

    //  現在のページの状態に合わせてツールバーのボタンを調整する。
    fileprivate func adjustToolbarButtons() {
        self.rewinditem?.isEnabled = (self.curtImageIndex > 0)
        self.forwarditem?.isEnabled = (self.curtImageIndex < (self.documents.count - 1))
    }

    func startHB() {
//      canvasView.line.removeAllPoints()
      canvasView.startHB()
  }
    func stopHB() {
      canvasView.stopHB()
  }
    //  新しい落書きページを用意する。
    func addCanvas() {
        self.documents.saveImage(self.canvasView.image, atIndex:self.curtImageIndex)
    _ = self.documents.addImage()
        self.curtImageIndex = self.documents.count - 1
        self.canvasView.image = nil
        self.adjustToolbarButtons()
    }

    //  アクションボタン対応。
    func showActionMenu(_ sender:UIBarButtonItem) {
        
        //  アクションシート準備。
        let commandController = UIAlertController(title:nil, message:nil, preferredStyle:.actionSheet)
        
        //  削除ボタンの追加。
        let deleteAction = UIAlertAction(title: "削除", style: .destructive ) { (action:UIAlertAction!) -> Void in
            self.deleteCanvas()
        }
        
        //  一覧ボタンの追加。
        let thumbnailAction = UIAlertAction(title: "一覧", style: .default ) { (action:UIAlertAction!) -> Void in
            self.showThumbnail(sender)
        }
        
        //  コピーボタンの追加。
        let copyAction = UIAlertAction(title: "コピー", style: .default ) { (action:UIAlertAction!) -> Void in
            self.duplicateCanvas()
        }
        
        //  キャンセルボタンの追加。
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler:nil)
        
        commandController.addAction(deleteAction)
        commandController.addAction(thumbnailAction)
        commandController.addAction(copyAction)
        commandController.addAction(cancelAction)
        
        //  ポップオーバー時の設定。ボタンの矩形を利用。
        if let pc = commandController.popoverPresentationController {
            pc.barButtonItem = sender
        }
        self.present(commandController, animated:true, completion:nil)
    }

    //  表示する画像ファイルを変更する。
    func changeCanvasImage(_ sender:UIBarButtonItem) {
        let direction = (sender.tag == 2) ? -1 : 1
        let index = self.curtImageIndex + direction
        if (index < 0) {
            return
        }
        if (index > (self.documents.count - 1)) {
            return
        }
        self.documents.saveImage(self.canvasView.image, atIndex:self.curtImageIndex)
        self.curtImageIndex = index
        self.canvasView.image = self.documents.loadImageAtIndex(self.curtImageIndex)
        self.adjustToolbarButtons()
    }
    
    //  表示中の落書きを削除する。
    func deleteCanvas() {
        //  現在表示中の画像のファイルを削除する。
        self.documents.removeImageAtIndex(self.curtImageIndex)
        if (self.documents.count == 0) {
            //  落書きが0枚になったので、新しく追加し画面をクリア。
            _ = self.documents.addImage()
            self.curtImageIndex = 0
            self.canvasView.image = nil
        } else {
            //  もしcurtImageIndexが末尾を越えていたら、末尾を指すように調整する。
            if (self.curtImageIndex >= self.documents.count) {
                self.curtImageIndex = self.documents.count - 1
            }
            self.canvasView.image = self.documents.loadImageAtIndex(self.curtImageIndex)
        }
        self.adjustToolbarButtons()
    }
    
    //  現在の落書きをコピーした新しい落書きページを用意する。
    func duplicateCanvas() {
        //  現在の落書きを取り出しておく。
        let image = self.canvasView.image
        //  現在表示中の落書きをファイルに保存する。
        self.documents.saveImage(image, atIndex:self.curtImageIndex)
        //  新しく落書きを追加。
        _ = self.documents.addImage()
        //  インデックスを末尾に設定（追加した落書きを指すようにする）。
        self.curtImageIndex = self.documents.count - 1
        //  取り出しておいた画像を、新しいファイルに保存。
        self.documents.saveImage(image, atIndex:self.curtImageIndex)

        //  コピーされるイメージでアニメーション。
        let imageView = UIImageView(frame: self.canvasView.bounds)
        imageView.image = image
        imageView.transform = CGAffineTransform(translationX: self.canvasView.bounds.size.width, y: 0)
        self.canvasView.addSubview(imageView)
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            imageView.transform = CGAffineTransform.identity
            }, completion: { (_:Bool) -> Void in
                imageView.removeFromSuperview()
        }) 
        self.adjustToolbarButtons()
    }

    //  画像ファイルの一覧を表示する。
    func showThumbnail(_ sender:UIBarButtonItem) {
        //  現在表示中の落書きをファイルに保存する。
        self.documents.saveImage(self.canvasView.image, atIndex:self.curtImageIndex)
        let thumbnailViewController = ThumbnailViewController()
        thumbnailViewController.delegate = self
        thumbnailViewController.URLs = self.documents.URLs

        //  iPadの時はポップオーバーさせる。
        thumbnailViewController.modalPresentationStyle = .popover
        if let pc = thumbnailViewController.popoverPresentationController {
            pc.barButtonItem = sender
        }
        self.present(thumbnailViewController, animated: true, completion: nil)
    }
    
    //  タップされたサムネイルのインディックスを通知する。
    func thumbnailViewController(_ controller:ThumbnailViewController, didSelectIndex index:Int) {
        if (self.curtImageIndex != index) {
            self.curtImageIndex = index
            self.canvasView.image = self.documents.loadImageAtIndex(self.curtImageIndex)
            self.adjustToolbarButtons()
        }
        self.dismiss(animated: true, completion: nil)
    }

    //  MARK:- 拡張パレット
    
    //  スライド画面用。
    fileprivate var slideInView:ExtendablePalletView!
    
    //  スライド画面がすべて見えている状態ならtrue
    fileprivate var slideInViewFullOpend = false

    //  slideInViewのself.viewへの子登録。
    fileprivate func loadSlideInView() {
        //  ExtendablePalletViewを作成しself.viewと親子関係を結ぶ。この時点では左上を(0,0)に固定
        self.slideInView = ExtendablePalletView(frame:CGRect(x: 0, y: 0, width: 300, height: 350))
        self.view.addSubview(self.slideInView)
        
        self.slideInView.palletView.addTarget(self, action: #selector(ViewController.palletActionValueChanged(_:)), for: .valueChanged)
        self.slideInView.delegate = self
    }

    //  パレットの色パッチの色が変わったので、キャンバスも変更する。
    func palletActionValueChanged(_ sender:Pallet) {
        self.canvasView.penColor = sender.selectedColor!
    }
    
    //  引数opendで指定される状態（true:全表示, false:最小表示）でのslideInViewの矩形を戻す。
    fileprivate func slideInViewFrame(_ opend:Bool) -> CGRect {
        var frame = self.slideInView.frame
        frame.origin.y = self.topLayoutGuide.length + 44
        frame.origin.x = self.view.bounds.maxX      //  右側に隠れ完全に見えない位置。
        if opend {
            //  全部見せる。
            frame.origin.x -= frame.size.width
        } else {
            //  44ポイント分だけ見せる。
            frame.origin.x -= self.slideInView.compactWidth
        }
        return frame
    }
    
    //  MARK:- ExtendablePalletViewDelegate
    
    //  ExtendablePalletViewのデリゲートメソッド。色パッチ編集画面アイテムを矩形をeditorFrameにして作成。
    func palletView(_ palletView:ExtendablePalletView, editorFrame:CGRect, atIndex:Int) -> UIView? {
        if (atIndex == 0) {
            return hsbEditor(editorFrame)   //  HSB用。
        }
        return hueEditor(editorFrame)    //  Hue単独用。
    }
    
    //    色パッチ編集画面アイテムの総数
    func editorCountPalletView(_ palletView:ExtendablePalletView) -> Int {
        return 2
    }
    
    //  取っ手に触れた。
    func didTapHandlePalletView(_ palletView:ExtendablePalletView) {
        self.slideInViewFullOpend = !self.slideInViewFullOpend    //  状態をtrueならfalse、falseならtrueに切り替える。
        
        //  slideInView.frameの変更をアニメーション化する。
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.slideInView.frame = self.slideInViewFrame(self.slideInViewFullOpend)
        })
    }
    
    //  MARK:- 色エディタ群
    
    //  HSB用色パッチ編集画面アイテムを作成し戻す。
    fileprivate func hsbEditor(_ editorFrame:CGRect) -> UIView {
        let baseView = UIView(frame:editorFrame)
        var frame = baseView.bounds
        frame.size.height /= 3  //  均等に配置するための前準備
        frame.origin.x = 0
        for tag in 1...3  {
            let slider = UISlider(frame:frame)
            slider.addTarget(self, action:#selector(ViewController.sliderAction(_:)), for:UIControlEvents.valueChanged)
            slider.tag = tag    //  1:色相用、2:彩度用、3:明度用
            baseView.addSubview(slider)
            frame = frame.offsetBy(dx: 0, dy: frame.size.height)
        }
        return baseView
    }
    
    //  Hue用色パッチ編集画面アイテムを作成し戻す。
    fileprivate func hueEditor(_ editorFrame:CGRect) -> UIView {
        //  UISliderを作成し貼付け、アクションとして-sliderAction:を登録。
        let slider = UISlider(frame:editorFrame)
        slider.addTarget(self, action:#selector(ViewController.hueSliderAction(_:)), for:UIControlEvents.valueChanged)
        return slider
    }

    //  3つのUISliderの値を取り出し、それを元に色を決めPalletに設定。
    func sliderAction(_ sender:UISlider) {
        //  UISliderの親側UIViewを求め、そこから-viewWithTag:で各UISliderを探し出し、現在の色を決定する。
        if let view = sender.superview {
            var slider = view.viewWithTag(1) as! UISlider    //  色相
            let hue = CGFloat(slider.value)
            slider = view.viewWithTag(2) as! UISlider    //  彩度
            let saturation = CGFloat(slider.value)
            slider = view.viewWithTag(3) as! UISlider    //  明度
            let brightness = CGFloat(slider.value)
            self.slideInView.palletView.selectedColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
            self.palletActionValueChanged(self.slideInView.palletView)
        }
    }
    
    //  UISliderの値を取り出し、それを元に色を決めPalletに設定。
    func hueSliderAction(_ slider:UISlider) {
        self.slideInView.palletView.selectedColor = UIColor(hue: CGFloat(slider.value), saturation: 1.0, brightness: 1.0, alpha: 1.0)
        self.palletActionValueChanged(self.slideInView.palletView)
    }

}

