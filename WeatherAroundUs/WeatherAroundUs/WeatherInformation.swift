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
    var currentSearchTrees = [String: QTree]()
    var currentSearchTreeDict = [String: [String: WeatherDataQTree]]()

    
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
        
        var dict = [String: WeatherDataQTree]()
        var tree = QTree()
        
        for node in treeArr{
            
            if !cityExist(node.objectForKey("cityID") as! String){
                var data = WeatherDataQTree(position: CLLocationCoordinate2DMake(node.objectForKey("latitude")!.doubleValue, node.objectForKey("longitude")!.doubleValue), cityID: node.objectForKey("cityID") as! String)
                dict.updateValue(data, forKey: data.cityID)
                tree.insertObject(data)
            }
        }
        currentSearchTreeDict.updateValue(dict, forKey: cityID)
        currentSearchTrees.updateValue(tree, forKey: cityID)
        
    }
    
    func cityExist(cityID: String)->Bool{
        for tree in currentSearchTreeDict.keys.array {
            if currentSearchTreeDict[tree]![cityID] != nil{
                return true
            }
        }
        return false
    }
    
    func removeTree(cityID: String){
        
        currentSearchTreeDict.removeValueForKey(cityID)
        currentSearchTrees.removeValueForKey(cityID)
    }
    
    // get the closest icon
    func getTheNearestIcon(position: CLLocationCoordinate2D)->WeatherDataQTree{
        let nearestTree = mainTree.neighboursForLocation(position, limitCount: 1)[0] as! WeatherDataQTree
        let data = currentSearchTrees[nearestTree.cityID]?.neighboursForLocation(position, limitCount: 1)[0] as! WeatherDataQTree
        return data
    }
    
    // get the five closest icons
    func getTheTwoNearestIcons(position: CLLocationCoordinate2D)->NSArray?{
        let nearestTree = mainTree.neighboursForLocation(position, limitCount: 1)[0] as! WeatherDataQTree
        let data = currentSearchTrees[nearestTree.cityID]?.neighboursForLocation(position, limitCount: 2)
        return data
    }
    
    // get the five closest icons
    func getTheFiveNearestIcons(position: CLLocationCoordinate2D)->NSArray?{
        let nearestTree = mainTree.neighboursForLocation(position, limitCount: 1)[0] as! WeatherDataQTree
        let data = currentSearchTrees[nearestTree.cityID]?.neighboursForLocation(position, limitCount: 5)
        return data
    }
    
    // get the closest icons
    func getNearestIcons(position: CLLocationCoordinate2D)->NSArray{
        let nearestTrees = mainTree.neighboursForLocation(position, limitCount: 2)
        var set = currentSearchTrees[(nearestTrees[0] as! WeatherDataQTree).cityID]?.neighboursForLocation(position, limitCount: 30)
        set = set! + (currentSearchTrees[(nearestTrees[1] as! WeatherDataQTree).cityID]?.neighboursForLocation(position, limitCount: 5))!
        
        return set!
    }
    
    func getObjectsInRegion(region: MKCoordinateRegion)->NSArray{
        
        var arr = [AnyObject]()
        
        println(currentSearchTrees.count)
        for tree in currentSearchTrees.keys.array{
            arr = arr + currentSearchTrees[tree]!.getObjectsInRegion(region, minNonClusteredSpan: min(region.span.latitudeDelta, region.span.longitudeDelta) / 6)!
        }
        
        return arr
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