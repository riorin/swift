//
//  ViewController.swift
//  hintme
//
//  Created by Rio Rinaldi on 23/12/18.
//  Copyright © 2018 Rio Rinaldi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var hint: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }
    
    
    @IBAction func hintBtn(_ sender: Any) {
        
        alert()
        
    }
    
    func alert() {
        let allert = UIAlertController.init(title: "Hai", message: "Hello World", preferredStyle: .alert)
        let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        allert.addAction(action)
        present(allert, animated: true, completion: nil)
    }
    
    
}


