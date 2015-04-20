

//
//  ClockView.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/20.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Spring

class ClockView: DesignableButton {
    
    var clock: UIImageView!
    var blurView: UIVisualEffectView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup(){
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blurView.frame = bounds
        blurView.userInteractionEnabled = false
        addSubview(blurView)
        
        clock = UIImageView(image:UIImage(named: "Newclock"))
        clock.frame = bounds//CGRectMake(2, 2, blurView.frame.width - 4, blurView.frame.height - 4)
        addSubview(clock)

        clock.layer.shadowOffset = CGSizeMake(0, 2)
        clock.layer.shadowRadius = 1
        clock.layer.shadowOpacity = 0.3
        
        let maskPath = UIBezierPath(ovalInRect:self.bounds)
        let mask = CAShapeLayer()
        mask.path = maskPath.CGPath
        self.layer.mask = mask
        

    }

}
