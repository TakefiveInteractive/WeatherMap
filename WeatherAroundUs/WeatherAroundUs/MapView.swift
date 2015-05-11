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
    
    var shouldDisplayCard = true
    
    func setup() {
        let userDefaults = NSUserDefaults.standardUserDefaults()

        if userDefaults.valueForKey("longitude") != nil{
            var camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(userDefaults.valueForKey("latitude") as! Double, longitude: userDefaults.valueForKey("longitude") as! Double, zoom: 12)
            self.camera = camera
        }
        
        self.setMinZoom(5, maxZoom: 14)

        self.mapType = kGMSTypeNormal
        self.myLocationEnabled = true
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
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        WeatherInfo.currentCityID = marker.title
        parentController.card.displayCity(marker.title)
        self.animateToLocation(marker.position)
        return true
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        let thisLocation = CLLocation(latitude: self.camera.target.longitude, longitude: self.camera.target.latitude)
        // update weather info
        WeatherInfo.getLocalWeatherInformation(self.camera.target, number: 15)
        displayIcon()
    }
    
    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
        //move
        if gesture{
            // hide board
            parentController.searchBar.hideSelf()
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
            displayIcon()
        }
    }
    
    //display the icon on the map
    func displayIcon() {
        
        var icons = weatherIcons
        weatherIcons.removeAll(keepCapacity: false)
        
        var mapRegion = WeatherMapCalculations.convertRegion(self.camera.target, region: self.projection.visibleRegion())
        
        var reducedLocations = WeatherInfo.quadTree.getObjectsInRegion(mapRegion, minNonClusteredSpan: min(mapRegion.span.latitudeDelta, mapRegion.span.longitudeDelta) / 3)
        
        for icon in reducedLocations{
            if icon.isMemberOfClass(WeatherDataQTree){
                // is an icon
                if icons[(icon as! WeatherDataQTree).cityID] != nil{
                    weatherIcons.updateValue(icons[(icon as! WeatherDataQTree).cityID]!, forKey: (icon as! WeatherDataQTree).cityID)
                    icons.removeValueForKey((icon as! WeatherDataQTree).cityID)
                }else{
                    addIconToMap((icon as! WeatherDataQTree).cityID, position: (icon as! WeatherDataQTree).coordinate)
                }
            }else{
                // is cluster
                let cluster = icon as! QCluster
                let centerIcon = WeatherInfo.quadTree.neighboursForLocation(cluster.coordinate, limitCount: UInt(cluster.objectsCount))[0] as! WeatherDataQTree
                if icons[centerIcon.cityID] != nil{
                    weatherIcons.updateValue(icons[centerIcon.cityID]!, forKey: centerIcon.cityID)
                    icons.removeValueForKey(centerIcon.cityID)
                }else{
                    addIconToMap(centerIcon.cityID, position: centerIcon.coordinate)
                }
            }
        }
        
        for key in icons.keys.array{
            icons[key]?.map = nil
        }

        if WeatherInfo.forcastMode{
            changeIconWithTime(parentController.clockButton.futureDay)
        }else{
            changeIconWithTime(-1)
        }

    }
    
    func addIconToMap(cityID: String, position: CLLocationCoordinate2D){
        
        //display card if needed
        if shouldDisplayCard {
            shouldDisplayCard = false
            //diplay the card of the first city getted
            WeatherInfo.currentCityID = cityID
            parentController.card.displayCity(cityID)
        }
        
        var marker = GMSMarker(position: position)
        var iconStr = ""
        if !WeatherInfo.forcastMode{
            iconStr = (((WeatherInfo.citiesAroundDict[cityID] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String
        }else{
            let data: AnyObject? = WeatherInfo.citiesForcast[cityID as String]
            //in case doesn't have forcast data
            if data == nil{
                return
            }
            iconStr = (((data![self.parentController.clockButton.futureDay] as! [String: AnyObject])["weather"] as! [AnyObject])[0] as! [String: AnyObject])["icon"] as! String
        }
        marker.icon = IconImage.getImageWithNameAndSize(iconStr, size: iconSize)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = self
        marker.title = cityID
        weatherIcons.updateValue(marker, forKey: cityID)
        
    }

    
    //if day == -1  display current time
    func changeIconWithTime(day: Int){
        
        for city in weatherIcons.keys.array {
            
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

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    


}
