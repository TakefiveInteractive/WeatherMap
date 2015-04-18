//
//  CitySearchView.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/14.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Alamofire

@objc protocol SearchInformationDelegate: class {
    optional func addACity(placeID: String, description: String)
    optional func removeCities()
}

class CitySearchView: UISearchBar, UISearchBarDelegate, InternetConnectionDelegate{
    
    var searchDelegate : SearchInformationDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(){
        self.delegate = self
        self.layer.shadowOffset = CGSizeMake(0, 2)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.3
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        var connection = InternetConnection()
        connection.delegate = self
        connection.searchCityName(searchText)
    }
    
    func gotCityNameAutoComplete(cities: [AnyObject]) {
        // got the search result from internet
        for city in cities{
            self.searchDelegate?.addACity!(city["place_id"] as! String, description: city["description"] as! String)
        }
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        self.resignFirstResponder()
        return true
    }
}