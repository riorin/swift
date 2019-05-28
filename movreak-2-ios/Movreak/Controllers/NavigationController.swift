//
//  NavigationController.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 10/6/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        var statusBarStyle: UIStatusBarStyle = .default
        if let topViewController = topViewController {
            statusBarStyle = topViewController.preferredStatusBarStyle
        }
        return statusBarStyle
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        var interfaceOrientations: UIInterfaceOrientationMask = .portrait
        if let topViewController = topViewController {
            interfaceOrientations = topViewController.supportedInterfaceOrientations
        }
        return interfaceOrientations
    }
}
