//
//  ViewController.swift
//  map
//
//  Created by Rio Rinaldi on 27/09/18.
//  Copyright © 2018 dycodeEdu. All rights reserved.
//

import UIKit
import GoogleMaps

private let locationManager = CLLocationManager()

class ViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self as! CLLocationManagerDelegate
        locationManager.requestWhenInUseAuthorization()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
   
}

