//
//  TodoFetchedResultsController.swift
//  ContactApp
//
//  Created by Sachin on 11/05/18.
//  Copyright © 2018 Sachin. All rights reserved.
//

import UIKit
import CoreData
class TodoFetchedResultsController : NSFetchedResultsController<ContactDBC>,NSFetchedResultsControllerDelegate{
    private let tableView: UITableView
    init(managedObjectContex : NSManagedObjectContext, tableView : UITableView){
        self.tableView = tableView
        super.init(fetchRequest: ContactDBC.fetchRequest(), managedObjectContext: managedObjectContex, sectionNameKeyPath: nil, cacheName: nil)
        
        self.delegate = self
    }
    
    //MARK :- TO FETCH AND LOAD DATA      similar written in TodoListController
        func tryFetch(){
            do{
                try performFetch()
            }catch{
                print("Unresolved Error : \(error.localizedDescription)")
            }
        }
    
//    MARK:- Fetched Result Control Delegate
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            tableView.reloadData()
        }
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//
//        switch type {
//        case .insert:
//            guard let newIndexPath = newIndexPath else { return }
//            tableView.insertRows(at: [newIndexPath], with: .automatic)
//                    case .delete:
//            guard let indexPath = indexPath else { return }
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        case .update, .move:
//            guard let indexPath = indexPath else { return }
//            tableView.reloadRows(at: [indexPath], with: .automatic)
//        }
//    }
//
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
//    }
}
