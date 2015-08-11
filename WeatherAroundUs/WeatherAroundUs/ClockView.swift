

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
    @IBOutlet var timeDisplay: UIVisualEffectView!
    
    var timeLab: UILabel!

    var timeDisplayOutLine = CAShapeLayer()

    // transform index in dragging
    var clockIndex: CGFloat = 0
    // 0 - 9 witch dot it displays
    var futureDay = 0
    
    var parentController: ViewController!

    var dragger: UIPanGestureRecognizer!
    var dragger2: UIPanGestureRecognizer!

    var timer = NSTimer()
    var timerCount = 0
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.shadowOffset = CGSizeMake(1, 1)
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.5
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func setup() {
        timeDisplay.roundCorner(UIRectCorner.AllCorners, radius: frame.width / 2)
        clock.addTarget(self, action: "clockClicked", forControlEvents: UIControlEvents.TouchUpInside)
        blurView.roundCircle()
        blurView.alpha = 1
        addRotatingAnimation()
        
        self.timeLab = UILabel(frame: CGRectMake(0, 0, self.timeDisplay.frame.width - self.timeDisplay.frame.height, self.timeDisplay.frame.height))
        self.timeLab.font = UIFont(name: "AvenirNextCondensed-Regular", size: 22)
        self.timeLab.textAlignment = NSTextAlignment.Center
        self.timeDisplay.addSubview(self.timeLab)
    }
    
    func dragged(sender: UIPanGestureRecognizer){
        
        if sender.state == UIGestureRecognizerState.Began{
            displayWeatherOfTheDay(futureDay)
        }
        
        var index = sender.translationInView(self.parentController.timeLine.blurView).y + clockIndex
        if index < 0{
            self.transform = CGAffineTransformMake(0.75, 0, 0, 0.75, 0, 0)
        }else if index <= self.parentController.timeLine.blurView.frame.height{
            self.transform = CGAffineTransformMake(0.75, 0, 0, 0.75, 0, index)
        }else{
            self.transform = CGAffineTransformMake(0.75, 0, 0, 0.75, 0, self.parentController.timeLine.blurView.frame.height)
        }
        if sender.state == UIGestureRecognizerState.Cancelled || sender.state == UIGestureRecognizerState.Ended || sender.state == UIGestureRecognizerState.Failed{
            
            if index < 0{
                clockIndex = 0
            }else if index > self.parentController.timeLine.blurView.frame.height{
                clockIndex = self.parentController.timeLine.blurView.frame.height
            }else{
                clockIndex = index
            }
            
            let dotNum = parentController.timeLine.numberOfDots
            // i is the number of day from current date  from 0 - dotNum
            for var i = 1; i <= dotNum; i++ {
                if index < self.parentController.timeLine.dots[i].center.y {
                    futureDay = i
                    if sender.translationInView(self.parentController.timeLine.blurView).y > 0{
                        //dragging down
                        clockIndex = parentController.timeLine.dots[i].center.y
                        parentController.mapView.changeIconWithTime()
                        
                    }else{
                        //dragging up
                        i--
                        clockIndex = parentController.timeLine.dots[i].center.y
                        parentController.mapView.changeIconWithTime()
                    }
                    displayWeatherOfTheDay(futureDay)
                    self.parentController.card.displayCity(WeatherInfo.currentCityID)
                    break
                }
            }
        }
    }
    
    func displayWeatherOfTheDay(dayNum: Int){
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.transform = CGAffineTransformMake(0.75, 0, 0, 0.75, 0, self.clockIndex)
        })
        
        self.timerCount = 0
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.addLineAnimation()
            self.timeDisplay.alpha = 1
        })
        timer.invalidate()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "countDisplayTime", userInfo: nil, repeats: true)
        
        var currDate = NSDate(timeIntervalSinceNow: 24 * 60 * 60 * Double(dayNum))
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        let dateStr = dateFormatter.stringFromDate(currDate)
        self.timeLab.text = dateStr
        
        //handle chinese
        if self.timeLab.text!.rangeOfString("月") != nil {
            self.timeLab.text = self.timeLab.text! + "日"
        }

    }
    
    func countDisplayTime(){
        timerCount++
        if timerCount >= 30{
            timer.invalidate()
            timerCount = 0
            dateIndicatorDisappear()
        }
    }
    
    func dateIndicatorDisappear(){
        timerCount = 0
        timer.invalidate()
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.timeDisplay.alpha = 0
            self.timeDisplayOutLine.removeFromSuperlayer()
        })
    }
    
    func clockClicked(){
        if !WeatherInfo.forcastMode{
            WeatherInfo.forcastMode = true
            clock.userInteractionEnabled = false
            parentController.timeLine.appear()
            parentController.returnBut.appear()
            parentController.searchBar.hideSelf()
            parentController.mapView.changeIconWithTime()
            self.displayWeatherOfTheDay(0)
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.transform = CGAffineTransformMakeScale(0.75, 0.75)
                }){ (finish) -> Void in
                    self.dragger = UIPanGestureRecognizer(target: self, action: "dragged:")
                    self.blurView.addGestureRecognizer(self.dragger)
                    self.dragger2 = UIPanGestureRecognizer(target: self, action: "dragged:")
                    self.timeDisplay.addGestureRecognizer(self.dragger2)
            }

        }
    }
    
    func clockReturnNormalSize(){
        
        if WeatherInfo.forcastMode{
            WeatherInfo.forcastMode = false
            parentController.mapView.changeIconWithTime()
            clockIndex = 0
            futureDay = 0
            blurView.removeGestureRecognizer(dragger)
            timeDisplay.removeGestureRecognizer(dragger)
            dateIndicatorDisappear()
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.transform = CGAffineTransformMakeScale(1, 1)
                }) { (finish) -> Void in
                    self.clock.userInteractionEnabled = true
            }
        }
    }
    
    func addRotatingAnimation(){
        rotatePin(pin1, time: 10)
        rotatePin(pin2, time: 100)
        rotatePin(pin3, time: 1000)
    }
    
    func rotatePin(pin: UIView, time: Double){
        pin.layer.removeAllAnimations()
        var rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(float: Float(M_PI * 2.0))
        rotationAnimation.duration = time
        rotationAnimation.removedOnCompletion = false
        rotationAnimation.cumulative = true
        rotationAnimation.delegate = self
        pin.layer.addAnimation(rotationAnimation, forKey: "loading")
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        //rotate forever
        if anim == pin1.layer.animationForKey("loading"){
            rotatePin(pin1, time: 10)
        }else if anim == pin2.layer.animationForKey("loading"){
            rotatePin(pin2, time: 100)
        }else if anim == pin3.layer.animationForKey("loading"){
            rotatePin(pin3, time: 1000)
        }
    }
    
    func addLineAnimation(){
        timeDisplayOutLine.path = drawPath().CGPath
        timeDisplayOutLine.strokeColor = UIColor(red: 0.267, green: 0.608, blue: 0.600, alpha: 1.000).CGColor
        timeDisplayOutLine.fillColor = UIColor.clearColor().CGColor
        timeDisplayOutLine.lineWidth = 2
        timeDisplayOutLine.lineCap = kCALineCapRound
        timeDisplay.layer.addSublayer(timeDisplayOutLine)
        
        var animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        animateStrokeEnd.duration = 3.0
        animateStrokeEnd.fromValue = 0
        animateStrokeEnd.toValue = 1.0
        animateStrokeEnd.delegate = self
        animateStrokeEnd.fillMode = kCAFillModeForwards
        animateStrokeEnd.removedOnCompletion = true
        timeDisplayOutLine.addAnimation(animateStrokeEnd, forKey: "drawOutline")
    }
    
    func drawPath()->UIBezierPath{
        var polygonPath = UIBezierPath()
        polygonPath.moveToPoint(CGPointMake(timeDisplay.bounds.maxX, timeDisplay.bounds.maxY / 2))
        polygonPath.addCurveToPoint(CGPointMake(timeDisplay.bounds.maxX - timeDisplay.bounds.maxY / 2, 0), controlPoint1: CGPointMake(timeDisplay.bounds.maxX, timeDisplay.bounds.maxY / 4), controlPoint2: CGPointMake(timeDisplay.bounds.maxX - timeDisplay.bounds.maxY / 4, 0))
        polygonPath.addLineToPoint(CGPointMake(timeDisplay.bounds.maxY / 2, 0))
        polygonPath.addCurveToPoint(CGPointMake(0, timeDisplay.bounds.maxY / 2), controlPoint1: CGPointMake(timeDisplay.bounds.maxY / 4, 0), controlPoint2: CGPointMake(0, timeDisplay.bounds.maxY / 4))
        polygonPath.addCurveToPoint(CGPointMake(timeDisplay.bounds.maxY / 2, timeDisplay.bounds.maxY), controlPoint1: CGPointMake(0, timeDisplay.bounds.maxY * 3 / 4), controlPoint2: CGPointMake(timeDisplay.bounds.maxY / 4, timeDisplay.bounds.maxY))
        polygonPath.addLineToPoint(CGPointMake(timeDisplay.bounds.maxX, timeDisplay.bounds.maxY))

        polygonPath.closePath()
        return polygonPath
    }

}
