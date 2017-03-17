//
//  ThumbnailViewController.swift
//  HBTransition
//
//  Created by kunii on 2014/12/15.
//  Copyright (c) 2014年 國居貴浩. All rights reserved.
//

import UIKit

class ThumbnailViewController: UIViewController, ThumbnailViewDelegate {

    //  ファイルURL群、受け取り用。
    var URLs = [URL]()
    weak var delegate:ThumbnailViewControllerDelegate?

    //  サムネイル用画面。-viewDidLayoutSubviews用にプロパティにする。
    fileprivate var thumbnailView:ThumbnailView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        //  サムネイル用画面を用意。
        let thumbnailView = ThumbnailView(frame: self.view.bounds)
        self.view.addSubview(thumbnailView)
        thumbnailView.thumbnails = self.URLs
        
        thumbnailView.thumbnailDelegate = self
        self.thumbnailView = thumbnailView
        self.view.backgroundColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //  サムネイルがタップされた。
    func thumbnailView(_ thumbnailView:ThumbnailView, didSelectIndex index:Int) {
        self.delegate?.thumbnailViewController(self, didSelectIndex:index)
    }
    
    //  self.viewの矩形が変わったのでサムネイル用画面もそれに合わせる。
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.thumbnailView.frame = self.view.bounds
    }
}

//  デリゲート用
@objc protocol ThumbnailViewControllerDelegate : NSObjectProtocol {
    func thumbnailViewController(_ controller:ThumbnailViewController, didSelectIndex index:Int)
}
