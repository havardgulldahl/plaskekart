//
//  NowCastViewController.swift
//  VC for the NowCast tab
//  Plaskekart
//
//  Created by Håvard Gulldahl on 09.08.2016.
//  Copyright © 2016 Håvard Gulldahl. All rights reserved.
//

import UIKit
import CoreLocation
//import Haneke

class NowCastViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var NowCastLabel: UILabel!
    @IBOutlet weak var NowCastImageView: UIImageView!

    var locationManager: CLLocationManager!
    //let cache = Cache<NSDictionary>(name: "positions")
    let locationCast = LocationCast.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up location manager (GPS) stuff
        self.locationManager = CLLocationManager()
        self.locationManager.requestWhenInUseAuthorization() // TODO: ask nicely first
        
        /*
        cache.fetch(key: "latlon").onSuccess { data in
            // we have a cached position, start getting nowcast
            print("nowcastviewcontroller.swift: cached position found: \(data)")
            self.updateNowCast(data["latitude"] as! String, long: data["longitude"] as! String!)
        }
        */
        
        print("nowcastvc: ")
        debugPrint(locationCast)
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            self.locationManager.startUpdatingLocation()
        }
        // Do any additional setup after loading the view.
    }
    // MARK: Location aware implementation
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("new location atuh status: \(status)")
        var message: String = ""
        switch status {
        case CLAuthorizationStatus.Restricted:
            // "Restricted Access to location"
            message = NSLocalizedString("CLAuthorizationStatus.Restricted",
                                        value:"Location access is restricted. Please go to settings to re-enable it",
                                        comment:"User alert")
        case CLAuthorizationStatus.Denied:
            // "User denied access to location"
            message = NSLocalizedString("CLAuthorizationStatus.Denied",
                                        value:"Access to current location is needed for automatic maps. If you want to re-enable this, please go to settings",
                                        comment:"User alert")
            
        case CLAuthorizationStatus.NotDetermined:
            // "Status not determined"
            message = NSLocalizedString("CLAuthorizationStatus.NotDetermined",
                                        value:"Could not read Location. Please try again later",
                                        comment:"User alert")
            
        default:
            self.locationManager.startUpdatingLocation()
            
        }
        if !message.isEmpty{
            showAlert(message, vc:self)
        }
        
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Get a fix on the user's location
        //self.locationManager.stopUpdatingLocation()
        
        // get correct map from coordinates
        let latestLocation = locations.last
        
        let latitude = String(format: "%.4f", latestLocation!.coordinate.latitude)
        let longitude = String(format: "%.4f", latestLocation!.coordinate.longitude)
        
        print("nowcastvc Latitude: \(latitude)")
        print("nowcastvc Longitude: \(longitude)")
        //cache.set(value: ["latitude": latitude, "longitude": longitude], key: "latlon")
        self.updateNowCast(latitude, long: longitude)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateNowCast(lat: String, long: String) {
        if self.locationCast.loc?.latitude == lat && self.locationCast.loc?.longitude == long {
            // same spot, abort
            return
        }
        NowCastLabel.text = "Latitude: \(lat), longitude: \(long)"
        let newLoc = Location(latitude: lat, longitude: long)!
        self.locationCast.loc = newLoc
        getNowCasts(newLoc, completion: analyzeCasts)
        
        
    }
    
    func analyzeCasts(casts: [NowCast]) -> Void {
        print("analyzeCasts")
        //debugPrint(casts)
        self.locationCast.nowCasts = casts
        
        
        var symbols = [PrecipitationCast]()
        
        for c in casts {
            if symbols.count > 0  { // get last element of array to compare
                do {
                   try symbols[symbols.endIndex-1].appendIfEqual(c)
                    continue
                }
                catch PrecipitationCastError.PrecipitationDiffers {
                    print ("lastsymbol )")
                }
                catch {
                    print ("some other error \(error)")
                }
            }
            // no last element found (= empty array)
            // or not equal
            symbols.append(PrecipitationCast(from: c.timeFrom, to: c.timeTo, precipitation: c.cast))
        }
        debugPrint(symbols)
        
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
