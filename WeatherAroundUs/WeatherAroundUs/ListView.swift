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
    
    let theHeight: CGFloat = 25
    
    var timer = NSTimer()
    var timeCount = 0
    
    func addACity(cityID: String, cityName: String){
        
        //move down cards

        if weatherCardList.count > 0 {
            
            // move down
            for city in weatherCardList {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    city.center = CGPointMake(city.center.x, city.center.y + self.theHeight + 8)
                })
            }
            
        }
        
        //add a card
        let aCity = UIButton(frame: CGRectMake(4, 4, self.frame.width - 8, theHeight))
        aCity.setImage(UIImage(named: "acard"), forState: UIControlState.Normal)
        aCity.titleLabel?.text = cityID
        aCity.alpha = 0.8
        self.addSubview(aCity)
        weatherCardList.insert(aCity, atIndex: 0)
        
        var lab = UILabel(frame: aCity.frame)
        lab.font = UIFont(name: "Slayer", size: 11)
        lab.text = cityName
        lab.textColor = UIColor(red: 196/255.0, green: 138/255.0, blue: 92/255.0, alpha: 1)
        aCity.addSubview(lab)
        
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            aCity.alpha = 1
            
            }, completion: { (finish) -> Void in
                self.timeCount = 0
                self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "startCounting", userInfo: nil, repeats: true)
        })
        
        if weatherCardList.count > 12{
            
            let card = weatherCardList.last
            weatherCardList.removeLast()
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                card?.alpha = 0
            })
        }
        
        // change size
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.frame.size = CGSizeMake(self.frame.width, CGFloat(self.weatherCardList.count) * self.theHeight + 8)
        })
        
        
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
    
    func resize(){
        
    }
    
}
