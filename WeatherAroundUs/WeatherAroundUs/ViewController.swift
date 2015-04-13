//
//  ViewController.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/2/25.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Spring

class ViewController: UIViewController, GMSMapViewDelegate {

    @IBOutlet var clockButton: DesignableButton!
    @IBOutlet var mapView: MapViewForWeather!
    @IBOutlet var card: CardView!

    var cityList: ListView!
    
    var weatherCardList = [UIImageView]()
    
    var draggingGesture: UIScreenEdgePanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.parentController = self
        
        var cityListDisappearDragger: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "cityListDisappear:")

        clockButton.layer.shadowOffset = CGSizeMake(0, 2);
        clockButton.layer.shadowRadius = 1;
        clockButton.layer.shadowOpacity = 0.3;
       
        cityList = ListView(frame: CGRectMake(0, 0, self.view.frame.width / 2, 0))
        cityList.alpha = 0
        cityList.backgroundColor = UIColor.clearColor()
        self.view.addSubview(cityList)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        clockButton.animate()
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

}

