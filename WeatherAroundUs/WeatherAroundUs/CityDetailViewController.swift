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

class CityDetailViewController: UIViewController, ImageCacheDelegate, UIScrollViewDelegate {

    @IBOutlet var backgroundImageView: DesignableImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mainTemperatureShimmerView: FBShimmeringView!
    @IBOutlet var mainTemperatureDisplay: UILabel!
    @IBOutlet var dateDisplayLabel: UILabel!
    @IBOutlet var mainTempatureToTopHeightConstraint: NSLayoutConstraint!
    @IBOutlet var basicForecastViewHeight: NSLayoutConstraint!
    
    
    @IBOutlet var digestWeatherView: DigestWeatherView!
    @IBOutlet var forecastView: BasicWeatherView!

    var isCnotF = false

    var tempImage: UIImage!
    
    var cityID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
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
    
    
    // have to override function to manipulate status bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        backgroundImageView.image = tempImage
        setBackgroundImage()
    }
    
    override func viewDidAppear(animated: Bool) {
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height / 3 + basicForecastViewHeight.constant + digestWeatherView.frame.height + 240)
        
        let nineDayWeatherForcast = WeatherInfo.citiesForcast[cityID] as! [[String: AnyObject]]
        forecastView.setup(nineDayWeatherForcast)
        digestWeatherView.setup(nineDayWeatherForcast)
        
        
        var currDate = NSDate()
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        let dateStr = dateFormatter.stringFromDate(currDate)
        dateDisplayLabel.text = dateStr

        
        var screenEdgeWipeReco:  UIScreenEdgePanGestureRecognizer! = UIScreenEdgePanGestureRecognizer(target: self, action: "swipeScreenEdgeLeft:")
        screenEdgeWipeReco.edges = UIRectEdge.Left
        view.addGestureRecognizer(screenEdgeWipeReco)
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func swipeScreenEdgeLeft(sender: UIScreenEdgePanGestureRecognizer) {
        self.performSegueWithIdentifier("backToMain", sender: self)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -90 {
            self.performSegueWithIdentifier("backToMain", sender: self)
        }
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
