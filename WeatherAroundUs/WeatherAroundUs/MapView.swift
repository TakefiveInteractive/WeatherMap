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
        self.setMinZoom(7.5, maxZoom: 15)

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
            let data = WeatherInfo.getTheNearestIcon((marker as! WeatherMarker).position)
            self.animateToCameraPosition(GMSCameraPosition(target: data.coordinate, zoom: 11.5, bearing: self.camera.bearing, viewingAngle: self.camera.viewingAngle))
            WeatherInfo.currentCityID = data.cityID
            parentController.card.displayCity(data.cityID)
            
        }else{
            if WeatherInfo.citiesAroundDict[((marker as! WeatherMarker).data as! QTreeInsertable).cityID] != nil {
                WeatherInfo.currentCityID = ((marker as! WeatherMarker).data as! QTreeInsertable).cityID
                parentController.card.displayCity(((marker as! WeatherMarker).data as! QTreeInsertable).cityID)
                self.animateToLocation(marker.position)
            }
        }
        
        return true

    }
    
    //whether the display function is currently running
    var displaying = false
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {

        let thisLocation = CLLocation(latitude: self.camera.target.longitude, longitude: self.camera.target.latitude)
       
        if !displaying{
            displayIcon()
        }

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
            if (camera.zoom < clusterZoom && weatherIcons.count > 0) || (camera.zoom >= clusterZoom && weatherCluster.count > 0){
                clearIcons()
            }
            zoom = camera.zoom
        }
        
        let previousSize = iconSize
        
        if camera.zoom > 14{
            iconSize = .XLarge
        }else if camera.zoom > 13{
            iconSize = .Large
        }else if camera.zoom > 12{
            iconSize = .Mid
        }else if camera.zoom >= 11{
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
        
        displaying = true
        
        let distance = WeatherMapCalculations.getTheDistanceBased(self.projection.visibleRegion())
        
        var trees: AnyObject = WeatherInfo.mainTree.neighboursForLocation(camera.target, limitCount: 4)
        
        var deleteArr = WeatherInfo.currentSearchTreeDict
        
        for tree in trees as! [AnyObject]{
            //load trees if not loaded
            if WeatherInfo.currentSearchTreeDict[(tree as! WeatherDataQTree).cityID] == nil {
                WeatherInfo.loadTree((tree as! WeatherDataQTree).cityID)
            }else{
                deleteArr.removeValueForKey((tree as! WeatherDataQTree).cityID)
            }
        }
        
        for tree in deleteArr.keys{
            WeatherInfo.removeTree(tree)
        }
        
        if camera.zoom >= clusterZoom {
            //display all icon
            
            var iconToRemove = weatherIcons
            weatherIcons = [String: WeatherMarker]()
            
            var iconsData = WeatherInfo.getNearestIcons(camera.target)
            
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
            var reducedLocations = WeatherInfo.getObjectsInRegion(mapRegion)
            reducedLocations = removeIconOutSideScreen(reducedLocations as [AnyObject])
            
            var iconToRemove = weatherCluster
            weatherCluster = [WeatherMarker]()
            
            for icon in reducedLocations {
                
                var iconsData = WeatherInfo.getTheFiveNearestIcons(icon.coordinate)
                
                if iconsData != nil{
                    WeatherInfo.getLocalWeatherInformation(iconsData as! [QTreeInsertable])
                    
                    var coord = CLLocation()
                    var iconCoord = CLLocation()
                    
                    if icon.isMemberOfClass(QCluster){
                        coord = CLLocation(latitude: (icon as! QCluster).coordinate.latitude, longitude: (icon as! QCluster).coordinate.longitude)
                    }else{
                        coord = CLLocation(latitude: (icon as! QTreeInsertable).coordinate.latitude, longitude: (icon as! QTreeInsertable).coordinate.longitude)
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
                
            }
            
            for icon in iconToRemove{
                icon.map = nil
                weatherClusterTree.removeObject(icon)
            }
            iconToRemove.removeAll(keepCapacity: false)
            
        }
        
        changeIconWithTime()

        replaceCard()
        
        displaying = false
    }
    
    func removeIconOutSideScreen(weatherData: [AnyObject])->[AnyObject]{
        
        var result = [AnyObject]()
        
        for weather in weatherData{
            if weather.isMemberOfClass(QCluster){
                if self.projection.containsCoordinate((weather as! QCluster).coordinate) {
                    result.append(weather)
                }
            }else{
                if self.projection.containsCoordinate((weather as! QTreeInsertable).coordinate) {
                    result.append(weather)
                }
            }
        }
        return result
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
            if weatherClusterTree.count > 0 || weatherIcons.count > 0{
                shouldDisplayCard = false
                //diplay the card of the first city getted
                WeatherInfo.currentCityID = WeatherInfo.getTheNearestIcon(camera.target).cityID
                if (WeatherInfo.citiesAroundDict[WeatherInfo.currentCityID] != nil && !WeatherInfo.forcastMode) || (WeatherInfo.citiesForcast[WeatherInfo.currentCityID] != nil && WeatherInfo.forcastMode){
                    parentController.card.displayCity(WeatherInfo.currentCityID)
                }
            }
        }
    }
    
    //cityID = empty if should display fake
    //cityID = ""   if is cluster
    func addIconToMap(cityID: String, position: CLLocationCoordinate2D, iconInfo: AnyObject){
        
        var marker = WeatherMarker(position: position, cityID: cityID, info: iconInfo)
        var iconStr = ""
        
        if cityID != "empty"{
            
            if iconInfo.isMemberOfClass(QCluster) {
                //is cluster
                iconStr = getMaxWeatherInCluster(iconInfo as! QCluster)
            }else{
                if WeatherInfo.citiesAroundDict[cityID] == nil{
                    iconStr = "empty"
                }else{
                    if !WeatherInfo.forcastMode {
                        iconStr = (((WeatherInfo.citiesAroundDict[cityID] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String
                    }else{
                        if WeatherInfo.citiesForcast[cityID] == nil{
                            iconStr = "empty"
                            //no forcast data
                        }else{
                        iconStr = (((WeatherInfo.citiesForcast[cityID]![self.parentController.clockButton.futureDay] as! [String: AnyObject])["weather"] as! [AnyObject])[0] as! [String: AnyObject])["icon"] as! String
                        }
                    }
                }
            }
            
        }else{
            iconStr = "empty"
        }
        
        marker.icon = IconImage.getImageWithNameAndSize(iconStr, size: iconSize)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = self
        marker.title = cityID
        
        if camera.zoom >= clusterZoom {
            weatherIcons.updateValue(marker, forKey: (iconInfo as! QTreeInsertable).cityID)
        }else{
            weatherClusterTree.insertObject(marker)
            weatherCluster.append(marker)
        }
        
    }
    
    func getMaxWeatherInCluster(iconInfo: QCluster) ->String{
        
        var iconStr = "empty"
        
        var cities: [AnyObject]!
        if iconInfo.objectsCount > 5{
            cities = WeatherInfo.getTheFiveNearestIcons(iconInfo.coordinate) as! [AnyObject]
        }else{
            cities = WeatherInfo.getTheTwoNearestIcons(iconInfo.coordinate) as! [AnyObject]
        }
        
        var iconArray = [String:Int]()
        
        for city in cities {
            let cityID = (city as! QTreeInsertable).cityID
            if !WeatherInfo.forcastMode && WeatherInfo.citiesAroundDict[cityID] != nil{
                iconStr = (((WeatherInfo.citiesAroundDict[cityID] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String
                if iconArray[iconStr] == nil {
                    iconArray.updateValue(1, forKey: iconStr)
                }else{
                    iconArray.updateValue((iconArray[iconStr]! + 1), forKey: iconStr)
                }
            }else if WeatherInfo.forcastMode{
            
                if WeatherInfo.citiesForcast[cityID] != nil{
                    iconStr = (((WeatherInfo.citiesForcast[cityID]![self.parentController.clockButton.futureDay] as! [String: AnyObject])["weather"] as! [AnyObject])[0] as! [String: AnyObject])["icon"] as! String
                    if iconArray[iconStr] == nil {
                        iconArray.updateValue(1, forKey: iconStr)
                    }else{
                        iconArray.updateValue((iconArray[iconStr]! + 1), forKey: iconStr)
                    }
                }else{
                    //no forcast data
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

    //let changeIconRate = 25
    var changeIcon = false
    
    func gotWeatherInformation() {
        //display if first open
        if weatherCluster.count == 0 && weatherIcons.count == 0{
            displayIcon()
            return
        }
        
        if !changeIcon {
            changeIconWithTime()
        }
    }
    
    //if day == -1  display current time

    func changeIconWithTime(){
        
        changeIcon = true
        
        if zoom >= clusterZoom {
            
            for cityID in weatherIcons.keys.array {
                
                //set to low priority    performance issue
                //dispatch_after(DISPATCH_TIME_NOW, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) { () -> Void in
                if !WeatherInfo.forcastMode {
                    if WeatherInfo.citiesAroundDict[cityID] != nil{
                        let iconStr = (((WeatherInfo.citiesAroundDict[cityID] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String
                        weatherIcons[cityID]!.icon = IconImage.getImageWithNameAndSize(iconStr, size: self.iconSize)
                    }else{
                        weatherIcons[cityID]!.icon = IconImage.getImageWithNameAndSize("empty", size: self.iconSize)
                    }
                }else{
                    if WeatherInfo.citiesForcast[cityID] != nil{
                        let iconStr = (((WeatherInfo.citiesForcast[cityID]![self.parentController.clockButton.futureDay] as! [String: AnyObject])["weather"] as! [AnyObject])[0] as! [String: AnyObject])["icon"] as! String
                        weatherIcons[cityID]!.icon = IconImage.getImageWithNameAndSize(iconStr, size: self.iconSize)
                    }else{
                        weatherIcons[cityID]!.icon = IconImage.getImageWithNameAndSize("empty", size: self.iconSize)
                    }
                }
            }
            
        }else{
            //change icon display
            for marker in weatherCluster{
                //set to low priority    performance issue
                
                    if marker.data.isMemberOfClass(QCluster){
                        let iconStr = getMaxWeatherInCluster(marker.data as! QCluster)
                        marker.icon = IconImage.getImageWithNameAndSize(iconStr, size: self.iconSize)
                    }

            }
            
        }
        
        changeIcon = false
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
