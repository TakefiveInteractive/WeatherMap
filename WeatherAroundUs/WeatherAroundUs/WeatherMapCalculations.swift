//
//  MapCalculations.swift
//  PaperPlane
//
//  Created by Kedan Li on 15/3/4.
//  Copyright (c) 2015年 Yu Wang. All rights reserved.
//

import UIKit

class WeatherMapCalculations: NSObject {
    
    // get the distance of one CM based on Zoom returned by KM
    class func getTheDistanceBasedOnZoom(zoom: Float)->Double{
        var result: Double = 0
        var base = 21 - zoom
        result = Double(pow(2, base)) * 0.00294668257
        return result
    }
    
    // correctly display the distance with text
    class func displayKMWithLabel(kilometer: Double)->String{
        
        if kilometer >= 1{
            var km = Int(kilometer)
            if km > 100 && km <= 1000 {
                km = km / 10
                km = km * 10
            }else if km > 1000 && km <= 10000 {
                km = km / 10
                km = km * 10
            }
            
            return "\(km) km"
            
        }else{
            var m = Int(kilometer * 1000)
            if m > 100 {
                m = m / 10
                m = m * 10
            }
            
            return "\(m) m"
            
        }

    }
    
    // get the weather around according to map center and zoom
    class func getWeatherAround(mapCenter:CLLocationCoordinate2D, zoom: Float)->[CLLocationCoordinate2D]{
        let distance = WeatherMapCalculations.getTheDistanceBasedOnZoom(zoom)
        var locationArray = [CLLocationCoordinate2D]()
        //scan upper screen
        
        for var y:Double = 0; y < 3; y += 1 {
            //scan west
            for var x:Double = 0; x < 3; x += 1 {
                locationArray.append(WeatherMapCalculations.getDestinationPointWithDistanceAndLongitudeAndLatitude(mapCenter, distanceX: distance * Double(x), distanceY: distance * Double(y)))
                locationArray.append(WeatherMapCalculations.getDestinationPointWithDistanceAndLongitudeAndLatitude(mapCenter, distanceX: distance * Double(-x), distanceY: distance * Double(y)))
                locationArray.append(WeatherMapCalculations.getDestinationPointWithDistanceAndLongitudeAndLatitude(mapCenter, distanceX: distance * Double(x), distanceY: distance * Double(-y)))
                locationArray.append(WeatherMapCalculations.getDestinationPointWithDistanceAndLongitudeAndLatitude(mapCenter, distanceX: distance * Double(-x), distanceY: distance * Double(-y)))
            }
        }
       
        return locationArray
    }
    
    class func getDestinationPointWithDistanceAndLongitudeAndLatitude(centerLocation:CLLocationCoordinate2D, distanceX: Double, distanceY: Double)->CLLocationCoordinate2D{
        let constant = 0.1
        
        var locationYdegree = centerLocation.latitude
        if locationYdegree > 0{
            locationYdegree = locationYdegree - constant
        }else{
            locationYdegree = locationYdegree + constant
        }

        var locationXdegree = centerLocation.longitude
        if locationXdegree > 0{
            locationXdegree = locationXdegree - constant
        }else{
            locationXdegree = locationXdegree + constant
        }
        
        let currlocation = CLLocation(latitude: centerLocation.latitude, longitude: centerLocation.longitude)
        
        let xRatio = currlocation.distanceFromLocation(CLLocation(latitude: centerLocation.latitude, longitude: locationXdegree)) / 1000
        let yRatio = currlocation.distanceFromLocation(CLLocation(latitude: locationYdegree, longitude: centerLocation.longitude)) / 1000

        let x = distanceX * constant / xRatio + centerLocation.longitude
        let y = distanceY * constant / yRatio + centerLocation.latitude
        return CLLocationCoordinate2D(latitude: y, longitude: x)
        
    }
    
    
    // get the destination point according to distance and direction
    class func getDestinationPointWithDistanceAndBearing(distance: Double, bearing: CLLocationDirection)->CLLocationCoordinate2D{
        
        let constant = 0.1
        
        var locationXdegree = UserLocation.centerLocation.coordinate.longitude
        if locationXdegree > 0{
            locationXdegree = locationXdegree - constant
        }else{
            locationXdegree = locationXdegree + constant
        }
        
        var locationYdegree = UserLocation.centerLocation.coordinate.latitude
        if locationYdegree > 0{
            locationYdegree = locationYdegree - constant
        }else{
            locationYdegree = locationYdegree + constant
        }
        
        let yRatio = UserLocation.centerLocation.distanceFromLocation(CLLocation(latitude: locationYdegree, longitude: UserLocation.centerLocation.coordinate.longitude)) / 1000
        let xRatio = UserLocation.centerLocation.distanceFromLocation(CLLocation(latitude: UserLocation.centerLocation.coordinate.latitude, longitude: locationXdegree)) / 1000
        
        // positive east, negative west
        let xAcceleration = sin(bearing * M_PI / 180) * distance
        //positive north,  negative south
        let yAcceleration = cos(bearing * M_PI / 180) * distance
        
        //distance travel in xy coordinates
        let x = xAcceleration * constant / xRatio
        let y = yAcceleration * constant / yRatio

        let arrivingYCoordinate = UserLocation.centerLocation.coordinate.latitude + y
        let arrivingXCoordinate = UserLocation.centerLocation.coordinate.longitude + x
        
        return CLLocationCoordinate2D(latitude: arrivingYCoordinate, longitude: arrivingXCoordinate)

    }
    

}
