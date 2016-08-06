//
//  main.swift
//  
//
//  Created by Håvard Gulldahl on 06.08.2016.
//
//

import Foundation

func getradarimage (site: String, static: Bool = true, size: String = "large") -> String {
 // Documentation: http://aa004xmu0m4dtdqty.api.met.no/weatherapi/radar/1.5/documentation
    // example url https://aa004xmu0m4dtdqty.api.met.no/weatherapi/radar/1.5/?radarsite=nordland_troms;type=reflectivity;content=animation;size=large"

    let api_version = "1.5"
    
    let url_base = "https://aa004xmu0m4dtdqty.api.met.no/weatherapi/radar/"
    return "\(url_base)\(api_version)/?radarsite=\(site);type=reflectivity;content=animation;size=\(size)"
}



    
let nord_troms = getradarimage("nordland_troms")

print(nord_troms)