//
//  MapView.swift
//  PaperPlane
//
//  Created by Kedan Li on 15/3/1.
//  Copyright (c) 2015年 Yu Wang. All rights reserved.
//

import UIKit

class MapViewForWeather: GMSMapView, GMSMapViewDelegate, LocationManagerDelegate, WeatherInformationDelegate{

    var mapKMRatio:Double = 0
    
    var mapCenter: GMSMarker!
    
    var currentLocation: CLLocation!
    
    var weatherIcons = [String: GMSMarker]()
    var searchedArea = [CLLocation]()
    
    var zoom:Float = 12
    
    func setup() {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.valueForKey("longitude") != nil{
            var camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(userDefaults.valueForKey("latitude") as! Double, longitude: userDefaults.valueForKey("longitude") as! Double, zoom: zoom)
            self.camera = camera
            
        }
        
        self.mapType = kGMSTypeNone
        self.setMinZoom(10, maxZoom: 14)
        self.myLocationEnabled = false
        self.delegate = self
        self.mapType = kGMSTypeNone
        
        var layer = CachingTileClass()
        layer.map = self
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
            
            if WeatherInfo.citiesAround.count > WeatherInfo.maxCityNum{
                self.weatherIcons.removeValueForKey(WeatherInfo.citiesAround[0])
                WeatherInfo.citiesAround.removeLast()
            }
            WeatherInfo.updateIconListDelegate?.updateIconList!()
            
            var marker = GMSMarker(position: CLLocationCoordinate2DMake(latitude
                , longitude))
            marker.icon = getImageAccordingToZoom(cityID)
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.map = self
            marker.title = cityID
            
            weatherIcons.updateValue(marker, forKey: cityID)
        }
    }
    
    func getImageAccordingToZoom(cityID: String)->UIImage{
        if zoom > 12.5{
            return UIImage(named: "cloudAndSun")!.resize(CGSizeMake(40, 40))
        }else if zoom < 11{
            return UIImage(named: "cloudAndSun")!.resize(CGSizeMake(15, 15))
        }else{
            return UIImage(named: "cloudAndSun")!.resize(CGSizeMake(25, 25))
        }
    }

    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        println(marker.title)
        return true
    }
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        // move the prebase if in add base mode
        
    }
    
    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
        //move
        if gesture{
            let thisLocation = CLLocation(latitude: self.camera.target.longitude, longitude: self.camera.target.latitude)
            
            let distance = WeatherMapCalculations.getTheDistanceBasedOnZoom(self.camera.zoom)
            
            var shouldSearch = true
            // check if should perform new search
            for location in searchedArea{
                if thisLocation.distanceFromLocation(location) / 1000 < distance * 2 {
                    shouldSearch = false
                }
            }
            
            if shouldSearch{
                // update weather info
                WeatherInfo.getLocalWeatherInformation(self.camera.target)
                
                searchedArea.append(CLLocation(latitude: self.camera.target.longitude, longitude: self.camera.target.latitude))
                
                if searchedArea.count > 3{
                    searchedArea.removeAtIndex(0)
                }
            }
        }

    }
    
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        
        
    }
    
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        var content = GMSMarker(position: coordinate)
        content.icon = UIImage(named: "rainning")?.resize(CGSizeMake(25, 25))
        content.appearAnimation = kGMSMarkerAnimationPop
        //content.snippet = "sdds"
        content.map = self
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
