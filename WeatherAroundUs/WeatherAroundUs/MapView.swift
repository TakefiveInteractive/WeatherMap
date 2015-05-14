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
    
    // both contain the same data
    var weatherIconsTree = QTree()
    var weatherIcons = [WeatherMarker: AnyObject]()
    var iconToRemove = [WeatherMarker: AnyObject]()

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
        if (marker as! WeatherMarker).data.isMemberOfClass(QCluster) {
            //handle cluster
            self.animateToZoom(10.5)
        }else{
            WeatherInfo.currentCityID = marker.title
            parentController.card.displayCity(marker.title)
        }
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
        if camera.zoom > 13{
            iconSize = .XLarge
        }else if camera.zoom > 12{
            iconSize = .Large
        }else if camera.zoom > 11{
            iconSize = .Mid
        }else if camera.zoom > 10{
            iconSize = .Small
        }else{
            iconSize = .Reduced
        }
        if iconSize != previousSize{
            displayIcon()
        }
    }
    
    //display the icon on the map
    func displayIcon() {
        
        println(camera.zoom)
        
        iconToRemove = weatherIcons
        weatherIcons = [WeatherMarker: AnyObject]()
        
        let distance = WeatherMapCalculations.getTheDistanceBased(self.projection.visibleRegion())
        
        if camera.zoom > 10{
            //display all icon
            let iconsData = WeatherInfo.quadTree.neighboursForLocation(camera.target, limitCount: 30)
            
            for icon in iconsData{
                //an icon can be taken
                var markers = weatherIconsTree.neighboursForLocation((icon as! WeatherDataQTree).coordinate, limitCount: 1)
                
                changeIconDisplay(markers, newLocation: (icon as! WeatherDataQTree).coordinate, distance: distance / 15, data: icon, cityID: (icon as! WeatherDataQTree).cityID)
            }
            
        }else{
        
            var mapRegion = WeatherMapCalculations.convertRegion(camera.target, distance: distance)
            println(mapRegion.span.latitudeDelta)
            var reducedLocations = WeatherInfo.quadTree.getObjectsInRegion(mapRegion, minNonClusteredSpan: min(mapRegion.span.latitudeDelta, mapRegion.span.longitudeDelta) / 8)
            
            for icon in reducedLocations {
                
                if icon.isMemberOfClass(WeatherDataQTree){
                    // is an icon
                    var markers = weatherIconsTree.neighboursForLocation((icon as! WeatherDataQTree).coordinate, limitCount: 1)
                    
                    changeIconDisplay(markers, newLocation: (icon as! WeatherDataQTree).coordinate, distance: distance / 15, data: icon, cityID: (icon as! WeatherDataQTree).cityID)
                    
                }else{
                    // is cluster
                    let cluster = icon as! QCluster
                    
                        var markers = weatherIconsTree.neighboursForLocation(cluster.coordinate, limitCount: 1)
                        
                        changeIconDisplay(markers, newLocation: cluster.coordinate, distance: distance / 15, data: icon, cityID: "")
                    
                }
            }
            println("~~~~~~~~~~~~~~~~~~~~~~~~~")
        }

        //remove unuse icons
        for key in iconToRemove.keys.array {
            key.map = nil
            weatherIconsTree.removeObject(key)
            iconToRemove.removeValueForKey(key)
        }
        
        if WeatherInfo.forcastMode{
            changeIconWithTime(parentController.clockButton.futureDay)
        }else{
            changeIconWithTime(-1)
        }

        replaceCard()
    }
    
    func changeIconDisplay(markers: NSArray? , newLocation: CLLocationCoordinate2D, distance: Double, data: AnyObject, cityID: String){
        
        if markers != nil && markers!.count > 0 && iconToRemove[markers![0] as! WeatherMarker] != nil {
            let location = CLLocation(latitude: (markers![0] as! WeatherMarker).coordinate.latitude, longitude: (markers![0] as! WeatherMarker).coordinate.longitude)
            if location.distanceFromLocation(CLLocation(latitude: newLocation.latitude, longitude: newLocation.longitude)) < distance {
                // reset icon   change corresponding data
                weatherIcons.updateValue(data, forKey: (markers![0] as! WeatherMarker))
                (markers![0] as! WeatherMarker).data = data
                iconToRemove.removeValueForKey((markers![0] as! WeatherMarker))
            }else{
                addIconToMap(cityID, position: newLocation, iconInfo: data)
            }
        }else{
            addIconToMap(cityID, position: newLocation, iconInfo: data)
        }
    }
    
    //display card if needed
    func replaceCard(){
        if shouldDisplayCard {
            if WeatherInfo.quadTree.count > 0{
                shouldDisplayCard = false
                //diplay the card of the first city getted
                WeatherInfo.currentCityID = (WeatherInfo.quadTree.neighboursForLocation(camera.target, limitCount: 1)[0] as! WeatherDataQTree).cityID
                parentController.card.displayCity(WeatherInfo.currentCityID)
            }
        }
    }
    
    func addIconToMap(cityID: String, position: CLLocationCoordinate2D, iconInfo: AnyObject){
        
        var marker = WeatherMarker(position: position, cityID: cityID, info: iconInfo)
        var iconStr = ""
        if !WeatherInfo.forcastMode{
            if cityID == ""{
                //is cluster
                let city = (WeatherInfo.quadTree.neighboursForLocation((iconInfo as! QCluster).coordinate, limitCount: 1)[0] as! WeatherDataQTree).cityID
                iconStr = (((WeatherInfo.citiesAroundDict[city] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String

            }else{
                iconStr = (((WeatherInfo.citiesAroundDict[cityID] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String
            }
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
        weatherIconsTree.insertObject(marker)
        weatherIcons.updateValue(iconInfo, forKey: marker)
    }

    
    //if day == -1  display current time
    func changeIconWithTime(day: Int){
        
        for city in weatherIcons.keys.array {
            
            //set to low priority    performance issue
            //dispatch_after(DISPATCH_TIME_NOW, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) { () -> Void in
            if day == -1{
                if city.data.isMemberOfClass(QCluster){
                    let thecity = (WeatherInfo.quadTree.neighboursForLocation((city.data as! QCluster).coordinate, limitCount: 1)[0] as! WeatherDataQTree).cityID
                    let iconStr = (((WeatherInfo.citiesAroundDict[thecity] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String
                    city.icon = IconImage.getImageWithNameAndSize(iconStr, size: self.iconSize)
                }else{
                    let iconStr = (((WeatherInfo.citiesAroundDict[(city.data as! WeatherDataQTree).cityID] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String
                    city.icon = IconImage.getImageWithNameAndSize(iconStr, size: self.iconSize)
                }

            }else{
                /*
                if let data: AnyObject = WeatherInfo.citiesForcast[city.cityID] {
                    let name = (((data[day] as! [String: AnyObject])["weather"] as! [AnyObject])[0] as! [String: AnyObject])["icon"] as! String
                    city.icon = IconImage.getImageWithNameAndSize(name, size: self.iconSize)
                }else{
                    // get the weather data if not found
                    var connection = InternetConnection()
                    connection.delegate = WeatherInfo
                    connection.getWeatherForcast(city.cityID)
                }*/
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

class WeatherMarker: GMSMarker, QTreeInsertable{
    
    var coordinate: CLLocationCoordinate2D
    
    var data: AnyObject!
    
    init(position: CLLocationCoordinate2D, cityID: String, info: AnyObject) {
        coordinate = position
        super.init()
        self.position = position
        data = info
    }
    
}
