//
//  NowCast.swift
//  plaskekart
//
//  An interface to precipitation measurements by api.met.no / YR.no
//  see: http://api.met.no/weatherapi/nowcast/0.9/documentation
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
    // http://api.met.no/weatherapi/nowcast/0.9/?lat=60.10;lon=9.58
    return NSURL(string: "http://api.met.no/weatherapi/nowcast/0.9/?lat=60.10;lon=9.58")!
}