//
//  CityDetailViewController.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/4.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import GPUImage

class CityDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var image = GPUImagePicture(image: UIImage(named: "20150104075606381.jpg")!)
        var filter = GPUImageToonFilter()
        filter.threshold = 0.8
        filter.quantizationLevels = 40

        var img = filter.imageByFilteringImage(UIImage(named: "1175782717.jpg"))
        
        var imgv = UIImageView(image: img)
        imgv.frame = CGRectMake(10, 10, 620, 400)
        
        self.view.addSubview(imgv)

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
