//
//  todoViewController.swift
//  myApps
//
//  Created by Rio Rinaldi on 24/05/18.
//  Copyright © 2018 Rio Rinaldi. All rights reserved.
//

import UIKit
import RealmSwift

class todoViewController: UIViewController {
    
    var realm : Realm!
    
    var todoList : Results<TodoItem> {
        get {
            return realm.objects(TodoItem.self)
        }
        
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func addButton(_ sender: UIBarButtonItem) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let directory : URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
