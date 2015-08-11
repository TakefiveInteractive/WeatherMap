//
//  LocationManager.swift
//  PaperPlane
//
//  Created by Kedan Li on 15/3/4.
//  Copyright (c) 2015年 Yu Wang. All rights reserved.
//

import UIKit

@objc protocol LocationManagerDelegate: NSObjectProtocol{
     optional func gotCurrentLocation(location: CLLocation)
}

var UserLocation: LocationManager = LocationManager()

class LocationManager: NSObject, CLLocationManagerDelegate, AMapSearchDelegate{
    
    var delegate:LocationManagerDelegate?
    
    var centerLocation:CLLocation!
    
    var inChina = false
    
    var locationM:CLLocationManager = CLLocationManager()

    var search: AMapSearchAPI?

    func setup(){
        // start updating location
        search = AMapSearchAPI(searchKey: APIKey, delegate: self)
        self.locationM.delegate = self
        self.locationM.desiredAccuracy = kCLLocationAccuracyBest
        self.locationM.requestAlwaysAuthorization()
        self.locationM.startUpdatingLocation()
        
    }
    
    //called when location update
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        if centerLocation == nil{
            //check if in China
            var regeoRequest = AMapReGeocodeSearchRequest()
            let coord = (locations[locations.count - 1] as! CLLocation).coordinate
            regeoRequest.location = AMapGeoPoint.locationWithLatitude(CGFloat(coord.latitude), longitude: CGFloat(coord.longitude))
            search!.AMapReGoecodeSearch(regeoRequest)
        }
        
        centerLocation = locations[locations.count - 1] as! CLLocation        
        self.delegate?.gotCurrentLocation!(centerLocation)
        
    }
    
    func onReGeocodeSearchDone(request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {

        if response.regeocode.addressComponent.district == "" && response.regeocode.addressComponent.city == "" {
            inChina = false
        }else{
            inChina = true
        }
    }
    
}
