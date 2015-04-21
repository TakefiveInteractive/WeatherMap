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

}

class InternetConnection: NSObject {
    
    var delegate : InternetConnectionDelegate?
    
    var passData: [String: AnyObject]!
    
    // search city name using google framework
    func searchCityName(content:String){
        
        // avoid crash when there is space
        //handle case when there is chinese
        var searchContent = content.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        let url =  NSURL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(searchContent)&types=(cities)&language=en&key=AIzaSyDHwdGU463x3_aJfg4TNWm0fijTjr9VEdg")
        
        var req = Alamofire.request(.GET, url!).responseJSON { (_, response, JSON, error) in
            
            if error == nil && JSON != nil {
                let myjson = SwiftyJSON.JSON(JSON!)
                var predictions = myjson["predictions"].arrayObject
                if predictions != nil{
                    self.delegate?.gotCityNameAutoComplete!(predictions!)
                }
            }
            
        }
        
    }
    
    //search for local weather data
    func getLocalWeather(location: CLLocationCoordinate2D, number:Int){
        
        var req = Alamofire.request(.GET, NSURL(string: "http://api.openweathermap.org/data/2.5/find?lat=\(location.latitude)&lon=\(location.longitude)&cnt=\(number)&mode=json")!).responseJSON { (_, response, JSON, error) in
            
            if error == nil && JSON != nil {
                let myjson = SwiftyJSON.JSON(JSON!)
                if let data = myjson["list"].arrayObject{
                    self.delegate?.gotLocalCityWeather!(data)
                }
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
                
            }
        }
        
    }
    
    
    // get small city image
    func getPictureURLOfACity(location: CLLocationCoordinate2D, name: String, cityID: String){
        
        var geocoder = GMSGeocoder()
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
                    searchText = name + " " + address.country
                }
                
                // avoid error when there is space
                searchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                
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
                        
                        self.delegate?.gotImageUrls!(tbUrl, imageURL: imageUrl, cityID: cityID)
                        
                    }
                }
            }
            
        }
    }
    
    func getWeatherForcast(cityID: String){
        var req = Alamofire.request(.GET, NSURL(string: "http://api.openweathermap.org/data/2.5/forecast?id=\(cityID)")!).responseJSON { (_, response, JSON, error) in
            
            if error == nil && JSON != nil {
                
                let myjson = SwiftyJSON.JSON(JSON!)
                let list = myjson["list"].arrayObject
                self.delegate?.gotWeatherForcastData!(cityID, forcast:list!)
            }
        }
    }
    
}



/*
[responseStatus: 200, responseDetails: <null>, responseData: {
results =     (
{
GsearchResultClass = GimageSearch;
content = "Transportation[edit]";
contentNoFormatting = "Transportation[edit]";
height = 2304;
imageId = "ANd9GcRekABJ9DZW6_5npnJHMK8eWGWM-ZsbPf4e-CItySjYz5hWVd0Eh2f1OgPZ";
originalContextUrl = "http://en.wikipedia.org/wiki/Sunnyvale,_California";
tbHeight = 100;
tbUrl = "http://t3.gstatic.com/images?q=tbn:ANd9GcRekABJ9DZW6_5npnJHMK8eWGWM-ZsbPf4e-CItySjYz5hWVd0Eh2f1OgPZ";
tbWidth = 150;
title = "<b>Sunnyvale</b>, <b>California</b> - Wikipedia, the free encyclopedia";
titleNoFormatting = "Sunnyvale, California - Wikipedia, the free encyclopedia";
unescapedUrl = "http://upload.wikimedia.org/wikipedia/commons/9/9a/El_camino_and_mathilda.jpg";
url = "http://upload.wikimedia.org/wikipedia/commons/9/9a/El_camino_and_mathilda.jpg";
visibleUrl = "en.wikipedia.org";
width = 3456;
},
{
GsearchResultClass = GimageSearch;
content = "63178_Sunriseof<b>Sunnyvale</b>_ ...";
contentNoFormatting = "63178_SunriseofSunnyvale_ ...";
height = 792;
imageId = "ANd9GcSWSQPydIA290Qr8n7l721tFTg8j4Rz-GC1a8fsN4Gbl6iYY7bgp5vit1Y";
originalContextUrl = "http://www.sunriseseniorliving.com/communities/sunrise-of-sunnyvale/overview.aspx";
tbHeight = 103;
tbUrl = "http://t0.gstatic.com/images?q=tbn:ANd9GcSWSQPydIA290Qr8n7l721tFTg8j4Rz-GC1a8fsN4Gbl6iYY7bgp5vit1Y";
tbWidth = 150;
title = "63178_Sunriseof<b>Sunnyvale</b>_ ...";
titleNoFormatting = "63178_SunriseofSunnyvale_ ...";
unescapedUrl = "http://www.sunriseseniorliving.com/~/media/New-Community-Images/CA/63178/63178_SunriseofSunnyvale_Sunnyvale_CA_Exterior.jpg";
url = "http://www.sunriseseniorliving.com/~/media/New-Community-Images/CA/63178/63178_SunriseofSunnyvale_Sunnyvale_CA_Exterior.jpg";
visibleUrl = "www.sunriseseniorliving.com";
width = 1152;
},
{
GsearchResultClass = GimageSearch;
content = "Las-Palmas-Park-1.jpg";
contentNoFormatting = "Las-Palmas-Park-1.jpg";
height = 1200;
imageId = "ANd9GcRivVoGEuFzZTgfBBOo3j2FAdgzg-Tvzz7-MURZzx802Sb9ek-1tx1iXu0";
originalContextUrl = "http://www.stynesgroup.com/silicon-valley-real-estate/sunnyvale-real-estate/";
tbHeight = 113;
tbUrl = "http://t2.gstatic.com/images?q=tbn:ANd9GcRivVoGEuFzZTgfBBOo3j2FAdgzg-Tvzz7-MURZzx802Sb9ek-1tx1iXu0";
tbWidth = 150;
title = "Las-Palmas-Park-1.jpg";
titleNoFormatting = "Las-Palmas-Park-1.jpg";
unescapedUrl = "http://www.stynesgroup.com/wp-content/uploads/2009/02/Las-Palmas-Park-1.jpg";
url = "http://www.stynesgroup.com/wp-content/uploads/2009/02/Las-Palmas-Park-1.jpg";
visibleUrl = "www.stynesgroup.com";
width = 1600;
},
{
GsearchResultClass = GimageSearch;
content = "<b>Sunnyvale CA</b>";
contentNoFormatting = "Sunnyvale CA";
height = 823;
imageId = "ANd9GcRDupRNi32yreaV8z3LoqjPQoHtYgyK37_TEorE0YOuecT6AtyQEZyRUwKk";
originalContextUrl = "http://home-design.science/apartments/apartments-for-rent-in-sunnyvale-ca-76-rentals.html";
tbHeight = 95;
tbUrl = "http://t2.gstatic.com/images?q=tbn:ANd9GcRDupRNi32yreaV8z3LoqjPQoHtYgyK37_TEorE0YOuecT6AtyQEZyRUwKk";
tbWidth = 150;
title = "Apartments For Rent In <b>Sunnyvale Ca</b> 76 Rentals | HDS - Home design <b>...</b>";
titleNoFormatting = "Apartments For Rent In Sunnyvale Ca 76 Rentals | HDS - Home design ...";
unescapedUrl = "http://thumbs.trulia-cdn.com/pictures/thumbs_6/ps.67/4/1/9/8/picture-uh=9d1c47ee75704533384dfebfe7a6f7b1-ps=41984ad5c2128b2d94e7bbbedd05a64-The-Meadows-1000-Escalon-Ave-Sunnyvale-CA-94085.jpg";
url = "http://thumbs.trulia-cdn.com/pictures/thumbs_6/ps.67/4/1/9/8/picture-uh%3D9d1c47ee75704533384dfebfe7a6f7b1-ps%3D41984ad5c2128b2d94e7bbbedd05a64-The-Meadows-1000-Escalon-Ave-Sunnyvale-CA-94085.jpg";
visibleUrl = "home-design.science";
width = 1295;
}
);
}]
*/
