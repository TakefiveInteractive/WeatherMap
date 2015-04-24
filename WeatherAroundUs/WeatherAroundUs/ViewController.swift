//
//  ViewController.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/2/25.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Spring

class ViewController: UIViewController, GMSMapViewDelegate, InternetConnectionDelegate{

    @IBOutlet var clockButton: ClockView!
    @IBOutlet var mapView: MapView!
    @IBOutlet var searchBar: CitySearchView!
    @IBOutlet var card: CardView!
    @IBOutlet var timeLine: TimeLineView!
    @IBOutlet var returnBut: ReturnButton!

    var smallImageView: ImageCardView!
    var searchResultList: SearchResultView!

    var weatherCardList = [UIImageView]()
    
    var draggingGesture: UIScreenEdgePanGestureRecognizer!
    
    // get small city image from google
    func gotImageUrls(btUrl: String, imageURL: String, cityID: String) {
        var cache = ImageCache()
        cache.delegate = card
        cache.getSmallImageFromCache(btUrl, cityID: cityID)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.parentController = self
        clockButton.parentController = self
        timeLine.parentController = self
        returnBut.parentController = self
    }
    
    override func viewWillAppear(animated: Bool) {
        
        searchResultList = SearchResultView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        searchResultList.frame = CGRectMake(self.searchBar.frame.origin.x + 3, self.searchBar.frame.origin.y + self.searchBar.frame.height + 10, searchBar.frame.width - 6, 0)
        searchResultList.parentController = self
        self.view.addSubview(searchResultList)
        searchBar.delegate = searchResultList
        searchResultList.parentController = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        clockButton.setup()
        timeLine.setup()
        card.setup()
        
        //first weather search
        WeatherInfo.getLocalWeatherInformation(mapView.camera.target, number: mapView.getNumOfWeatherBasedOnZoom())

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

