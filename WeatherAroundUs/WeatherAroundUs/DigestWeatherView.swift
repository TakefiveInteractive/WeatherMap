//
//  DigestWeatherView.swift
//  WeatherAroundUs
//
//  Created by Wang Yu on 4/24/15.
//  Copyright (c) 2015 Kedan Li. All rights reserved.
//

import UIKit
import Spring
import Shimmer

class DigestWeatherView: DesignableView {

    @IBOutlet var line: UIImageView!

    var parentController: CityDetailViewController!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setup(forecastInfos: [[String: AnyObject]]) {
        let todayTemp = forecastInfos[0]["temp"] as! [String: AnyObject]
        let todayWeather = (forecastInfos[0]["weather"] as! [AnyObject])[0] as! [String: AnyObject]
        
        let beginY = line.frame.origin.y + line.frame.height
        let beginX = line.frame.origin.x
        
        //digest icon
        let weatherIcon = SpringImageView(frame: CGRectMake(beginX + line.frame.width / 12, beginY + 8, self.frame.height * 2 / 3, self.frame.height * 2 / 3))
        weatherIcon.image = UIImage(named: todayWeather["icon"] as! String)
        self.addSubview(weatherIcon)
        weatherIcon.animation = "zoomIn"
        weatherIcon.animate()
        
        //digest current weather condition
        let labelView = UIView(frame: CGRectMake(beginX + line.frame.width / 2, beginY, self.frame.width / 2, self.frame.height))
        self.addSubview(labelView)
        let shimmerWeatherDescription = FBShimmeringView(frame: CGRectMake(0, 26, line.frame.width / 2, 30))
        labelView.addSubview(shimmerWeatherDescription)
        let weatherDescription = SpringLabel(frame: CGRectMake(0, 0, line.frame.width / 2, 30))
        weatherDescription.text = (todayWeather["description"] as? String)?.capitalizedString
        weatherDescription.textAlignment = .Left
        weatherDescription.font = UIFont(name: "AvenirNext-Medium", size: 16)
        weatherDescription.textColor = UIColor.whiteColor()
        shimmerWeatherDescription.addSubview(weatherDescription)
        weatherDescription.animation = "fadeIn"
        weatherDescription.delay = 0.1
        weatherDescription.animate()
        shimmerWeatherDescription.contentView = weatherDescription
        shimmerWeatherDescription.shimmering = true
        
        //digest tempature range for the day
        let shimmerTempRange = FBShimmeringView(frame: CGRectMake(0, self.frame.height / 5 - 5, line.frame.width / 2, self.frame.height / 2))
        labelView.addSubview(shimmerTempRange)
        let tempRange = SpringLabel(frame: CGRectMake(0, 0, line.frame.width / 2, self.frame.height / 2))
        let minTemp = todayTemp["min"]!.intValue
        let maxTemp = todayTemp["max"]!.intValue
        tempRange.font = UIFont(name: "AvenirNext-Regular", size: 24)
        tempRange.textAlignment = .Left
        tempRange.textColor = UIColor.whiteColor()
        var unit = "F"
        if parentController.isCnotF {
            unit = "C"
        }
        tempRange.text = "\(parentController.degreeConvert(minTemp))° ~ \(parentController.degreeConvert(maxTemp))°\(unit)"
        shimmerTempRange.addSubview(tempRange)
        tempRange.animation = "fadeIn"
        tempRange.delay = 0.2
        tempRange.animate()
        shimmerTempRange.contentView = tempRange
        shimmerTempRange.shimmering = true
        
        //digest the main weather of the day
        let mainWeather = SpringLabel(frame: CGRectMake(0, beginY + self.frame.height / 5 + 18 - beginY, line.frame.width / 2 + 10, self.frame.height / 2))
        mainWeather.font = UIFont(name: "AvenirNext-Regular", size: 12)
        mainWeather.textAlignment = .Left
        mainWeather.textColor = UIColor.whiteColor()
        mainWeather.text = "Mainly " + (todayWeather["main"] as? String)!.lowercaseString + " today"
        labelView.addSubview(mainWeather)
        mainWeather.animation = "fadeIn"
        mainWeather.delay = 0.3
        mainWeather.animate()
        
    }
}
