//
//  DetailViewController.swift
//  CollectinView
//
//  Created by Rio Rinaldi on 26/09/18.
//  Copyright © 2018 dycodeEdu. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var selection: String!

    @IBOutlet weak var detailsLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsLabel.text = selection

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
