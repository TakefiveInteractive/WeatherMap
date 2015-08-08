
//
//  SearchResultView.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/14.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit

class SearchResultView: UIVisualEffectView, InternetConnectionDelegate, SearchInformationDelegate{
    
    var parentController: ViewController!
    
    var placeIDList = [String]()
    var resultList = [UIButton]()
    var placeLocationList = [AMapGeoPoint]()
    
    let theHeight: CGFloat = 20
    let maxCity: Int = 12
    
    override init(effect: UIVisualEffect) {
        super.init(effect: effect)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(){
        self.layer.shadowOffset = CGSizeMake(0, 2)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.3
        self.userInteractionEnabled = true
    }
    
    func addACityCN(coordinate: AMapGeoPoint, description: String){
    
        //add a card
        let aCity = UIButton(frame: CGRectMake(4, (theHeight + 6) * CGFloat(resultList.count), self.frame.width - 8, theHeight))
        aCity.alpha = 0
        aCity.addTarget(self, action: "chooseCityCN:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(aCity)
        resultList.insert(aCity, atIndex: 0)
        placeLocationList.insert(coordinate, atIndex: 0)
        
        var lab = UILabel(frame: aCity.bounds)
        lab.font = UIFont(name: "AvenirNext-Regular", size: 14)
        lab.text = description
        lab.textColor = UIColor.darkGrayColor()
        aCity.addSubview(lab)
        
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.alpha = 1
            aCity.alpha = 0.8
            
            })
        
        // change size
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.frame.size = CGSizeMake(self.frame.width, (self.theHeight + 6) * CGFloat(self.resultList.count))
        })
        
    }
    
    func addACity(placeID: String, description: String){
        
        //add a card
        let aCity = UIButton(frame: CGRectMake(4, (theHeight + 6) * CGFloat(resultList.count), self.frame.width - 8, theHeight))
        aCity.alpha = 0
        aCity.addTarget(self, action: "chooseCity:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(aCity)
        resultList.insert(aCity, atIndex: 0)
        placeIDList.insert(placeID, atIndex: 0)
        
        var lab = UILabel(frame: aCity.bounds)
        lab.font = UIFont(name: "AvenirNext-Regular", size: 14)
        lab.text = description
        lab.textColor = UIColor.darkGrayColor()
        aCity.addSubview(lab)
        
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.alpha = 1
            aCity.alpha = 0.8
            
        })
        
        // change size
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.frame.size = CGSizeMake(self.frame.width, (self.theHeight + 6) * CGFloat(self.resultList.count))
        })
        
    }
    
    
    func chooseCityCN(sender: UIButton){
        
        parentController.searchBar.hideSelf()
    
        let location = placeLocationList[find(resultList, sender)!]
        
        parentController.card.hideSelf()
        parentController.clockButton.clockReturnNormalSize()
        parentController.searchBar.searchBar.text = ""
        removeCities()

        self.parentController.mapView.setCenterCoordinate(CLLocationCoordinate2DMake(Double(location.latitude), Double(location.longitude)), zoomLevel: 12, animated: true)
        var iconsData = WeatherInfo.getNearestIcons(CLLocationCoordinate2DMake(Double(location.latitude), Double(location.longitude)))
        WeatherInfo.searchWeather(iconsData as! [WeatherDataQTree])
    }
    
    func gotLocationWithPlaceID(location: CLLocationCoordinate2D){
        self.parentController.mapView.setCenterCoordinate(location, zoomLevel: 12, animated: true)
        var iconsData = WeatherInfo.getNearestIcons(location)
        WeatherInfo.searchWeather(iconsData as! [WeatherDataQTree])
    }

    func chooseCity(sender: UIButton){
        
        parentController.searchBar.hideSelf()
        
        let placeid = placeIDList[find(resultList, sender)!]
        
        parentController.card.hideSelf()
        parentController.clockButton.clockReturnNormalSize()
        parentController.searchBar.searchBar.text = ""
        removeCities()
        
        var connection = InternetConnection()
        connection.delegate = self
        connection.getLocationWithPlaceID(placeid)
        
    }
    
    func removeCities(){
        
        for var index:Int = 0; index < resultList.count; index++ {
            let temp = resultList[index]
            temp.removeFromSuperview()
        }
        
        resultList.removeAll(keepCapacity: false)
        placeLocationList.removeAll(keepCapacity: false)
        placeIDList.removeAll(keepCapacity: false)
        // change size
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.frame.size = CGSizeMake(self.frame.width, 0)
        })
    }
    
}
