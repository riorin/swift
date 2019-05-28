//
//  RegisterViewController.swift
//  LoginDemo
//
//  Created by Bayu Yasaputro on 03/04/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

// MARK: - UIViewController
extension UIViewController {
    
    func showRegisterViewController() {
        
        let storyboard = UIStoryboard(name: "Register", bundle: nil)
        let nc = storyboard.instantiateViewController(withIdentifier: "rootRegister") as! UINavigationController
        let vc = nc.viewControllers.first as! RegisterViewController
        
        present(nc, animated: true, completion: nil)
    }
}
