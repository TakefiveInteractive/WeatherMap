//
//  ListView.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/13.
import UIKit

class ListView: UIView {
    
    var parentController: ViewController!
    
    var weatherCardList = [UIButton]()
    
    let theHeight: CGFloat = 20
    let maxCity: Int = 15
    
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
        let aCity = UIButton(frame: CGRectMake(4, 2, self.frame.width - 8, theHeight))
        aCity.setImage(UIImage(named: "acard"), forState: UIControlState.Normal)
        aCity.tag = (cityID as NSString).integerValue
        aCity.alpha = 0
        aCity.addTarget(self, action: "chooseCity:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(aCity)
        weatherCardList.insert(aCity, atIndex: 0)
        
        var lab = UILabel(frame: aCity.frame)
        lab.font = UIFont(name: "Slayer", size: 11)
        lab.text = cityName
        lab.textColor = UIColor(red: 196/255.0, green: 138/255.0, blue: 92/255.0, alpha: 1)
        aCity.addSubview(lab)
        
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.alpha = 1
            aCity.alpha = 0.8
            
            }, completion: { (finish) -> Void in
                self.timeCount = 0
                self.timer = NSTimer.scheduledTimerWithTimeInterval(25, target: self, selector: "startCounting", userInfo: nil, repeats: true)
        })
        
        if weatherCardList.count > maxCity{
            
            let card = weatherCardList.last
            weatherCardList.removeLast()
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                card?.alpha = 0
                card?.removeFromSuperview()
            })
        }
        
        // change size
        self.frame.size = CGSizeMake(self.frame.width, CGFloat(self.weatherCardList.count) * self.theHeight + 4)
        
    }
    
    func startCounting(){
        if timeCount < 8{
            timeCount++
        }else{
            
            removeCities()
            timer.invalidate()
            timeCount = 0
        }
    }
    
    func chooseCity(sender: UIButton){
        parentController.card.displayCity("\(sender.tag)")
        removeCities()
    }
    
    func removeCities(){
        
        for var index:Int = 0; index < weatherCardList.count; index++ {
            
            let temp = weatherCardList[index]
            
            UIView.animateWithDuration(0.4, delay: Double(weatherCardList.count - index + 1) * 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                temp.transform = CGAffineTransformMakeTranslation(-self.frame.width, 0)
                
                }) { (finish) -> Void in
                    temp.removeFromSuperview()
            }
            
        }
        weatherCardList.removeAll(keepCapacity: false)
    }
    
}
