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
    var currentCityID = ""
    
    var zoom:Float = 12
    
    func setup() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.valueForKey("longitude") != nil{
            var camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(userDefaults.valueForKey("latitude") as! Double, longitude: userDefaults.valueForKey("longitude") as! Double, zoom: zoom)
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
        // save user location in nsdefault
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setDouble(location.coordinate.longitude, forKey: "longitude")
        userDefaults.setDouble(location.coordinate.latitude, forKey: "latitude")
        userDefaults.synchronize()
        
    }
    
    func gotOneNewWeatherData(cityID: String, latitude:CLLocationDegrees, longitude:CLLocationDegrees) {
        
        // update city if doesn't exist
        if weatherIcons[cityID] == nil{
            
            WeatherInfo.citiesAround.insert(cityID, atIndex: 0)
            
            if weatherIcons.count == 0 {
                //diplay the first city getted
                parentController.card.displayCity(cityID)
                currentCityID = cityID
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
            var icon = UIImage()
            if !WeatherInfo.forcastMode{
                icon = UIImage(named: (((WeatherInfo.citiesAroundDict[cityID] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String)!
            }else{
                let data: AnyObject = WeatherInfo.citiesForcast[cityID as String]!
                let name = (((data[self.parentController.clockButton.futureDay] as! [String: AnyObject])["weather"] as! [AnyObject])[0] as! [String: AnyObject])["icon"] as! String
                icon = UIImage(named: name)!
            }
            marker.icon = getImageAccordingToZoom(icon)
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.map = self
            marker.title = cityID

            weatherIcons.updateValue(marker, forKey: cityID)
        }
    }
    
    func getImageAccordingToZoom(icon: UIImage)->UIImage{
        
        if camera.zoom > 12.5{
            return icon.resize(CGSizeMake(50, 50)).addShadow(blurSize: 3.0)
        }else if camera.zoom > 11{
            return icon.resize(CGSizeMake(35, 35)).addShadow(blurSize: 3.0)
        }else if camera.zoom < 9.5{
            return icon.resize(CGSizeMake(15, 15)).addShadow(blurSize: 3.0)
        }else{
            return icon.resize(CGSizeMake(25, 25)).addShadow(blurSize: 3.0)
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
    
    func changeIconWithTime(day: Int){
        
        for city in WeatherInfo.citiesAround{
            if let data: AnyObject = WeatherInfo.citiesForcast[city as String] {
                let name = (((data[day] as! [String: AnyObject])["weather"] as! [AnyObject])[0] as! [String: AnyObject])["icon"] as! String
                let icon = UIImage(named: name)
                weatherIcons[city]?.icon = getImageAccordingToZoom(icon!)
            }else{
                // get the weather data if not found
                var connection = InternetConnection()
                connection.delegate = WeatherInfo
                connection.getWeatherForcast(city)
            }
        }
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        parentController.card.displayCity(marker.title)
        
        currentCityID = (weatherIcons as NSDictionary).allKeysForObject(marker)[0] as! String
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        if let url: AnyObject = (userDefault.objectForKey("smallImgUrl") as! NSMutableDictionary).objectForKey(currentCityID){
            // if doesn't have url  get url
            var cache = ImageCache()
            cache.delegate = parentController.card
            cache.getSmallImageFromCache(url as! String, cityID: currentCityID)
        }else{
            var connection = InternetConnection()
            connection.delegate = parentController.card
            //get image url
            connection.getSearchAddressOfACity(marker.position, name:((WeatherInfo.citiesAroundDict[(weatherIcons as NSDictionary).allKeysForObject(marker)[0] as! String] as! [String: AnyObject])["name"] as? String)!, cityID: currentCityID)
        }
        
        
        self.animateToLocation(marker.position)
        
        return true
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        let thisLocation = CLLocation(latitude: self.camera.target.longitude, longitude: self.camera.target.latitude)
        // update weather info
        WeatherInfo.getLocalWeatherInformation(self.camera.target, number: getNumOfWeatherBasedOnZoom())
        
    }
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        // move the prebase if in add base mode
        
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
        
        if abs(zoom - camera.zoom) > 0.5{
            zoom = camera.zoom
        // change size of icons
            let iconKeys = weatherIcons.keys
            for key in iconKeys{
                var icon = UIImage(named: (((WeatherInfo.citiesAroundDict[key] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String)
                weatherIcons[key]?.icon = getImageAccordingToZoom(icon!)
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
