//
//  CardView.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/4.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Spring

class CardView: DesignableView {

    @IBOutlet var icon: UIImageView!
    @IBOutlet var temperature: UILabel!
    @IBOutlet var city: UILabel!
    @IBOutlet var weatherDescription: UITextView!
    var blurView: UIVisualEffectView!

    var hide = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
 
    func displayCity(cityID: String){
        
        if hide {
            hide = false
            
            let info: AnyObject? = WeatherInfo.citiesAroundDict[cityID]
            self.icon.image = UIImage(named: "cloudAndSun")!
            
            var temp = ((info as! [String: AnyObject])["main"] as! [String: AnyObject])["temp"] as! Double
            temp = temp - 273
            self.temperature.text = "\(Int(temp))"
            self.city.text = (info as! [String: AnyObject])["name"] as? String
            println(self.city.text)
            self.weatherDescription.text = (((info as! [String: AnyObject])["weather"] as! [AnyObject])[0] as! [String: AnyObject])["description"] as? String
            
            self.y = -10
            self.animation = "slideUp"
            self.animate()
            
        }else{
        
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.icon.alpha = 0
                self.temperature.alpha = 0
                self.city.alpha = 0
                self.weatherDescription.alpha = 0
                }) { (done) -> Void in
                    
                    let info: AnyObject? = WeatherInfo.citiesAroundDict[cityID]
                    self.icon.image = UIImage(named: "rain")!
                    
                    var temp = ((info as! [String: AnyObject])["main"] as! [String: AnyObject])["temp"] as! Double
                    temp = temp - 273
                    self.temperature.text = "\(Int(temp))"
                    self.city.text = (info as! [String: AnyObject])["name"] as? String
                    self.weatherDescription.text = (((info as! [String: AnyObject])["weather"] as! [AnyObject])[0] as! [String: AnyObject])["description"] as? String
                    
                    UIView.animateWithDuration(0.4, animations: { () -> Void in
                        self.icon.alpha = 1
                        self.temperature.alpha = 1
                        self.city.alpha = 1
                        self.weatherDescription.alpha = 1
                        }) { (done) -> Void in
                    }
            }
        }
    }
    
    func addShadow(){
        blurView.layer.shadowOffset = CGSizeMake(0, 2);
        blurView.layer.shadowRadius = 1;
        blurView.layer.shadowOpacity = 0.3;
    }
    
    func hideSelf(){

        if !hide {
            hide = true
            self.y = 0
            animateToNext {
                self.animation = "slideUp"
                self.animateTo()
            }
        }
    }
    
    // movement  0 - 200
    func moveAccordingToDrag(movement:CGFloat){
        self.transform = CGAffineTransformMakeTranslation(0, movement)
    }

}
