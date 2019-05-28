//
//  ContactDetailViewController.swift
//  ContactApp
//
//  Created by Sachin on 10/05/18.
//  Copyright © 2018 Sachin. All rights reserved.
//

import UIKit
import CoreData

class ContactDetailViewController: UITableViewController {
    
    var contact : ContactDBC?
    var context : NSManagedObjectContext!
  
    
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var zipCodeLabel: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
 //   weak var delegate : ContactDetailViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
       
        configureViewData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func configureViewData()
    {
        guard let contact = contact else{return}
//        contactImage.image = contact.image
        fullNameLabel.text = "\(contact.firstName!) \(contact.lastName!)"
        print(contact)
        phoneNumberLabel.text = contact.phoneNumber!
        emailLabel.text = contact.email
        streetLabel.text = contact.streetAddress!
        cityLabel.text = contact.city!
        stateLabel.text = contact.state!
        zipCodeLabel.text = contact.zip!
    }
    
    @IBAction func markAsFavourite(_ sender: Any) {
        showToast(message: "Marked Favourite")
//        guard  let contact = contact else {
//            return
//        }
//        delegate?.didMarkedAsFavouriteContact(contact)
        
        
    }
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 0.2, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    

}
