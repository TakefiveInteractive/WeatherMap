

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

    var timer = NSTimer()
    var timerCount = 0
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.shadowOffset = CGSizeMake(0, 2)
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.3
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func setup() {

        timeDisplay.roundCorner(UIRectCorner.AllCorners, radius: frame.width / 2)
        clock.addTarget(self, action: "clockClicked", forControlEvents: UIControlEvents.TouchUpInside)
        clock.layer.shadowOffset = CGSizeMake(0, 2)
        clock.layer.shadowRadius = 1
        clock.layer.shadowOpacity = 0.3
        blurView.roundCircle()
        blurView.alpha = 1
        addRotatingAnimation()
    }
    
    func dragged(sender: UIPanGestureRecognizer){
        
        if sender.state == UIGestureRecognizerState.Began{
            displayWeatherOfTheDay(futureDay)
        }
        
        let dotNum = parentController.timeLine.numberOfDots
        var index = sender.translationInView(self.parentController.timeLine.blurView).y + clockIndex
        if index < 0{
            self.transform = CGAffineTransformMake(0.5, 0, 0, 0.5, 0, 0)
        }else if index <= self.parentController.timeLine.blurView.frame.height{
            self.transform = CGAffineTransformMake(0.5, 0, 0, 0.5, 0, index)
        }else{
            self.transform = CGAffineTransformMake(0.5, 0, 0, 0.5, 0, self.parentController.timeLine.blurView.frame.height)
        }
        if sender.state == UIGestureRecognizerState.Cancelled || sender.state == UIGestureRecognizerState.Ended || sender.state == UIGestureRecognizerState.Failed{
            
            if index < 0{
                clockIndex = 0
            }else if index > self.parentController.timeLine.blurView.frame.height{
                clockIndex = self.parentController.timeLine.blurView.frame.height
            }else{
                clockIndex = index
            }
            
            // i is the number of day from current date  from 0 - dotNum
            for var i = 1; i <= dotNum; i++ {
                if clockIndex < self.parentController.timeLine.dots[i].center.y {
                    if sender.translationInView(self.parentController.timeLine.blurView).y > 0{
                        //dragging down
                        clockIndex = parentController.timeLine.dots[i].center.y
                        parentController.mapView.changeIconWithTime(i)

                    }else{
                        //dragging up
                        i--
                        clockIndex = parentController.timeLine.dots[i].center.y
                        parentController.mapView.changeIconWithTime(i)
                    }
                    futureDay = i
                    displayWeatherOfTheDay(futureDay)
                    break
                }
            }
        }
    }
    
    func displayWeatherOfTheDay(dayNum: Int){
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.transform = CGAffineTransformMake(0.5, 0, 0, 0.5, 0, self.clockIndex)
            }, completion: { (finish) -> Void in
                
                let date = NSDate()
                let calendar = NSCalendar.currentCalendar()
                let components = calendar.components(.CalendarUnitMonth | .CalendarUnitDay, fromDate: date)
                let month = components.month
                let day = components.day + dayNum
                
                if self.timerCount > 0{
                    self.timerCount = 0
                }else{
                    
                    self.timeLab = UILabel(frame: CGRectMake(0, 0, self.timeDisplay.frame.width - self.timeDisplay.frame.height, self.timeDisplay.frame.height))
                    self.timeLab.font = UIFont(name: "AvenirNextCondensed-Regular", size: 22)
                    self.timeLab.textAlignment = NSTextAlignment.Center
                    
                    self.timeDisplay.addSubview(self.timeLab)
                    
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.addLineAnimation()
                        self.timeDisplay.alpha = 1
                        })
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "countDisplayTime", userInfo: nil, repeats: true)

                }
                self.timeLab.text = "\(self.getBriefMonth(month)) \(day)"
                
        })

    }
    
    func getBriefMonth(month: Int)->String{
        switch month {
        case 1:
            return "Jan"
        case 2:
            return "Feb"
        case 3:
            return "Mar"
        case 4:
            return "Apr"
        case 5:
            return "May"
        case 6:
            return "June"
        case 7:
            return "July"
        case 8:
            return "Aug"
        case 9:
            return "Sep"
        case 10:
            return "Oct"
        case 11:
            return "Nov"
        case 12:
            return "Dec"
        default:
            return "??"
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
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.timeDisplay.alpha = 0
            self.timeDisplayOutLine.removeFromSuperlayer()
            self.timeLab.alpha = 0
        })
    }
    
    func clockClicked(){
        if !WeatherInfo.forcastMode{
            WeatherInfo.forcastMode = true
            clock.userInteractionEnabled = false
            parentController.timeLine.appear()
            parentController.returnBut.appear()
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.transform = CGAffineTransformMakeScale(0.5, 0.5)
            }, completion: { (finish) -> Void in
                self.displayWeatherOfTheDay(0)
            })
            dragger = UIPanGestureRecognizer(target: self, action: "dragged:")
            blurView.addGestureRecognizer(dragger)
        }
    }
    
    func clockReturnNormalSize(){
        if WeatherInfo.forcastMode{
            WeatherInfo.forcastMode = false
            parentController.mapView.changeIconWithTime(-1)
            clockIndex = 0
            futureDay = 0
            blurView.removeGestureRecognizer(dragger)
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
