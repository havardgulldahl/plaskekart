//
//  NowCast.swift
//  plaskekart
//
//  An interface to precipitation measurements by api.met.no / YR.no
//  see: https://api.met.no/weatherapi/nowcast/0.9/documentation
//
//  Created by Håvard Gulldahl on 06.08.2016.
//  Copyright © 2016 Håvard Gulldahl. All rights reserved.
//
//  License: GPL3

import Foundation

import Alamofire
import SWXMLHash


func getCastURL(latitude: String, longitude: String) -> NSURL {
    // get lat+lon and return something like
    // https://api.met.no/weatherapi/nowcast/0.9/?lat=60.10;lon=9.58
    return NSURL(string: "https://api.met.no/weatherapi/nowcast/0.9/?lat=\(latitude);lon=\(longitude)")!
}

func getNowCasts(loc: Location, completion: ([NowCast], errors: String?) -> Void) {
    
    let url = getCastURL(loc.latitude, longitude: loc.longitude)
    
    // Creating an Instance of the Alamofire Manager
    let manager = Manager.sharedInstance
    
    // Specifying the Headers we need
    manager.session.configuration.HTTPAdditionalHeaders = [
        "User-Agent": "Paraplu http://github.com/havardgulldahl/paraplu"
    ]
    Alamofire.request(.GET, url, parameters: nil)
        .validate()
        .responseString{ (response) -> Void in
            response
            guard response.result.isSuccess else {
                completion([], errors: "Error while fetching nowcasts: \(response.result.error)")
                return
            }
            do {
                //debugPrint(response.result.value)
                let xml = SWXMLHash.parse(response.result.value!)
                let casts: [NowCast] =  try xml["weatherdata"]["product"]["time"].value()
                completion(casts, errors: nil)
            } catch {
                completion([], errors: "couldnt parse xml")
                
            }
    }
    
}