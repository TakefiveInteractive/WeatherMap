//
//  InternetSearch.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/11.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

@objc protocol InternetConnectionDelegate: class {
    optional func gotCityNameAutoComplete(cities: [AnyObject])
    optional func gotImageUrls(btUrl: String, imageURL: String, cityID: String)
    optional func gotLocalCityWeather(cities: [AnyObject])
    optional func gotLocationWithPlaceID(location: CLLocationCoordinate2D)
    optional func gotWeatherForcastData(cityID: String, forcast:[AnyObject])
    optional func gotThreeHourForcastData(cityID: String, forcast:[AnyObject])
}

//var connectionCount: Int = 0

class InternetConnection: NSObject {
    
    let apiKey = "ee87492c2987b4f04895330984934350"

    var delegate : InternetConnectionDelegate?
    
    var passData: [String: AnyObject]!
    
    // search city name using google framework
    func searchCityName(content:String){
        
        // avoid crash when there is space
        //handle case when there is chinese
        var searchContent = content.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(searchContent)&types=(cities)&language=en&key=AIzaSyDHwdGU463x3_aJfg4TNWm0fijTjr9VEdg")
        
        var req = Alamofire.request(.GET, url!).responseJSON { (_, response, JSON, error) in
            
            if error == nil && JSON != nil {
                let myjson = SwiftyJSON.JSON(JSON!)
                var predictions = myjson["predictions"].arrayObject
                if predictions != nil{
                    self.delegate?.gotCityNameAutoComplete!(predictions!)
                }
            }else{
                //resend
                self.searchCityName(content)
            }
            
        }
        
    }
    
    //search for local weather data
    func getLocalWeather(info: [QTreeInsertable]){
        
        var searchIDs = ""
        for city in info{
            searchIDs = searchIDs + "," + city.cityID
        }
        searchIDs = (searchIDs as NSString).substringFromIndex(1)
        
        var req = Alamofire.request(.GET, NSURL(string: "http://api.openweathermap.org/data/2.5/group?id=\(searchIDs)&units=metric")!).responseJSON { (_, response, JSON, error) in
            
            if error == nil && JSON != nil {
                let myjson = SwiftyJSON.JSON(JSON!)
                
                if let data = myjson["list"].arrayObject{
                    self.delegate?.gotLocalCityWeather!(data)
                }
            }else{
                self.getLocalWeather(info)
            }
        }
    }
    
    // search for location with placeid
    func getLocationWithPlaceID(placeid: String){
        
        var req = Alamofire.request(.GET, NSURL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeid)&key=AIzaSyDHwdGU463x3_aJfg4TNWm0fijTjr9VEdg")!).responseJSON { (_, response, JSON, error) in
            
            if error == nil && JSON != nil {
                
                let myjson = SwiftyJSON.JSON(JSON!)
                let lat = myjson["result"]["geometry"]["location"]["lat"].doubleValue
                let long = myjson["result"]["geometry"]["location"]["lng"].doubleValue
                
                self.delegate?.gotLocationWithPlaceID!(CLLocationCoordinate2DMake(lat, long))
                
            }else{
                //resend
                self.getLocationWithPlaceID(placeid)
            }
        }
        
    }
    
    
    //searh url with flicker
    func flickrSearch(location: CLLocationCoordinate2D, cityID: String){
        var searchText = "https://api.flickr.com/services/rest/?accuracy=11&api_key=\(apiKey)&per_page=10&lat=\(location.latitude)&lon=\(location.longitude)&method=flickr.photos.search&sort=interestingness-desc&tags=scenic,landscape,city,beautiful&tagmode=all&format=json&nojsoncallback=1"
        searchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    
        
        var req = Alamofire.request(.GET, NSURL(string: searchText)!).responseJSON { (_, response, JSON, error) in

            if error == nil && JSON != nil {
                
                let myjson = SwiftyJSON.JSON(JSON!)
                
                let id = myjson["photos"]["photo"][Int(arc4random_uniform(9))]["id"].string

                if id != nil{
                    self.searchPhotoID(id!, cityID: cityID, location:location)
                }else{
                    self.flickrSearch(location, cityID: cityID)
                }
            }else{
                //resend
                // delay 1 second
                let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                    Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
                    self.flickrSearch(location, cityID: cityID)
                }
            }
        }

    }
    
    // get image url of sizes
    func searchPhotoID(photoID: String, cityID: String, location: CLLocationCoordinate2D){
        
        var searchText = "https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=\(apiKey)&photo_id=\(photoID)&format=json&nojsoncallback=1"
        searchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        var req = Alamofire.request(.GET, NSURL(string: searchText)!).responseJSON { (_, response, JSON, error) in

            if error == nil && JSON != nil {
                
                let myjson = SwiftyJSON.JSON(JSON!)
                
                let tbUrl = myjson["sizes"]["size"][1]["source"].string
                let arr = myjson["sizes"]["size"].arrayObject!//["source"].string
                let imageUrl = myjson["sizes"]["size"][arr.count - 1]["source"].string
                

                if tbUrl != nil && imageUrl != nil{
                    ImageCache.smallImagesUrl.updateValue(tbUrl!, forKey: cityID)
                    ImageCache.imagesUrl.updateValue(imageUrl!, forKey: cityID)
                    self.delegate?.gotImageUrls!(tbUrl!, imageURL: imageUrl!, cityID: cityID)
                }else{
                    //resend
                    self.flickrSearch(location, cityID: cityID)
                }
                
            }else{
                //resend
                self.searchPhotoID(photoID, cityID: cityID, location:location)
            }
        }
        
    }
    
    /*
    // get small city image
    func mamapSearch(location: CLLocationCoordinate2D, name: String, cityID: String){
        
        var geocoder = AMapSearchAPI()
        geocoder.reverseGeocodeCoordinate(location) { (response, error) -> Void in
            
            if error == nil && response != nil{
                
                
                let address = response!.results()[0] as! GMSAddress
                
                var searchText = ""
                
                if address.subLocality != nil{
                    
                    if address.locality != nil{
                        searchText = address.subLocality + " " + address.locality
                    }else if address.administrativeArea != nil{
                        searchText = address.subLocality + " " + address.administrativeArea
                    }else{
                        searchText = address.subLocality + " " + address.country
                    }
                    
                }else if address.locality != nil{
                    if address.administrativeArea != nil{
                        searchText = address.locality + " " + address.administrativeArea
                    }else{
                        searchText = address.locality + " " + address.country
                    }
                }else if address.administrativeArea != nil{
                    searchText = address.administrativeArea + " " + address.country
                }else{
                    searchText = address.country
                }
                searchText = searchText + " -human -people -crowd -person"
                // avoid error when there is space
                searchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                
                self.getPictureURLOfACity(searchText, cityID: cityID)
                
            }else{
                //resend
                self.googleSearch(location, name: name, cityID: cityID)
            }
        }
    }
    */
    func getPictureURLOfACity(searchText: String, cityID: String){
        
        let url = NSURL(string: "https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=\(searchText)&imgtype=photo&imgsz=xxlarge%7Chuge&imgc=color&hl=en")!
        // request for the image
        var req = Alamofire.request(.GET, url).responseJSON { (_, response, JSON, error) in
            
            if error == nil && JSON != nil {
                var tbUrl = ""
                var imageUrl = ""
                let myjson = SwiftyJSON.JSON(JSON!)
                if let data = myjson["responseData"]["results"].array{
                    for url in data {
                        //search for wiki result first
                        if url.description.rangeOfString("wikipedia") != nil{
                            
                            if let url =  url["tbUrl"].string
                            {
                                tbUrl = url
                            }
                            
                            if let url = url["unescapedUrl"].string{
                                
                                imageUrl = url
                            }
                            
                            break;
                        }
                    }
                    
                }
                
                if tbUrl == ""{
                    // get the first result if there is no wiki result
                    if let url =  myjson["responseData"]["results"][0]["tbUrl"].string{
                        tbUrl = url
                    }
                    if let url = myjson["responseData"]["results"][0]["unescapedUrl"].string{
                        imageUrl = url
                    }
                }
                // save image in local
                ImageCache.smallImagesUrl.updateValue(tbUrl, forKey: cityID)
                ImageCache.imagesUrl.updateValue(imageUrl, forKey: cityID)
                self.delegate?.gotImageUrls!(tbUrl, imageURL: imageUrl, cityID: cityID)
                
            }else{
                //resend
                self.getPictureURLOfACity(searchText, cityID: cityID)
            }
        }
    }
    
    
    func getWeatherForcast(cityID: String){
        var req = Alamofire.request(.GET, NSURL(string: "http://api.openweathermap.org/data/2.5/forecast/daily?id=\(cityID)&cnt=9")!).responseJSON { (_, response, JSON, error) in
            
            if error == nil && JSON != nil {
                let myjson = SwiftyJSON.JSON(JSON!)
                let list = myjson["list"].arrayObject
                if list != nil && list!.count == 9 {
                    self.delegate?.gotWeatherForcastData!(cityID, forcast:list!)
                }else{
                    //resend
                    self.getWeatherForcast(cityID)
                }
                
            }else{
               //resend
                self.getWeatherForcast(cityID)
            }
        }
    }
    
    func getThreeHourForcast(cityID: String){
        
        var req = Alamofire.request(.GET, NSURL(string: "http://api.openweathermap.org/data/2.5/forecast?id=\(cityID)")!).responseJSON { (_, response, JSON, error) in
            
            if error == nil && JSON != nil {
                let myjson = SwiftyJSON.JSON(JSON!)
                let list = myjson["list"].arrayObject
                if list != nil{
                    self.delegate?.gotThreeHourForcastData!(cityID, forcast:list!)
                }else{
                    //resend
                    self.getThreeHourForcast(cityID)
                }
                
            }else{
                //resend
                self.getThreeHourForcast(cityID)
            }
        }
    }

    
    // get image info
    func searchForCityPhotos(location: CLLocationCoordinate2D, name: String, cityID: String){
            flickrSearch(location, cityID: cityID)
    }

 /*
    var map;
    var service;
    var infowindow;
    
    function initialize() {
    var pyrmont = new google.maps.LatLng(-33.8665433,151.1956316);
    
    map = new google.maps.Map(document.getElementById('map'), {
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    center: pyrmont,
    zoom: 15
    });
    
    var request = {
        location: pyrmont,
        radius: '500',
        query: 'restaurant'
    };
    
    service = new google.maps.places.PlacesService(map);
    service.textSearch(request, callback);
}

function callback(results, status) {
    if (status == google.maps.places.PlacesServiceStatus.OK) {
        for (var i = 0; i < results.length; i++) {
            var place = results[i];
            createMarker(results[i]);
        }
    }*/
    
    
}

