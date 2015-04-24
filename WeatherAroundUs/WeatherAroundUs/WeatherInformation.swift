//
//  WeatherInformation.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/5.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Alamofire

@objc protocol WeatherInformationDelegate: class {
    optional func gotOneNewWeatherData(cityID: String, latitude:CLLocationDegrees, longitude:CLLocationDegrees)
}

@objc protocol UpdateIconListDelegate: class {
    optional func updateIconList()
}

var WeatherInfo: WeatherInformation = WeatherInformation()

class WeatherInformation: NSObject, InternetConnectionDelegate{
    
    // 9 days weather forcast for city
    var citiesForcast = [String: AnyObject]()
    // all city in database with one day weather info
    var citiesAroundDict = [String: AnyObject]()
    // all the icons displayed
    var citiesAround = [String]()

    let maxCityNum = 40

    var forcastMode = false
    
    var weatherDelegate : WeatherInformationDelegate?
    var updateIconListDelegate : UpdateIconListDelegate?
    
    override init() {
        super.init()
        if let forcast: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("citiesForcast"){
            citiesForcast = forcast as! [String : AnyObject]
        }
    }
    
    func getLocalWeatherInformation(location: CLLocationCoordinate2D, number:Int){
        var connection = InternetConnection()
        connection.delegate = self
        connection.getLocalWeather(location, number: number)
    }

    // got local city weather from member
    func gotLocalCityWeather(cities: [AnyObject]) {
        
            for city in cities{
                let id: Int = (city as! [String : AnyObject]) ["id"] as! Int
                // first time weather data
                if self.citiesAroundDict["\(id)"] == nil {
                    self.citiesAroundDict.updateValue(city, forKey: "\(id)")
                    
                        var connection = InternetConnection()
                        connection.delegate = self
                        connection.getWeatherForcast("\(id)")
                    
            }
                if !forcastMode {
                    self.weatherDelegate?.gotOneNewWeatherData!("\(id)", latitude: (((city as! [String : AnyObject]) ["coord"] as! [String: AnyObject])["lat"]! as! Double), longitude: (((city as! [String : AnyObject]) ["coord"] as! [String: AnyObject])["lon"]! as! Double))
                }

            }

    }
    
    func gotWeatherForcastData(cityID: String, forcast: [AnyObject]) {
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        
        //remove object if not the same day
        if userDefault.objectForKey("currentDate") != nil && userDefault.objectForKey("currentDate") as! NSNumber == (forcast[0] as! [String: AnyObject])["dt"] as! NSNumber {
        }else{
            userDefault.setValue((forcast[0] as! [String: AnyObject])["dt"], forKey: "currentDate")
            userDefault.removeObjectForKey("citiesForcast")
            citiesForcast.removeAll(keepCapacity: false)
        }
        citiesForcast.updateValue(forcast, forKey: cityID)
        userDefault.setObject(citiesForcast, forKey: "citiesForcast")
        userDefault.synchronize()
        
        citiesForcast.updateValue(forcast, forKey: cityID)

        //display new icon
        if forcastMode{
            self.weatherDelegate?.gotOneNewWeatherData!("\(cityID)", latitude: (((citiesAroundDict[cityID] as! [String : AnyObject]) ["coord"] as! [String: AnyObject])["lat"]! as! Double), longitude: (((citiesAroundDict[cityID] as! [String : AnyObject]) ["coord"] as! [String: AnyObject])["lon"]! as! Double))
        }
    }
    
    func removeAllCities(){
        citiesAround.removeAll(keepCapacity: false)
    }
}

/*                    var queueLow = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
dispatch_sync(queueLow) {
}*/
