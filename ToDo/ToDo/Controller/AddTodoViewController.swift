//
//  AddTodoViewController.swift
//  ToDo
//
//  Created by Rio Rinaldi on 30/10/18.
//  Copyright © 2018 Rio Rinaldi. All rights reserved.
//

import UIKit
import CoreData

class AddTodoViewController: UIViewController {
    
    var managedContex: NSManagedObjectContext!
    var todo: Todos?

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var saveBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textView.becomeFirstResponder()
        
        if let todo = todo {
            textView.text = todo.title
            textView.text = todo.title
        }
        
    }
    
    
    
    fileprivate func didmissAndResign() {
        dismiss(animated: true)
        textView.resignFirstResponder()
    }
    
    @IBAction func saveBtn(_ sender: UIButton) {
        guard let title = textView.text, !title.isEmpty else {
            return
        }

        if let todo = self.todo {
            todo.title = title
        } else {
            todo?.title = title
            todo?.date = Date()
        }

        do {
            try managedContex.save()
            didmissAndResign()
        } catch {
            print("error saving : \(error)")
        }
        
        dismiss(animated: true)

    }
    
    @IBAction func cancel(_ sender: UIButton) {
        didmissAndResign()
    }
    
}
