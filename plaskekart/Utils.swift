//
//  Utils.swift
//  Plaskekart
//
//  Created by Håvard Gulldahl on 09.08.2016.
//  Copyright © 2016 Håvard Gulldahl. All rights reserved.
//

import UIKit


func showAlert(message: String, vc: UIViewController, title: String = "Error") {
    let myAlert: UIAlertController = UIAlertController(title: title,
                                                       message: message,
                                                       preferredStyle: .Alert)
    
    myAlert.addAction(UIAlertAction(title: "OK",
        style: .Default,
        handler: nil))
    
    vc.presentViewController(myAlert, animated: true, completion: nil)
}
  