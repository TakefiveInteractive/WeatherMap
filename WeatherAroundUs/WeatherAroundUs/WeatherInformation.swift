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
    
    var citiesForcast = [String: AnyObject]()
    var citiesAroundDict = [String: AnyObject]()
    var citiesAround = [String]()

    let maxCityNum = 50
    
    var weatherDelegate : WeatherInformationDelegate?
    var updateIconListDelegate : UpdateIconListDelegate?
        
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
                // save the city in db
            }
            self.weatherDelegate?.gotOneNewWeatherData!("\(id)", latitude: (((city as! [String : AnyObject]) ["coord"] as! [String: AnyObject])["lat"]! as! Double), longitude: (((city as! [String : AnyObject]) ["coord"] as! [String: AnyObject])["lon"]! as! Double))
        }
    }
    
    func gotWeatherForcastData(cityID: String, forcast: [AnyObject]) {
        citiesForcast.updateValue(forcast, forKey: cityID)
    }
    
    func removeAllCities(){
        citiesAround.removeAll(keepCapacity: false)
    }
}
/*
Optional({
    city =     {
        coord =         {
            lat = "37.323002";
            lon = "-122.032181";
        };
        country = US;
        id = 5341145;
        name = Cupertino;
        population = 58302;
    };
    cnt = 7;
    cod = 200;
    list =     (
        {
            clouds = 0;
            deg = 225;
            dt = 1429732800;
            humidity = 66;
            pressure = "984.9400000000001";
            speed = "1.42";
            temp =             {
                day = "295.41";
                eve = "290.32";
                max = "295.41";
                min = "280.64";
                morn = "292.08";
                night = "280.64";
            };
            weather =             (
                {
                    description = "light rain";
                    icon = 10d;
                    id = 500;
                    main = Rain;
                }
            );
        },
        {
            clouds = 0;
            deg = 209;
            dt = 1429819200;
            humidity = 68;
            pressure = "984.8200000000001";
            speed = "1.11";
            temp =             {
                day = "292.4";
                eve = "287.24";
                max = "292.4";
                min = "280.93";
                morn = "282.41";
                night = "280.93";
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
            deg = 293;
            dt = 1429905600;
            humidity = 58;
            pressure = "989.41";
            speed = "3.01";
            temp =             {
                day = "288.2";
                eve = "283.44";
                max = "288.2";
                min = "278.53";
                morn = "282.84";
                night = "278.53";
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
            deg = 317;
            dt = 1429992000;
            humidity = 0;
            pressure = "1009.94";
            speed = "3.99";
            temp =             {
                day = "288.49";
                eve = "290.76";
                max = "290.76";
                min = "281.96";
                morn = "281.96";
                night = "286.81";
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
            deg = 337;
            dt = 1430078400;
            humidity = 0;
            pressure = "1013.39";
            speed = "2.35";
            temp =             {
                day = "291.4";
                eve = "294.19";
                max = "294.19";
                min = "283.28";
                morn = "283.28";
                night = "288.17";
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
            clouds = 57;
            deg = 328;
            dt = 1430164800;
            humidity = 0;
            pressure = "1013.47";
            speed = "2.4";
            temp =             {
                day = "292.15";
                eve = "294.19";
                max = "294.19";
                min = "284.52";
                morn = "284.52";
                night = "287.12";
            };
            weather =             (
                {
                    description = "light rain";
                    icon = 10d;
                    id = 500;
                    main = Rain;
                }
            );
        },
        {
            clouds = 61;
            deg = 291;
            dt = 1430251200;
            humidity = 0;
            pressure = "1009.24";
            speed = "1.93";
            temp =             {
                day = "291.08";
                eve = "292.62";
                max = "292.62";
                min = "284.66";
                morn = "284.66";
                night = "285.55";
            };
            weather =             (
                {
                    description = "light rain";
                    icon = 10d;
                    id = 500;
                    main = Rain;
                }
            );
        }
    );
    message = "0.0063";
})

*/