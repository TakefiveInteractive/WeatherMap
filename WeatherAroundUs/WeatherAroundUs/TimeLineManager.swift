//
//  TimeLineManager.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/20.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit

@objc protocol TimeLineManagerDelegate: class {
    optional func progressUpdated(progress: Double)
}

class TimeLineManager: NSObject, InternetConnectionDelegate {
   
    var delegate:TimeLineManagerDelegate?
    
    var map: MapView!
    
    //percentage of the loading done
    var progress: Double = 0
    //total steps of the loading
    var totalSteps: Double = 0
    var currentStep: Double = 0
    
    var citiesToLoad = [String]()
    var forcastInfo = [String:[String: AnyObject]]()
    
    init(mapView: MapView) {
        super.init()
        map = mapView
    }
    
    func getAffectedCities(){
        var connection = InternetConnection()
        connection.delegate = self
        connection.getLocalWeather(map.camera.target, number: 20)
    }
    
    func gotLocalCityWeather(cities: [AnyObject]) {
        
        totalSteps = Double(cities.count) + 1
        WeatherInfo.gotLocalCityWeather(cities)
        citiesToLoad = WeatherInfo.citiesAround
        updateProgress()
        getWeatherForcastData()
    }
    
    func getWeatherForcastData(){
        
        if citiesToLoad.count != 0 {
            var connection = InternetConnection()
            connection.delegate = self
            connection.getWeatherForcast(citiesToLoad.last!)
        }
    }
    
    func gotWeatherForcastData(cityID: String, forcast:[AnyObject]){
        
        //forcast valid
        if forcast.count >= 39{
            updateProgress()
            var cityData = [String: AnyObject]()
            for var index = 0; index < 14; index++ {
                cityData.updateValue(forcast[index], forKey: (forcast[index] as! [String: AnyObject])["dt_txt"] as! String)
            }
            cityData.updateValue(forcast[22], forKey: (forcast[22] as! [String: AnyObject])["dt_txt"] as! String)
            cityData.updateValue(forcast[30], forKey: (forcast[30] as! [String: AnyObject])["dt_txt"] as! String)
            cityData.updateValue(forcast[38], forKey: (forcast[38] as! [String: AnyObject])["dt_txt"] as! String)
            forcastInfo.updateValue(cityData, forKey: cityID)
            citiesToLoad.removeLast()
        }
        getWeatherForcastData()
    }
    
    func updateProgress(){
        currentStep++
        progress = currentStep / totalSteps
        self.delegate?.progressUpdated!(progress)
        if progress >= 1{
            //reset
            progress = 0
            currentStep = 0
        }
    }
}
/*
{
    "list" : [
    {
    "main" : {
    "grnd_level" : 1012.41,
    "temp_min" : 288.077,
    "temp_max" : 288.08,
    "pressure" : 1012.41,
    "temp_kf" : 0,
    "sea_level" : 1024.21,
    "humidity" : 81,
    "temp" : 288.08
    },
    "dt" : 1429563600,
    "weather" : [
    {
    "id" : 800,
    "description" : "sky is clear",
    "main" : "Clear",
    "icon" : "01d"
    }
    ],
    "clouds" : {
    "all" : 0
    },
    "rain" : {
    "3h" : 0
    },
    "dt_txt" : "2015-04-20 21:00:00",
    "wind" : {
    "deg" : 229,
    "speed" : 1.57
    },
    "sys" : {
    "pod" : "d"
    }
    }
}*/
