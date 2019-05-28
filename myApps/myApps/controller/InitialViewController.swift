//
//  InitialViewController.swift
//  myApps
//
//  Created by Rio Rinaldi on 12/04/18.
//  Copyright © 2018 Rio Rinaldi. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.performSegue(withIdentifier: "toMenuScreen", sender: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    
    @IBAction func nextTapped(_ sender: UITapGestureRecognizer) {
        
    }
    
    
}
