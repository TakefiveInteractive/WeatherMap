//
//  BasicWeatherView.swift
//  WeatherAroundUs
//
//  Created by Wang Yu on 4/24/15.
//  Copyright (c) 2015 Kedan Li. All rights reserved.
//

import UIKit
import Spring

class BasicWeatherView: DesignableView, InternetConnectionDelegate {

    //@IBOutlet var hourForcastScrollView: UIScrollView!
    @IBOutlet weak var upperLine: UIImageView!
    @IBOutlet weak var lowerLine: UIImageView!
    @IBOutlet weak var scrollViewPosition: UIScrollView!
    var hourForcastScrollView: UIScrollView!
    let displayedDays: Int = 9
    
    var parentController: CityDetailViewController!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func timeConvert(var curTime: Int) -> String {
        if (curTime < 12) {
            if curTime == 0 {
                curTime = 12
            }
            return "\(curTime)AM"
        } else {
            curTime %= 12
            if curTime == 0 {
                curTime = 12
            }
            return "\(curTime)PM"
        }
    }
    
    var hourForcastTemperatureLabelArr = [SpringLabel]()
    var hourForcastTemperatureIntArr = [Int32]()
    var dayForcastMinTemperatureLabelArr = [UILabel]()
    var dayForcastMinTemperatureIntArr = [Int32]()
    var dayForcastMaxTemperatureLabelArr = [UILabel]()
    var dayForcastMaxTemperatureIntArr = [Int32]()

    func setup(forecastInfos: [[String: AnyObject]]) {
        
//        var hourForcastScrollViewConstraints = [NSLayoutConstraint]()
//        hourForcastScrollViewConstraints += [NSLayoutConstraint(item: hourForcastScrollView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: upperLine, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)]
//        hourForcastScrollViewConstraints += [NSLayoutConstraint(item: hourForcastScrollView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: upperLine, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)]
//        hourForcastScrollViewConstraints += [NSLayoutConstraint(item: hourForcastScrollView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: lowerLine, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)]
//        hourForcastScrollViewConstraints += [NSLayoutConstraint(item: hourForcastScrollView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: lowerLine, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)]
//        hourForcastScrollView.addConstraints(hourForcastScrollViewConstraints)
        
        hourForcastScrollView = UIScrollView(frame: scrollViewPosition.frame)
        self.addSubview(hourForcastScrollView)
        // each daily display block height
        let blockHeight: CGFloat = 30
        let labelFont = UIFont(name: "AvenirNext-Regular", size: 16)

        parentController.basicForecastViewHeight.constant = hourForcastScrollView.frame.height + CGFloat(displayedDays) * blockHeight + 50
        
        /// set up week weather forcast
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let component = calendar.component(NSCalendarUnit.CalendarUnitWeekday, fromDate: date)
        let week = [0: "Sunday", 1: "Monday", 2: "Tuesday", 3: "Wednesday", 4: "Thursday", 5: "Friday", 6: "Saturday"]
        var weekDate = [Int: String]()
        for var index = 0; index < displayedDays; index++ {
            weekDate[index] = week[(index + component - 1) % 7]
        }
        weekDate[0] = "Today"
        weekDate[1] = "Tomorrow"

        let beginY = hourForcastScrollView.frame.origin.y + hourForcastScrollView.frame.height + 8
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
            maxTempLabel.text = "\(WeatherMapCalculations.kelvinConvert(maxTempInt, isFnotC: parentController.isFnotC))°"
            backView.addSubview(maxTempLabel)
            dayForcastMaxTemperatureIntArr.append(maxTempInt)
            dayForcastMaxTemperatureLabelArr.append(maxTempLabel)
            
            var minTempLabel = UILabel(frame: CGRectMake(backView.frame.width - 50, 0, 50, blockHeight))
            minTempLabel.textColor = UIColor(hex: "#ADD8E6")
            minTempLabel.textAlignment = .Right
            minTempLabel.font = labelFont
            let minTempInt = ((forecastInfos[index]["temp"] as! [String: AnyObject])["min"])!.intValue
            minTempLabel.text = "\(WeatherMapCalculations.kelvinConvert(minTempInt, isFnotC: parentController.isFnotC))°"
            backView.addSubview(minTempLabel)
            dayForcastMinTemperatureIntArr.append(minTempInt)
            dayForcastMinTemperatureLabelArr.append(minTempLabel)
            
            var weatherIcon = UIImageView(frame: CGRect(x: backView.frame.width/2 - 10, y: 4, width: blockHeight - 8, height: blockHeight - 8))
            let iconString = ((forecastInfos[index]["weather"] as! [AnyObject])[0] as! [String: AnyObject])["icon"] as! String
            weatherIcon.image = UIImage(named: iconString)
            backView.addSubview(weatherIcon)
            
            backView.animation = "fadeIn"
            backView.delay = 0.1 * CGFloat(index)
            backView.animate()
        }

        // get three hour forcast data
        var connection = InternetConnection()
        connection.delegate = self
        connection.getThreeHourForcast(parentController.cityID)
        
    }

    
    func gotThreeHourForcastData(cityID: String, forcast: [AnyObject]) {
        parentController.loadingIndicator.stopAnimating()
        
        /// set up scroll view daily forcast
        let hourItemViewWidth: CGFloat = 40
        let numOfDailyWeatherForcast = forcast.count
        hourForcastScrollView.contentSize = CGSize(width: hourItemViewWidth * CGFloat(numOfDailyWeatherForcast), height: hourForcastScrollView.frame.height)
        
        for var index = 0; index < numOfDailyWeatherForcast; index++ {
            let hourItemView = SpringView(frame: CGRectMake(hourItemViewWidth * CGFloat(index), 0, hourItemViewWidth, hourForcastScrollView.frame.height))
            hourForcastScrollView.addSubview(hourItemView)
            
            var timeData = (forcast[index]["dt_txt"]) as! String
            timeData = timeData.substringWithRange(Range<String.Index>(start: advance(timeData.startIndex, 11), end: advance(timeData.endIndex, -6)))
            let curTime = timeData.toInt()
            let hourTimeLabel = SpringLabel(frame: CGRectMake(0, 5, hourItemViewWidth, 20))
            hourTimeLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
            hourTimeLabel.text = "\(timeConvert(curTime!))"
            hourTimeLabel.textColor = UIColor.whiteColor()
            hourTimeLabel.textAlignment = .Center
            hourItemView.addSubview(hourTimeLabel)
            
            let iconString = ((forcast[index]["weather"] as! [AnyObject])[0] as! [String: AnyObject])["icon"] as! String
            let hourImageIcon = SpringImageView(frame: CGRectMake(0, hourTimeLabel.frame.origin.y + hourTimeLabel.frame.height, hourItemViewWidth, 20))
            hourImageIcon.image = UIImage(named: iconString)
            hourImageIcon.contentMode = UIViewContentMode.ScaleAspectFit
            hourItemView.addSubview(hourImageIcon)
            
            let temp = ((forcast[index]["main"] as! [String: AnyObject])["temp"])!.intValue
            let hourTemperatureLabel = SpringLabel(frame: CGRectMake(0, hourImageIcon.frame.origin.y + hourImageIcon.frame.height, hourItemViewWidth, 20))
            hourTemperatureLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
            hourTemperatureLabel.textColor = UIColor.whiteColor()
            hourTemperatureLabel.textAlignment = .Center
            hourTemperatureLabel.text = "\(WeatherMapCalculations.kelvinConvert(temp, isFnotC: parentController.isFnotC))°"
            hourItemView.addSubview(hourTemperatureLabel)
            
            hourItemView.animation = "fadeIn"
            hourItemView.delay = 0.1 * CGFloat(index)
            hourItemView.animate()
            
            hourForcastTemperatureLabelArr.append(hourTemperatureLabel)
            hourForcastTemperatureIntArr.append(temp)
        }
    }
    
    func reloadTempatureContent() {
        
        for var index = 0; index < hourForcastTemperatureLabelArr.count; index++ {
            hourForcastTemperatureLabelArr[index].text = "\(WeatherMapCalculations.kelvinConvert(hourForcastTemperatureIntArr[index], isFnotC: parentController.isFnotC))°"
        }
        for var index = 0; index < dayForcastMaxTemperatureLabelArr.count; index++ {
            dayForcastMaxTemperatureLabelArr[index].text = "\(WeatherMapCalculations.kelvinConvert(dayForcastMaxTemperatureIntArr[index], isFnotC: parentController.isFnotC))°"
            dayForcastMinTemperatureLabelArr[index].text = "\(WeatherMapCalculations.kelvinConvert(dayForcastMinTemperatureIntArr[index], isFnotC: parentController.isFnotC))°"

        }
        
    }

}
