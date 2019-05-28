//
//  ContactListViewController.swift
//  ContactApp
//
//  Created by Sachin on 10/05/18.
//  Copyright © 2018 Sachin. All rights reserved.
//

import UIKit
import CoreData

class ContactListViewController: UITableViewController {

   
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
        tableView.reloadData()

    }
   
    override func viewDidLoad() {
        do {
            try fetchedResultController.performFetch()
        }catch{
            print("Error Fetching Item Objects:\(error.localizedDescription)")
        }
        self.managedObjectContext.saveChanges()
        tableView.reloadData()
        super.viewDidLoad()
        
        
        do {
            try fetchedResultController.performFetch()
        }catch{
            print("Error Fetching Item Objects:\(error.localizedDescription)")
        }
        self.managedObjectContext.saveChanges()

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       var tapped = indexPath.row
        print("Tapped +++ \(tapped)")
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let section = fetchedResultController.sections?[section] else {return 0}
        return section.numberOfObjects
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = fetchedResultController.object(at: indexPath)
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as? ContactListCell else{fatalError()}
            cell.nameLabel.text = ("\(contact.firstName!) \(contact.lastName!)")
            cell.cityLabel.text = contact.city!
            cell.contactImageLabel.image = #imageLiteral(resourceName: "icons8-home.png")
                // Configure the cell...
        
        return cell
    }
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//
//        if editingStyle == .delete {
//
//            let contact = fetchedResultController.object(at: indexPath)
//            managedObjectContext.delete(contact)
//            managedObjectContext.saveChanges()
//        } else if editingStyle == .insert {
//            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "UpdateViewController") as! UpdateViewController
//            self.navigationController?.pushViewController(secondViewController, animated: true)
//        }
//    }
    
//    private func ConfigureCell(_ cell:UITableViewCell , at indexPath : IndexPath) -> UITableViewCell{
//        let contact = fetchedResultController.object(at: indexPath)
//        cell.textLabel?.text = ("\(contact.firstName!) \(contact.lastName!)")
//        cell.detailTextLabel?.text = contact.email
//
//        return cell
//    }
    
    //MARK :- UI DELEGATE
//    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .delete
//
//    }
   
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let more = UITableViewRowAction(style: .normal, title: "Update", handler: { action , indexPath in
            
            print("IN UPDATE CONTACT  \(indexPath.row)")
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let contact = self.fetchedResultController.object(at: indexPath)
                
                guard let updateViewController = self.navigationController?.topViewController as? UpdateViewController
                    else{return}
                
                updateViewController.contact = contact
              
            }
            
            
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "UpdateViewController") as! UpdateViewController
//            if let indexPath = tableView.indexPathForSelectedRow{
//                let contact = self.fetchedResultController.object(at: indexPath)
//                let updateViewController = self.navigationController?.topViewController as? UpdateViewController
//                updateViewController?.contact = contact
//            }
             let contact1 = self.fetchedResultController.object(at: indexPath)
            secondViewController.contact = contact1; self.navigationController?.pushViewController(secondViewController, animated: true)
            
        })
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete", handler: { action , indexPath in
            print("Delete Click SuccessFully")
            let contact = self.fetchedResultController.object(at: indexPath)
            self.managedObjectContext.delete(contact)
            self.managedObjectContext.saveChanges()
        })
        
        return [more,delete]
    }
   
    //Mark :- Navigation Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showContactDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let contact = fetchedResultController.object(at: indexPath)
                
                guard let navigationController = segue.destination as? UINavigationController, let contactDetailsController = navigationController.topViewController as? ContactDetailsViewController
                    else{return}
                
                contactDetailsController.contact = contact
//                contactDetailsController.delegate = self
            }
        }
    }

}
