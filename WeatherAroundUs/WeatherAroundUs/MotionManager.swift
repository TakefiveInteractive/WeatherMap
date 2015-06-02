
//
//  MotionManager.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/26.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import CoreMotion

@objc protocol MotionManagerDelegate: NSObjectProtocol{
    optional func gotAttitudeRoll(roll: CGFloat)
}

var UserMotion: MotionManager = MotionManager()

class MotionManager: NSObject{
    
    var manager = CMMotionManager()
    var delegate: MotionManagerDelegate?
    
    func start(){
        if manager.gyroAvailable {
            manager.gyroUpdateInterval = 0.4
            let queue = NSOperationQueue.mainQueue
            manager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XArbitraryCorrectedZVertical, toQueue: queue(), withHandler: { (data, error) -> Void in
                self.delegate?.gotAttitudeRoll!(CGFloat((data as CMDeviceMotion).attitude.roll))
            })
        }
    }
    
    func stop(){
        manager.stopDeviceMotionUpdates()
    }
    
}
