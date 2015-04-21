//
//  LoadingView.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/20.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Spring

class TimeLineView: DesignableView ,TimeLineManagerDelegate{

    var blurView: UIVisualEffectView!

    var parentController: ViewController!

    var manager: TimeLineManager!
    
    var unloadedLine: UIView!

    var loadedLine = UIView()
    var dots = [UIImageView]()


    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.shadowOffset = CGSizeMake(0, 2)
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.3
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blurView.frame = bounds
        blurView.roundCorner(UIRectCorner.AllCorners, radius: bounds.width / 2)
        addSubview(blurView)
        
        unloadedLine = UIView()
        unloadedLine.frame.size = CGSizeMake(1.5, self.frame.height - self.frame.width)
        unloadedLine.backgroundColor = UIColor.lightGrayColor()
        unloadedLine.alpha = 0.5
        unloadedLine.center = blurView.center
        addSubview(unloadedLine)
        
        createDotsAndLine()
    }
    
    func setupManager(){
        manager = TimeLineManager(mapView: parentController.mapView)
        manager.delegate = self
    }
    
    func createDotsAndLine(){
        
        loadedLine.removeFromSuperview()
        loadedLine = UIView(frame: unloadedLine.bounds)
        loadedLine.frame.size = CGSizeMake(unloadedLine.frame.width, 0)
        loadedLine.backgroundColor = UIColor(red: 68/255.0, green: 155/255.0, blue: 153/255.0, alpha: 1)
        unloadedLine.addSubview(loadedLine)
        
        for var index:CGFloat = 0; index < 17; index++ {
            var dot = UIImage(color: UIColor(red: 68/255.0, green: 155/255.0, blue: 153/255.0, alpha: 1), size: CGSizeMake(50, 50))
            dot = dot?.roundCornersToCircle()
            var dotView = UIImageView(image: dot!)
            dotView.frame.size = CGSizeMake(6, 6)
            dotView.center = CGPointMake(self.frame.width / 2, unloadedLine.frame.origin.y +  unloadedLine.frame.height / 17 * (index + 1))
            dots.append(dotView)
        }
    }
    
    func progressUpdated(progress: Double) {
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            self.loadedLine.frame.size = CGSizeMake(self.loadedLine.frame.width, self.unloadedLine.frame.height * CGFloat(progress))
        })
    }

}
