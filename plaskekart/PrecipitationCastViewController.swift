//
//  PrecipitationCastViewController.swift
//  Plaskekart
//
//  Created by Håvard Gulldahl on 15.08.2016.
//  Copyright © 2016 Håvard Gulldahl. All rights reserved.
//

import UIKit

class PrecipitationCastViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {

    let locationCast = LocationCast.sharedInstance
    private let reuseIdentifier = "PrecipitationCastIconCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func photoForIndexPath(indexPath: NSIndexPath) -> UIImage {
        switch locationCast.precipitationCasts![indexPath.section].precipitation.value {
        case 0.0 :
            return UIImage(named: "cloud")!
        default :
            return UIImage(named: "rain-1")!
            
        }
    }
    


    //1
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return locationCast.precipitationCasts!.count
    }
    
    //2
     func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locationCast.precipitationCasts!.count
    }
    
    //3
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PrecipitationCastIconCell
        cell.backgroundColor = UIColor.blackColor()
        // Configure the cell
        let icon = self.photoForIndexPath(indexPath)
        cell.backgroundColor = UIColor.blackColor()
        //3
        cell.imageView.image = icon
        return cell
    }
}