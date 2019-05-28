//
//  ContactDB+CoreDataProperties.swift
//  ContactApp
//
//  Created by Sachin on 10/05/18.
//  Copyright © 2018 Sachin. All rights reserved.
//
//

import Foundation
import CoreData


extension ContactDBC {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactDBC> {
        let request = NSFetchRequest<ContactDBC>(entityName: "ContactDBC")
        request.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        return request
    }

    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var email: String?
    @NSManaged public var streetAddress: String?
    @NSManaged public var city: String?
    @NSManaged public var state: String?
    @NSManaged public var zip: String?
   

}
