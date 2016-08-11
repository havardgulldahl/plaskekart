//
//  Models.swift
//  Plaskekart
//
//  Created by Håvard Gulldahl on 11.08.2016.
//  Copyright © 2016 Håvard Gulldahl. All rights reserved.
//

import UIKit
import SWXMLHash

class Location {
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

struct LocationCast {
    // MARK: properties
    
    var loc: Location
    var nowCasts: Array<NowCast>?
    var regionRadarMap: NSURL?
}

struct Precipitation {
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


struct NowCast: XMLIndexerDeserializable {
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
    
    static func deserialize(node: XMLIndexer) throws -> NowCast {
        return try NowCast(
            timeFrom: node.value(ofAttribute: "from"),
            timeTo: node.value(ofAttribute: "to"),
            location: Location(latitude: node["location"].value(ofAttribute: "latitude"),
                longitude: node["location"].value(ofAttribute: "longitude"))!,
            cast: Precipitation(unit: node["precipitation"].value(ofAttribute: "unit"),
                value: node["precipitation"].value(ofAttribute: "value"))!
        )
    }
}