//
//  MapView.swift
//  PaperPlane
//
//  Created by Kedan Li on 15/3/1.
//  Copyright (c) 2015年 Yu Wang. All rights reserved.
//

import UIKit



class MapView: GMSMapView, GMSMapViewDelegate, LocationManagerDelegate, WeatherInformationDelegate{
    
    var parentController: ViewController!
    
    var mapKMRatio:Double = 0
    
    var mapCenter: GMSMarker!
    
    var currentLocation: CLLocation!
        
    var weatherIcons = [String: GMSMarker]()
    var searchedArea = [CLLocation]()
    var iconSize = IconSize.Large
    
    func setup() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.valueForKey("longitude") != nil{
            var camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(userDefaults.valueForKey("latitude") as! Double, longitude: userDefaults.valueForKey("longitude") as! Double, zoom: 12)
            self.camera = camera
        }
        
        self.mapType = kGMSTypeNormal
        self.setMinZoom(8, maxZoom: 14)
        self.myLocationEnabled = false
        self.delegate = self
        self.trafficEnabled = false
        
        UserLocation.delegate = self
        
        WeatherInfo.weatherDelegate = self
                
    }

    func gotCurrentLocation(location: CLLocation) {
        if currentLocation == nil{
            self.animateToLocation(location.coordinate)
        }
        currentLocation = location
    }
    
    func gotOneNewWeatherData(cityID: String, latitude:CLLocationDegrees, longitude:CLLocationDegrees) {
        
        // update city if doesn't exist
        if weatherIcons[cityID] == nil{
            
            WeatherInfo.citiesAround.insert(cityID, atIndex: 0)
            
            if weatherIcons.count == 0 {
                //diplay the first city getted
                parentController.card.displayCity(cityID)
                WeatherInfo.currentCityID = cityID
                var connection = InternetConnection()
                connection.delegate = parentController.card
                connection.getSearchAddressOfACity(CLLocationCoordinate2DMake(latitude, longitude), name:((WeatherInfo.citiesAroundDict[cityID] as! [String: AnyObject])["name"] as? String)!, cityID: cityID)
            }
            
            if WeatherInfo.citiesAround.count > WeatherInfo.maxCityNum{
                self.weatherIcons[WeatherInfo.citiesAround.last!]!.map = nil
                self.weatherIcons.removeValueForKey(WeatherInfo.citiesAround.last!)
                WeatherInfo.citiesAround.removeLast()
            }
            WeatherInfo.updateIconListDelegate?.updateIconList!()
            
            var marker = GMSMarker(position: CLLocationCoordinate2DMake(latitude
                , longitude))
            var iconStr = ""
            if !WeatherInfo.forcastMode{
                iconStr = (((WeatherInfo.citiesAroundDict[cityID] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String
            }else{
                let data: AnyObject = WeatherInfo.citiesForcast[cityID as String]!
                iconStr = (((data[self.parentController.clockButton.futureDay] as! [String: AnyObject])["weather"] as! [AnyObject])[0] as! [String: AnyObject])["icon"] as! String
            }
            marker.icon = IconImage.getImageWithNameAndSize(iconStr, size: iconSize)
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.map = self
            marker.title = cityID

            weatherIcons.updateValue(marker, forKey: cityID)
        }
    }
    
    func getNumOfWeatherBasedOnZoom()->Int{
        if camera.zoom > 12.5{
            return 3
        }else if camera.zoom > 11{
            return 5
        }else if camera.zoom < 9.5{
            return 9
        }else{
            return 7
        }
    }
    
    //if day == -1  display current time
    func changeIconWithTime(day: Int){
        
        for city in WeatherInfo.citiesAround{
            
            //set to low priority    performance issue
            //dispatch_after(DISPATCH_TIME_NOW, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) { () -> Void in
            if day == -1{
                let iconStr = (((WeatherInfo.citiesAroundDict[city as String] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String
                self.weatherIcons[city]?.icon = IconImage.getImageWithNameAndSize(iconStr, size: self.iconSize)
            }else{
                if let data: AnyObject = WeatherInfo.citiesForcast[city as String] {
                    let name = (((data[day] as! [String: AnyObject])["weather"] as! [AnyObject])[0] as! [String: AnyObject])["icon"] as! String
                    self.weatherIcons[city]?.icon = IconImage.getImageWithNameAndSize(name, size: self.iconSize)
                }else{
                    // get the weather data if not found
                    var connection = InternetConnection()
                    connection.delegate = WeatherInfo
                    connection.getWeatherForcast(city)
                }
            }
        }
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        parentController.card.displayCity(marker.title)
        
        WeatherInfo.currentCityID = (weatherIcons as NSDictionary).allKeysForObject(marker)[0] as! String
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        if let url: AnyObject = (userDefault.objectForKey("smallImgUrl") as! NSMutableDictionary).objectForKey(WeatherInfo.currentCityID){
            // if doesn't have url  get url
            var cache = ImageCache()
            cache.delegate = parentController.card
            cache.getSmallImageFromCache(url as! String, cityID: WeatherInfo.currentCityID)
        }else{
            var connection = InternetConnection()
            connection.delegate = parentController.card
            //get image url
            connection.getSearchAddressOfACity(marker.position, name:((WeatherInfo.citiesAroundDict[(weatherIcons as NSDictionary).allKeysForObject(marker)[0] as! String] as! [String: AnyObject])["name"] as? String)!, cityID: WeatherInfo.currentCityID)
        }
        
        
        self.animateToLocation(marker.position)
        
        return true
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        let thisLocation = CLLocation(latitude: self.camera.target.longitude, longitude: self.camera.target.latitude)
        // update weather info
        WeatherInfo.getLocalWeatherInformation(self.camera.target, number: getNumOfWeatherBasedOnZoom())
        
    }
    
    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
        //move
        if gesture{
            // hide board
            parentController.searchBar.searchBar.resignFirstResponder()
            parentController.searchResultList.removeCities()
            parentController.card.hideSelf()
        }

    }
    
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        
        // change the size of the icon according to zoom
        let previousSize = iconSize
        if camera.zoom > 12.5{
            iconSize = .XLarge
        }else if camera.zoom > 11{
            iconSize = .Large
        }else if camera.zoom < 9.5{
            iconSize = .Small
        }else{
            iconSize = .Mid
        }
        if iconSize != previousSize{
            if WeatherInfo.forcastMode{
                changeIconWithTime(parentController.clockButton.futureDay)
            }else{
                changeIconWithTime(-1)
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    


}
