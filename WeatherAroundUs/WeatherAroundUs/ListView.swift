//
//  ListView.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/13.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit

class ListView: UIView {

    var weatherCardList = [UIButton]()
    
    let theHeight: CGFloat = 40
    
    var timer = NSTimer()
    var timeCount = 0
    
    func addACity(cityID: String, name: String){
        let aCity = UIButton(frame: CGRectMake(4, 4, self.frame.width - 8, theHeight))
        aCity.titleLabel?.text = cityID
        aCity.alpha = 0
        weatherCardList.append(aCity)
        
        //only one card
        if weatherCardList.count == 1{
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                aCity.alpha = 1
            }, completion: { (finish) -> Void in
                self.timeCount = 0
                self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "startCounting", userInfo: nil, repeats: true)
            })
        }
        
    }
    
    func startCounting(){
        if timeCount < 8{
            timeCount++
        }else{
            cardsDisappear()
            timer.invalidate()
            timeCount = 0
        }
    }
    
    func cardsDisappear(){
        
    }
    
}
