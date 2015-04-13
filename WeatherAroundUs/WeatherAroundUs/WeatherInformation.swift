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

class WeatherInformation: NSObject {
    
    var citiesAroundDict = [String: AnyObject]()
    var citiesAround = [String]()

    let maxCityNum = 30
    
    var weatherDelegate : WeatherInformationDelegate?
    var updateIconListDelegate : UpdateIconListDelegate?

    func getLocalWeatherInformation(location: CLLocationCoordinate2D){
        
        var req = Alamofire.request(.GET, NSURL(string: "http://api.openweathermap.org/data/2.5/find?lat=\(location.latitude)&lon=\(location.longitude)&cnt=10&mode=json")!).responseJSON { (_, response, JSON, error) in
            
            if error == nil && JSON != nil {
                
                
                var result = JSON as! [String : AnyObject]
                
                let list:[AnyObject] = result["list"] as! [AnyObject]
                
                for city in list{
                    
                    let id: Int = (city as! [String : AnyObject]) ["id"] as! Int
                    
                    self.weatherDelegate?.gotOneNewWeatherData!("\(id)", latitude: (((city as! [String : AnyObject]) ["coord"] as! [String: AnyObject])["lat"]! as! Double), longitude: (((city as! [String : AnyObject]) ["coord"] as! [String: AnyObject])["lon"]! as! Double))
                    
                    // first time weather data
                    if self.citiesAroundDict["\(id)"] == nil {
                        self.citiesAroundDict.updateValue(city, forKey: "\(id)")
                        // save the city in db
                    }
                }
                
            }
            
            
        }

        
    }

    
    func removeAllCities(){
        citiesAround.removeAll(keepCapacity: false)
        citiesAroundDict.removeAll(keepCapacity: false)
        
    }
}
/*
Optional({
    city =     {
        coord =         {
            lat = "40.650101";
            lon = "-73.94957700000001";
        };
        country = US;
        id = 5110302;
        name = Brooklyn;
        population = 0;
    };
    cnt = 2;
    cod = 200;
    list =     (
        {
            clouds = 0;
            deg = 238;
            dt = 1428249600;
            humidity = 68;
            pressure = "1033.26";
            speed = "3.21";
            temp =             {
                day = "282.42";
                eve = "284.51";
                max = "284.89";
                min = "281.81";
                morn = "282.42";
                night = "281.81";
            };
            weather =             (
                {
                    description = "sky is clear";
                    icon = 01d;
                    id = 800;
                    main = Clear;
                }
            );
        },
        {
            clouds = 0;
            deg = 225;
            dt = 1428336000;
            humidity = 68;
            pressure = "1036.05";
            speed = "1.7";
            temp =             {
                day = "284.73";
                eve = "288.65";
                max = "288.65";
                min = "278.17";
                morn = "278.17";
                night = "284.86";
            };
            weather =             (
                {
                    description = "sky is clear";
                    icon = 01d;
                    id = 800;
                    main = Clear;
                }
            );
        }
    );
    message = "0.0024";
})

*/
