//
//  ImageScrollerView.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/26.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit

class ImageScrollerView: UIScrollView, ImageCacheDelegate, MotionManagerDelegate{

    var imageView = UIImageView()
    
    func setup(image: UIImage){
        imageView.image = image
        
        let width = UIScreen.mainScreen().bounds.width
        let height = UIScreen.mainScreen().bounds.height
        // long image
        if image.size.width / image.size.height > width / height{
            contentSize = CGSizeMake(height * image.size.width / image.size.height, height)
            imageView.frame.size = contentSize
            addSubview(imageView)
            setContentOffset(CGPointMake((contentSize.width - width) / 2, 0), animated: false)
        }else{
            // don't enable motion
            contentSize = CGSizeMake(width, width * image.size.height / image.size.width)
            imageView.frame.size = contentSize
            addSubview(imageView)
            setContentOffset(CGPointMake(0, (contentSize.height - height) / 2), animated: false)
        }
        
        UserMotion.delegate = self
        UserMotion.start()
    }
    
    func gotImageFromCache(image: UIImage, cityID: String) {
        imageView.image = image
    }
    
    func gotAttitudeRoll(roll: CGFloat) {
        println(roll)
        var num = roll
        if abs(roll) > 0.1{
            if contentOffset.x >= 5 && contentOffset.x <= contentSize.width - UIScreen.mainScreen().bounds.width - 5 {
                if num > 1{
                    num = 1
                }else if num < -1 {
                    num = -1
                }
                setContentOffset(CGPointMake(contentOffset.x + num, 0), animated: false)
            }else if contentOffset.x < 5{
                setContentOffset(CGPointMake(5, 0), animated: false)
            }else if contentOffset.x > contentSize.width - UIScreen.mainScreen().bounds.width - 5{
                setContentOffset(CGPointMake(contentSize.width - UIScreen.mainScreen().bounds.width - 5, 0), animated: false)
            }
        }
    }

}
