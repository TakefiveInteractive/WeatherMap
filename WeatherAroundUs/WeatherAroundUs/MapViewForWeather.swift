//
//  MapView.swift
//  PaperPlane
//
//  Created by Kedan Li on 15/3/1.
//  Copyright (c) 2015年 Yu Wang. All rights reserved.
//

import UIKit

class MapViewForWeather: GMSMapView, GMSMapViewDelegate, LocationManagerDelegate, WeatherInformationDelegate{

    var parentController: ViewController!
    
    var mapKMRatio:Double = 0
    
    var mapCenter: GMSMarker!
    
    var currentLocation: CLLocation!
    
    var weatherIcons = [String: GMSMarker]()
    var searchedArea = [CLLocation]()
    
    
    func setup() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.valueForKey("longitude") != nil{
            var camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(userDefaults.valueForKey("latitude") as! Double, longitude: userDefaults.valueForKey("longitude") as! Double, zoom: 12)
            self.camera = camera
            
        }
        
        self.mapType = kGMSTypeNormal
        self.setMinZoom(10, maxZoom: 14)
        self.myLocationEnabled = false
        self.delegate = self
        self.trafficEnabled = false
        
        UserLocation.delegate = self
        
        WeatherInfo.weatherDelegate = self
        
        WeatherInfo.getLocalWeatherInformation(self.camera.target, number: getNumOfWeatherBasedOnZoom())
        
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
                var connection = InternetConnection()
                connection.delegate = parentController
                connection.getSmallPictureOfACity(CLLocationCoordinate2DMake(latitude, longitude), name:((WeatherInfo.citiesAroundDict[cityID] as! [String: AnyObject])["name"] as? String)!)
            }
            
            if WeatherInfo.citiesAround.count > WeatherInfo.maxCityNum{
                self.weatherIcons[WeatherInfo.citiesAround.last!]!.map = nil
                self.weatherIcons.removeValueForKey(WeatherInfo.citiesAround.last!)
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
        
        var str = (((WeatherInfo.citiesAroundDict[cityID] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String
        
        if camera.zoom > 12.5{
            return UIImage(named: str)!.resize(CGSizeMake(50, 50)).addShadow(blurSize: 3.0)
        }else if camera.zoom < 11{
            return UIImage(named: str)!.resize(CGSizeMake(25, 25)).addShadow(blurSize: 3.0)
        }else{
            return UIImage(named: str)!.resize(CGSizeMake(35, 35)).addShadow(blurSize: 3.0)
        }
    }
    
    func getNumOfWeatherBasedOnZoom()->Int{
        if camera.zoom > 12.5{
            return 3
        }else if camera.zoom < 11{
            return 10
        }else{
            return 6
        }

    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        parentController.card.displayCity(marker.title)
        var connection = InternetConnection()
        connection.delegate = parentController
        connection.getSmallPictureOfACity(marker.position, name:((WeatherInfo.citiesAroundDict[(weatherIcons as NSDictionary).allKeysForObject(marker)[0] as! String] as! [String: AnyObject])["name"] as? String)!)
        self.animateToLocation(marker.position)
        
        return true
    }
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        // move the prebase if in add base mode
        
    }
    
    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
        //move
        if gesture{
            let thisLocation = CLLocation(latitude: self.camera.target.longitude, longitude: self.camera.target.latitude)
            
                // update weather info
                if WeatherInfo.requestNum < 2{
                    WeatherInfo.getLocalWeatherInformation(self.camera.target, number: getNumOfWeatherBasedOnZoom())
                }
                            
            // hide board
            parentController.card.hideSelf()
            parentController.searchBar.resignFirstResponder()

        }

    }
    

    
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        
        let iconKeys = weatherIcons.keys
        for key in iconKeys{
            weatherIcons[key]?.icon = getImageAccordingToZoom(key)
        }
        /*if abs(camera.zoom - zoom) > 0.5{
            zoom = camera.zoom
            if !WeatherInfo.requesting{
                WeatherInfo.getLocalWeatherInformation(self.camera.target, number: getNumOfWeatherBasedOnZoom())
            }

        }*/
        
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
