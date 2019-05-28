//
//  DetailContactViewController.swift
//  ContactApp
//
//  Created by Sachin on 11/05/18.
//  Copyright © 2018 Sachin. All rights reserved.
//

import UIKit
import CoreData

var contact : ContactDBC?
var context : NSManagedObjectContext!
class DetailContactViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        //if let detail = detailVC {
            if let contact = contact {
                nameLabel.text = contact.firstName!
            }
       // }
    }
    
   
    
    var detailVC: ContactDBC? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}
