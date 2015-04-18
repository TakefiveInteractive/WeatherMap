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
    
    var citiesAroundDict = [String: AnyObject]()
    var citiesAround = [String]()

    let maxCityNum = 30
    
    var weatherDelegate : WeatherInformationDelegate?
    var updateIconListDelegate : UpdateIconListDelegate?
    
    var requestNum = 0
    
    func getLocalWeatherInformation(location: CLLocationCoordinate2D, number:Int){
        requestNum++
        var connection = InternetConnection()
        connection.delegate = self
        connection.getLocalWeather(location, number: number)
    }

    // got local city weather from member
    func gotLocalCityWeather(cities: [AnyObject]) {
        requestNum--
        for city in cities{
            let id: Int = (city as! [String : AnyObject]) ["id"] as! Int
            // first time weather data
            if self.citiesAroundDict["\(id)"] == nil {
                self.citiesAroundDict.updateValue(city, forKey: "\(id)")
                // save the city in db
            }
            self.weatherDelegate?.gotOneNewWeatherData!("\(id)", latitude: (((city as! [String : AnyObject]) ["coord"] as! [String: AnyObject])["lat"]! as! Double), longitude: (((city as! [String : AnyObject]) ["coord"] as! [String: AnyObject])["lon"]! as! Double))
        }
    }
    
    func removeAllCities(){
        citiesAround.removeAll(keepCapacity: false)
    }
}
/*

for city in list{

let id: Int = (city as! [String : AnyObject]) ["id"] as! Int

// first time weather data
if self.citiesAroundDict["\(id)"] == nil {
self.citiesAroundDict.updateValue(city, forKey: "\(id)")
// save the city in db
}
self.weatherDelegate?.gotOneNewWeatherData!("\(id)", latitude: (((city as! [String : AnyObject]) ["coord"] as! [String: AnyObject])["lat"]! as! Double), longitude: (((city as! [String : AnyObject]) ["coord"] as! [String: AnyObject])["lon"]! as! Double))


}


{
    clouds =     {
        all = 0;
    };
    coord =     {
        lat = "37.323002";
        lon = "-122.032181";
    };
    dt = 1429251735;
    id = 5341145;
    main =     {
        "grnd_level" = "993.61";
        humidity = 73;
        pressure = "993.61";
        "sea_level" = "1032.13";
        temp = "280.762";
        "temp_max" = "280.762";
        "temp_min" = "280.762";
    };
    name = Cupertino;
    sys =     {
        country = "";
    };
    weather =     (
        {
            description = "Sky is Clear";
            icon = 01n;
            id = 800;
            main = Clear;
        }
    );
    wind =     {
        deg = 184;
        speed = "0.91";
    };
}
*/
