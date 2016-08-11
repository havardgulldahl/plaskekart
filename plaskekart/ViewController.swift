//
//  ViewController.swift
//  VC for the radar map tab
//  plaskekart
//
//  Created by Håvard Gulldahl on 06.08.2016.
//  Copyright © 2016 Håvard Gulldahl. All rights reserved.
//
//  License: GPL3

import UIKit
import CoreLocation

import Kingfisher
import Haneke


class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {
    
    // MARK: Properties from UI
    
    @IBOutlet weak var ProjectionName: UILabel!
    @IBOutlet weak var NetworkProgress: UIProgressView!
    @IBOutlet weak var ProjectionMap: UIImageView!
    @IBOutlet weak var ProjectionPicker: UIPickerView!

    let pickerRows = [String](common_radars.keys)
    var locationManager: CLLocationManager!
    let cache = Cache<NSDictionary>(name: "positions")
    let mapcache = KingfisherManager.sharedManager.cache
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set max map cache to duration to 3 hours,
        // which is roughly the duration for the maps returned
        mapcache.maxCachePeriodInSecond = 60 * 60 * 3
        
        // connect radar picker to here, must implement picker protocol
        // (see *pickerView* functions below)
        self.ProjectionPicker.delegate = self
        self.ProjectionPicker.dataSource = self
        
        // only show progressbar on network activity
        self.NetworkProgress.hidden = true

        // set up location manager (GPS) stuff
        cache.fetch(key: "latlon").onSuccess { data in
            // we have a cached position, start finding map
            print("viewcontroller.swift: cached position found: \(data)")
        }
        self.locationManager = CLLocationManager()
        self.locationManager.requestWhenInUseAuthorization() // TODO: ask nicely first
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            self.locationManager.startUpdatingLocation()
        }
        
        // load initial precipitation map of norway, while waiting for regional info from gps
        ProjectionMap.kf_setImageWithURL(radar_norway,
                                         placeholderImage: UIImage.init(named: "nordland_troms"))

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: pickerView implementation
    
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerRows.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerRows[row]
    }
    
    // Catpure the picker view selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        let val = pickerRows[row]
        print("Got picked value: \(val)")
        let radar_url = common_radars[val]
        print("that is url: \(radar_url)")
        getProjectionMap(radar_url!)
    }
    

    
    
    // MARK: custom functions
    
    func getProjectionMap(mapUrl: NSURL) {
        // get projection map from the internet
        if ProjectionMap.kf_webURL == mapUrl {
            // the url is the same as before
            // check to see if cache is stale, else abort
            print("Uncaught: url is the same :(")
        }
        NetworkProgress.setProgress(0.0, animated: false)
        NetworkProgress.hidden = false
        ProjectionMap.kf_setImageWithURL(mapUrl,
                                         progressBlock: { (receivedSize, totalSize) -> () in
                                            let fractionalProgress = Float(receivedSize) / Float(totalSize)
                                            let animated = receivedSize != 0
                                            //print("Download Progress: \(fractionalProgress)")
                                            self.NetworkProgress.setProgress(fractionalProgress, animated: animated)
            },
                                         completionHandler: { (image, error, cacheType, imageURL) -> () in
                                            // image is downloaded, hide progressbar
                                            self.NetworkProgress.hidden = true
            }
        )
        
    }
    /*
    func showAlert(message: String, title: String = "Error") {
        let myAlert: UIAlertController = UIAlertController(title: title,
                                                           message: message,
                                                           preferredStyle: .Alert)
        
        myAlert.addAction(UIAlertAction(title: "OK",
                                        style: .Default,
                                        handler: nil))
        
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    */
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            if error != nil{
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
    
            if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                self.displayLocationInfo(pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })}
    
    // Stop location updates
    //self.locationManager.stopUpdatingLocation()
    
    func displayLocationInfo(placemark: CLPlacemark) {
        //get reverse geocoded area for our current place, and update with the best map for that area
        print("Updating with the presumed best map for area: \(placemark.administrativeArea)")
        if placemark.administrativeArea != nil {
            getProjectionMap(getMapForArea(placemark.administrativeArea!))
        }
    }

    
    // MARK: Actions and events

    

}

