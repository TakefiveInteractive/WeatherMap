//
//  CitySearchView.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/14.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Spring

@objc protocol SearchInformationDelegate: class {
    optional func addACity(placeID: String, description: String)
    optional func removeCities()
}

class CitySearchView: DesignableView, UISearchBarDelegate, InternetConnectionDelegate{
    
    var delegate : SearchInformationDelegate?
    var blurView: UIVisualEffectView!
    var searchBar: UISearchBar!
    var hide = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(){
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blurView.frame = bounds
        addSubview(blurView)
        
        searchBar = UISearchBar(frame: bounds)
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchBar.delegate = self
        addSubview(searchBar)
        
        self.layer.shadowOffset = CGSizeMake(0, 2)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.3
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        var connection = InternetConnection()
        connection.delegate = self
        connection.searchCityName(searchText)
    }
    
    // got the search result from internet

    func gotCityNameAutoComplete(cities: [AnyObject]) {
        // only display 10 result maximum
        self.delegate?.removeCities!()
        var cityNum = cities.count
        if cityNum > 10{
            cityNum = 10
        }
        for var index = 0; index < cityNum; index++ {
            self.delegate?.addACity!((cities[index] as! [String: AnyObject])["place_id"] as! String, description: (cities[index] as! [String: AnyObject])["description"] as! String)
        }
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchBar.resignFirstResponder()
        return true
    }
    
    func hideSelf(){
        
        if !hide {
            hide = true
            self.center = CGPointMake(self.center.x, self.center.y - 80)
            self.animation = "slideDown"
            self.animate()
        }
    }
    
    func showSelf(){
        
        if hide {
            hide = false
            self.center = CGPointMake(self.center.x, self.center.y + 80)
            self.animation = "slideDown"
            self.animate()
        }
    }
    
}