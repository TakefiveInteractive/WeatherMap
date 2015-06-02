//
//  CitySearchView.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/14.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Spring

@objc protocol SearchInformationDelegate: class {
    optional func addACity(placeID: String, description: String)
    optional func removeCities()
}

class CitySearchView: DesignableView, UITextFieldDelegate, InternetConnectionDelegate{
    
    var parentController: ViewController!

    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var searchDraw: UIView!
    @IBOutlet var searchBack: UIView!
    @IBOutlet var searchBar: UITextField!
    
    var searchDisplayOutLine = CAShapeLayer()
    var longDisplayOutLine = CAShapeLayer()

    var delegate : SearchInformationDelegate?
    var hide = true

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.shadowOffset = CGSizeMake(0, 2)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.3
    }
    
    func setup(){
        addSearchAnimation()
        changeCircleSize()
    }

    
    // got the search result from internet

    func gotCityNameAutoComplete(cities: [AnyObject]) {
        // only display 10 result maximum
        self.delegate?.removeCities!()
        var cityNum = cities.count
        if cityNum > 10{
            cityNum = 10
        }
        for var index = 0; index < cityNum; index++ {
            self.delegate?.addACity!((cities[index] as! [String: AnyObject])["place_id"] as! String, description: (cities[index] as! [String: AnyObject])["description"] as! String)
        }
    }
    
    func hideSelf(){

        self.searchBar.resignFirstResponder()

    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var connection = InternetConnection()
        connection.delegate = self
        connection.searchCityName(textField.text)
        return true

    }

    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        longDisplayOutLine.removeFromSuperlayer()
        searchBar.text = ""
        //fixed w
        dispatch_async(dispatch_get_main_queue(), {
            
            UIView.animateWithDuration(0.8, animations: { () -> Void in
                self.transform = CGAffineTransformMake(100 / self.parentController.fullLengthOfSearchBar, 0, 0, 1, -(self.parentController.fullLengthOfSearchBar - 100) / 2, 0)
                }) { (finish) -> Void in
                    self.parentController.searchBarLength.constant = 100
                    self.layoutIfNeeded()
                    self.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0)
                    self.changeCircleSize()
                    self.addSearchAnimation()
            }
        })
        
        
        return true

    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        longDisplayOutLine.removeFromSuperlayer()
        self.parentController.searchBarLength.constant = parentController.fullLengthOfSearchBar
        self.parentController.returnBut.dissAppear()
        self.setNeedsUpdateConstraints()
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            self.searchDraw.alpha = 0
            self.layoutIfNeeded()
            }) { (finish) -> Void in
                self.changeCircleSize()
                self.searchDisplayOutLine.removeFromSuperlayer()
                self.searchDraw.alpha = 1
                //rr
        }
        return true

    }

    
    // draw the outside circ
    func changeCircleSize(){
        
        let path = UIBezierPath(roundedRect: searchBack.bounds, cornerRadius: 5)
        longDisplayOutLine.path = path.CGPath
        longDisplayOutLine.strokeColor = UIColor(red: 0.267, green: 0.608, blue: 0.600, alpha: 1.000).CGColor
        longDisplayOutLine.fillColor = UIColor.clearColor().CGColor
        longDisplayOutLine.lineWidth = 1
        longDisplayOutLine.lineCap = kCALineCapRound
        searchBack.layer.addSublayer(longDisplayOutLine)
        
    }
    
    func showSelf(){
        
        if hide {
            hide = false
            self.center = CGPointMake(self.center.x, self.center.y + 80)
            self.animation = "slideDown"
            self.animate()
        }
    }
    
    func addSearchAnimation(){
        searchDisplayOutLine.path = drawSearch().CGPath
        searchDisplayOutLine.strokeColor = UIColor(red: 0.267, green: 0.608, blue: 0.600, alpha: 1.000).CGColor
        searchDisplayOutLine.fillColor = UIColor.clearColor().CGColor
        searchDisplayOutLine.lineWidth = 1.5
        searchDisplayOutLine.lineCap = kCALineCapRound
        searchDraw.layer.addSublayer(searchDisplayOutLine)
        
        var animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        animateStrokeEnd.duration = 2.0
        animateStrokeEnd.fromValue = 0
        animateStrokeEnd.toValue = 1.0
        animateStrokeEnd.delegate = self
        animateStrokeEnd.fillMode = kCAFillModeForwards
        animateStrokeEnd.removedOnCompletion = true
        searchDisplayOutLine.addAnimation(animateStrokeEnd, forKey: "drawOutline")
    }
    
    func drawSearch()->UIBezierPath{
        var searchPath = UIBezierPath()
        searchPath.moveToPoint(CGPointMake(searchDraw.bounds.minX + 0.58602 * searchDraw.bounds.width, searchDraw.bounds.minY + 0.63137 * searchDraw.bounds.height))
        searchPath.addCurveToPoint(CGPointMake(searchDraw.bounds.minX + 0.89703 * searchDraw.bounds.width, searchDraw.bounds.minY + 0.89702 * searchDraw.bounds.height), controlPoint1: CGPointMake(searchDraw.bounds.minX + 0.59006 * searchDraw.bounds.width, searchDraw.bounds.minY + 0.62779 * searchDraw.bounds.height), controlPoint2: CGPointMake(searchDraw.bounds.minX + 0.89314 * searchDraw.bounds.width, searchDraw.bounds.minY + 0.90085 * searchDraw.bounds.height))
        searchPath.addCurveToPoint(CGPointMake(searchDraw.bounds.minX + 0.60783 * searchDraw.bounds.width, searchDraw.bounds.minY + 0.61000 * searchDraw.bounds.height), controlPoint1: CGPointMake(searchDraw.bounds.minX + 0.90043 * searchDraw.bounds.width, searchDraw.bounds.minY + 0.89366 * searchDraw.bounds.height), controlPoint2: CGPointMake(searchDraw.bounds.minX + 0.60463 * searchDraw.bounds.width, searchDraw.bounds.minY + 0.61348 * searchDraw.bounds.height))
        searchPath.addCurveToPoint(CGPointMake(searchDraw.bounds.minX + 0.59792 * searchDraw.bounds.width, searchDraw.bounds.minY + 0.20388 * searchDraw.bounds.height), controlPoint1: CGPointMake(searchDraw.bounds.minX + 0.71441 * searchDraw.bounds.width, searchDraw.bounds.minY + 0.49445 * searchDraw.bounds.height), controlPoint2: CGPointMake(searchDraw.bounds.minX + 0.71111 * searchDraw.bounds.width, searchDraw.bounds.minY + 0.31550 * searchDraw.bounds.height))
        searchPath.addCurveToPoint(CGPointMake(searchDraw.bounds.minX + 0.17568 * searchDraw.bounds.width, searchDraw.bounds.minY + 0.20388 * searchDraw.bounds.height), controlPoint1: CGPointMake(searchDraw.bounds.minX + 0.48132 * searchDraw.bounds.width, searchDraw.bounds.minY + 0.08890 * searchDraw.bounds.height), controlPoint2: CGPointMake(searchDraw.bounds.minX + 0.29228 * searchDraw.bounds.width, searchDraw.bounds.minY + 0.08890 * searchDraw.bounds.height))
        searchPath.addCurveToPoint(CGPointMake(searchDraw.bounds.minX + 0.17568 * searchDraw.bounds.width, searchDraw.bounds.minY + 0.62025 * searchDraw.bounds.height), controlPoint1: CGPointMake(searchDraw.bounds.minX + 0.05909 * searchDraw.bounds.width, searchDraw.bounds.minY + 0.31886 * searchDraw.bounds.height), controlPoint2: CGPointMake(searchDraw.bounds.minX + 0.05909 * searchDraw.bounds.width, searchDraw.bounds.minY + 0.50527 * searchDraw.bounds.height))
        searchPath.addCurveToPoint(CGPointMake(searchDraw.bounds.minX + 0.58602 * searchDraw.bounds.width, searchDraw.bounds.minY + 0.63137 * searchDraw.bounds.height), controlPoint1: CGPointMake(searchDraw.bounds.minX + 0.28839 * searchDraw.bounds.width, searchDraw.bounds.minY + 0.73140 * searchDraw.bounds.height), controlPoint2: CGPointMake(searchDraw.bounds.minX + 0.46879 * searchDraw.bounds.width, searchDraw.bounds.minY + 0.73510 * searchDraw.bounds.height))
        
        searchPath.closePath()
        return searchPath
    }

}