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
        
        UserMotion.stop()
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.alpha = 0.4
            }) { (finish) -> Void in
                let width = UIScreen.mainScreen().bounds.width
                let height = UIScreen.mainScreen().bounds.height
                // long image
                if image.size.width / image.size.height > width / height{
                    self.contentSize = CGSizeMake(height * image.size.width / image.size.height, height)
                    self.imageView.frame.size = self.contentSize
                    self.setContentOffset(CGPointMake((self.contentSize.width - width) / 2, 0), animated: false)
                    
                    UserMotion.delegate = self
                    UserMotion.start()
                }else{
                    // don't enable motion
                    self.contentSize = CGSizeMake(width, width * image.size.height / image.size.width)
                    self.imageView.frame.size = self.contentSize
                    self.setContentOffset(CGPointMake(0, (self.contentSize.height - height) / 2), animated: false)
                }
                
                self.imageView.image = image
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.alpha = 1
                })
        }
        
    }
    
    func gotImageFromCache(image: UIImage, cityID: String) {
        changeImage(image)
    }
    
    func gotAttitudeRoll(roll: CGFloat) {
        var num = roll
        if abs(roll) > 0.1{

            var animateIndex:CGFloat = 0
            
            if contentOffset.x >= 5 && contentOffset.x <= contentSize.width - UIScreen.mainScreen().bounds.width - 5 {
                if num > 1{
                    num = 1
                }else if num < -1 {
                    num = -1
                }
                animateIndex = contentOffset.x + num
            }else if contentOffset.x < 5{
                animateIndex = 5
            }else if contentOffset.x > contentSize.width - UIScreen.mainScreen().bounds.width - 5{
                animateIndex = contentSize.width - UIScreen.mainScreen().bounds.width - 5
            }
            
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.contentOffset = CGPointMake(animateIndex, 0)
            })
            
        }
    }

}
