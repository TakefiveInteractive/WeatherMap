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

    @IBOutlet var clockButton: DesignableButton!
    @IBOutlet var mapView: MapViewForWeather!
    @IBOutlet var searchBar: CitySearchView!
    @IBOutlet var card: CardView!
    @IBOutlet var shadow: UIVisualEffectView!

    
    var smallImageView: ImageCardView!
    var cityList: ListView!
    var searchResultList: SearchResultView!

    var weatherCardList = [UIImageView]()
    
    
    var draggingGesture: UIScreenEdgePanGestureRecognizer!
    
    func getSmallImageOfCity(image: UIImage, btUrl: String, imageURL: String, cityName: String) {
        
        smallImageView.changeImage(image, frame:CGRectMake(self.view.frame.width - image.size.width / 2 - 20, card.frame.origin.y - image.size.height / 2 - 10, image.size.width / 2 + 8, image.size.height / 2 + 8))
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.parentController = self
        
        var cityListDisappearDragger: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "cityListDisappear:")
        
        clockButton.layer.shadowOffset = CGSizeMake(0, 2);
        clockButton.layer.shadowRadius = 1;
        clockButton.layer.shadowOpacity = 0.3;
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        clockButton.animate()
        
        // create result list
        searchResultList = SearchResultView(frame: CGRectMake(self.searchBar.frame.origin.x + 3, self.searchBar.frame.origin.y + self.searchBar.frame.height + 10, searchBar.frame.width - 6, 0))
        searchResultList.parentController = self
        self.view.addSubview(searchResultList)
        searchBar.searchDelegate = searchResultList
        
        // create smallImageView
        smallImageView = ImageCardView(image: UIImage(named: "board")!)
        self.view.addSubview(smallImageView)
        
        let gesture = UIPanGestureRecognizer(target: self, action: "dragged:")
        self.smallImageView.addGestureRecognizer(gesture)
    }
    
    func dragged(sender: UIPanGestureRecognizer){
        var movement: CGFloat = 0
        if sender.translationInView(self.smallImageView).x < 0{
            movement = sqrt(pow(sender.translationInView(self.smallImageView).x, 2) + pow(sender.translationInView(self.smallImageView).y, 2))
            smallImageView.moveAccordingToDrag(movement)
            card.moveAccordingToDrag(movement)
            shadow.alpha = movement / 200
        }
        
        if movement > 150 || sender.state == UIGestureRecognizerState.Cancelled || sender.state == UIGestureRecognizerState.Failed || sender.state == UIGestureRecognizerState.Ended {
            sender.removeTarget(self, action: "dragged:")
            UIView.animateWithDuration(Double(movement) / 200, animations: { () -> Void in
                self.shadow.alpha = 1
                self.card.transform = CGAffineTransformMakeTranslation(0, self.card.frame.height * 1.5)
                self.smallImageView.frame = CGRectMake(4, 4, self.view.frame.width - 8, self.view.frame.height - 8)
                }, completion: { (finish) -> Void in
                    
            })
        }

    }
    
    @IBAction func menuButtonClicked(sender: AnyObject) {
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            }, completion: { (bool) -> Void in
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

