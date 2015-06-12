//
//  WeatherCoreData.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/10.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

/*
import UIKit
import FMDB

class CitySQL: NSObject{
    
    var queue = FMDatabaseQueue()
    
    override init() {
        super.init()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let dbPath = paths.stringByAppendingPathComponent("citiesInfo.db")
        queue = FMDatabaseQueue(path: dbPath)
    }
    
    func saveCity(name: String, cityID: String, location: CLLocationCoordinate2D) {
        
        queue.inDatabase { (db) -> Void in
            
            //var search = db.executeQuery("SELECT * FROM City WHERE id LIKE ?", withArgumentsInArray: [cityID])
            let sql = "insert into City(id, name, longitude, latitude) values (?, ?, ?, ?)"
            db.executeUpdate(sql, withArgumentsInArray: [cityID, name, location.longitude, location.latitude])
        }
        
    }

    func loadDataToTree(tree: QTree){
        
        queue.inDatabase { (db) -> Void in
            
            let resultSet = db.executeQuery("select * from City", withArgumentsInArray: nil) 
            while resultSet.next() {

                let element = WeatherDataQTree(position: CLLocationCoordinate2DMake(resultSet.doubleForColumn("latitude"), resultSet.doubleForColumn("longitude")), cityID: resultSet.stringForColumn("id"))
                tree.insertObject(element)
            }
        }
    }
    
}
*/