//
//  CityDetailViewController.swift
//  WeatherAroundUs
//
//  Created by Wang Yu on 4/23/15.
//  Copyright (c) 2015 Kedan Li. All rights reserved.
//

import UIKit
import Spring

class CityDetailViewController: UIViewController, ImageCacheDelegate {

    @IBOutlet var backgroundImageView: DesignableImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mainTemperatureDisplay: UILabel!
    @IBOutlet var degreeToTopHeightConstraint: NSLayoutConstraint!
    
    var cityID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage()
        degreeToTopHeightConstraint.constant = view.frame.height / 4
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setBackgroundImage() {
        var userDefault = NSUserDefaults.standardUserDefaults()
        let imageDict: AnyObject! = userDefault.objectForKey("imgUrl")
                
        if let imageDict = imageDict as? NSMutableDictionary {
            let imageUrl: AnyObject! = imageDict.objectForKey(cityID)
            if let imageUrl = imageUrl as? String {
                var cache = ImageCache()
                cache.delegate = self
                println(imageUrl)
                cache.getImageFromCache(imageUrl, cityID: cityID)
            }
        }
    }
    
    func gotImageFromCache(image: UIImage, cityID: String) {

        backgroundImageView.image = image
    }
    
}
