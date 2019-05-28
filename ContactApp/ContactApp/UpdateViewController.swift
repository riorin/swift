//
//  UpdateViewController.swift
//  ContactApp
//
//  Created by Sachin on 11/05/18.
//  Copyright © 2018 Sachin. All rights reserved.
//

import UIKit
import CoreData

class UpdateViewController: UIViewController {
   var contact : ContactDBC?
    var managedObjectContext : NSManagedObjectContext!
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
   var context : NSManagedObjectContext!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var cityTextLabel: UITextField!
    @IBOutlet weak var stateTextLabel: UITextField!
    @IBOutlet weak var zipTextLabel: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let contact = contact {
            print("COntact==========\(String(describing: contact.firstName))")
            firstNameTextField.text = contact.firstName
            lastNameTextField.text = contact.lastName
            phoneNumberTextField.text = contact.phoneNumber
            emailTextField.text = contact.email
            streetTextField.text = contact.streetAddress
            cityTextLabel.text = contact.city
            stateTextLabel.text = contact.state
            zipTextLabel.text = contact.zip
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(_ sender: Any) {
        if let contact = contact, let newFirstName = firstNameTextField.text, let newLastName = lastNameTextField.text,let newPhoneNumber = phoneNumberTextField.text, let newEmail = emailTextField.text, let newStreet = streetTextField.text, let newCity = cityTextLabel.text, let newState = stateTextLabel.text, let newZip = zipTextLabel.text  {
            print("Contact Data is Printed in UpdateVC")
            print(contact)
            print(contact)
            print("++++++++++++++++++++++++++")
            contact.setValue(newFirstName, forKey: "firstName")
            contact.setValue(newLastName, forKey: "lastName")
            contact.setValue(newPhoneNumber, forKey: "phoneNumber")
            contact.setValue(newEmail, forKey: "email")
            contact.setValue(newStreet, forKey: "streetAddress")
            contact.setValue(newCity, forKey: "city")
            contact.setValue(newState, forKey: "state")
            contact.setValue(newZip, forKey: "zip")
            print("\(contact.email)")
            
            print(contact)
        managedContext.saveChanges()
           //context.saveChanges()

            navigationController?.popViewController(animated: true)
       }
    
        
       
    }
    
    @IBAction func cancel(_ sender: Any) {
       navigationController?.popViewController(animated: true)
    }

    
    

}
