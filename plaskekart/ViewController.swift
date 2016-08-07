//
//  ViewController.swift
//  plaskekart
//
//  Created by Håvard Gulldahl on 06.08.2016.
//  Copyright © 2016 Håvard Gulldahl. All rights reserved.
//
//  License: GPL3

import UIKit
import CoreLocation

import Kingfisher

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {
    
    // MARK: Properties from UI
    
    @IBOutlet weak var ProjectionName: UILabel!
    @IBOutlet weak var NetworkProgress: UIProgressView!
    @IBOutlet weak var ProjectionMap: UIImageView!
    @IBOutlet weak var ProjectionPicker: UIPickerView!

    let pickerRows = [String](common_radars.keys)
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // connect radar picker to here, must implement picker protocol 
        // (see *pickerView* functions below)
        self.ProjectionPicker.delegate = self
        self.ProjectionPicker.dataSource = self
        
        // only show progressbar on network activity
        self.NetworkProgress.hidden = true
        
        // set up location manager (GPS) stuff
        self.locationManager = CLLocationManager()
        self.locationManager.requestWhenInUseAuthorization() // TODO: ask nicely first
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
        }
        
        // load initial precipitation map, either from cache or disk
        ProjectionMap.kf_setImageWithURL(radar_norway,
                                         placeholderImage: UIImage.init(named: "nordland_troms"),
                                         optionsInfo: [.ForceRefresh]) //dont get from the net 

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
    
    // MARK: Location aware implementation
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("new location atuh status: \(status)")
        var message: String = ""
        switch status {
            case CLAuthorizationStatus.Restricted:
                // "Restricted Access to location"
                message = "Location access is restricted. Please go to settings to re-enable it"
            case CLAuthorizationStatus.Denied:
                // "User denied access to location"
                message = "Access to current location is needed for automatic maps. If you want to re-enable this, please go to settings"
            case CLAuthorizationStatus.NotDetermined:
                // "Status not determined"
                message = "Could not read Location. Please try again later"
            
        default:
            self.locationManager.startUpdatingLocation()
            
        }
        if !message.isEmpty{
            showAlert(message)
        }

    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Get a fix on the user's location
        
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
        })
        
        // Stop location updates
        //self.locationManager.stopUpdatingLocation()
        
        // get correct map from coordinates
        let latestLocation = locations.last
        
        let latitude = String(format: "%.4f", latestLocation!.coordinate.latitude)
        let longitude = String(format: "%.4f", latestLocation!.coordinate.longitude)
        
        print("Latitude: \(latitude)")
        print("Longitude: \(longitude)")
        
    }

    
    
    // MARK: custom functions
    
    func getProjectionMap(mapUrl: NSURL) {
        // get projection map from the internet
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
    
    func showAlert(message: String, title: String = "Error") {
        let myAlert: UIAlertController = UIAlertController(title: title,
                                                           message: message,
                                                           preferredStyle: .Alert)
        
        myAlert.addAction(UIAlertAction(title: "OK",
                                        style: .Default,
                                        handler: nil))
        
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        //get reverse geocoded area for our current place, and update with the best map for that area
        print("Updating with the presumed best map for area: \(placemark.administrativeArea)")
        if placemark.administrativeArea != nil {
            getProjectionMap(getMapForArea(placemark.administrativeArea!))
        }
    }

    
    // MARK: Actions and events

    

}

