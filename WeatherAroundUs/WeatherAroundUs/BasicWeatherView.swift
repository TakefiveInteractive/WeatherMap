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
    
    func timeConvert(curTime: Int) -> String {
        if (curTime < 12) {
            return "\(curTime)AM"
        } else {
            return "\(curTime % 12)PM"
        }
    }
    
    func setup(forecastInfos: [[String: AnyObject]]) {
        // each daily display block height
        let blockHeight: CGFloat = 30
        let labelFont = UIFont(name: "AvenirNext-Regular", size: 16)

        parentController.basicForecastViewHeight.constant = hourForcastScrollView.frame.height + CGFloat(displayedDays) * blockHeight + 50
        
        /// set up scroll view daily forcast
        let hourItemViewWidth: CGFloat = 40
        let numOfDailyWeatherForcast = 8
        hourForcastScrollView.contentSize = CGSize(width: hourItemViewWidth * CGFloat(numOfDailyWeatherForcast), height: hourForcastScrollView.frame.height)
        for var index = 0; index < numOfDailyWeatherForcast; index++ {
            let hourItemView = SpringView(frame: CGRectMake(hourItemViewWidth * CGFloat(index), 0, hourItemViewWidth, hourForcastScrollView.frame.height))
            hourForcastScrollView.addSubview(hourItemView)
            
            let hourTimeLabel = UILabel(frame: CGRectMake(0, 5, hourItemViewWidth, 20))
            hourTimeLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
            hourTimeLabel.text = "\(timeConvert(24 / numOfDailyWeatherForcast * index))"
            hourTimeLabel.textColor = UIColor.whiteColor()
            hourTimeLabel.textAlignment = .Center
            hourItemView.addSubview(hourTimeLabel)
            
            let hourImageIcon = UIImageView(frame: CGRectMake(0, hourTimeLabel.frame.origin.y + hourTimeLabel.frame.height, hourItemViewWidth, 20))
            hourImageIcon.image = UIImage(named: "10d")
            hourImageIcon.contentMode = UIViewContentMode.ScaleAspectFit
            hourItemView.addSubview(hourImageIcon)
        }
        
        
        /// set up week weather forcast
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
        
        for var index = 0; index < displayedDays; index++ {
            var backView = SpringView(frame: CGRectMake(beginX, beginY + CGFloat(index) * blockHeight, hourForcastScrollView.frame.width, blockHeight))
            self.addSubview(backView)
            
            var dateLabel = UILabel(frame: CGRectMake(0, 0, 100, blockHeight))
            dateLabel.text = weekDate[index]
            dateLabel.textColor = UIColor.whiteColor()
            dateLabel.textAlignment = .Left
            dateLabel.font = labelFont
            backView.addSubview(dateLabel)
            
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
