//
//  Documents.swift
//  HBTransition
//
//  Created by kunii on 2014/12/05.
//  Copyright (c) 2014年 國居貴浩. All rights reserved.
//

import UIKit

class Documents : NSObject {

    //  画像ファイルのNSURL配列。
    fileprivate var imageURLs:[URL]!
    
    //  self.imageDirURL下に存在する画像ファイルをリストアップしself.imageURLsを準備する。
    override init() {
        super.init()
      _ = try? FileManager.default.createDirectory(at: self.imageDirURL,
                                             withIntermediateDirectories: true, attributes: nil)
//      var error:NSError?
      let list = try? FileManager.default.contentsOfDirectory(at: self.imageDirURL,
                                      includingPropertiesForKeys:nil, options:.skipsHiddenFiles)
      let URLs = list! //as! [URL]
      self.imageURLs = URLs.sorted {
        $0.lastPathComponent < $1.lastPathComponent
      }
    }

    //  self.imageDirURL下に存在する画像ファイルの数を戻す。
    var count:Int {
        return self.imageURLs.count
    }
    
    //  新しい画像ファイルを用意しUIImageとして戻す。用意できなかったらnilを戻す。
    func addImage() -> UIImage? {
        if let url = self.URLNow() {        //  新しいファイル用NSURLをもらう。
            self.imageURLs.append(url)      //  新しいNSURLを末尾に追加。
            let image = self.createImage()
            self.saveImage(image, atIndex:self.imageURLs.count - 1)
            return image
        }
        return nil
    }
    
    //  indexで指定される画像をファイルから読み込みUIImageとして戻す。
    func loadImageAtIndex(_ index:Int) -> UIImage! {
        let url = self.imageURLs[index]
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }
    
    //  indexで指定される画像をファイルに保存する。
    func saveImage(_ image:UIImage!, atIndex:Int) {
        if (image != nil) {
            let imageData = UIImagePNGRepresentation(image)
            let url = self.imageURLs[atIndex]
          try? imageData?.write(to:url, options: .atomic)
        }
    }
    
    //  画像ファイルを保存するディレクトリ（Documents/images/）のNSURLを戻す。
    fileprivate var imageDirURL:URL {
        //  DocumentsディレクトリのNSURLを作成。
        let URLs = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask)
        var documentsDirectoryURL = URLs.first! //as! URL
        //  Documets/imagesディレクトリ作成。
        documentsDirectoryURL.appendPathComponent("images")
        let imageDirURL = documentsDirectoryURL
        return imageDirURL
    }
    
    //  新しい画像ファイル用にNSURLを戻す。
    fileprivate func URLNow() -> URL? {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMddHHmmss"
        let name = formatter.string(from: Date())
        let imageDirURL = self.imageDirURL
        for num in 0...1000 {
            let componentName = NSString(format:"%@_%05d.png",name, num)
            let url = imageDirURL.appendingPathComponent(componentName as String)
            if (FileManager.default.fileExists(atPath: url.path) == false) {
                return url
            }
        }
        return nil
    }
    
    //  ダミー画像作成。
    fileprivate func createImage()-> UIImage {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: 100, height: 100),   //  100x100の画像を作る。
            true,               //  不透明に設定。
            1)                  //  Retina画面へ最適化はしない。
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    //  指定されたインデックスのファイルを削除しimageURLsから取り除く。
    func removeImageAtIndex(_ index:Int) {
        let url = self.imageURLs[index]
      do {
        try FileManager.default.removeItem(at: url)
        self.imageURLs.remove(at: index)
      } catch {}
    }
    
    var URLs:[URL]! {
        return self.imageURLs
    }
}
