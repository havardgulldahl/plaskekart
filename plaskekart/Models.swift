//
//  Models.swift
//  Plaskekart
//
//  Created by Håvard Gulldahl on 11.08.2016.
//  Copyright © 2016 Håvard Gulldahl. All rights reserved.
//

import UIKit
import SWXMLHash


enum PrecipitationCastError: ErrorType {
    case IllegalPrecipitationValue
    case PrecipitationDiffers
    case DateRangeDisconnected
}


public class Location {
    // MARK: properties
    var latitude: String
    var longitude: String
    var region: String?
    
    init?(latitude: String, longitude: String) {
        self.latitude = latitude
        self.longitude = longitude
        
        if latitude.isEmpty || longitude.isEmpty {
            return nil
        }
    }
}


public struct Precipitation {
    let unit: String
    let value: Float
    
    init?(unit: String, value: Float) {
        self.unit = unit
        self.value = value
        
        if unit.isEmpty {
            return nil
        }
    }
}

public struct PrecipitationCast {
    var from: NSDate
    var to: NSDate
    let precipitation: Precipitation
    
    init(from: NSDate, to: NSDate, precipitation: Precipitation) {
        self.from = from
        self.to = to
        self.precipitation = precipitation
        
    }
    
    public mutating func appendIfEqual(cast: NowCast) throws -> Bool {
        // get another precipitationCast, and compare 
        // 1. if precipitation is the same, extend self.to 
        // 2. if not the same, throw something 
        if self.precipitation.unit == cast.cast.unit &&
            self.precipitation.value == cast.cast.value {
            self.to = cast.timeTo
            return true
        } else {
            throw PrecipitationCastError.PrecipitationDiffers
        }
    }
}

extension NSDate: XMLAttributeDeserializable  {
    public static func deserialize(attribute: XMLAttribute) throws -> Self {
        if attribute.text.isEmpty {
            throw XMLDeserializationError.NodeHasNoValue
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.dateFromString(attribute.text)
        
        guard let validDate = date else {
            throw XMLDeserializationError.AttributeDeserializationFailed(type: "Date", attribute: attribute)
        }
        
        // NOTE THIS
        return value(validDate)
    }
    
    // AND THIS
    private static func value<T>(date: NSDate) -> T {
        return date as! T
    }
}


public struct NowCast: XMLIndexerDeserializable {
    // a struct that is fit to deserialize a nowcast structure with SWXMLHash
    // see https://github.com/drmohundro/SWXMLHash
/* <time datatype="forecast" from="2016-08-10T22:30:00Z" to="2016-08-10T22:30:00Z">
 <location latitude="60.1000" longitude="9.5800">
 <precipitation unit="mm/h" value="0.0"/>
 </location>
 </time>
 */
    let timeFrom: NSDate
    let timeTo: NSDate
    let location: Location
    let cast: Precipitation
    
    public static func deserialize(node: XMLIndexer) throws -> NowCast {
        return try NowCast(
            timeFrom: node.value(ofAttribute: "from"),
            timeTo: node.value(ofAttribute: "to"),
            location: Location(latitude: node["location"].value(ofAttribute: "latitude"),
                longitude: node["location"].value(ofAttribute: "longitude"))!,
            cast: Precipitation(unit: node["location"]["precipitation"].value(ofAttribute: "unit"),
                value: node["location"]["precipitation"].value(ofAttribute: "value"))!
   
        )
    }
}


public class LocationCast {
    class var sharedInstance: LocationCast {
        struct Static {
            static var instance: LocationCast?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = LocationCast()
        }
        
        return Static.instance!
    }
        
    var loc: Location?
    var nowCasts: Array<NowCast>?
    var regionRadarMap: NSURL?
    

}



