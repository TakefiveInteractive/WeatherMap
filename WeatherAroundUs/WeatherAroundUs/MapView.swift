//
//  MapView.swift
//  PaperPlane
//
//  Created by Kedan Li on 15/3/1.
//  Copyright (c) 2015年 Yu Wang. All rights reserved.
//

import UIKit

class MapView: MAMapView, MAMapViewDelegate, LocationManagerDelegate, WeatherInformationDelegate{
    
    var parentController: ViewController!
    
    var mapKMRatio:Double = 0
    
    var currentLocation: CLLocation!
    
    // both contain the same data
    var weatherClusterTree = QTree()
    var weatherCluster = [WeatherMarker]()
    var weatherIcons = [String: WeatherMarker]()
    var lastLocation = CLLocation()
    
    var prevzoom: Double = 12
    
    let clusterZoom: Double = 11
    
    let searchTreeCount = 3
    
    var iconSize = IconSize.Large
    
    var shouldDisplayCard = true
    
    
    func setup() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if userDefaults.valueForKey("longitude") != nil{
            setCenterCoordinate(CLLocationCoordinate2DMake(userDefaults.valueForKey("latitude") as! Double, userDefaults.valueForKey("longitude") as! Double), animated: true)
        }
        //maxZoomLevel = 15
        //minZoomLevel = 8
        lastLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        setZoomLevel(prevzoom, animated: true)
        self.delegate = self
        self.showTraffic = false
        self.showsUserLocation = true
        UserLocation.delegate = self
        
        WeatherInfo.weatherDelegate = self
                
    }

    func gotCurrentLocation(location: CLLocation) {
        if currentLocation == nil{
            setCenterCoordinate(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), animated: true)
        }
        currentLocation = location
    }
    
    func mapView(mapView: MAMapView!, didSelectAnnotationView view: MAAnnotationView!) {
        if (view.annotation as! WeatherMarker).data.isMemberOfClass(QCluster) {
            //handle cluster
            let data = WeatherInfo.getTheNearestIcon((view.annotation as! WeatherMarker).coordinate)
            setCenterCoordinate(CLLocationCoordinate2DMake(data.coordinate.latitude, data.coordinate.longitude), animated: true)
            setZoomLevel(11.5, animated: true)
            WeatherInfo.currentCityID = data.cityID
            
        }else{
            if WeatherInfo.citiesAroundDict[((view.annotation as! WeatherMarker).data as! QTreeInsertable).cityID] != nil {
                WeatherInfo.currentCityID = ((view.annotation as! WeatherMarker).data as! QTreeInsertable).cityID
                parentController.card.displayCity(((view.annotation as! WeatherMarker).data as! QTreeInsertable).cityID)
                setCenterCoordinate(CLLocationCoordinate2DMake((view.annotation as! WeatherMarker).coordinate.latitude, (view.annotation as! WeatherMarker).coordinate.longitude), animated: true)
            }
        }
    }
    
    //whether the display function is currently running
    var displaying = false
    var displayTimeCount = 0

    func mapView(mapView: MAMapView!, regionDidChangeAnimated animated: Bool) {
        
        // delay 1 second
        /*
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
        Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
        
        }*/
        let thisLocation = CLLocation(latitude: centerCoordinate.longitude, longitude: centerCoordinate.latitude)
        
        if zoomLevel >= self.clusterZoom {
            parentController.searchBar.endLoading()
        }
        
        if !self.displaying || zoomLevel >= self.clusterZoom{
            self.displayIcon(centerCoordinate)
        }
        
        
        if displayTimeCount == 0{
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "displayCardOnIdle:", userInfo: nil, repeats: true)
        }else{
            displayTimeCount = 0
        }
        
        if prevzoom != zoomLevel{
            if (zoomLevel < clusterZoom && weatherIcons.count > 0) || (zoomLevel >= clusterZoom && weatherCluster.count > 0){
                clearIcons()
            }
            prevzoom = zoomLevel
        }
        
        let previousSize = iconSize
        
        if zoomLevel > 14{
            iconSize = .XLarge
        }else if zoomLevel > 13{
            iconSize = .Large
        }else if zoomLevel > 12{
            iconSize = .Mid
        }else if zoomLevel >= 11{
            iconSize = .Small
        }else{
            iconSize = .Reduced
        }
        
        if iconSize != previousSize{
            changeIconWithTime()
        }
        
    }

    
    
    func displayCardOnIdle(timer: NSTimer){
        
        if self.zoomLevel >= self.clusterZoom{
        
            if displayTimeCount < 3{
                displayTimeCount++
            }else{
                if parentController.card.hide{
                    shouldDisplayCard = true
                    replaceCard()
                }
                displayTimeCount = 0
                timer.invalidate()
            }
        }else{
            displayTimeCount = 0
            timer.invalidate()
        }
    }
    
    func mapView(mapView: MAMapView!, regionWillChangeAnimated animated: Bool) {
        // hide board
        
        parentController.searchBar.hideSelf()
        parentController.searchResultList.removeCities()
        if parentController.card.weatherDescriptionBack != nil{
            parentController.card.hideSelf()
        }
    }
    

    
    //display the icon on the map
    func displayIcon(center: CLLocationCoordinate2D) {
        
        displaying = true
        
        let distance = WeatherMapCalculations.getTheDistanceBased(region)
        
        var trees: AnyObject = WeatherInfo.mainTree.neighboursForLocation(center, limitCount: UInt(searchTreeCount))
        
        var deleteArr = WeatherInfo.currentSearchTreeDict
        
        for tree in trees as! [AnyObject]{
            //load trees if not loaded
            if WeatherInfo.currentSearchTreeDict[(tree as! WeatherDataQTree).cityID] == nil {
                if WeatherInfo.searchTreeDict[(tree as! WeatherDataQTree).cityID] == nil{
                    WeatherInfo.loadTree((tree as! WeatherDataQTree).cityID)
                }
                WeatherInfo.currentSearchTreeDict.updateValue(WeatherInfo.searchTreeDict[(tree as! WeatherDataQTree).cityID]!, forKey: (tree as! WeatherDataQTree).cityID)
                WeatherInfo.currentSearchTrees.updateValue(WeatherInfo.searchTrees[(tree as! WeatherDataQTree).cityID]!, forKey: (tree as! WeatherDataQTree).cityID)
            }else{
                deleteArr.removeValueForKey((tree as! WeatherDataQTree).cityID)
            }
        }
        
        for tree in deleteArr.keys{
            WeatherInfo.removeTree(tree)
        }
        
        if zoomLevel >= clusterZoom {
            //display all icon
            
            var iconToRemove = weatherIcons
            weatherIcons = [String: WeatherMarker]()
            
            var iconsData = WeatherInfo.getNearestIcons(center)
            
            WeatherInfo.searchWeather(iconsData as! [WeatherDataQTree])
            
            for icon in iconsData{
                
                let cityID = (icon as! WeatherDataQTree).cityID
                
                if iconToRemove[cityID] == nil{
                    //if the icon has valid weather data
                    if WeatherInfo.citiesAroundDict[cityID] != nil{
                        if weatherIcons[cityID] == nil{
                            addIconToMap(cityID, position: (icon as! WeatherDataQTree).coordinate, iconInfo: icon)
                        }
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
                removeAnnotation(iconToRemove[icon]!)
            }
            iconToRemove.removeAll(keepCapacity: false)
            
        }else{
            
            parentController.searchBar.startLoading()
            
            var reducedLocations = WeatherInfo.getObjectsInRegion(MKCoordinateRegion(center: region.center, span: MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta, longitudeDelta: region.span.longitudeDelta)))
            
            println(reducedLocations.count)
            
            reducedLocations = removeIconOutSideScreen(reducedLocations as [AnyObject])
            
            println(reducedLocations.count)

            
            var iconToRemove = weatherCluster
            weatherCluster = [WeatherMarker]()
            
            var iconsData = [QTreeInsertable]()
            
            for icon in reducedLocations {
                
                var temp: NSArray = NSArray()
                
                if icon.isMemberOfClass(QCluster){
                    temp = WeatherInfo.getTheFiveNearestIcons((icon as! QCluster).coordinate)!
                }
                
                if temp.count > 0{
                    
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
                    iconsData = iconsData + (temp as! [QTreeInsertable])
                    if iconsData.count > 60{
                        break
                    }
                }
                
            }
            
            WeatherInfo.searchWeatherIfLimitedRequest(iconsData as [QTreeInsertable])
            
            for icon in iconToRemove{
                removeAnnotation(icon)
                weatherClusterTree.removeObject(icon)
            }
            iconToRemove.removeAll(keepCapacity: false)
            
        }
        
        WeatherInfo.currentCityID = WeatherInfo.getTheNearestIcon(center).cityID
        
        changeIconWithTime()
        

        UIView.animateWithDuration(0.1, delay: 0.4, options: nil, animations: { () -> Void in
            
            }) { (done) -> Void in
                self.displaying = false
        }
    }
    
    func removeIconOutSideScreen(weatherData: [AnyObject])->[AnyObject]{
        
        var result = [AnyObject]()
        
        for weather in weatherData{
            
            let mapRegion = MKCoordinateRegion(center: region.center, span: MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta, longitudeDelta: region.span.longitudeDelta))
            
            if weather.isMemberOfClass(QCluster){
                if WeatherMapCalculations.checkIfPointInRegion(mapRegion, location: (weather as! QCluster).coordinate) {
                    result.append(weather)
                }
            }else{
                if WeatherMapCalculations.checkIfPointInRegion(mapRegion, location: (weather as! QTreeInsertable).coordinate) {
                    result.append(weather)
                }

            }
        }
        return result
    }
    

    
    //clean the map
    func clearIcons() {
            removeAnnotations(annotations)
            weatherClusterTree = QTree()
            weatherCluster = [WeatherMarker]()
            weatherIcons = [String: WeatherMarker]()
    }
    
    //display card if needed
    func replaceCard(){
        if shouldDisplayCard {
            if weatherClusterTree.count > 0 || weatherIcons.count > 0{
                //diplay the card of the first city getted
                if (WeatherInfo.currentCityID != "" && WeatherInfo.citiesAroundDict[WeatherInfo.currentCityID] != nil && !WeatherInfo.forcastMode) || (WeatherInfo.citiesForcast[WeatherInfo.currentCityID] != nil && WeatherInfo.forcastMode) {
                    shouldDisplayCard = false
                    parentController.card.displayCity(WeatherInfo.currentCityID)
                }
            }
        }
    }
    
    //cityID = empty if should display fake
    //cityID = ""   if is cluster
    func addIconToMap(cityID: String, position: CLLocationCoordinate2D, iconInfo: AnyObject){
        
        var marker = WeatherMarker(position: position, cityID: cityID, info: iconInfo)

        marker.cityID = cityID
        addAnnotation(marker)
        
        if zoomLevel >= clusterZoom {
            weatherIcons.updateValue(marker, forKey: (iconInfo as! QTreeInsertable).cityID)
        }else{
            weatherClusterTree.insertObject(marker)
            weatherCluster.append(marker)
        }
        
    }
    
    func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation.isMemberOfClass(MAPointAnnotation) {
            
            var iconStr = ""
            
            var marker = (annotation as! WeatherMarker)
            
            if marker.cityID != "empty"{
                
                if marker.data.isMemberOfClass(QCluster) {
                    //is cluster
                    iconStr = getMaxWeatherInCluster(marker.data as! QCluster)
                }else{
                    if WeatherInfo.citiesAroundDict[marker.cityID] == nil{
                        iconStr = "empty"
                    }else{
                        if !WeatherInfo.forcastMode {
                            iconStr = (((WeatherInfo.citiesAroundDict[marker.cityID] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String
                        }else{
                            if WeatherInfo.citiesForcast[marker.cityID] == nil{
                                iconStr = "empty"
                                //no forcast data
                            }else{
                                iconStr = (((WeatherInfo.citiesForcast[marker.cityID]![self.parentController.clockButton.futureDay] as! [String: AnyObject])["weather"] as! [AnyObject])[0] as! [String: AnyObject])["icon"] as! String
                            }
                        }
                    }
                }
                
            }else{
                iconStr = "empty"
            }
            
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(iconStr)
            if (annotationView == nil)
            {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: iconStr)
            }
            annotationView.image = IconImage.getImageWithNameAndSize(iconStr, size: iconSize)

            annotationView.canShowCallout = false     //设置气泡可以弹出，默认为NO
            annotationView.draggable = false;        //设置标注可以拖动，默认为NO
            
            return annotationView;
        }
        return nil
    }
    
    func mapView(mapView: MAMapView!, didAddAnnotationViews views: [AnyObject]!) {
        for annotation in views{
            (annotation as! UIView).transform = CGAffineTransformMakeScale(0.1, 0.1)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                (annotation as! UIView).transform = CGAffineTransformMakeScale(1, 1)
            })
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
            displayIcon(centerCoordinate)
            return
        }
        
        if WeatherInfo.ongoingRequest < WeatherInfo.maxRequestNum{
            parentController.searchBar.endLoading()
        }
        
        if !changeIcon || zoomLevel >= clusterZoom {
            changeIconWithTime()
        }
    }
    
    //if day == -1  display current time

    func changeIconWithTime(){
        
        changeIcon = true
        
        if zoomLevel >= clusterZoom {
            
            replaceCard()
            
            for cityID in weatherIcons.keys.array {
                
                //set to low priority    performance issue
                //dispatch_after(DISPATCH_TIME_NOW, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) { () -> Void in
                if !WeatherInfo.forcastMode {
                    if WeatherInfo.citiesAroundDict[cityID] != nil && weatherIcons[cityID] != nil && viewForAnnotation(weatherIcons[cityID]!) != nil{
                        let iconStr = (((WeatherInfo.citiesAroundDict[cityID] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String
                        viewForAnnotation(weatherIcons[cityID]!).image = IconImage.getImageWithNameAndSize(iconStr, size: self.iconSize)
                    }
                }else{
                    if WeatherInfo.citiesForcast[cityID] != nil && weatherIcons[cityID] != nil{
                        let iconStr = (((WeatherInfo.citiesForcast[cityID]![self.parentController.clockButton.futureDay] as! [String: AnyObject])["weather"] as! [AnyObject])[0] as! [String: AnyObject])["icon"] as! String
                        viewForAnnotation(weatherIcons[cityID]!).image = IconImage.getImageWithNameAndSize(iconStr, size: self.iconSize)
                    }
                }
            }
            
        }else{
            //change icon display
            for marker in weatherCluster{
                //set to low priority    performance issue
                
                    if marker.data.isMemberOfClass(QCluster){
                        let iconStr = getMaxWeatherInCluster(marker.data as! QCluster)
                        viewForAnnotation(marker).image = IconImage.getImageWithNameAndSize(iconStr, size: self.iconSize)
                    }

            }
            
        }
        self.changeIcon = false
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

class WeatherMarker: MAPointAnnotation, QTreeInsertable{
    
    var cityID: String!
    var data: AnyObject!
    
    init(position: CLLocationCoordinate2D, cityID: String, info: AnyObject) {
        super.init()
        coordinate = position
        data = info
        self.cityID = cityID
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
