//
//  TimeLineManager.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/20.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit

@objc protocol TimeLineManagerDelegate: class {
    optional func progressUpdated(progress: Double)
}

class TimeLineManager: NSObject, InternetConnectionDelegate {
   
    

}
/*
{
    "list" : [
    {
    "main" : {
    "grnd_level" : 1012.41,
    "temp_min" : 288.077,
    "temp_max" : 288.08,
    "pressure" : 1012.41,
    "temp_kf" : 0,
    "sea_level" : 1024.21,
    "humidity" : 81,
    "temp" : 288.08
    },
    "dt" : 1429563600,
    "weather" : [
    {
    "id" : 800,
    "description" : "sky is clear",
    "main" : "Clear",
    "icon" : "01d"
    }
    ],
    "clouds" : {
    "all" : 0
    },
    "rain" : {
    "3h" : 0
    },
    "dt_txt" : "2015-04-20 21:00:00",
    "wind" : {
    "deg" : 229,
    "speed" : 1.57
    },
    "sys" : {
    "pod" : "d"
    }
    }
}*/
