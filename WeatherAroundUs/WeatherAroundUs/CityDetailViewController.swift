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

class CityDetailViewController: UIViewController, UIScrollViewDelegate, InternetConnectionDelegate{

    @IBOutlet var backgroundImageView: ImageScrollerView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mainTemperatureShimmerView: FBShimmeringView!
    
    @IBOutlet var switchWeatherUnitButton: UIButton!
    @IBOutlet var mainTemperatureDisplay: UILabel!
    @IBOutlet var dateDisplayLabel: UILabel!
    @IBOutlet var mainTempatureToTopHeightConstraint: NSLayoutConstraint!
    @IBOutlet var basicForecastViewHeight: NSLayoutConstraint!
    
    @IBOutlet var detailWeatherView: DetailWeatherView!
    @IBOutlet var digestWeatherView: DigestWeatherView!
    @IBOutlet var forecastView: BasicWeatherView!

    var isFnotC = NSUserDefaults.standardUserDefaults().objectForKey("temperatureDisplay")!.boolValue!

    var tempImage: UIImage!
    
    var cityID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        forecastView.parentController = self
        digestWeatherView.parentController = self
        detailWeatherView.parentController = self
        
        mainTempatureToTopHeightConstraint.constant = view.frame.height / 3
        mainTemperatureShimmerView.contentView = mainTemperatureDisplay
        mainTemperatureShimmerView.shimmering = true

        forecastView.clipsToBounds = true
        digestWeatherView.clipsToBounds = true
        detailWeatherView.clipsToBounds = true
        
        if isFnotC == true {
            mainTemperatureDisplay.text = "°F"
        } else {
            mainTemperatureDisplay.text = "°C"

        }
    }
    
    
    // have to override function to manipulate status bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
       // backgroundImageView = tempImage
        switchWeatherUnitButton.addTarget(self, action: "switchWeatherUnitButtonDidPressed", forControlEvents: UIControlEvents.TouchUpInside)
        
        backgroundImageView.setup(tempImage)
        setBackgroundImage()
    }
    
    override func viewDidAppear(animated: Bool) {
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height / 3 + basicForecastViewHeight.constant + digestWeatherView.frame.height + detailWeatherView.frame.height + 250)
        
        let nineDayWeatherForcast = WeatherInfo.citiesForcast[cityID] as! [[String: AnyObject]]
        forecastView.setup(nineDayWeatherForcast)
        digestWeatherView.setup(nineDayWeatherForcast)
        detailWeatherView.setup(nineDayWeatherForcast)

        
        var currDate = NSDate()
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        let dateStr = dateFormatter.stringFromDate(currDate)
        dateDisplayLabel.text = dateStr
        //handle chinese
        if dateDisplayLabel.text!.rangeOfString("月") != nil {
            dateDisplayLabel.text = dateDisplayLabel.text! + "日"
        }
        switchWeatherUnitButtonDidPressed()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -90 {
            UserMotion.stop()
            self.performSegueWithIdentifier("backToMain", sender: self)
        }
    }
    

    
    func degreeConvert(degree: Int32) -> Int32 {
        if isFnotC {
            return degree - 273
        } else {
            return Int32(round(Double(Double(degree) - 273.13) * 9.0 / 5.0 + 32))
        }
    }
    
    func switchWeatherUnitButtonDidPressed() {

        NSUserDefaults.standardUserDefaults().setBool(isFnotC, forKey: "temperatureDisplay")
        NSUserDefaults.standardUserDefaults().synchronize()

        isFnotC = !isFnotC
        
        let todayDegree = (((WeatherInfo.citiesForcast[cityID] as! [[String: AnyObject]])[0]["temp"] as! [String: AnyObject])["day"])!.intValue
        if isFnotC {
            mainTemperatureDisplay.text = "\(degreeConvert(todayDegree))°C"
        } else {
            mainTemperatureDisplay.text = "\(degreeConvert(todayDegree))°F"
        }
        let nineDayWeatherForcast = WeatherInfo.citiesForcast[cityID] as! [[String: AnyObject]]
        digestWeatherView.reloadTemperature(nineDayWeatherForcast)
        forecastView.reloadTempatureContent()
        detailWeatherView.reloadTempatureContent(nineDayWeatherForcast)
    }
    
    func setBackgroundImage() {
        
        let imageDict = ImageCache.imagesUrl
        let imageUrl = imageDict[cityID]
        if imageUrl != nil {
            var cache = ImageCache()
            cache.delegate = backgroundImageView
            cache.getImageFromCache(imageUrl!, cityID: cityID)
        }else{
            // search if image not found
            var connection = InternetConnection()
            connection.delegate = self
            //get image url
            connection.searchForCityPhotos(CLLocationCoordinate2DMake(((WeatherInfo.citiesAroundDict[cityID] as! [String : AnyObject]) ["coord"] as! [String: AnyObject])["lat"]! as! Double, ((WeatherInfo.citiesAroundDict[cityID] as! [String : AnyObject]) ["coord"] as! [String: AnyObject])["lon"]! as! Double), name: ((WeatherInfo.citiesAroundDict[cityID] as! [String: AnyObject])["name"] as? String)!, cityID: WeatherInfo.currentCityID)
        }
    }
    
    func gotImageUrls(btUrl: String, imageURL: String, cityID: String) {
        var cache = ImageCache()
        cache.delegate = backgroundImageView
        cache.getImageFromCache(imageURL, cityID: cityID)
    }

}
