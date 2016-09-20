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
    @IBOutlet weak var Place: UILabel!
    @IBOutlet weak var Until: UILabel!
    @IBAction func Share(sender: AnyObject) {
        debugPrint("Sharing nowcast")
        let nowcast: String = self.locationCast.summary()
        let secondActivityItem : NSURL = NSURL(string: "http://lurtgjort.no")!
        // If you want to put an image
        //let image : UIImage = UIImage(named: "image.jpg")!
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [nowcast, secondActivityItem], applicationActivities: nil)
        //activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivityTypePostToWeibo,
            UIActivityTypePrint,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo
        ]
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    @IBAction func Refresh(sender: AnyObject) {
        debugPrint("refreshing nowcast")
    }
    var locationManager: CLLocationManager!
    let locationCast = LocationCast.sharedInstance
    override func viewDidLoad() {
        super.viewDidLoad()
        Chart.noDataText = NSLocalizedString("No live weather data loaded", comment: "barchart says- no data")
        Chart.descriptionText = ""
        Chart.xAxis.labelPosition = .Bottom
        Chart.xAxis.drawAxisLineEnabled = false
        Chart.xAxis.drawGridLinesEnabled = false
        Chart.xAxis.drawLabelsEnabled = true
        Chart.legend.enabled = false
        // Left y axis
        Chart.leftAxis.drawLabelsEnabled = false
        Chart.leftAxis.drawGridLinesEnabled = false
        Chart.leftAxis.drawAxisLineEnabled = false
        // right y axis
        Chart.rightAxis.drawAxisLineEnabled = false
        Chart.animate(yAxisDuration: 1.5, easingOption: .EaseInOutQuart)
        
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
        reverseGeocode(currentLocation, completion: {(placemark, errors)->Void in
            if let place = placemark?.name {
                self.Place.text = place
            } else {
                print("no place name retrieved from geocoder")
                if let locality = placemark?.locality {
                    self.Place.text = locality
                } else {
                    self.Place.text = NSLocalizedString("Unknown place", comment: "no locality from geoocoder")
                }
            }
        })
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
            if i==0 {
                // first entry by timestamp
                dataLabels.append(casts[i].humanizeFrom())
            } else {
                // the rest in minutes, relatively from now
                dataLabels.append(casts[i].minutesFromNow())
            }
        }
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: NSLocalizedString("mm per hour", comment: "mm/h"))
        let chartData = BarChartData(xVals: dataLabels, dataSet: chartDataSet)
        chartData.setDrawValues(false)
        debugPrint("set chartdata xvalcount:", chartData.xValCount)
        Chart.data = chartData
        if let _last = casts.last {
            let _minutes = minutesFrom(_last.timeTo, style: NSDateComponentsFormatterUnitsStyle.Full)
            Until.text = String.localizedStringWithFormat(NSLocalizedString("The next %@", comment: "the next x min"),
                                                          _minutes)
        }
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
