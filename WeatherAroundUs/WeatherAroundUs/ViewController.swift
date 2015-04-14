//
//  ViewController.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/2/25.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Spring
import GPUImage

class ViewController: UIViewController, GMSMapViewDelegate {

    @IBOutlet var clockButton: DesignableButton!
    @IBOutlet var mapView: MapViewForWeather!
    @IBOutlet var card: CardView!

    var cityList: ListView!
    
    var weatherCardList = [UIImageView]()
    
    var draggingGesture: UIScreenEdgePanGestureRecognizer!

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
        
        cityList = ListView(frame: CGRectMake(0, 10, self.view.frame.width * 0.4, 0))
        cityList.backgroundColor = UIColor.clearColor()
        cityList.parentController = self
        self.view.addSubview(cityList)
        
        var image = GPUImagePicture(image: UIImage(named: "20150104075606381.jpg")!)
        var filter = GPUImageToonFilter()
        filter.threshold = 0.8
        filter.quantizationLevels = 50
        //image.addTarget(filter)
        //filter.useNextFrameForImageCapture()
        //image.processImage()
        var img = filter.imageByFilteringImage(UIImage(named: "1175782717.jpg"))
        
        var imgv = UIImageView(image: img)
        imgv.frame = CGRectMake(10, 10, 620, 400)
        
        self.view.addSubview(imgv)
        /*
        UIImage *inputImage = [UIImage imageNamed:@"Lambeau.jpg"];
        
        GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
        GPUImageSepiaFilter *stillImageFilter = [[GPUImageSepiaFilter alloc] init];
        GPUImageToneCurveFilter
        [stillImageSource addTarget:stillImageFilter];
        [stillImageFilter useNextFrameForImageCapture];
        [stillImageSource processImage];
        
        UIImage *currentFilteredVideoFrame = [stillImageFilter imageFromCurrentFramebuffer];
*/
    }
    
    @IBAction func menuButtonClicked(sender: AnyObject) {
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            }, completion: { (bool) -> Void in
        })
    }
    
    func cityListDisappear(sender: UIPanGestureRecognizer) {
        var x = sender.translationInView(card).x
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

