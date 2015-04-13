//
//  CardView.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/4.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit

class CardView: UIView {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var cardImage = UIImageView(image: UIImage(named: "Card"))
        cardImage.frame = frame
        self.addSubview(cardImage)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
