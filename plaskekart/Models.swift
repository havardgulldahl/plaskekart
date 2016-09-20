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
    
    public func humanizeTime() -> String {
        let formatterFrom = NSDateFormatter()
        formatterFrom.doesRelativeDateFormatting = true
        formatterFrom.dateStyle = .NoStyle
        formatterFrom.timeStyle = .ShortStyle
        let dateStringFrom = formatterFrom.stringFromDate(self.from)
        let form = NSDateComponentsFormatter()
        form.maximumUnitCount = 2
        form.unitsStyle = .Full
        form.allowedUnits = [.Hour, .Minute]
        let dateStringInterval = form.stringFromDate(self.from, toDate: self.to)!
        return String.localizedStringWithFormat(NSLocalizedString("From %@ and for %@", comment:""),
                                                dateStringFrom,  dateStringInterval)
        
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
    
    public func minutesFromNow() -> String {
        let form = NSDateComponentsFormatter()
        form.maximumUnitCount = 1
        form.unitsStyle = .Abbreviated
        form.allowedUnits = [.Minute]
        let timeStringInterval = form.stringFromDate(NSDate(), toDate: self.timeFrom)
        return timeStringInterval!
    }
    
    public func humanizeFrom() -> String {
        let dateFormatter = NSDateFormatter()
        //the "M/d/yy, H:mm" is put together from the Symbol Table
        dateFormatter.dateFormat = "H:mm"
        return dateFormatter.stringFromDate(self.timeFrom)
        
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
    var precipitationCasts: Array<PrecipitationCast>?
    
    public func summary() -> String {
        let form = NSDateComponentsFormatter()
        form.allowedUnits = [NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute]

        form.maximumUnitCount = 2
        form.unitsStyle = .SpellOut
        if self.nowCasts?.count == 0 {
            return NSLocalizedString("locationcast_summary_nocasts",
                                     value: "No casts loaded",
                                     comment: "summary no casts")
        }
        let rain = self.nowCasts!.filter { $0.cast.value > 0.0 }
        if rain.count == 0 {
            // no rain
            return NSLocalizedString("No precipitation in sight", comment:"")
        }
        // find the most rain
        
        let maxRain = self.nowCasts!.maxElement({ (a,b) -> Bool in
            return a.cast.value < b.cast.value
        })!
        
        let peak = String.localizedStringWithFormat(NSLocalizedString("%.2f %@", comment: "peak"),
                                                    maxRain.cast.value,
                                                    maxRain.cast.unit)
        
        if rain.count == self.nowCasts?.count {
            // all rain
            var r = NSLocalizedString("It's raining cats and dogs — peak:", comment:"")
            r += peak
            return r
        }
        
        let rainNow = self.nowCasts!.first!.cast.value > 0.0
        // classify rain
        // see https://en.wikipedia.org/wiki/Rain
        var heaviness = ""
        if maxRain.cast.value > 50.0 {
            heaviness = NSLocalizedString("violent rain", comment: "above 50.0 mm/h")
        } else if maxRain.cast.value > 7.6 {
            heaviness = NSLocalizedString("heavy rain", comment: "above 7.6 mm/h")
        } else if maxRain.cast.value > 2.5 {
            heaviness = NSLocalizedString("moderate rain", comment: "above 2.5 mm/h")
        } else if maxRain.cast.value > 0.5 {
            heaviness = NSLocalizedString("light rain", comment: "above 0.5 mm/h")
        } else if maxRain.cast.value > 0.0 {
            heaviness = NSLocalizedString("a drizzle", comment: "between 0.0 and 0.5 mm/h")
        }
        if rainNow {
            // it's raining now
            var duration = ""
            for c in nowCasts! {
                // find out when the rain stops
                if c.cast.value > 0.0 {
                    // still raining
                    duration = c.minutesFromNow()
                } else {
                    // stopped raining
                    break
                }
            }
            let r = String.localizedStringWithFormat(NSLocalizedString("We're having %@ now, but it will end in %@", comment: "raining now"),
                                                     heaviness,
                                                     duration)
            return r
        } else {
            // it's not raining, now, but it will in a while
            var rainStarts = ""
            var rainEnds = ""
            var rainFlag: Bool = false
            for c in nowCasts! {
                // find out when the rain stops
                if c.cast.value == 0.0 {
                    // not raining
                    if rainFlag == true {
                        // this is the end of the rain
                        rainEnds = c.minutesFromNow()
                        rainFlag = false
                    } else {
                        continue
                    }
                } else {
                    // it rains 
                    if rainFlag == true {
                        // it's continuing to rain
                        continue
                    } else {
                        // this is the start of the rain
                        rainStarts = c.minutesFromNow()
                        rainFlag = true
                    }
                    
                }
            }
            var r = String.localizedStringWithFormat(NSLocalizedString("We will have %@ in %@ (peak: %@), ", comment: "raining now"),
                                                     heaviness,
                                                     rainStarts,
                                                     peak
                                                     )
            var endString = ""
            if rainEnds == "" {
                // it will rain for as long as we have data
                rainEnds = nowCasts!.last!.minutesFromNow()
                endString = NSLocalizedString("and it will continue for at least %@", comment: "continues beyond data")
            } else {
                endString = NSLocalizedString("which ends in %@", comment: "ends at this duration")
            }
            r += String.localizedStringWithFormat(endString, rainEnds)
            return r
            
        }
        
        

        var r = NSLocalizedString("It's going to be on and off", comment:"")
        r.appendContentsOf(peak)
        return r
    }
}



