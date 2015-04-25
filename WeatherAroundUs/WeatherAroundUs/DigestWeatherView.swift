//
//  DigestWeatherView.swift
//  WeatherAroundUs
//
//  Created by Wang Yu on 4/24/15.
//  Copyright (c) 2015 Kedan Li. All rights reserved.
//

import UIKit
import Spring

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
        
        let weatherIcon = UIImageView(frame: CGRectMake(beginX + line.frame.width / 16, beginY, self.frame.height * 2 / 3, self.frame.height * 2 / 3))
        weatherIcon.image = UIImage(named: todayWeather["icon"] as! String)
        self.addSubview(weatherIcon)
        
        let weatherDescription = UILabel(frame: CGRectMake(beginX + line.frame.width / 2, beginY + 18, line.frame.width / 2, 30))
        weatherDescription.text = (todayWeather["description"] as? String)?.capitalizedString
        weatherDescription.textAlignment = .Left
        weatherDescription.font = UIFont(name: "AvenirNext-Medium", size: 20)
        weatherDescription.textColor = UIColor.whiteColor()
        self.addSubview(weatherDescription)
        
        let minTemp = todayTemp["min"]!.intValue
        let maxTemp = todayTemp["max"]!.intValue
        let tempRange = UILabel(frame: CGRectMake(beginX + line.frame.width / 2, beginY + self.frame.height / 5 - 6, line.frame.width / 2, self.frame.height / 2))
        tempRange.font = UIFont(name: "AvenirNext-Regular", size: 28)
        tempRange.textAlignment = .Left
        tempRange.textColor = UIColor.whiteColor()
        var unit = "F"
        if parentController.isCnotF {
            unit = "C"
        }
        tempRange.text = "\(parentController.degreeConvert(minTemp))° ~ \(parentController.degreeConvert(maxTemp))°\(unit)"
        self.addSubview(tempRange)
        
        let mainWeather = UILabel(frame: CGRectMake(beginX + line.frame.width / 2, beginY + self.frame.height / 5 + 20, line.frame.width / 2, self.frame.height / 2))
        mainWeather.font = UIFont(name: "AvenirNext-Regular", size: 14)
        mainWeather.textAlignment = .Left
        mainWeather.textColor = UIColor.whiteColor()
        mainWeather.text = "Today mainly is " + (todayWeather["main"] as? String)!.capitalizedString
        mainWeather.numberOfLines = 0
        self.addSubview(mainWeather)
        
    }
}
