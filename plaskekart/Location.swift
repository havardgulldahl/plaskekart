//
//  Location.swift
//  Plaskekart
//
//  Created by Håvard Gulldahl on 11.08.2016.
//  Copyright © 2016 Håvard Gulldahl. All rights reserved.
//

import UIKit

class LocationCast {
    // MARK: properties
    var latitude: String
    var longitude: String
    var region: String?
    var nowCasts: Array<AnyObject>?
    var regionRadarMap: NSURL?
    
    init?(latitude: String, longitude: String) {
        self.latitude = latitude
        self.longitude = longitude
        
        if latitude.isEmpty || longitude.isEmpty {
            return nil
        }
    }
}
