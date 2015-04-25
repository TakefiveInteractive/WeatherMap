//
//  BasicWeatherView.swift
//  WeatherAroundUs
//
//  Created by Wang Yu on 4/24/15.
//  Copyright (c) 2015 Kedan Li. All rights reserved.
//

import UIKit
import Spring

class BasicWeatherView: DesignableView {

    @IBOutlet var hourForcastScrollView: UIScrollView!
    
    var parentController: CityDetailViewController!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setup(forecastInfos: [[String: AnyObject]]) {
        let weekDate = [0: "Friday", 1: "Saturday", 2: "Sunday", 3: "Monday", 4: "Tuesday"]
        let beginY = hourForcastScrollView.frame.origin.y + hourForcastScrollView.frame.height
        let beginX = hourForcastScrollView.frame.origin.x
        let blockHeight: CGFloat = 30
        let labelFont = UIFont(name: "AvenirNext-Regular", size: 16)
        
        for var index = 0; index < 5; index++ {
            var backView = SpringView(frame: CGRectMake(beginX, beginY + CGFloat(index) * blockHeight, hourForcastScrollView.frame.width, blockHeight))
            self.addSubview(backView)
            
            var dateLabel = UILabel(frame: CGRectMake(0, 0, 100, blockHeight))
            dateLabel.text = weekDate[index]
            dateLabel.textColor = UIColor.whiteColor()
            dateLabel.textAlignment = .Left
            dateLabel.font = labelFont
            backView.addSubview(dateLabel)
            
            //println((nineDayWeatherForcast[0]["temp"] as! [String: AnyObject])["day"])
            var maxTempLabel = UILabel(frame: CGRectMake(backView.frame.width - 90, 0, 50, blockHeight))
            maxTempLabel.textColor = UIColor.whiteColor()
            maxTempLabel.textAlignment = .Right
            maxTempLabel.font = labelFont
            let maxTempInt = ((forecastInfos[index]["temp"] as! [String: AnyObject])["max"])!.intValue
            maxTempLabel.text = "\(degreeConvert(maxTempInt))°"
            backView.addSubview(maxTempLabel)
            
            var minTempLabel = UILabel(frame: CGRectMake(backView.frame.width - 50, 0, 50, blockHeight))
            minTempLabel.textColor = UIColor(hex: "#ADD8E6")
            minTempLabel.textAlignment = .Right
            minTempLabel.font = labelFont
            let minTempInt = ((forecastInfos[index]["temp"] as! [String: AnyObject])["min"])!.intValue
            minTempLabel.text = "\(degreeConvert(minTempInt))°"
            backView.addSubview(minTempLabel)
            
            var weatherIcon = UIImageView(frame: CGRect(x: backView.frame.width/2 - 20, y: 0, width: blockHeight, height: blockHeight))
//            println( (forecastInfos[index]["weather"])["icon"] )
//            let iconString = ((forecastInfos[index]["weather"] as! [String: AnyObject])["icon"])!.stringValue
//            weatherIcon.image = UIImage(named: iconString)
//            backView.addSubview(weatherIcon)
            
            backView.animation = "fadeIn"
            backView.delay = 0.1 * CGFloat(index)
            backView.animate()
        }
    }
    
    func degreeConvert(degree: Int32) -> Int32 {
        if parentController.isCnotF {
            return degree - 273
        } else {
            return (degree-273) * 9 / 5 + 32
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
