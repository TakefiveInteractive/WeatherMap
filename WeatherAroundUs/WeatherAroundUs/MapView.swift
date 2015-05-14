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
    var weatherClusterTree = QTree()
    var weatherCluster = [WeatherMarker]()
    var weatherIcons = [String: WeatherMarker]()

    var zoom: Float = 12
    
    let clusterZoom: Float = 10
    
    var iconSize = IconSize.Large
    
    var shouldDisplayCard = true
    
    func setup() {
        let userDefaults = NSUserDefaults.standardUserDefaults()

        if userDefaults.valueForKey("longitude") != nil{
            var camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(userDefaults.valueForKey("latitude") as! Double, longitude: userDefaults.valueForKey("longitude") as! Double, zoom: zoom)
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
            if WeatherInfo.citiesAroundDict[((marker as! WeatherMarker).data as! WeatherDataQTree).cityID] != nil {
                WeatherInfo.currentCityID = marker.title
                parentController.card.displayCity(marker.title)
            }
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
        if zoom != camera.zoom{
            clearIcons()
        }
        
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
        zoom = camera.zoom

    }
    
    //display the icon on the map
    func displayIcon() {
        
        let distance = WeatherMapCalculations.getTheDistanceBased(self.projection.visibleRegion())
        
        if camera.zoom > clusterZoom {
            //display all icon
            let iconsData = WeatherInfo.quadTree.neighboursForLocation(camera.target, limitCount: 30)
            
            for icon in iconsData{
                
                let cityID = (icon as! WeatherDataQTree).cityID
                
                if weatherIcons[cityID] == nil{
                    //if the icon has valid weather data
                    if WeatherInfo.citiesAroundDict[cityID] != nil{
                        addIconToMap(cityID, position: (icon as! WeatherDataQTree).coordinate, iconInfo: icon)
                    }else{
                        addIconToMap("empty", position: (icon as! WeatherDataQTree).coordinate, iconInfo: icon)
                    }
                }
            }
            
        }else{
            
            if zoom != camera.zoom{
                clearIcons()
            }
        
            var mapRegion = WeatherMapCalculations.convertRegion(camera.target, distance: distance)
            println(mapRegion.span.latitudeDelta)
            var reducedLocations = WeatherInfo.quadTree.getObjectsInRegion(mapRegion, minNonClusteredSpan: min(mapRegion.span.latitudeDelta, mapRegion.span.longitudeDelta) / 5)
            
            println(reducedLocations.count)
            
            for icon in reducedLocations {
                
                var coord = CLLocationCoordinate2DMake(0, 0)
                var iconCoord = CLLocationCoordinate2DMake(0, 0)
                if icon.isMemberOfClass(QCluster){
                    coord = (icon as! QCluster).coordinate
                }else{
                    coord = (icon as! WeatherDataQTree).coordinate
                }
                var markers = weatherClusterTree.neighboursForLocation(coord, limitCount: 1)
                
                if markers != nil && markers.count > 0{
                    if icon.isMemberOfClass(QCluster){
                        iconCoord = (icon as! QCluster).coordinate
                    }else{
                        iconCoord = (icon as! WeatherDataQTree).coordinate
                    }
                    
                    let sameLat = (markers[0] as! QTreeInsertable).coordinate.latitude == icon.coordinate.latitude
                    let sameLong = (markers[0] as! QTreeInsertable).coordinate.longitude == icon.coordinate.longitude
                    if sameLat && sameLong {
                        // have the same icon
                    }else{
                        addIconToMap("", position: coord, iconInfo: icon)
                    }
                }else{
                    addIconToMap("", position: coord, iconInfo: icon)
                }
            }
        }
        
        changeIconWithTime()

        replaceCard()
    }
    
    //clean the map
    func clearIcons() {
        clear()
        weatherClusterTree = QTree()
        weatherCluster = [WeatherMarker]()
        weatherIcons = [String: WeatherMarker]()
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
                if iconInfo.isMemberOfClass(QCluster) {
                    //is cluster
                    let city = (WeatherInfo.quadTree.neighboursForLocation((iconInfo as! QCluster).coordinate, limitCount: 1)[0] as! WeatherDataQTree).cityID
                    iconStr = (((WeatherInfo.citiesAroundDict[city] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String
                    
                }else{
                    if WeatherInfo.citiesAroundDict[cityID] == nil{
                        iconStr = "empty"
                    }else{
                        iconStr = (((WeatherInfo.citiesAroundDict[cityID] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String
                    }
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
        
        if iconInfo.isMemberOfClass(WeatherDataQTree){
            weatherIcons.updateValue(marker, forKey: (iconInfo as! WeatherDataQTree).cityID)
        }else{
            weatherClusterTree.insertObject(marker)
            weatherCluster.append(marker)
        }
        
    }

    
    //if day == -1  display current time
    func changeIconWithTime(){
        
        if zoom > clusterZoom {
        
            for city in weatherIcons.keys.array {
                
                //set to low priority    performance issue
                //dispatch_after(DISPATCH_TIME_NOW, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) { () -> Void in
                if WeatherInfo.citiesAroundDict[city] != nil{
                    if !WeatherInfo.forcastMode {
                        let iconStr = (((WeatherInfo.citiesAroundDict[city] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String
                        weatherIcons[city]!.icon = IconImage.getImageWithNameAndSize(iconStr, size: self.iconSize)
                    }else{
                        //To Do !!!forcast mode
                    }
                }else{
                    weatherIcons[city]!.icon = IconImage.getImageWithNameAndSize("empty", size: self.iconSize)
                }
            
            }
        }else{
            
            /*
            
            change icon display
            
            for city in weatherCluster{
                
                //set to low priority    performance issue
                //dispatch_after(DISPATCH_TIME_NOW, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) { () -> Void in
                if WeatherInfo.forcastMode {
                    
                        var markers = weatherClusterTree.neighboursForLocation((city as QTreeInsertable).coordinate, limitCount: 1)
                        
                        let sameLat = (markers[0] as! QTreeInsertable).coordinate.latitude == city.coordinate.latitude
                        let sameLong = (markers[0] as! QTreeInsertable).coordinate.longitude == city.coordinate.longitude
                        
                        if markers != nil && markers.count > 0 && sameLat && sameLong {

                        }else{
                            
                        }
                    
                }else{
                    var i = parentController.clockButton.futureDay
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
            */
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
