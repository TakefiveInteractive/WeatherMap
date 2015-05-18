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
    optional func gotWeatherInformation()
}

var WeatherInfo: WeatherInformation = WeatherInformation()

class WeatherInformation: NSObject, InternetConnectionDelegate{
    
    var currentDate = ""

    // 9 days weather forcast for city
    var citiesForcast = [String: AnyObject]()
    // all city in database with one day weather info
    var citiesAroundDict = [String: AnyObject]()
    
    // tree that store all the weather data
    var currentSearchTree = QTree()

    var level1Tree = QTree()
    
    //current city id
    var currentCityID = ""

    let maxCityNum = 150

    var forcastMode = false
    
    var blockSize = 10
    
    var weatherDelegate : WeatherInformationDelegate?
    
    override init() {
        super.init()
        if let forcast: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("citiesForcast"){
            citiesForcast = forcast as! [String : AnyObject]
        }

        splitIntoSubtree()
    }
    
    func splitIntoSubtree(){
        
        let db = CitySQL()
        var entireTree = QTree()
        db.loadDataToTree(entireTree)
        
        for var x = -180; x < 180; x += blockSize {
            for var y = -90; y < 90; y += blockSize{
                
                let centerCoordinate = CLLocationCoordinate2DMake(Double(y + blockSize / 2), Double(x + blockSize / 2))
                let location1 = CLLocation(latitude: Double(y), longitude: Double(x))
                let distance = location1.distanceFromLocation(CLLocation(latitude: Double(y + blockSize), longitude: Double(x + blockSize)))
                let region = MKCoordinateRegionMakeWithDistance(centerCoordinate, distance, distance)
                
                // get all nodes in an area
                let cities = entireTree.getObjectsInRegion(region, minNonClusteredSpan: 0.000001)
                
                if cities.count > 0{
                    
                    if cities.count < 400{
                        var tree = SecondLevelQTree(position: centerCoordinate, cityID: (cities[0] as! WeatherDataQTree).cityID)
                        
                        for city in cities{
                            
                            tree.insertObject(city as! WeatherDataQTree)
                            
                        }
                        println(cities.count)
                        level1Tree.insertObject(tree)
                    }else{
                        // split into level 3 tree
                        
                        var uptree = SecondLevelQTree(position: centerCoordinate, cityID: (cities[0] as! WeatherDataQTree).cityID)
                        
                        let size = 0.33
                        
                        for var xm: Double = Double(x); xm < Double(x + blockSize); xm += size {
                            for var ym: Double = Double(y); ym < Double(y + blockSize); ym += size {
                                let centerCoordinateThird = CLLocationCoordinate2DMake(Double(ym + size / 2), Double(xm + size / 2))
                                let location1 = CLLocation(latitude: Double(ym), longitude: Double(xm))
                                let distanceThird = location1.distanceFromLocation(CLLocation(latitude: Double(ym + size), longitude: Double(xm + size)))
                                let region = MKCoordinateRegionMakeWithDistance(centerCoordinateThird, distanceThird, distanceThird)
                                
                                // get all nodes in an area
                                let citiesInThirdLevel = entireTree.getObjectsInRegion(region, minNonClusteredSpan: 0.000001)
                                if citiesInThirdLevel.count > 0{
                                    
                                    var tree = ThirdLevelQTree(position: (citiesInThirdLevel[0] as! WeatherDataQTree).coordinate, cityID: (citiesInThirdLevel[0] as! WeatherDataQTree).cityID)
                                    
                                    for thirdCity in citiesInThirdLevel{
                                        
                                        tree.insertObject(thirdCity as! WeatherDataQTree)
                                        
                                    }
                                    uptree.insertObject(tree)
                                    println(citiesInThirdLevel.count)
                                }
                            }
                        }
                        level1Tree.insertObject(uptree)
                    }
                }
            }
        }
        
    }

    
    func getLocalWeatherInformation(cities: [QTreeInsertable]){
        
        var connection = InternetConnection()
        connection.delegate = self
        connection.getLocalWeather(cities)
    }

    // got local city weather from member
    func gotLocalCityWeather(cities: [AnyObject]) {
        
        var hasNewInfo = false
        
        for var index = 0; index < cities.count; index++ {
                
            let id: Int = (cities[index] as! [String : AnyObject]) ["id"] as! Int
            
            // first time weather data
            if self.citiesAroundDict["\(id)"] == nil {
                self.citiesAroundDict.updateValue(cities[index], forKey: "\(id)")
                
                var connection = InternetConnection()
                connection.delegate = self
                connection.getWeatherForcast("\(id)")
                hasNewInfo = true
            }
        }
        
        if !forcastMode && hasNewInfo {
            self.weatherDelegate?.gotWeatherInformation!()
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
            self.weatherDelegate?.gotWeatherInformation!()
        }
    }
    
}

/*
class FourthLevelQTree: QTree, QTreeInsertable{
    
    var coordinate: CLLocationCoordinate2D
    var centerCity: String!
    
    init(position: CLLocationCoordinate2D) {
        coordinate = position
        super.init()
    }
    
}*/

class ThirdLevelQTree: QTree, QTreeInsertable{
    
    var coordinate: CLLocationCoordinate2D
    var cityID: String
    
    init(position: CLLocationCoordinate2D, cityID: String) {
        coordinate = position
        self.cityID = cityID
        super.init()
    }
    
}

class SecondLevelQTree: QTree, QTreeInsertable{
    
    var coordinate: CLLocationCoordinate2D
    var cityID: String

    init(position: CLLocationCoordinate2D, cityID: String) {
        coordinate = position
        self.cityID = cityID
        super.init()
    }
    
}

class WeatherDataQTree: NSObject, QTreeInsertable{
    
    var coordinate: CLLocationCoordinate2D
    
    var cityID = ""
    
    init(position: CLLocationCoordinate2D, cityID: String) {
        coordinate = position
        self.cityID = cityID
        super.init()
    }
    
}

