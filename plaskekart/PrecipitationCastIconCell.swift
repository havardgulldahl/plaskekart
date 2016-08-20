//
//  PrecipitationCastIconCell.swift
//  Plaskekart
//
//  Created by Håvard Gulldahl on 16.08.2016.
//  Copyright © 2016 Håvard Gulldahl. All rights reserved.
//

import UIKit

class PrecipitationCastIconCell: UICollectionViewCell {
    
    @IBOutlet weak var Timestamp: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    
    
    override func prepareForReuse() {
        self.Timestamp.text = nil
        self.imageView.image = nil
        super.prepareForReuse()
        
    }
}
