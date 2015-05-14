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
    optional func displayIcon()
}

var WeatherInfo: WeatherInformation = WeatherInformation()

class WeatherInformation: NSObject, InternetConnectionDelegate{
    
    var currentDate = ""

    // 9 days weather forcast for city
    var citiesForcast = [String: AnyObject]()
    // all city in database with one day weather info
    var citiesAroundDict = [String: AnyObject]()
    
    // tree that store all the weather data
    var quadTree = QTree()
    
    //current city id
    var currentCityID = ""

    let maxCityNum = 150

    var forcastMode = false
    
    var weatherDelegate : WeatherInformationDelegate?
    
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
        
        var hasNewInfo = false
        
        for var index = 0; index < cities.count; index++ {
                
            let id: Int = (cities[index] as! [String : AnyObject]) ["id"] as! Int
            
            // first time weather data
            if self.citiesAroundDict["\(id)"] == nil {
                self.citiesAroundDict.updateValue(cities[index], forKey: "\(id)")
                // add to the tree
                quadTree.insertObject(WeatherDataQTree(position: CLLocationCoordinate2DMake(((cities[index] as! [String : AnyObject]) ["coord"] as! [String: AnyObject])["lat"]! as! Double, ((cities[index] as! [String : AnyObject]) ["coord"] as! [String: AnyObject])["lon"]! as! Double), cityID: "\(id)"))
                
                var connection = InternetConnection()
                connection.delegate = self
                connection.getWeatherForcast("\(id)")
                
                hasNewInfo = true
            }
            
        }
        
        if !forcastMode && hasNewInfo {
            self.weatherDelegate?.displayIcon!()
        }

    }
    
    func gotWeatherForcastData(cityID: String, forcast: [AnyObject]) {
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        
        // get currentDate
        var currDate = NSDate()
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.YY"
        let dateStr = dateFormatter.stringFromDate(currDate)
        
        //remove object if not the same day
        if currentDate != dateStr {
            currentDate = dateStr
            userDefault.setValue(dateStr, forKey: "currentDate")
            userDefault.setObject([String: AnyObject](), forKey: "citiesForcast")
            userDefault.synchronize()
            citiesForcast.removeAll(keepCapacity: false)
        }
        citiesForcast.updateValue(forcast, forKey: cityID)

        //display new icon
        if forcastMode{
            self.weatherDelegate?.displayIcon!()
        }
    }
    
}


class WeatherDataQTree: NSObject, QTreeInsertable{
    
    var coordinate: CLLocationCoordinate2D
    
    var cityID = ""
    
    init(position: CLLocationCoordinate2D, cityID: String) {
        coordinate = position
        super.init()
        self.cityID = cityID
    }
    
}

