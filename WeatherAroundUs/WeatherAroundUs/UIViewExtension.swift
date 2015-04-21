//
//  UIViewExtension.swift
//  PaperPlane
//
//  Created by Kedan Li on 15/2/27.
//  Copyright (c) 2015年 Yu Wang. All rights reserved.
//
import QuartzCore
import UIKit

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = duration
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        self.layer.addAnimation(rotateAnimation, forKey: nil)
    }
    
    func getTheImageOfTheView()->UIImage{
        UIGraphicsBeginImageContext(self.bounds.size)
        self.layer.renderInContext(UIGraphicsGetCurrentContext())
        var outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage
    }
    
    func roundCorner(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSizeMake(radius, radius))
        var mask = CAShapeLayer()
        mask.frame = self.bounds;
        mask.path = maskPath.CGPath;
        layer.mask = mask;
    }
    
    func roundCircle(){
        let maskPath = UIBezierPath(ovalInRect:self.bounds)
        let mask = CAShapeLayer()
        mask.path = maskPath.CGPath
        layer.mask = mask
    }
    
}