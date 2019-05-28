//
//  ViewController.swift
//  myApps
//
//  Created by Rio Rinaldi on 11/04/18.
//  Copyright © 2018 Rio Rinaldi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scroolView: UIScrollView!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginButton(_ sender: Any) {
//        login()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        scroolView.contentSize.height = 500
        loginButton.layer.cornerRadius = 5
        loginButton.layer.masksToBounds = true
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

