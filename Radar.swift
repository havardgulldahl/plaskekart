//
//  Radar.swift
//
//  An interface to precipitation radars by api.met.no / YR.no
//  see: http://api.met.no/weatherapi/radar/1.5/documentation
//
//  Created by Håvard Gulldahl on 06.08.2016.
//  Copyright © 2016 Håvard Gulldahl. All rights reserved.
//
//  License: GPL3

import Foundation

func getRadarURL (site: String, animated: Bool = true, size: String = "normal") -> NSURL {
    // Documentation: http://api.met.no/weatherapi/radar/1.5/documentation
    // example url https://api.met.no/weatherapi/radar/1.5/?radarsite=nordland_troms;type=reflectivity;content=animation;size=large"
    // valid sites: see bottom of this file
    // valid sizes: "large", "normal"
    let api_version = "1.5"
    var content = "animation" // by default, we want animation
    if !animated {
        content = "image"
    }
    let url_base = "https://api.met.no/weatherapi/radar/"
    return NSURL(string: "\(url_base)\(api_version)/?radarsite=\(site);type=reflectivity;content=\(content);size=\(size)")!
}



// MARK: Iterate through all valid radar sites and create their urls
let radar_finnmark = getRadarURL("finnmark")
let radar_troms_finnmark = getRadarURL("troms_finnmark")
let radar_nordland_troms = getRadarURL("nordland_troms")
let radar_nordland = getRadarURL("nordland")
let radar_trlagnordland = getRadarURL("trlagnordland")
let radar_central_norway = getRadarURL("central_norway")
let radar_western_norway = getRadarURL("western_norway")
let radar_southwest_norway = getRadarURL("southwest_norway")
let radar_southeast_norway = getRadarURL("southeast_norway")
let radar_south_norway = getRadarURL("south_norway")
let radar_norway = getRadarURL("norway")
let radar_nordic = getRadarURL("nordic")
let radar_boemlo = getRadarURL("boemlo")
let radar_avinoreast = getRadarURL("avinoreast")
let radar_avinorwest = getRadarURL("avinorwest")
let radar_helsfyr = getRadarURL("helsfyr")
let radar_andoya = getRadarURL("andoya")
let radar_berlevaag = getRadarURL("berlevaag")
let radar_bomlo = getRadarURL("bomlo")
let radar_hasvik = getRadarURL("hasvik")
let radar_hagebostad = getRadarURL("hagebostad")
let radar_hurum = getRadarURL("hurum")
let radar_rissa = getRadarURL("rissa")
let radar_rost = getRadarURL("rost")
let radar_stad = getRadarURL("stad")
let radar_somna = getRadarURL("somna")

let common_radars: [String: NSURL] = ["Finnmark": radar_finnmark,
                                      "Troms/Finnmark": radar_troms_finnmark,
                                      "Troms/Nordland": radar_nordland_troms,
                                      "Trøndelag": radar_trlagnordland,
                                      "Midt-Norge": radar_central_norway,
                                      "Vestlandet": radar_western_norway,
                                      "Sørlandet": radar_south_norway,
                                      "Østlandet": radar_southeast_norway,
                                      "Norge": radar_norway
]
