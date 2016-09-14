//
//  LocationViewController.swift
//  Sub class to add custom properties to tab bar controller
//  namely
//  .location
//  .locationCast
//  Plaskekart
//
//  Created by Håvard Gulldahl on 11.08.2016.
//  Copyright © 2016 Håvard Gulldahl. All rights reserved.
//

import UIKit

class LocationViewController: UITabBarController {
    
    // MARK: Properties
    var location = Location.self
    var locationCast = LocationCast.self

    override func viewDidLoad() {
        super.viewDidLoad()
        print("LocationViewController loaded")
        // Do any additional setup after loading the view.
        //LocationService.sharedInstance.delegate = self
        LocationService.sharedInstance.startUpdatingLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
