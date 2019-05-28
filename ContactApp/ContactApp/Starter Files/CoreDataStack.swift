 //
//  CoreDataStack.swift
//  ContactApp
//
//  Created by Sachin on 10/05/18.
//  Copyright © 2018 Sachin. All rights reserved.
//

import Foundation
import CoreData
class CoreDataStack{
    //Registering managed object with managedobjectcontext
    lazy var managedObjectContext : NSManagedObjectContext = {
        //        let coordinator = self.persistentStoreCoordinator
        //        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        //        moc.persistentStoreCoordinator = coordinator
        //        return moc
        
        let container = self.persistentContainer
        return container.viewContext
    }()
    
  
    lazy var persistentContainer : NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ContactApp")
        container.loadPersistentStores(){storeDescription , error in
            if let error = error as NSError?{
                fatalError("Unresolved Error : \(error) \(error.userInfo)")
            }
        }
        return container
    }()
    
    
}

extension NSManagedObjectContext
{
    //To save changes
    func saveChanges(){
        if self.hasChanges{
            do {
                try save()
            }catch{
                fatalError("Error : \(error.localizedDescription)")
            }
        }
    }
}
