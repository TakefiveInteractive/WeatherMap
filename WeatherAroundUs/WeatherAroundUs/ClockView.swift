

//
//  ClockView.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/20.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Spring

class ClockView: DesignableView{
    
    @IBOutlet var clock: UIButton!
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var pin3: UIImageView!
    @IBOutlet var pin2: UIImageView!
    @IBOutlet var pin1: UIImageView!

    // transform index in dragging
    var clockIndex: CGFloat = 0
    
    var parentController: ViewController!

    var dragMode = false
    var dragger: UIPanGestureRecognizer!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func setup() {
        layer.shadowOffset = CGSizeMake(0, 2)
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.3
        clock.addTarget(self, action: "clockClicked", forControlEvents: UIControlEvents.TouchUpInside)
        clock.layer.shadowOffset = CGSizeMake(0, 2)
        clock.layer.shadowRadius = 1
        clock.layer.shadowOpacity = 0.3
        blurView.roundCircle()
        
        clock.userInteractionEnabled = false
        addRotatingAnimation()

        dragger = UIPanGestureRecognizer(target: self, action: "dragged:")
        blurView.addGestureRecognizer(dragger)
    }
    
    func addRotatingAnimation(){
        rotatePin(pin1, time: 1)
        rotatePin(pin2, time: 10)
        rotatePin(pin3, time: 100)
    }
    func rotatePin(pin: UIView, time: Double){
        var rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(float: Float(M_PI * 2.0))
        rotationAnimation.duration = time
        rotationAnimation.removedOnCompletion = false
        rotationAnimation.cumulative = true
        rotationAnimation.delegate = self
        pin.layer.addAnimation(rotationAnimation, forKey: "loading")
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
      
        if flag{
            if anim == pin1.layer.animationForKey("loading"){
                rotatePin(pin1, time: 10)
            }else if anim == pin2.layer.animationForKey("loading"){
                rotatePin(pin2, time: 100)
            }else if anim == pin3.layer.animationForKey("loading"){
                rotatePin(pin3, time: 1000)
            }
        }
    }
    
    func dragged(sender: UIPanGestureRecognizer){
        

        var index = sender.translationInView(self.parentController.timeLine.blurView).y + clockIndex
        println(index)
        if index < 0{
            self.transform = CGAffineTransformMakeTranslation(0, 0)
        }else if index <= self.parentController.timeLine.blurView.frame.height - self.parentController.timeLine.blurView.frame.width{
            self.transform = CGAffineTransformMakeTranslation(0, index)
        }else{
            self.transform = CGAffineTransformMakeTranslation(0, self.parentController.timeLine.blurView.frame.height - self.parentController.timeLine.blurView.frame.width)
        }
        if sender.state == UIGestureRecognizerState.Cancelled || sender.state == UIGestureRecognizerState.Ended || sender.state == UIGestureRecognizerState.Failed{
            
            if index < 0{
                clockIndex = 0
            }else if index > self.parentController.timeLine.blurView.frame.height - self.parentController.timeLine.blurView.frame.width{
                clockIndex = self.parentController.timeLine.blurView.frame.height - self.parentController.timeLine.blurView.frame.width
            }else{
                clockIndex = index
            }
            
            // initially set to the highest
            for var i = 0; i < 7; i++ {
                if clockIndex < self.parentController.timeLine.frame.height / 7 * CGFloat(i) + parentController.timeLine.frame.height / 7 / 2 {
                    clockIndex = parentController.timeLine.dots[i].center.y - self.parentController.timeLine.blurView.frame.width
                    parentController.mapView.changeIconWithTime(i)
                    break
                }
            }
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.transform = CGAffineTransformMakeTranslation(0, self.clockIndex)
            })
            
        }
        
    }
    
}
