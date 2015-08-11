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
    var tempRange: SpringLabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setup(forecastInfos: [[String: AnyObject]]) {
        let todayTemp = forecastInfos[0]["temp"] as! [String: AnyObject]
        let todayWeather =  ((WeatherInfo.citiesAroundDict[WeatherInfo.currentCityID] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject]
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
        let cityDisplay = SpringLabel(frame: CGRectMake(0, 0, line.frame.width / 2, 30))
        cityDisplay.text = parentController.cityName
        cityDisplay.textAlignment = .Left
        cityDisplay.font = UIFont(name: "AvenirNext-Medium", size: 18)
        cityDisplay.adjustsFontSizeToFitWidth = true
        cityDisplay.textColor = UIColor.whiteColor()
        shimmerWeatherDescription.addSubview(cityDisplay)
        cityDisplay.animation = "fadeIn"
        cityDisplay.delay = 0.1
        cityDisplay.animate()
        shimmerWeatherDescription.contentView = cityDisplay
        shimmerWeatherDescription.shimmering = true
        
        //digest tempature range for the day
        let shimmerTempRange = FBShimmeringView(frame: CGRectMake(0, self.frame.height / 5 - 5, line.frame.width / 2, self.frame.height / 2))
        labelView.addSubview(shimmerTempRange)
        tempRange = SpringLabel(frame: CGRectMake(0, 0, line.frame.width / 2, self.frame.height / 2))
        let minTemp = todayTemp["min"]!.doubleValue
        let maxTemp = todayTemp["max"]!.doubleValue
        tempRange.font = UIFont(name: "AvenirNext-Regular", size: 24)
        tempRange.adjustsFontSizeToFitWidth = true
        tempRange.textAlignment = .Left
        tempRange.textColor = UIColor.whiteColor()
        let unit = parentController.unit.stringValue
        tempRange.text = "\(WeatherMapCalculations.kelvinConvert(minTemp, unit: parentController.unit))° ~ \(WeatherMapCalculations.kelvinConvert(maxTemp, unit: parentController.unit))°\(unit)"
        shimmerTempRange.addSubview(tempRange)
        tempRange.animation = "fadeIn"
        tempRange.delay = 0.2
        tempRange.animate()
        shimmerTempRange.contentView = tempRange
        shimmerTempRange.shimmering = true
        
        //digest the main weather of the day
        let mainWeather = SpringLabel(frame: CGRectMake(0, beginY + self.frame.height / 5 + 18 - beginY, line.frame.width / 2 + 10, self.frame.height / 2))
        mainWeather.font = UIFont(name: "AvenirNext-Regular", size: 17)
        mainWeather.textAlignment = .Left
        mainWeather.textColor = UIColor.whiteColor()
        
        if UserLocation.inChina{
            mainWeather.text = IconImage.getWeatherInChinese(todayWeather["icon"] as! String)
        }else{
            mainWeather.text = (((WeatherInfo.citiesAroundDict[WeatherInfo.currentCityID] as! [String: AnyObject])["weather"] as! [AnyObject])[0] as! [String: AnyObject])["main"]?.capitalizedString
        }
        labelView.addSubview(mainWeather)
        mainWeather.animation = "fadeIn"
        mainWeather.delay = 0.3
        mainWeather.animate()
        
    }
    
    func reloadTemperature(forecastInfos: [[String: AnyObject]]) {
        let todayTemp = forecastInfos[0]["temp"] as! [String: AnyObject]
        let minTemp = todayTemp["min"]!.doubleValue
        let maxTemp = todayTemp["max"]!.doubleValue
        var unit = parentController.unit.stringValue
        tempRange.text = "\(WeatherMapCalculations.kelvinConvert(minTemp, unit: parentController.unit))° ~ \(WeatherMapCalculations.kelvinConvert(maxTemp, unit: parentController.unit))°\(unit)"
        setNeedsDisplay()
    }
}
