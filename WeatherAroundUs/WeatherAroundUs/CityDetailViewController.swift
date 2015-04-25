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
    
    @IBOutlet var forecastView: BasicWeatherView!
    @IBOutlet var detailView: DesignableView!

    var fiveDaysWeather = [SpringView]()

    var isCnotF = false

    var cityID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage()

        forecastView.parentController = self
        
        let todayDegree = (((WeatherInfo.citiesForcast[cityID] as! [[String: AnyObject]])[0]["temp"] as! [String: AnyObject])["day"])!.intValue
        if isCnotF {
            mainTemperatureDisplay.text = "\(todayDegree - 273)°C"
        } else {
            mainTemperatureDisplay.text = "\((todayDegree-273) * 9 / 5 + 32)°C"
        }
        
        mainTempatureToTopHeightConstraint.constant = view.frame.height / 3
        mainTemperatureShimmerView.contentView = mainTemperatureDisplay
        mainTemperatureShimmerView.shimmering = true

        forecastView.clipsToBounds = true
        detailView.clipsToBounds = true
    }
    
    // have to override function to manipulate status bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 200)
        
        let nineDayWeatherForcast = WeatherInfo.citiesForcast[cityID] as! [[String: AnyObject]]
        forecastView.setup(nineDayWeatherForcast)
        
        //println((nineDayWeatherForcast[0]["temp"] as! [String: AnyObject])["day"])
        //println(WeatherInfo.citiesAround)
        //println(WeatherInfo.citiesAroundDict[cityID])
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
                cache.getImageFromCache(imageUrl, cityID: cityID)
            }
        }
    }
    

    
    func gotImageFromCache(image: UIImage, cityID: String) {
        backgroundImageView.image = image
    }
    
}
