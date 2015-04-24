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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.parentController = self
        clockButton.parentController = self
        timeLine.parentController = self
        returnBut.parentController = self
        
        var tapGestureReco = UITapGestureRecognizer(target: self, action: "tappedCard:")
        self.card.addGestureRecognizer(tapGestureReco)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        searchResultList = SearchResultView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        searchResultList.frame = CGRectMake(self.searchBar.frame.origin.x + 3, self.searchBar.frame.origin.y + self.searchBar.frame.height + 10, searchBar.frame.width - 6, 0)
        searchResultList.parentController = self
        self.view.addSubview(searchResultList)
        searchBar.delegate = searchResultList
        searchResultList.parentController = self
        clockButton.setup()

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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "cityDetailSegue" {
            let toView = segue.destinationViewController as! CityDetailViewController
            toView.cityID = WeatherInfo.currentCityID
        }
    }
    
    func tappedCard(sender: UITapGestureRecognizer) {
        let touchPoint = sender.locationInView(self.view)
        performSegueWithIdentifier("cityDetailSegue", sender: self)
    }

}

