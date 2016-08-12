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

func getNowCasts(loc: Location, completion: ([NowCast]) -> Void) {
    
    let url = getCastURL(loc.latitude, longitude: loc.longitude)
    Alamofire.request(.GET, url, parameters: nil)
        .validate()
        .responseString{ (response) -> Void in
            guard response.result.isSuccess else {
                print("Error while fetching nowcasts: \(response.result.error)")
                return
            }
            do {
                //debugPrint(response.result.value)
                let xml = SWXMLHash.parse(response.result.value!)
                let casts: [NowCast] =  try xml["weatherdata"]["product"]["time"].value()
                completion(casts)
            } catch {
                print(error)
                
            }
    }
    
}