//
//  Utils.swift
//  Plaskekart
//
//  Created by Håvard Gulldahl on 09.08.2016.
//  Copyright © 2016 Håvard Gulldahl. All rights reserved.
//

import UIKit
import Haneke
import CoreLocation



// MARK: add type support for NSDictionary to Haneke cache, for storing latlon
extension NSDictionary : DataConvertible, DataRepresentable {
    
    public typealias Result = NSDictionary
    
    public class func convertFromData(data:NSData) -> Result? {
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDictionary
    }
    
    public func asData() -> NSData! {
        return NSKeyedArchiver.archivedDataWithRootObject(self)
    }
    
}

func showAlert(message: String, vc: UIViewController, title: String = "Error") {
    let myAlert: UIAlertController = UIAlertController(title: title,
                                                       message: message,
                                                       preferredStyle: .Alert)
    
    myAlert.addAction(UIAlertAction(title: "OK",
        style: .Default,
        handler: nil))
    
    vc.presentViewController(myAlert, animated: true, completion: nil)
}

// modify headers for all HTTP traffic
let modifiedHTTPHeaders = [
    "User-Agent": "paraplu http://github.com/havardgulldahl/paraplu"
]

func reverseGeocode(location: CLLocation, completion: (CLPlacemark?, errors: String?) -> Void) {
    CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
        if error != nil{
            print("Reverse geocoder failed with error" + error!.localizedDescription)
            completion (nil, errors: error?.localizedDescription)
            return
        }
        
        if placemarks!.count > 0 {
            let pm = placemarks![0] as CLPlacemark
            completion(pm, errors: nil)
        } else {
            print("Problem with the data received from geocoder")
        }
    })
    
}


