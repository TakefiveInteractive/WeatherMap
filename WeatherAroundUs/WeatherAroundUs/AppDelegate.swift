//
//  AppDelegate.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/2/25.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import CoreData
import ZipArchive


let APIKey: String = "24ca61756c2b67cf28c5cc3bef430e2c"


@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //copy db to local if needed
        let fileManager = NSFileManager.defaultManager()
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        var target = path.stringByAppendingPathComponent("citiesInfo.db")
        
        /*
        create database
        if (!fileManager.fileExistsAtPath(target)) {
            var resource = NSBundle.mainBundle().pathForResource("citiesInfo", ofType: "db") as String?
            fileManager.copyItemAtPath(resource!, toPath: target, error: nil)
        }
        */
        println(path)
        
        target = path.stringByAppendingPathComponent("MainTree.plist")
        
        if !fileManager.fileExistsAtPath(target){
            //unzip the files
            let filePath = NSBundle.mainBundle().pathForResource("subtrees", ofType: "zip")
            let zip = ZipArchive()
            zip.UnzipOpenFile(filePath)
            zip.UnzipFileTo(path, overWrite: true)
            zip.UnzipCloseFile()
        }
        
        UserLocation.setup()
        IconImage.setupPhotos()

        let userDefault = NSUserDefaults.standardUserDefaults()
        // init the image url cache if not exist
        if userDefault.objectForKey("smallImgUrl") == nil{
            userDefault.setObject( [String: String](), forKey: "smallImgUrl")
            userDefault.setObject( [String: String](), forKey: "imgUrl")
            userDefault.synchronize()
        }else{
            ImageCache.imagesUrl = userDefault.objectForKey("imgUrl") as! [String: String]
            ImageCache.smallImagesUrl = userDefault.objectForKey("smallImgUrl") as! [String: String]
        }
        
        //set up current date if not exist
        if userDefault.objectForKey("currentDate") == nil{
            var currDate = NSDate()
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd.MM.YY"
            let dateStr = dateFormatter.stringFromDate(currDate)
            userDefault.setObject( dateStr, forKey: "currentDate")
            userDefault.synchronize()
            
        }else{
            WeatherInfo.currentDate = userDefault.objectForKey("currentDate") as! String
        }

        if userDefault.objectForKey("temperatureDisplay") == nil{
            userDefault.setBool(true, forKey: "temperatureDisplay")
            userDefault.synchronize()

        }
        
        if userDefault.objectForKey("citiesForcast") == nil{
            userDefault.setObject([String: AnyObject](), forKey: "citiesForcast")
            userDefault.synchronize()
        }

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        saveInformations()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        saveInformations()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }



    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.KedanLi.com.WeatherAroundUs" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("WeatherAroundUs", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("WeatherAroundUs.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as [NSObject : AnyObject])
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    func saveInformations(){
        // save user location in nsdefault
        var userDefaults = NSUserDefaults.standardUserDefaults()
        
        userDefaults.setDouble(UserLocation.centerLocation.coordinate.longitude, forKey: "longitude")
        userDefaults.setDouble(UserLocation.centerLocation.coordinate.latitude, forKey: "latitude")
        userDefaults.setObject(ImageCache.imagesUrl, forKey: "imgUrl")
        userDefaults.setObject(ImageCache.smallImagesUrl, forKey: "smallImgUrl")
        userDefaults.setObject(WeatherInfo.citiesForcast, forKey: "citiesForcast")
        userDefaults.synchronize()
    }

}

