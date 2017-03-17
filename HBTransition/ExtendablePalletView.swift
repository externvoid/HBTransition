//
//  ExtendablePalletView.swift
//  SlideIn
//
//  Created by kunii on 2014/11/24.
//  Copyright (c) 2014年 國居貴浩. All rights reserved.
//

import UIKit

//  ExtendablePalletViewデリゲート用。
@objc protocol ExtendablePalletViewDelegate : NSObjectProtocol {
    //  atIndexで指定された色エディタ作成。
    //  palletView:には移譲元を指定。editorFrame:には色エディタ画面矩形を指定。
    //  atIndex:でどの色エディタを作るかを指定。
    //  作成した色エディタを戻す。
    func palletView(_ palletView:ExtendablePalletView, editorFrame:CGRect, atIndex:Int) -> UIView?

    //    色エディタの総数を戻す。
    func editorCountPalletView(_ palletView:ExtendablePalletView) -> Int
    
    //  取っ手に触れた。
    @objc optional func didTapHandlePalletView(_ palletView:ExtendablePalletView)
}


class ExtendablePalletView: UIView {

    //  パレット。
    let palletView = Pallet()
    
    //  取っ手。
    fileprivate let handle = UIView()
    
    //  取っ手のタップを通知するオブジェクト。
    fileprivate let tapGestureRecognizer = UITapGestureRecognizer()
    
    //  取っ手とパレットだけ見える幅を戻す。読み取り専用コンピューティッド・プロパティ。
    var compactWidth:CGFloat {
        return self.palletView.frame.maxX + 8
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        //  取っ手作成。上下は親画面いっぱいに広げる。
        self.handle.frame = CGRect(x: 0, y: 0, width: 22, height: self.bounds.size.height)
        //  取っ手にtapGestureRecognizer登録。
        self.handle.addGestureRecognizer(self.tapGestureRecognizer)
        self.addSubview(self.handle)
        
        //  パレット作成。上下は親画面の中心に合わせて配置する。
        self.palletView.center = CGPoint(
            x: handle.frame.maxX + self.palletView.frame.size.width / 2,
            y: self.bounds.size.height / 2)
        self.addSubview(self.palletView)
        
        //  色エディタ切り替えボタンの用意。
        let button = UIButton(type: .system) 
        button.frame = CGRect(x: self.palletView.frame.maxX, y: self.bounds.size.height - 22, width: self.bounds.maxX - self.palletView.frame.maxX, height: 22)
        button.setTitle("切り替え", for:UIControlState())
        button.addTarget(self, action:#selector(ExtendablePalletView.nextColorEditor), for:.touchUpInside)
        self.addSubview(button)
        self.tapGestureRecognizer.addTarget(self, action: #selector(ExtendablePalletView.tap))
    }
    
    //  required指定なので記述が必要だが現在未使用。
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //  デリゲート。
    weak var delegate:ExtendablePalletViewDelegate? {
        didSet {
            self.colorEditorIndex = nil //  無効にする。
            nextColorEditor()
        }
    }
    
    //  呼ばれるたびに色エディタを次の色エディタに切り替える。最後の色エディタを切り替える時は最初の色エディタに戻す。
    func nextColorEditor() {
        //  移譲先が有効な時だけ実行する。
        if let delegate = self.delegate {
            let count = delegate.editorCountPalletView(self)
            if (count <= 0) {
                //  無効にする。
                self.colorEditorIndex = nil
            } else {
                //  要求する色エディタ番号の決定。
                if (self.colorEditorIndex == nil) {
                    //  無効だったので、有効な値0に設定する。
                    self.colorEditorIndex = 0
                } else {
                    //  現在の値が有効なので1つ加算する。
                    var next = self.colorEditorIndex! + 1
                    if (next >= count) {
                        //  移譲先が持っている色エディタ数をこえてしまうので0番目に戻す。
                        next = 0
                    }
                    self.colorEditorIndex = next
                }
            }
        }
    }
    
    //  現在表示中の色エディタを記憶。
    fileprivate var colorEditor:UIView? {
        didSet {
            //  新しい値に変化がないなら何もしない。
            if (oldValue == self.colorEditor) {
                return
            }
            oldValue?.removeFromSuperview()  //  先に現在表示中の色エディタを取りはぶく。
            
            //  新しい色エディタが有効なら、自分の子供として登録する。
            if let editor = self.colorEditor {
                self.addSubview(editor)
            }
        }
    }
    
    //  現在表示中の色エディタの番号。
    fileprivate var colorEditorIndex:Int? {
        didSet {
            //  新しい値に変化がないなら何もしない。
            if (oldValue == self.colorEditorIndex) {
                return
            }
            //  新しい値が無効なら、self.colorEditor側も無効にして戻る。
            if (self.colorEditorIndex == nil) {
                self.colorEditor = nil
                return
            }
            //  移譲先が有効ならば、色エディタ作成を移譲する。
            if let delegate = self.delegate {
                //  矩形の計算。
                let frame = CGRect(x: 0, y: 0, width: self.bounds.maxX - self.palletView.frame.maxX, height: self.bounds.size.height).insetBy(dx: 22, dy: 22)
                
                //  移譲先からself.colorEditorIndex番目の色エディタをもらう。
                if let view = delegate.palletView(self, editorFrame:frame, atIndex:self.colorEditorIndex!) {
                    //  位置調整。
                    view.center = CGPoint(x: view.center.x + self.palletView.frame.maxX, y: self.bounds.size.height / 2)
                    
                    //  現在表示中の色エディタとして登録。
                    self.colorEditor = view
                }
            }
        }
    }
    
    //  取っ手がタップされた。
    func tap() {
        delegate?.didTapHandlePalletView?(self)
    }
}
