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
import Haneke


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