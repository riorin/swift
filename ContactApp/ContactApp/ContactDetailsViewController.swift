//
//  ContactDetailsViewController.swift
//  ContactApp
//
//  Created by Sachin on 11/05/18.
//  Copyright © 2018 Sachin. All rights reserved.
//

import UIKit
import CoreData
class ContactDetailsViewController: UITableViewController {
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var zipLabel: UILabel!
    
    var contact : ContactDBC?
    let managedObjectContext = CoreDataStack().managedObjectContext
    
    lazy var fetchedResultController : TodoFetchedResultsController = {
        return TodoFetchedResultsController(managedObjectContex: self.managedObjectContext, tableView: self.tableView)
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        do {
            try fetchedResultController.performFetch()
        }catch{
            print("Error Fetching Item Objects:\(error.localizedDescription)")
        }
       
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    func configureViewData()
    {
        guard let contact = contact else{return}
        imageLabel.image = #imageLiteral(resourceName: "icons8-home.png")
        fullNameLabel.text = "\(String(describing: contact.firstName!)) \(contact.lastName!)"
        phoneNumber.text = contact.phoneNumber
        emailLabel.text = contact.email
        streetLabel.text = contact.streetAddress
        cityLabel.text = contact.city
        stateLabel.text = contact.state
        zipLabel.text = contact.zip
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func edit(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "UpdateViewController") as! UpdateViewController
        secondViewController.contact = contact; self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    

}
