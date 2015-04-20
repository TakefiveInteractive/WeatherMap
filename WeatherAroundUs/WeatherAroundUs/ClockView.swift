

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
    @IBOutlet var clockLoading: UIImageView!

    var parentController: ViewController!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func setup() {
        clock.addTarget(self, action: "clockClicked", forControlEvents: UIControlEvents.TouchUpInside)
        clock.layer.shadowOffset = CGSizeMake(0, 2)
        clock.layer.shadowRadius = 1
        clock.layer.shadowOpacity = 0.3
        let maskPath = UIBezierPath(ovalInRect:self.bounds)
        let mask = CAShapeLayer()
        mask.path = maskPath.CGPath
        blurView!.layer.mask = mask
    }
    
    func clockClicked(){
        addRotatingAnimation()
        parentController.timeLine.manager.getAffectedCities()
        
    }
    func addRotatingAnimation(){
        var rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(float: Float(M_PI * 2.0))
        rotationAnimation.duration = 1.0
        rotationAnimation.removedOnCompletion = false
        rotationAnimation.cumulative = true
        rotationAnimation.delegate = self
        clockLoading.layer.addAnimation(rotationAnimation, forKey: "loading")
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        
        if anim == clockLoading.layer.animationForKey("loading"){
            addRotatingAnimation()
        }
    }
}
