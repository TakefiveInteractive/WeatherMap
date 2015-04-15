//
//  ViewController.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/2/25.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Spring
import GPUImage

class ViewController: UIViewController, GMSMapViewDelegate {

    @IBOutlet var clockButton: DesignableButton!
    @IBOutlet var mapView: MapViewForWeather!
    @IBOutlet var searchBar: CitySearchView!

    @IBOutlet var card: CardView!

    var cityList: ListView!
    var searchResultList: SearchResultView!

    var weatherCardList = [UIImageView]()
    
    var draggingGesture: UIScreenEdgePanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.parentController = self
        
        var cityListDisappearDragger: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "cityListDisappear:")

        searchBar.layer.shadowOffset = CGSizeMake(0, 2);
        searchBar.layer.shadowRadius = 1;
        searchBar.layer.shadowOpacity = 0.3;
        
        clockButton.layer.shadowOffset = CGSizeMake(0, 2);
        clockButton.layer.shadowRadius = 1;
        clockButton.layer.shadowOpacity = 0.3;
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        clockButton.animate()
        createTwoLists()
    }
    
    @IBAction func menuButtonClicked(sender: AnyObject) {
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            }, completion: { (bool) -> Void in
        })
    }
    
    func cityListDisappear(sender: UIPanGestureRecognizer) {
        var x = sender.translationInView(card).x
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createTwoLists() {
        
        searchResultList = SearchResultView(frame: CGRectMake(self.searchBar.frame.origin.x + 3, self.searchBar.frame.origin.y + self.searchBar.frame.height + 10, searchBar.frame.width - 6, 0))
        searchResultList.image = UIImage(named: "board")
        searchResultList.parentController = self
        searchResultList.userInteractionEnabled = true
        searchResultList.layer.shadowOffset = CGSizeMake(0, 2);
        searchResultList.layer.shadowRadius = 1;
        searchResultList.layer.shadowOpacity = 0.3;
        self.view.addSubview(searchResultList)
        
        searchBar.searchDelegate = searchResultList
    }

}

