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
    
    static func getWeatherInChinese(iconStr: String)->String{
        
        if UserLocation.inChina{
        
            if iconStr == "01d" || iconStr == "01n" {
                return "晴"
            }else if iconStr == "02d" || iconStr == "02n" {
                return "局部多云"
            }else if iconStr == "03d" || iconStr == "03n" {
                return "多云"
            }else if iconStr == "04d" || iconStr == "04n" {
                return "阴"
            }else if iconStr == "09d" || iconStr == "09n" {
                return "大雨"
            }else if iconStr == "10d" || iconStr == "10n" {
                return "小雨"
            }else if iconStr == "11d" || iconStr == "11n" {
                return "雷阵雨"
            }else if iconStr == "13d" || iconStr == "13n" {
                return "雪"
            }else if iconStr == "50d" || iconStr == "50n" {
                return "大雾"
            }
        }else{
            
        }
        return ""
    }
    
    static func createImageForName(name: String){
        
        var img: UIImage!
        img = UIImage(named: name)!.resize(CGSizeMake(40, 40)).addShadow(blurSize: 3.0)
        IconImage.xlargeImage.updateValue(img, forKey: name)
        img = UIImage(named: name)!.resize(CGSizeMake(33, 33)).addShadow(blurSize: 3.0)
        IconImage.largeImage.updateValue(img, forKey: name)
        img = UIImage(named: name)!.resize(CGSizeMake(25, 25)).addShadow(blurSize: 3.0)
        IconImage.midImage.updateValue(img, forKey: name)
        img = UIImage(named: name)!.resize(CGSizeMake(20, 20)).addShadow(blurSize: 3.0)
        IconImage.smallImage.updateValue(img, forKey: name)
        img = UIImage(named: name)!.resize(CGSizeMake(30, 30)).addShadow(blurSize: 3.0)
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
    
    static func getEmptyImage()->UIImage{
         return empty!
    }
    
}
