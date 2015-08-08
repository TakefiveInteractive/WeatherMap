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
    
    var isAnimating = false
    
    func setup(image: UIImage){
        imageView.image = image
        
        let width = UIScreen.mainScreen().bounds.width
        let height = UIScreen.mainScreen().bounds.height
        // long image
        if image.size.width / image.size.height > width / height{
            contentSize = CGSizeMake(height * image.size.width / image.size.height, height)
            imageView.frame.size = contentSize
            setContentOffset(CGPointMake((contentSize.width - width) / 2, 0), animated: false)
            
            UserMotion.delegate = self
            UserMotion.start()
        }else{
            // don't enable motion
            contentSize = CGSizeMake(width, width * image.size.height / image.size.width)
            imageView.frame.size = contentSize
            setContentOffset(CGPointMake(0, (contentSize.height - height) / 2), animated: false)
        }
        addSubview(imageView)
    }
    
    func changeImage(image: UIImage){
        
        UserMotion.delegate = nil
        
        var img = self.imageView
        
        let width = UIScreen.mainScreen().bounds.width
        let height = UIScreen.mainScreen().bounds.height
        var newsize = CGSize()
        
        if image.size.width / image.size.height > width / height{
            newsize = CGSizeMake(height * image.size.width / image.size.height, height)
            self.imageView = UIImageView()
            imageView.frame.size = newsize
            imageView.center = img.center
            
        }else{
            // don't enable motion
            newsize = CGSizeMake(width, width * image.size.height / image.size.width)
            self.imageView = UIImageView()
            imageView.frame.size = newsize
            imageView.center = img.center
        }
        imageView.alpha = 0
        addSubview(imageView)
        imageView.image = image
        
        UIView.animateWithDuration(5, animations: { () -> Void in
            img.alpha = 0
            self.imageView.alpha = 1
            self.setContentOffset(CGPointMake((img.frame.width - width) / 2, 0), animated: false)
            
            }) { (finish) -> Void in
                
                UserMotion.delegate = self
                UserMotion.start()
                self.contentSize = newsize
                self.imageView.frame = CGRectMake(0, 0, newsize.width, newsize.height)
                
                if image.size.width / image.size.height > width / height{
                    self.setContentOffset(CGPointMake( (newsize.width - width) / 2, 0), animated: false)
                }else{
                    // don't enable motion
                    self.setContentOffset(CGPointMake(0, (newsize.height - height) / 2), animated: false)
                }
        }
        
    }
    
    func gotImageFromCache(image: UIImage, cityID: String) {
        changeImage(image)
    }
    
    func gotAttitudeRoll(roll: CGFloat) {
        var num = roll
        if abs(roll) > 0.1{
            
            var animateIndex:CGFloat = 0
            
            if contentOffset.x >= 2 && contentOffset.x <= contentSize.width - UIScreen.mainScreen().bounds.width - 2 {
                if num > 0{
                    num = 2
                }else if num < 0 {
                    num = -2
                }
                animateIndex = contentOffset.x + num
            }else{
                return
            }
            
            if !isAnimating{
                self.isAnimating = true
                UIView.animateWithDuration(0.05, animations: { () -> Void in
                    self.contentOffset = CGPointMake(animateIndex, 0)
                    }, completion: { (finish) -> Void in
                        self.isAnimating = false
                })
            }
        }
    }
    
}
