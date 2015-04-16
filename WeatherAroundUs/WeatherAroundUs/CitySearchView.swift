//
//  CitySearchView.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/14.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Alamofire

@objc protocol SearchInformationDelegate: class {
    optional func addACity(placeID: String, description: String)
    optional func removeCities()
}

class CitySearchView: UISearchBar, UISearchBarDelegate{
    
    var searchDelegate : SearchInformationDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(){
        self.delegate = self
        self.layer.shadowOffset = CGSizeMake(0, 2)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.3
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        var searchContent = searchText

        // avoid crash when there is space
        searchContent = searchContent.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)

        let url =  NSURL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(searchContent)&types=(cities)&language=cn&key=AIzaSyDHwdGU463x3_aJfg4TNWm0fijTjr9VEdg")
        
        //handle case when there is chinese
        if url == nil{
            return
        }
        
        var req = Alamofire.request(.GET, url!).responseJSON { (_, response, JSON, error) in
            
            if error == nil && JSON != nil {
                
                self.searchDelegate?.removeCities!()
                
                let result = JSON as! [String : AnyObject]
                let predictions = result["predictions"] as! [AnyObject]
                for pred in predictions{
                     self.searchDelegate?.addACity!(pred["place_id"] as! String, description: pred["description"] as! String)
                }
                
            }
            
        }

    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        self.resignFirstResponder()
        return true
    }
    

}
/*

[status: OK, predictions: (
    {
        description = "Philadelphia, PA, United States";
        id = 489e2588263ef0cca39fbb0a0e9e4d8f40d07cb7;
        "matched_substrings" =         (
            {
                length = 1;
                offset = 0;
            }
        );
        "place_id" = "ChIJ60u11Ni3xokRwVg-jNgU9Yk";
        reference = "CkQ3AAAAk6oFY3-wfZE-i3MwLVHgI7GeSY086QEHWM9rZMCvyCMzUdjXkvJKr4SQZxPna3LuvHVkD3YwcjycbHNmbXwOixIQAkuS87VeOXtoiFoVyyy4ihoU5eUfhb1QrGIoa1ncgKfEFtomhhI";
        terms =         (
            {
                offset = 0;
                value = Philadelphia;
            },
            {
                offset = 14;
                value = PA;
            },
            {
                offset = 18;
                value = "United States";
            }
        );
        types =         (
            locality,
            political,
            geocode
        );
    },
    {
        description = "Pittsburgh, PA, United States";
        id = d23c7ba1e4c92a9544fde37bc4bf11a9ebd2adfe;
        "matched_substrings" =         (
            {
                length = 1;
                offset = 0;
            }
        );
        "place_id" = "ChIJA4UGSG_xNIgRNBuiWqEV-Y0";
        reference = "CkQ1AAAALjliRG4yTI0FaO7YYUpXFMvr6cgpBUIrTCeLgf8QVmiUQ35PSXKsthlWm3SnhF4T-uuSqXVLXRIywuiqnoaDKRIQWEDhgNbxLndfguyMpfJHfhoUtSq9X3wbo-hZk1jeNDXLN4x0KMc";
        terms =         (
            {
                offset = 0;
                value = Pittsburgh;
            },
            {
                offset = 12;
                value = PA;
            },
            {
                offset = 16;
                value = "United States";
            }
        );
        types =         (
            locality,
            political,
            geocode
        );
    },
    {
        description = "Paris, France";
        id = 691b237b0322f28988f3ce03e321ff72a12167fd;
        "matched_substrings" =         (
        {
        length = 1;
        offset = 0;
        }
        );
        "place_id" = ChIJD7fiBh9u5kcRYJSMaMOCCwQ;
        reference = "CjQlAAAALpHEX9qDW05mpB3oZcNZg6CNnaxPNmsi3nDra8iLOWUxWkDpoFH9a3sgDFVqax_TEhCWYPUGjwpDwTxSffOtwB-8GhR_PlAVjtaoAjlwWUIKuGL9LdRXQw";
        terms =         (
        {
        offset = 0;
        value = Paris;
        },
        {
        offset = 7;
        value = France;
        }
        );
        types =         (
        locality,
        political,
        geocode
        );
    },
    {
        description = "Phoenix, AZ, United States";
        id = c7a71d54ba38a3d7f60bdc9bb9c37f990660edee;
        "matched_substrings" =         (
            {
                length = 1;
                offset = 0;
            }
        );
        "place_id" = ChIJy3mhUO0SK4cRrBtKNfjHaYw;
        reference = "CkQyAAAAT6NlJ5-6kacN323xshqtp-vQtV-YjMHTqxw_BrrwtpXUL6PR_eFasQ1R2cUtPN_rTC1vSXjkEdYOJBzMNUhA4BIQDPHMVATLxSGvCSeonXhDnRoUEtKNB8goGRMCsw_hlZmpRyAkerA";
        terms =         (
            {
                offset = 0;
                value = Phoenix;
            },
            {
                offset = 9;
                value = AZ;
            },
            {
                offset = 13;
                value = "United States";
            }
        );
        types =         (
            locality,
            political,
            geocode
        );
    },
    {
        description = "Peoria, IL, United States";
        id = f1d6d8c2e9e9ba5f1497973c75e3e4f1b8aa48c0;
        "matched_substrings" =         (
            {
                length = 1;
                offset = 0;
            }
        );
        "place_id" = "ChIJrXlYU1xZCogR24B9azL0-8o";
        reference = "CkQxAAAAWqQe33XmxqbdUrFeU8hwavxqMK_ghzIfqKPNpRQAA4vWeQpuR2xFerGuIhwotEB8P0yMiXvMYqR727dsyOdpLRIQtDFn5Shj3feqJvZ9F-LfJxoUAdAx34hIvYcEybEIWq7fdiKJ2II";
        terms =         (
            {
                offset = 0;
                value = Peoria;
            },
            {
                offset = 8;
                value = IL;
            },
            {
                offset = 12;
                value = "United States";
            }
        );
        types =         (
            locality,
            political,
            geocode
        );
    }
)]
[status: OK, predictions: (
    {
        description = "Paris, France";
        id = 691b237b0322f28988f3ce03e321ff72a12167fd;
        "matched_substrings" =         (
        {
        length = 2;
        offset = 0;
        }
        );
        "place_id" = ChIJD7fiBh9u5kcRYJSMaMOCCwQ;
        reference = "CjQlAAAA8vNcY-7AppDY8JVsWADgeiRPnqu9M8aYrsY85P376YXuk1ozw9gG0rZk4RVGTqoHEhDfM3RbldZ0KhzqMy_gOpjoGhQAaBlluOte_ISs6lItCS8YSUqPnQ";
        terms =         (
        {
        offset = 0;
        value = Paris;
        },
        {
        offset = 7;
        value = France;
        }
        );
        types =         (
        locality,
        political,
        geocode
        );
    },
    {
        description = "Pasadena, CA, United States";
        id = 8b4b3c6cbc5db3b204124335deee6ae96ba83765;
        "matched_substrings" =         (
        {
        length = 2;
        offset = 0;
        }
        );
        "place_id" = "ChIJUQszONzCwoARSo_RGhZBKwU";
        reference = "CkQzAAAAbaQV__wXJnueT3uW21T7cJU5-PXMhAI8ujbNoD_HDTyrWqeB981j5IXATsKSZxRgmX3iHimNQZxfGQHzuQh3exIQ5KFSPpt8HiizLAtAXFnc7RoU9AqECChc-j71dAhuyPIW0BNu-qY";
        terms =         (
        {
        offset = 0;
        value = Pasadena;
        },
        {
        offset = 10;
        value = CA;
        },
        {
        offset = 14;
        value = "United States";
        }
        );
        types =         (
        locality,
        political,
        geocode
        );
    },
    {
        description = "Palatine, IL, United States";
        id = 5bb2acb2db7ca76a9cc1829429b2b607b435ee5e;
        "matched_substrings" =         (
        {
        length = 2;
        offset = 0;
        }
        );
        "place_id" = ChIJVTfJvy9LDogRAHzIzKsjIYc;
        reference = "CkQzAAAAosF32ItPX4ZqNCwN6QFGHLUWnXIF0RSSa1I7dq4vlKSHMue-tPM_4jApfjNOqwtaaLvQ4gA8UygWgbOhg47WLhIQYC301FpCQe8UYcDvUbSB9xoU8z3JtJy9WFgMh9bwi50Yd78xVQM";
        terms =         (
        {
        offset = 0;
        value = Palatine;
        },
        {
        offset = 10;
        value = IL;
        },
        {
        offset = 14;
        value = "United States";
        }
        );
        types =         (
        locality,
        political,
        geocode
        );
    },
    {
        description = "Palo Alto, CA, United States";
        id = 16033f5c80ea86ab13c93a2691c95cd0761e5b59;
        "matched_substrings" =         (
        {
        length = 2;
        offset = 0;
        }
        );
        "place_id" = ChIJORy6nXuwj4ARz3b1NVL1Hw4;
        reference = "CkQ0AAAAss_NZ-wiPVoRH2WoFpC6Xc6z02EOxUHU36mXLygwrBusHI-3mjKYD6OUn-C1YVc7mjCWZTgyw1Ck_A_x575aRhIQCmUPkycdZJrpfQT1gXLAqxoUo-DPY9280fqBouLyzyKHwaXXlHA";
        terms =         (
        {
        offset = 0;
        value = "Palo Alto";
        },
        {
        offset = 11;
        value = CA;
        },
        {
        offset = 15;
        value = "United States";
        }
        );
        types =         (
        locality,
        political,
        geocode
        );
    },
    {
        description = "Park Ridge, IL, United States";
        id = 3891abec499d23795c6570c4679dc7a0a56bd764;
        "matched_substrings" =         (
        {
        length = 2;
        offset = 0;
        }
        );
        "place_id" = "ChIJ_6LykSGwD4gR4roAry4BlwM";
        reference = "CkQ1AAAAvU_fiUit0jZUbbg3x2CITM7uHb7vvJa5LQAcz0vGzdw2WXxp2PePnrm4dd6YP5sBFlEEckOa-kDZTCIufTj34RIQDnwTmdkSlUL4iaSnYgdjxxoUqEnlrDtnlO_K156cVmcMia21n78";
        terms =         (
        {
        offset = 0;
        value = "Park Ridge";
        },
        {
        offset = 12;
        value = IL;
        },
        {
        offset = 16;
        value = "United States";
        }
        );
        types =         (
        locality,
        political,
        geocode
        );
    }
)]
*/


