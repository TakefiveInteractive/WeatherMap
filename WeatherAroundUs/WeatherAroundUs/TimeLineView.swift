//
//  LoadingView.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/20.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Spring

class TimeLineView: DesignableView {

    var parentController: ViewController!

    var manager: TimeLineManager!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.shadowOffset = CGSizeMake(0, 2)
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.3
    }
    
    func setupManager(){
        manager = TimeLineManager(mapView: parentController.mapView)
    }

}
