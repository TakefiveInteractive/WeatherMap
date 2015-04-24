//
//  CityDetailViewController.swift
//  WeatherAroundUs
//
//  Created by Wang Yu on 4/23/15.
//  Copyright (c) 2015 Kedan Li. All rights reserved.
//

import UIKit
import Spring

class CityDetailViewController: UIViewController {

    @IBOutlet var backgroundImageView: DesignableImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mainTemperatureDisplay: UILabel!
    @IBOutlet var degreeToTopHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        degreeToTopHeightConstraint.constant = view.frame.height / 4
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
