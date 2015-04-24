//
//  CityDetailViewController.swift
//  WeatherAroundUs
//
//  Created by Wang Yu on 4/23/15.
//  Copyright (c) 2015 Kedan Li. All rights reserved.
//

import UIKit
import Spring
import Shimmer

class CityDetailViewController: UIViewController, ImageCacheDelegate {

    @IBOutlet var backgroundImageView: DesignableImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mainTemperatureShimmerView: FBShimmeringView!
    @IBOutlet var mainTemperatureDisplay: UILabel!
    @IBOutlet var mainTempatureToTopHeightConstraint: NSLayoutConstraint!
    
    var cityID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage()
        mainTempatureToTopHeightConstraint.constant = view.frame.height / 4
        mainTemperatureShimmerView.contentView = mainTemperatureDisplay
        mainTemperatureShimmerView.shimmering = true
    }
    
    // have to override function to manipulate status bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 200)
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
