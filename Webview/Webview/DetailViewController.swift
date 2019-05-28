//
//  DetailViewController.swift
//  Webview
//
//  Created by Rio Rinaldi on 26/09/18.
//  Copyright © 2018 dycodeEdu. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailLabel: UILabel!
    
    var selection : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailLabel.text = selection

        // Do any additional setup after loading the view.
    }

}
