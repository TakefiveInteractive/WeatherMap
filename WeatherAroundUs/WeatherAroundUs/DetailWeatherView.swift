//
//  DetailWeatherView.swift
//  WeatherAroundUs
//
//  Created by Wang Yu on 4/25/15.
//  Copyright (c) 2015 Kedan Li. All rights reserved.
//

import UIKit

class DetailWeatherView: UIView {
    
    var parentController: CityDetailViewController!
    
    @IBOutlet var line: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var unit: String {
        return parentController.unit.stringValue
    }
    
    func setup(forecastInfos: [[String: AnyObject]]) {
        var beginY = line.frame.origin.y + line.frame.height + 5
        let blockHeight: CGFloat = 18
        let spaceHeight: CGFloat = 8
        
        let windSpeed = (forecastInfos[0] as [String: AnyObject])["speed"] as! Int
        let windDirection = (forecastInfos[0] as [String: AnyObject])["deg"] as! Int
        var windDirectionStr: String = ""
        if windDirection < 90 {
            windDirectionStr = "\(windDirection)° NE"
        } else if windDirection < 180 {
            windDirectionStr = "\(windDirection-90)° NW"
        } else if windDirection < 270 {
            windDirectionStr = "\(windDirection-180)° SW"
        } else {
            windDirectionStr = "\(windDirection-270)° SE"
        }
        
        if UserLocation.inChina{
            createTwoUILabelInMiddle("风速:", secondString: "\(windSpeed) mps", yPosition: beginY)
            
            beginY += blockHeight
            createTwoUILabelInMiddle("风向:", secondString: windDirectionStr, yPosition: beginY)
            
            beginY += blockHeight + spaceHeight
            let clouds = (forecastInfos[0] as [String: AnyObject])["speed"] as! Int
            createTwoUILabelInMiddle("云量:", secondString: "\(clouds) %", yPosition: beginY)
            
            beginY += blockHeight
            let humanity = (forecastInfos[0] as [String: AnyObject])["humidity"] as! Int
            createTwoUILabelInMiddle("湿度:", secondString: "\(humanity) %", yPosition: beginY)
            
            beginY += blockHeight + spaceHeight
            let precipitation = (forecastInfos[0] as [String: AnyObject])["rain"] as? Double
            var precipitationStr = "TBA"
            if precipitation != nil {
                precipitationStr = "\(precipitation! * 100) mm"
            }
            createTwoUILabelInMiddle("降雨量:", secondString: precipitationStr, yPosition: beginY)
            
            beginY += blockHeight
            let pressure = (forecastInfos[0] as [String: AnyObject])["pressure"] as! Int
            createTwoUILabelInMiddle("气压:", secondString: "\(pressure) hPa", yPosition: beginY)
            
            beginY += blockHeight + spaceHeight
            let mornTemperature = (forecastInfos[0]["temp"] as! [String: AnyObject])["morn"]!.doubleValue
            createTwoUILabelInMiddle("早晨气温:", secondString: "\(WeatherMapCalculations.kelvinConvert(mornTemperature, unit: parentController.unit)) °" + unit, yPosition: beginY)
            
            beginY += blockHeight
            let nightTemperature = (forecastInfos[0]["temp"] as! [String: AnyObject])["night"]!.doubleValue
            createTwoUILabelInMiddle("夜晚气温:", secondString: "\(WeatherMapCalculations.kelvinConvert(nightTemperature, unit: parentController.unit)) °" + unit, yPosition: beginY)
        }else{
            createTwoUILabelInMiddle("Wind Speed:", secondString: "\(windSpeed) mps", yPosition: beginY)
            
            beginY += blockHeight
            createTwoUILabelInMiddle("Wind Direction:", secondString: windDirectionStr, yPosition: beginY)
            
            beginY += blockHeight + spaceHeight
            let clouds = (forecastInfos[0] as [String: AnyObject])["speed"] as! Int
            createTwoUILabelInMiddle("Cloudiness:", secondString: "\(clouds) %", yPosition: beginY)
            
            beginY += blockHeight
            let humanity = (forecastInfos[0] as [String: AnyObject])["humidity"] as! Int
            createTwoUILabelInMiddle("Humidity:", secondString: "\(humanity) %", yPosition: beginY)
            
            beginY += blockHeight + spaceHeight
            let precipitation = (forecastInfos[0] as [String: AnyObject])["rain"] as? Double
            var precipitationStr = "TBA"
            if precipitation != nil {
                precipitationStr = "\(precipitation! * 100) mm"
            }
            createTwoUILabelInMiddle("Precipitation:", secondString: precipitationStr, yPosition: beginY)
            
            beginY += blockHeight
            let pressure = (forecastInfos[0] as [String: AnyObject])["pressure"] as! Int
            createTwoUILabelInMiddle("Pressure:", secondString: "\(pressure) hPa", yPosition: beginY)
            
            beginY += blockHeight + spaceHeight
            let mornTemperature = (forecastInfos[0]["temp"] as! [String: AnyObject])["morn"]!.doubleValue
            createTwoUILabelInMiddle("Morning Temp:", secondString: "\(WeatherMapCalculations.kelvinConvert(mornTemperature, unit: parentController.unit)) °" + unit, yPosition: beginY)
            
            beginY += blockHeight
            let nightTemperature = (forecastInfos[0]["temp"] as! [String: AnyObject])["night"]!.doubleValue
            createTwoUILabelInMiddle("Night Temp:", secondString: "\(WeatherMapCalculations.kelvinConvert(nightTemperature, unit: parentController.unit)) °" + unit, yPosition: beginY)
        }
    }
    
    var TempLabelArray = [UILabel]()
    
    func createTwoUILabelInMiddle(firstStirng: String, secondString: String, yPosition: CGFloat) {
        let labelHeight: CGFloat = 20
        let xPostion = line.frame.origin.x
        
        var leftLabel = UILabel(frame: CGRectMake(xPostion, yPosition, line.frame.width / 2, labelHeight))
        var rightLabel = UILabel(frame: CGRectMake(xPostion + line.frame.width / 2 + 20, yPosition, line.frame.width / 2, labelHeight))
        leftLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)
        rightLabel.font = leftLabel.font
        leftLabel.textColor = UIColor.whiteColor()
        rightLabel.textColor = leftLabel.textColor
        leftLabel.textAlignment = .Right
        rightLabel.textAlignment = .Left
        leftLabel.text = firstStirng
        rightLabel.text = secondString
        self.addSubview(leftLabel)
        self.addSubview(rightLabel)
        
        TempLabelArray.append(rightLabel)
    }
    
    func reloadTempatureContent(forecastInfos: [[String: AnyObject]]) {
        let lastFirst = TempLabelArray[TempLabelArray.count - 1]
        let lastSecond = TempLabelArray[TempLabelArray.count - 2]
        
        let nightTemperature = (forecastInfos[0]["temp"] as! [String: AnyObject])["night"]!.doubleValue
        lastFirst.text = "\(WeatherMapCalculations.kelvinConvert(nightTemperature, unit: parentController.unit)) °" + unit
        let mornTemperature = (forecastInfos[0]["temp"] as! [String: AnyObject])["morn"]!.doubleValue
        lastSecond.text = "\(WeatherMapCalculations.kelvinConvert(mornTemperature, unit: parentController.unit)) °" + unit
    }
    
}
