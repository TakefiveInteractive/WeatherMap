//
//  CityListViewController.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/4.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit

class CityListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UpdateIconListDelegate{
    
    var cardList: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        WeatherInfo.updateIconListDelegate = self
        // Do any additional setup after loading the view.
    }
    
    func updateIconList() {
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeatherInfo.citiesAround.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  /*
        var cell:UITableViewCell? = self.tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell?
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")

            var lab = UILabel(frame: CGRectMake(10, 0, 200, 40))
            lab.font = UIFont(name: "Slayer", size: 16)
            lab.textColor = UIColor.whiteColor()
            lab.tag = 10
            cell!.backgroundColor = UIColor.clearColor()
            cell!.contentView.addSubview(lab)
            
        }
        
        let cityInfo = WeatherInfo.citiesAroundDict[WeatherInfo.citiesAround[indexPath.row]] as! [String: AnyObject]
        println(cell?.subviews)
        var label:UILabel = cell!.contentView.viewWithTag(10)! as! UILabel
        label.text = cityInfo["name"]! as? String
        
        return cell!*/
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
    }

}
