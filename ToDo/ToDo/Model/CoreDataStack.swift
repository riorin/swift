//
//  CoreDataStack.swift
//  ToDo
//
//  Created by Rio Rinaldi on 30/10/18.
//  Copyright © 2018 Rio Rinaldi. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    var container: NSPersistentContainer {
        let container = NSPersistentContainer(name: "Todos")
        container.loadPersistentStores { (description, error) in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
        }
        
        return container
    }
    var managedContext: NSManagedObjectContext {
        return container.viewContext
    }
    
}



