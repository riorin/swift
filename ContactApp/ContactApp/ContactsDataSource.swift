//
//  ContactsDataSource.swift
//  ContactApp
//
//  Created by Sachin on 11/05/18.
//  Copyright © 2018 Sachin. All rights reserved.
//

import Foundation
import UIKit
class ContactsDataSource : NSObject,UITableViewDataSource{
    private var sectionedData : [[ContactDBC]]
    var sectionedTitles : [String]
    
    init(sectionedData :[[ContactDBC]], sectionedTitles : [String])
    {
        self.sectionedData = sectionedData
        self.sectionedTitles = sectionedTitles
        super.init()
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionedTitles[section]
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionedTitles
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionedData.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionedData[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let contactCell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as? ContactListCell else{fatalError()}
        let contact = sectionedData[indexPath.section][indexPath.row]
        //        cell.textLabel?.text = contact.firstName
        //        cell.imageView?.image = contact.image
        //        cell.detailTextLabel?.text = contact.lastName
        contactCell.nameLabel.text = "\(contact.firstName!) \(contact.lastName!)"
//        contactCell.contactImageLabel?.image = contact.image
        contactCell.cityLabel?.text = contact.city
//       if contact.isFavorite {
//            contactCell.favouriteLabel.image = #imageLiteral(resourceName: "star.png")
//        } else {
//            contactCell.favouriteLabel.image = nil
//        }
        return contactCell
        
    }
    
    //MARk:- Helper Methods
    
    func object(at indexPath : IndexPath) -> ContactDBC{
        return sectionedData[indexPath.section][indexPath.row]
    }
    
    func indexPath(for contact: ContactDBC) -> IndexPath? {
        for (index, contacts) in sectionedData.enumerated(){
            if let indexOfContact = contacts.index(of: contact) {
                return IndexPath(row: indexOfContact, section: index)
                
            }
        }
        return nil
    }
    func updateContact(_ contact:ContactDBC, at indexPath : IndexPath){
        sectionedData[indexPath.section][indexPath.row] = contact
    }
    
}
