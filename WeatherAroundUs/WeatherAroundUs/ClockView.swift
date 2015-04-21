

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

    var parentController: ViewController!

    var dragMode = false
    
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
    }
    
    func clockClicked(){
        
        if !dragMode{
            dragMode = true
            addRotatingAnimation()
            parentController.timeLine.startLoading()
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.transform = CGAffineTransformMakeScale(0.5, 0.5)
            })
        }
    }
    
    func addRotatingAnimation(){
        rotatePin1()
        rotatePin2()
        rotatePin3()
    }
    
    func rotatePin1(){
        var rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(float: Float(M_PI * 2.0))
        rotationAnimation.duration = 1
        rotationAnimation.removedOnCompletion = false
        rotationAnimation.cumulative = true
        rotationAnimation.delegate = self
        pin1.layer.addAnimation(rotationAnimation, forKey: "loading")
    }
    
    func rotatePin2(){
        var rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(float: Float(M_PI * 2.0))
        rotationAnimation.duration = 10
        rotationAnimation.removedOnCompletion = false
        rotationAnimation.cumulative = true
        rotationAnimation.delegate = self
        pin2.layer.addAnimation(rotationAnimation, forKey: "loading")
    }
    
    func rotatePin3(){
        var rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(float: Float(M_PI * 2.0))
        rotationAnimation.duration = 100
        rotationAnimation.removedOnCompletion = false
        rotationAnimation.cumulative = true
        rotationAnimation.delegate = self
        pin3.layer.addAnimation(rotationAnimation, forKey: "loading")
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        
        if anim == pin1.layer.animationForKey("loading"){
            rotatePin1()
        }else if anim == pin2.layer.animationForKey("loading"){
            rotatePin2()
        }else if anim == pin3.layer.animationForKey("loading"){
            rotatePin3()
        }
    }
    
    func dragged(sender: UIPanGestureRecognizer){
        println(sender.translationInView(self).y)
    }
    
}
