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
    let displayedDays: Int = 7
    
    var parentController: CityDetailViewController!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(forecastInfos: [[String: AnyObject]]) {
        // each daily display block height
        let blockHeight: CGFloat = 30

        parentController.basicForecastViewHeight.constant = hourForcastScrollView.frame.height + CGFloat(displayedDays) * blockHeight + 50
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let component = calendar.component(NSCalendarUnit.CalendarUnitWeekday, fromDate: date)
        let week = [0: "Sunday", 1: "Monday", 2: "Tuesday", 3: "Wednesday", 4: "Thursday", 5: "Friday", 6: "Saturday"]
        var weekDate = [Int: String]()
        for var index = 0; index < displayedDays; index++ {
            weekDate[index] = week[(index + component - 1) % 7]
        }

        let beginY = hourForcastScrollView.frame.origin.y + hourForcastScrollView.frame.height
        let beginX = hourForcastScrollView.frame.origin.x
        let labelFont = UIFont(name: "AvenirNext-Regular", size: 16)
        
        for var index = 0; index < displayedDays; index++ {
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
            maxTempLabel.text = "\(parentController.degreeConvert(maxTempInt))°"
            backView.addSubview(maxTempLabel)
            
            var minTempLabel = UILabel(frame: CGRectMake(backView.frame.width - 50, 0, 50, blockHeight))
            minTempLabel.textColor = UIColor(hex: "#ADD8E6")
            minTempLabel.textAlignment = .Right
            minTempLabel.font = labelFont
            let minTempInt = ((forecastInfos[index]["temp"] as! [String: AnyObject])["min"])!.intValue
            minTempLabel.text = "\(parentController.degreeConvert(minTempInt))°"
            backView.addSubview(minTempLabel)
            
            var weatherIcon = UIImageView(frame: CGRect(x: backView.frame.width/2 - 10, y: 4, width: blockHeight - 8, height: blockHeight - 8))
            let iconString = ((forecastInfos[index]["weather"] as! [AnyObject])[0] as! [String: AnyObject])["icon"] as! String
            weatherIcon.image = UIImage(named: iconString)
            backView.addSubview(weatherIcon)
            
            backView.animation = "fadeIn"
            backView.delay = 0.1 * CGFloat(index)
            backView.animate()
        }
    }

}
