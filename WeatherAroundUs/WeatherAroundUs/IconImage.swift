//
//  ImageFiles.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/24.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit

enum IconSize {
    case Large
    case Mid
    case Small
    case XLarge
    case Reduced
}

class IconImage: NSObject {
    
    static var smallImage = [String: UIImage]()
    static var midImage = [String: UIImage]()
    static var largeImage = [String: UIImage]()
    static var xlargeImage = [String: UIImage]()
    static var reducedImage = [String: UIImage]()
    static var empty = UIImage(color: UIColor.clearColor(), size: CGSizeMake(1, 1))
    static func setupPhotos() {
        
        IconImage.createImageForName("01d")
        IconImage.createImageForName("01n")
        IconImage.createImageForName("02d")
        IconImage.createImageForName("02n")
        IconImage.createImageForName("03d")
        IconImage.createImageForName("03n")
        IconImage.createImageForName("04d")
        IconImage.createImageForName("04n")
        IconImage.createImageForName("09d")
        IconImage.createImageForName("09n")
        IconImage.createImageForName("10d")
        IconImage.createImageForName("10n")
        IconImage.createImageForName("11d")
        IconImage.createImageForName("11n")
        IconImage.createImageForName("13d")
        IconImage.createImageForName("13n")
        IconImage.createImageForName("50d")
        IconImage.createImageForName("50n")

    }
    
    static func createImageForName(name: String){
        
        var img: UIImage!
        img = UIImage(named: name)!.resize(CGSizeMake(50, 50)).addShadow(blurSize: 3.0)
        IconImage.xlargeImage.updateValue(img, forKey: name)
        img = UIImage(named: name)!.resize(CGSizeMake(40, 40)).addShadow(blurSize: 3.0)
        IconImage.largeImage.updateValue(img, forKey: name)
        img = UIImage(named: name)!.resize(CGSizeMake(33, 33)).addShadow(blurSize: 3.0)
        IconImage.midImage.updateValue(img, forKey: name)
        img = UIImage(named: name)!.resize(CGSizeMake(25, 25)).addShadow(blurSize: 3.0)
        IconImage.smallImage.updateValue(img, forKey: name)
        img = UIImage(named: name)!.resize(CGSizeMake(35, 35)).addShadow(blurSize: 3.0)
        IconImage.reducedImage.updateValue(img, forKey: name)
    }
    
    static func getImageWithNameAndSize(name: String, size: IconSize)->UIImage{
        
        if name == "empty"{
            return empty!
        }
        
        switch size {
        case .XLarge:
            return IconImage.xlargeImage[name]!
        case .Large:
            return IconImage.largeImage[name]!
        case .Small:
            return IconImage.smallImage[name]!
        case .Mid:
            return IconImage.midImage[name]!
        case .Reduced:
            return IconImage.reducedImage[name]!
        }
    }
    
}
