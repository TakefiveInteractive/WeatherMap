
//
//  ImageCache.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/20.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Haneke

@objc protocol ImageCacheDelegate: class {
    optional func gotImageFromCache(image: UIImage, cityID: String)
    optional func gotSmallImageFromCache(image: UIImage, cityID: String)
}

class ImageCache: NSObject {
    
    static var smallImagesUrl = [String: String]()
    static var imagesUrl = [String: String]()

    var delegate: ImageCacheDelegate!

    func getSmallImageFromCache(url: String, cityID: String){
        // get the image from cache
        let cache = Shared.dataCache
        var img = UIImage()
        cache.fetch(URL: NSURL(string: url)!).onSuccess { image in
            img = UIImage(data: image)!
            self.delegate?.gotSmallImageFromCache!(img, cityID: cityID)
        }
    }
    
    func getImageFromCache(url: String, cityID: String){
        
        // get the image from cache
        let cache = Shared.dataCache
        var img = UIImage()
        cache.fetch(URL: NSURL(string: url)!).onSuccess { image in
            img = UIImage(data: image)!
            self.delegate?.gotImageFromCache!(img, cityID: cityID)
        }
    }
    
}
