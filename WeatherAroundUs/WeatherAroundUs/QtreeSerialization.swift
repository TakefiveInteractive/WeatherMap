//
//  QtreeSerialization.swift
//  WeatherMap
//
//  Created by Kedan Li on 15/5/28.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit

class QtreeSerialization: NSObject {
    
    
    class func saveFirstLevelTree(tree: QTree){
        let subtrees = tree.neighboursForLocation(CLLocationCoordinate2DMake(1, 1), limitCount: tree.count) as! [SecondLevelQTree]
        
        for subtree in subtrees{
            
            
            var subarr = NSMutableArray()
            
            let bottomTrees = subtree.neighboursForLocation(subtree.coordinate, limitCount: subtree.count) as! [ThirdLevelQTree]
            
            if bottomTrees.count > 0{
                
                for bottomTree in bottomTrees{
                    
                    var bottomarr = NSMutableArray()
                    
                    let data = bottomTree.neighboursForLocation(bottomTree.coordinate, limitCount: bottomTree.count) as! [WeatherDataQTree]
                    
                    for info in data{
                        bottomarr.addObject(["cityID":info.cityID, "longitude": NSNumber(double: info.coordinate.longitude), "latitude": NSNumber(double: info.coordinate.latitude)])
                    }
                    subarr.addObject(bottomarr)
                }
            }
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
            let documentsDirectory = paths.objectAtIndex(0) as! String
            let path = documentsDirectory.stringByAppendingPathComponent("\(subtree.cityID)sub.plist")
            subarr.writeToFile(path, atomically: true)
        }
    }
    
    
    class func saveSecondLevelTree(tree: QTree){
        
        let subtrees = tree.neighboursForLocation(CLLocationCoordinate2DMake(1, 1), limitCount: tree.count) as! [SecondLevelQTree]
        
        for subtree in subtrees{
            
            var subarr = NSMutableArray()
            
            let data = subtree.neighboursForLocation(subtree.coordinate, limitCount: subtree.count) as! [WeatherDataQTree]
            for info in data{
                subarr.addObject(["cityID":info.cityID, "longitude": NSNumber(double: info.coordinate.longitude), "latitude": NSNumber(double: info.coordinate.latitude)])
            }
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
            let documentsDirectory = paths.objectAtIndex(0) as! String
            let path = documentsDirectory.stringByAppendingPathComponent("\(subtree.cityID).plist")
            subarr.writeToFile(path, atomically: true)
            
            println(path)
        }
        
    }
    
    
    class func saveMainTree(tree: QTree){
        
        let subtrees = tree.neighboursForLocation(CLLocationCoordinate2DMake(1, 1), limitCount: tree.count) as! [SecondLevelQTree]
        var subarr = NSMutableArray()

        for info in subtrees{
            
            subarr.addObject(["cityID":info.cityID, "longitude": NSNumber(double: info.coordinate.longitude), "latitude": NSNumber(double: info.coordinate.latitude)])
            
        }
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! String
        let path = documentsDirectory.stringByAppendingPathComponent("MainTree.plist")
        subarr.writeToFile(path, atomically: true)
        println(path)

    }
    
    
    class func saveCityDict(tree: QTree){
        
        var dict = NSMutableDictionary()
        
        let data = tree.neighboursForLocation(CLLocationCoordinate2DMake(1, 1), limitCount: tree.count) as! [WeatherDataQTree]
        
        for info in data{
            
            var lat = "\(info.coordinate.latitude)"
            var lon = "\(info.coordinate.latitude)"

            dict.setObject(["latitude": NSNumber(double: info.coordinate.latitude), "longitude": NSNumber(double: info.coordinate.longitude)], forKey: info.cityID)
        }
        
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! String
        let path = documentsDirectory.stringByAppendingPathComponent("CityDict.plist")
        dict.writeToFile(path, atomically: true)
        
        println(path)
    }
    
}



