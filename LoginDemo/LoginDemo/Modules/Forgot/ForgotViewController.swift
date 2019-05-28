//
//  ForgotViewController.swift
//  LoginDemo
//
//  Created by Bayu Yasaputro on 03/04/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UIKit

class ForgotViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTextField.text = email
    }

}

// MARK: - UIViewController
extension UIViewController {
    
    func showForgotViewController(with email: String?) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "forgot") as! ForgotViewController
        
        vc.email = email
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

