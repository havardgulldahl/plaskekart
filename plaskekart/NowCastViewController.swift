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
import Charts


class NowCastViewController: UIViewController, LocationServiceDelegate, ChartViewDelegate {

    @IBOutlet weak var Chart: BarChartView!
    @IBOutlet weak var Summary: UILabel!

    var locationManager: CLLocationManager!
    let locationCast = LocationCast.sharedInstance
    override func viewDidLoad() {
        super.viewDidLoad()
        Chart.noDataText = NSLocalizedString("No live weather data loaded", comment: "barchart says- no data")
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocationService.sharedInstance.delegate = self
        //LocationService.sharedInstance.startUpdatingLocation()
        debugPrint("viewwillappear nowcast vc ")
        debugPrint(LocationService.sharedInstance.lastLocation)
        if let loc = LocationService.sharedInstance.lastLocation {
            self.tracingLocation(loc)
        } else {
            LocationService.sharedInstance.startUpdatingLocation()
        }
    }
    
    func tracingLocation(currentLocation: CLLocation){
        
        let latitude = String(format: "%.4f", currentLocation.coordinate.latitude)
        let longitude = String(format: "%.4f", currentLocation.coordinate.longitude)
        
        self.updateNowCast(latitude, long: longitude)
    
    }
    
    func tracingLocationDidFailWithError(error: NSError) {
        print("tracing Location Error : \(error.description)")
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
        //showAlert(getCastURL(lat, longitude: long).absoluteString, vc: self) // POOR MANS DEBUG!
        let newLoc = Location(latitude: lat, longitude: long)!
        print("updatenewcast: new location: \(newLoc)")
        self.locationCast.loc = newLoc
        getNowCasts(newLoc, completion: analyzeCasts)
        
        
    }
    
    func analyzeCasts(casts: [NowCast], errors: String?) -> Void {
        print("analyzeCasts")
        //debugPrint(casts)
        if errors != nil {
            // something's wrong. print errors
            debugPrint(errors)
            showAlert(errors!, vc: self)
            return
        }
        self.locationCast.nowCasts = casts
        self.Summary.text = self.locationCast.summary()
        
        var dataEntries: [BarChartDataEntry] = []
        var dataLabels: [String] = []
        for i in 0..<casts.count {
            let dataEntry = BarChartDataEntry(value: Double(casts[i].cast.value), xIndex: i)
            dataEntries.append(dataEntry)
            dataLabels.append(casts[i].minutesFromNow())
        }
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "mm/s")
        let chartData = BarChartData(xVals: dataLabels, dataSet: chartDataSet)
        Chart.data = chartData
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
