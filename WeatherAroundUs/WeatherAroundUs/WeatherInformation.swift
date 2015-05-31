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
    var currentSearchTreeDict = [String: [WeatherDataQTree]]()
    var currentSearchTreeUnique = [String: WeatherDataQTree]()

    
    var mainTree = QTree()
    
    var lv2 = QTree()
    
    
    //current city id
    var currentCityID = ""
        
    var forcastMode = false
    
    var blockSize = 8
    
    var weatherDelegate : WeatherInformationDelegate?
    
    override init() {
        super.init()
        if let forcast: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("citiesForcast"){
            citiesForcast = forcast as! [String : AnyObject]
        }
        
        //splitIntoSubtree()
        
        //Load Main Tree
        if var path =  NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as? String{
            path = path.stringByAppendingString("/MainTree.plist")
            var arr = NSArray(contentsOfFile: path) as! [NSDictionary]
            for tree in arr{
                mainTree.insertObject(WeatherDataQTree(position: CLLocationCoordinate2DMake((tree.objectForKey("latitude")! as! NSNumber).doubleValue, (tree.objectForKey("longitude")! as! NSNumber).doubleValue), cityID: tree.objectForKey("cityID") as! String))
            }
        }
    }
    
    func loadTree(cityID: String){
        
        var treeArr = [NSDictionary]()
        
        if var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as? String{
            path = path.stringByAppendingString("/" + cityID + ".plist")
            var arr = NSArray(contentsOfFile: path)
            treeArr = arr as! [NSDictionary]
        }
        
        var arr = [WeatherDataQTree]()
        
        for node in treeArr{
            
            if currentSearchTreeUnique[node.objectForKey("cityID") as! String] == nil{
                var data = WeatherDataQTree(position: CLLocationCoordinate2DMake(node.objectForKey("latitude")!.doubleValue, node.objectForKey("longitude")!.doubleValue), cityID: node.objectForKey("cityID") as! String)
                arr.append(data)
                currentSearchTree.insertObject(data)
                
                weak var weakData = data
                currentSearchTreeUnique.updateValue(weakData!, forKey: data.cityID)
            }
        }
        currentSearchTreeDict.updateValue(arr, forKey: cityID)
    }
    
    func removeTree(cityID: String){
        
        currentSearchTreeDict.removeValueForKey(cityID)

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
                    
                    var tree = SecondLevelQTree(position: centerCoordinate, cityID: (cities[0] as! WeatherDataQTree).cityID)
                    
                    for city in cities{
                        
                        tree.insertObject(city as! WeatherDataQTree)
                        
                    }
                    println(cities.count)
                    lv2.insertObject(tree)
                    
                    // split into level 3 tree
                }
            }
        }
        
        QtreeSerialization.saveSecondLevelTree(lv2)
        QtreeSerialization.saveMainTree(lv2)
    }
    
}



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



/*
class FourthLevelQTree: QTree, QTreeInsertable{

var coordinate: CLLocationCoordinate2D
var centerCity: String!

init(position: CLLocationCoordinate2D) {
coordinate = position
super.init()
}

}*/

/*

build   Tree   plist   files



*/