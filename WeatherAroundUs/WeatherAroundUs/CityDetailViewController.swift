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

class CityDetailViewController: UIViewController, ImageCacheDelegate, InternetConnectionDelegate{

    @IBOutlet var backgroundImageView: DesignableImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mainTemperatureShimmerView: FBShimmeringView!
    @IBOutlet var mainTemperatureDisplay: UILabel!
    @IBOutlet var mainTempatureToTopHeightConstraint: NSLayoutConstraint!
    @IBOutlet var basicForecastViewHeight: NSLayoutConstraint!
    
    @IBOutlet var digestWeatherView: DigestWeatherView!
    @IBOutlet var forecastView: BasicWeatherView!

    var isCnotF = false

    var cityID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get forcast
        threeHourForcast()
        
        setBackgroundImage()

        forecastView.parentController = self
        digestWeatherView.parentController = self
        
        let todayDegree = (((WeatherInfo.citiesForcast[cityID] as! [[String: AnyObject]])[0]["temp"] as! [String: AnyObject])["day"])!.intValue
        if isCnotF {
            mainTemperatureDisplay.text = "\(degreeConvert(todayDegree))°C"
        } else {
            mainTemperatureDisplay.text = "\(degreeConvert(todayDegree))°F"
        }
        
        mainTempatureToTopHeightConstraint.constant = view.frame.height / 3
        mainTemperatureShimmerView.contentView = mainTemperatureDisplay
        mainTemperatureShimmerView.shimmering = true

        forecastView.clipsToBounds = true
        digestWeatherView.clipsToBounds = true
    }
    
    func threeHourForcast(){
        var connection = InternetConnection()
        connection.delegate = self
        connection.getThreeHourForcast(cityID)
    }
    
    func gotThreeHourForcastData(cityID: String, forcast: [AnyObject]) {
        println(forcast)
    }
    
    
    // have to override function to manipulate status bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 200)
        
        let nineDayWeatherForcast = WeatherInfo.citiesForcast[cityID] as! [[String: AnyObject]]
        forecastView.setup(nineDayWeatherForcast)
        digestWeatherView.setup(nineDayWeatherForcast)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setBackgroundImage() {
        let imageDict = ImageCache.imagesUrl
        let imageUrl = imageDict[cityID]!
        var cache = ImageCache()
        cache.delegate = self
        cache.getImageFromCache(imageUrl, cityID: cityID)
    
    }
    
    func degreeConvert(degree: Int32) -> Int32 {
        if isCnotF {
            return degree - 273
        } else {
            return Int32(round(Double(degree - 273) * 9.0 / 5.0 + 32))
        }
    }
    
    func gotImageFromCache(image: UIImage, cityID: String) {
        backgroundImageView.image = image
    }
    
}
