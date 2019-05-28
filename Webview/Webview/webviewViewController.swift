//
//  ViewController.swift
//  Webview
//
//  Created by Rio Rinaldi on 26/09/18.
//  Copyright © 2018 dycodeEdu. All rights reserved.
//

import UIKit
import WebKit

class webviewViewController: UIViewController {

    @IBOutlet weak var webview: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://www.google.co.id")
        let request = URLRequest(url: url!)
        
        webview.load(request)
        
    }


}

