//
//  LoadingView.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/20.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Spring

class TimeLineView: DesignableView {

    let numberOfDots = 8
    
    @IBOutlet var blurView: UIVisualEffectView!

    var parentController: ViewController!

    var manager: TimeLineManager!
    
    var unloadLine: UIView!

    var loadedLine = UIView()
    var dots = [UIImageView]()


    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        layer.shadowOffset = CGSizeMake(0, 2)
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.3
        
        var gesture = UITapGestureRecognizer(target: self, action: "touched:")
        addGestureRecognizer(gesture)
    }
    
    func setup(){

        blurView.roundCorner(UIRectCorner.AllCorners, radius: bounds.width / 2)
        
        unloadLine = UIView()
        unloadLine.frame.size = CGSizeMake(1.5, self.blurView.frame.height - self.blurView.frame.width)
        unloadLine.backgroundColor = UIColor.lightGrayColor()
        unloadLine.alpha = 0.5
        unloadLine.center = blurView.center
        addSubview(unloadLine)
        
        loadedLine = UIView(frame: unloadLine.bounds)
        loadedLine.frame.size = CGSizeMake(unloadLine.frame.width, 0)
        loadedLine.backgroundColor = UIColor(red: 68/255.0, green: 155/255.0, blue: 153/255.0, alpha: 1)
        unloadLine.addSubview(loadedLine)
        
        for var index:CGFloat = 0; index <= CGFloat(numberOfDots); index++ {

            var dot = UIImage(color: UIColor(red: 68/255.0, green: 155/255.0, blue: 153/255.0, alpha: 1), size: CGSizeMake(50, 50))
            dot = dot?.roundCornersToCircle()
            var dotView = UIImageView(image: dot!)
            dotView.frame.size = CGSizeMake(6, 6)
            dotView.center = CGPointMake(self.frame.width / 2, unloadLine.frame.origin.y +  unloadLine.frame.height / CGFloat(numberOfDots) * (index))
            addSubview(dotView)
            dotView.transform = CGAffineTransformMakeScale(0.01, 0.01)
            dots.append(dotView)
        }
        
    }
    
    func touched(sender: UITapGestureRecognizer){
        
        // i is the number of day from current date  from 0 - dotNum
        for var i = 1; i <= numberOfDots; i++ {
            if sender.locationInView(self).y < dots[i].center.y {
                parentController.clockButton.futureDay = i
                if parentController.clockButton.clockIndex < sender.locationInView(self).y{
                    //dragging down
                    parentController.clockButton.clockIndex = dots[i].center.y
                    parentController.mapView.changeIconWithTime()
                    
                }else{
                    //dragging up
                    i--
                    parentController.clockButton.clockIndex = dots[i].center.y
                    parentController.mapView.changeIconWithTime()
                }
                parentController.clockButton.displayWeatherOfTheDay(i)
                parentController.card.displayCity(WeatherInfo.currentCityID)
                break
            }
        }

    }
    
    func appear(){
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.alpha = 1
        })

        UIView.animateWithDuration(1, animations: { () -> Void in
            self.loadedLine.frame.size = CGSizeMake(self.loadedLine.frame.width, self.unloadLine.frame.height)
        })
    
        for var i = 0; i <= numberOfDots; i++ {
            UIView.animateWithDuration(0.2, delay: 0.2 * Double(i), options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.dots[i].transform = CGAffineTransformMakeScale(1, 1)
                }) { (finish) -> Void in
            }
        }
    }
    func disAppear(){
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.alpha = 0
            }) { (finish) -> Void in
                for dot in self.dots{
                    dot.transform = CGAffineTransformMakeScale(0.01, 0.01)
                }
                self.loadedLine.frame.size = CGSizeMake(self.unloadLine.frame.width, 0)
        }
    }
}
