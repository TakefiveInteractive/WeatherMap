
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
    
    func saveImageURL(cityID: String, url: String, key:String){
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        var urlMap: NSMutableDictionary = (userDefault.objectForKey(key) as! NSDictionary).mutableCopy() as! NSMutableDictionary
        urlMap.setObject(url, forKey: cityID)
        userDefault.setObject(urlMap, forKey: key)
        userDefault.synchronize()
    }
    
    
}
