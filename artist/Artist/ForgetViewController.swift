//
//  ForgetViewController.swift
//  Artist
//
//  Created by Rio Rinaldi on 17/07/18.
//  Copyright © 2018 Rio Rinaldi. All rights reserved.
//

import UIKit

class ForgetViewController: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailText.text = email

        
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
