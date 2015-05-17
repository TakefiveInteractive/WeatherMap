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
    var lastLocation = CLLocation()
    
    var zoom: Float = 12
    
    let clusterZoom: Float = 11
    
    var iconSize = IconSize.Large
    
    var shouldDisplayCard = true
    
    func setup() {
        let userDefaults = NSUserDefaults.standardUserDefaults()

        if userDefaults.valueForKey("longitude") != nil{
            var camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(userDefaults.valueForKey("latitude") as! Double, longitude: userDefaults.valueForKey("longitude") as! Double, zoom: zoom)
            self.camera = camera
        }
        self.setMinZoom(6, maxZoom: 15)

        lastLocation = CLLocation(latitude: camera.target.latitude, longitude: camera.target.longitude)

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
            let data = WeatherInfo.currentSearchTree.neighboursForLocation(marker.position, limitCount: 1)[0] as! WeatherDataQTree
            self.animateToCameraPosition(GMSCameraPosition(target: data.coordinate, zoom: 11.5, bearing: self.camera.bearing, viewingAngle: self.camera.viewingAngle))
            WeatherInfo.currentCityID = data.cityID
            parentController.card.displayCity(data.cityID)
            
        }else{
            if WeatherInfo.citiesAroundDict[((marker as! WeatherMarker).data as! WeatherDataQTree).cityID] != nil {
                WeatherInfo.currentCityID = ((marker as! WeatherMarker).data as! WeatherDataQTree).cityID
                parentController.card.displayCity(((marker as! WeatherMarker).data as! WeatherDataQTree).cityID)
                self.animateToLocation(marker.position)
            }
        }
        return true

    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        
        // change the size of the icon according to zoom
        //let distance = WeatherMapCalculations.getTheDistanceBased(self.projection.visibleRegion())

        let thisLocation = CLLocation(latitude: self.camera.target.longitude, longitude: self.camera.target.latitude)
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
        
        if zoom != camera.zoom{
            clearIcons()
            zoom = camera.zoom
        }
        
        let previousSize = iconSize
        
        if camera.zoom > 14{
            iconSize = .XLarge
        }else if camera.zoom > 13{
            iconSize = .Large
        }else if camera.zoom > 12{
            iconSize = .Mid
        }else if camera.zoom > 11{
            iconSize = .Small
        }else{
            iconSize = .Reduced
        }

        if iconSize != previousSize{
            changeIconWithTime()
        }

    }
    
    //display the icon on the map
    func displayIcon() {
        
        let distance = WeatherMapCalculations.getTheDistanceBased(self.projection.visibleRegion())
        
        let tree = WeatherInfo.level1Tree.neighboursForLocation(camera.target, limitCount: 1)[0] as! SecondLevelQTree
        WeatherInfo.currentSearchTree = tree
        
        if camera.zoom > clusterZoom {
            //display all icon
            var iconToRemove = weatherIcons
            weatherIcons = [String: WeatherMarker]()
            
            let iconsData = tree.neighboursForLocation(camera.target, limitCount: 30)
            
            WeatherInfo.getLocalWeatherInformation(iconsData as! [WeatherDataQTree])
            
            for icon in iconsData{
                
                let cityID = (icon as! WeatherDataQTree).cityID
                
                if iconToRemove[cityID] == nil{
                    //if the icon has valid weather data
                    if WeatherInfo.citiesAroundDict[cityID] != nil{
                        addIconToMap(cityID, position: (icon as! WeatherDataQTree).coordinate, iconInfo: icon)
                    }else{
                        addIconToMap("empty", position: (icon as! WeatherDataQTree).coordinate, iconInfo: icon)
                    }
                }else{
                    // exist already
                    weatherIcons.updateValue(iconToRemove[cityID]!, forKey: cityID)
                    iconToRemove.removeValueForKey(cityID)
                }
            }
            
            for icon in iconToRemove.keys.array {
                iconToRemove[icon]!.map = nil
            }
            iconToRemove.removeAll(keepCapacity: false)
            
        }else{
        
            var mapRegion = WeatherMapCalculations.convertRegion(camera.target, distance: distance)
            var reducedLocations = tree.getObjectsInRegion(mapRegion, minNonClusteredSpan: min(mapRegion.span.latitudeDelta, mapRegion.span.longitudeDelta) / 6)
            reducedLocations = removeIconOutSideScreen(reducedLocations)
            
            var iconToRemove = weatherCluster
            weatherCluster = [WeatherMarker]()
            
            println(reducedLocations.count)
            
            for icon in reducedLocations {
                
                let iconsData = tree.neighboursForLocation(icon.coordinate, limitCount: 10)
                WeatherInfo.getLocalWeatherInformation(iconsData as! [WeatherDataQTree])
                
                var coord = CLLocation()
                var iconCoord = CLLocation()
                
                if icon.isMemberOfClass(QCluster){
                    coord = CLLocation(latitude: (icon as! QCluster).coordinate.latitude, longitude: (icon as! QCluster).coordinate.longitude)
                }else{
                    coord = CLLocation(latitude: (icon as! WeatherDataQTree).coordinate.latitude, longitude: (icon as! WeatherDataQTree).coordinate.longitude)
                }
                var markers = weatherClusterTree.neighboursForLocation(coord.coordinate, limitCount: 1)
                
                if markers != nil && markers.count > 0{
                    iconCoord = CLLocation(latitude: (markers[0] as! WeatherMarker).coordinate.latitude, longitude: (markers[0] as! WeatherMarker).coordinate.longitude)

                    if coord.distanceFromLocation(iconCoord) < distance / 20 && find(iconToRemove, markers[0] as! WeatherMarker) != nil{
                        // have the same icon
                        weatherCluster.append(markers[0] as! WeatherMarker)
                        (markers[0] as! WeatherMarker).data = icon
                        iconToRemove.removeAtIndex(find(iconToRemove, markers[0] as! WeatherMarker)!)
                    }else{
                        addIconToMap("", position: coord.coordinate, iconInfo: icon)
                    }
                }else{
                    addIconToMap("", position: coord.coordinate, iconInfo: icon)
                }
                
            }
            
            for icon in iconToRemove{
                icon.map = nil
                weatherClusterTree.removeObject(icon)
            }
            iconToRemove.removeAll(keepCapacity: false)
            
        }
        
        changeIconWithTime()

        replaceCard()
    }
    
    func removeIconOutSideScreen(weatherData: [AnyObject])->[AnyObject]{
        
        var result = [AnyObject]()
        
        for weather in weatherData{
            if weather.isMemberOfClass(QCluster){
                if self.projection.containsCoordinate((weather as! QCluster).coordinate) {
                    result.append(weather)
                }
            }else{
                if self.projection.containsCoordinate((weather as! WeatherDataQTree).coordinate) {
                    result.append(weather)
                }
            }
        }
        return result
    }
    
    func getMaxWeatherInCluster(iconInfo: QCluster) ->String{
        
        let tree = WeatherInfo.currentSearchTree
        
        var iconStr = "empty"
        
        var cities: [AnyObject]!
        if iconInfo.objectsCount > 5{
            cities = tree.neighboursForLocation(iconInfo.coordinate, limitCount: 5)
        }else{
            cities = tree.neighboursForLocation(iconInfo.coordinate, limitCount: UInt(iconInfo.objectsCount))
        }
        
        var iconArray = [String:Int]()
    
        for city in cities {
            let id = (city as! WeatherDataQTree).cityID
            if WeatherInfo.citiesAroundDict[id] != nil{
                iconStr = (((WeatherInfo.citiesAroundDict[id] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String
                if iconArray[iconStr] == nil {
                    iconArray.updateValue(1, forKey: iconStr)
                }else{
                    iconArray.updateValue((iconArray[iconStr]! + 1), forKey: iconStr)
                }
            }
        }
        
        
        var max = 0
        for key in iconArray.keys.array{
            if iconArray[key] > max{
                max = iconArray[key]!
                iconStr = key
            }
        }
        
        return iconStr
    }

    
    //clean the map
    func clearIcons() {
        if (camera.zoom <= clusterZoom && weatherIcons.count > 0) || (camera.zoom > clusterZoom && weatherCluster.count > 0) {
            clear()
            weatherClusterTree = QTree()
            weatherCluster = [WeatherMarker]()
            weatherIcons = [String: WeatherMarker]()
        }
    }
    
    //display card if needed
    func replaceCard(){
        if shouldDisplayCard {
            if WeatherInfo.currentSearchTree.count > 0{
                shouldDisplayCard = false
                //diplay the card of the first city getted
                WeatherInfo.currentCityID = (WeatherInfo.currentSearchTree.neighboursForLocation(camera.target, limitCount: 1)[0] as! WeatherDataQTree).cityID
                parentController.card.displayCity(WeatherInfo.currentCityID)
            }
        }
    }
    
    //cityID = empty if should display fake
    //cityID = ""   if is cluster
    func addIconToMap(cityID: String, position: CLLocationCoordinate2D, iconInfo: AnyObject){
        
        let tree = WeatherInfo.currentSearchTree
        println("addicon")
        
        var marker = WeatherMarker(position: position, cityID: cityID, info: iconInfo)
        var iconStr = ""
        
        if !WeatherInfo.forcastMode {
            if iconInfo.isMemberOfClass(QCluster) {
                //is cluster
                iconStr = getMaxWeatherInCluster(iconInfo as! QCluster)
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
        
        if camera.zoom > clusterZoom {
            weatherIcons.updateValue(marker, forKey: (iconInfo as! WeatherDataQTree).cityID)
        }else{
            weatherClusterTree.insertObject(marker)
            weatherCluster.append(marker)
        }
    }

    func gotWeatherInformation() {
        //display if first open
        if weatherCluster.count == 0 && weatherIcons.count == 0{
            displayIcon()
            return
        }
        changeIconWithTime()
    }
    
    //if day == -1  display current time

    func changeIconWithTime(){
        let tree = WeatherInfo.currentSearchTree
        
        if zoom > clusterZoom {
            
            for marker in weatherIcons.keys.array {
                
                //set to low priority    performance issue
                //dispatch_after(DISPATCH_TIME_NOW, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) { () -> Void in
                if WeatherInfo.citiesAroundDict[marker] != nil{
                    if !WeatherInfo.forcastMode {
                        let iconStr = (((WeatherInfo.citiesAroundDict[marker] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String
                        weatherIcons[marker]!.icon = IconImage.getImageWithNameAndSize(iconStr, size: self.iconSize)
                    }else{
                        //To Do !!!forcast mode
                    }
                }else{
                    weatherIcons[marker]!.icon = IconImage.getImageWithNameAndSize("empty", size: self.iconSize)
                }
            }
            
        }else{
            //change icon display
            
            for marker in weatherCluster{
                
                //set to low priority    performance issue
                //dispatch_after(DISPATCH_TIME_NOW, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) { () -> Void in
                if !WeatherInfo.forcastMode {
                    
                    if marker.data.isMemberOfClass(QCluster){
                        let iconStr = getMaxWeatherInCluster(marker.data as! QCluster)
                        marker.icon = IconImage.getImageWithNameAndSize(iconStr, size: self.iconSize)
                    }else{
                        let id = (marker.data as! WeatherDataQTree).cityID
                        let iconStr = "empty"
                        if WeatherInfo.citiesAroundDict[id] != nil{
                            (((WeatherInfo.citiesAroundDict[id] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String
                        }
                        marker.icon = IconImage.getImageWithNameAndSize(iconStr, size: self.iconSize)
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
    var cityID: String!
    var data: AnyObject!
    
    init(position: CLLocationCoordinate2D, cityID: String, info: AnyObject) {
        coordinate = position
        super.init()
        self.position = position
        data = info
        self.cityID = cityID
    }
    
}
