//
//  NowCastsCollection.swift
//  Paraplu
//
//  Created by Håvard Gulldahl on 17.09.2016.
//  Copyright © 2016 Håvard Gulldahl. All rights reserved.
//

import Foundation
import UIKit

class NowCastsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var CollectionView: UICollectionView!

    let locationCast = LocationCast.sharedInstance
    private let reuseIdentifier = "PrecipitationCell" // identical to "identifier" property of cell
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func analyzeCasts(casts: [NowCast], errors: String?) -> Void {
        
        var symbols = [PrecipitationCast]()
        
        for c in casts {
            if symbols.count > 0  { // get last element of array to compare
                do {
                    try symbols[symbols.endIndex-1].appendIfEqual(c)
                    continue
                }
                catch PrecipitationCastError.PrecipitationDiffers {
                    print ("precipitationdiffers")
                    debugPrint(symbols[symbols.endIndex-1], c)
                }
                catch {
                    print ("precipitioation appendifequal() some other error \(error)")
                }
            }
            // no last element found (= empty array)
            // or not equal
            symbols.append(PrecipitationCast(from: c.timeFrom, to: c.timeTo, precipitation: c.cast))
        }
        debugPrint(symbols)
        self.locationCast.precipitationCasts = symbols
        // refresh collection view
        dispatch_async(dispatch_get_main_queue(), {
            self.CollectionView.reloadData()
        })
        
    }
    
    
    
    
    // MARK: precipitationcast cell
    func nowCastForIndexPath(indexPath: NSIndexPath) -> (PrecipitationCast, UIImage) {
        var i = UIImage(named: "hail")! // default image
        if locationCast.precipitationCasts == nil {
            return (PrecipitationCast(from: NSDate(), to:NSDate(timeIntervalSinceNow: 60.0*60*6), precipitation: Precipitation(unit: "mm/t", value: 0.0)!),
                    i
            )
        }
        let p = locationCast.precipitationCasts![indexPath.section]
        switch p.precipitation.value {
        case 0.0 :
            i = UIImage(named: "cloud")!
        default :
            i = UIImage(named: "rain-1")!
        }
        return (p, i)
        
    }
    
    //1
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        debugPrint("//1 numberofsectionsincollectionview")
        if let c = locationCast.precipitationCasts {
            return c.count
        }
        return 1 // no locatoincasts yet
    }
    
    //2
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1 // single column info
    }
    
    //3
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        debugPrint("//3 collectionview cellforitematindexpath")
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PrecipitationCastIconCell
        // Configure the cell
        let (cast, icon) = self.nowCastForIndexPath(indexPath)
        cell.Timestamp.text = "\(cast.humanizeTime()):\n\(cast.precipitation.value) \(cast.precipitation.unit)"
        cell.imageView.image = icon
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        let (cast, _) = self.nowCastForIndexPath(indexPath)
        debugPrint("prec: \(cast.precipitation.value)")
    }
    




}

