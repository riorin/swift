//
//  ViewController.swift
//  Artist
//
//  Created by Rio Rinaldi on 17/07/18.
//  Copyright © 2018 Rio Rinaldi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var PasswordText: UITextField!
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        login()
    }
    
    @IBAction func foretPasswordTapped(_ sender: UIButton) {
        let vcForget = storyboard?.instantiateViewController(withIdentifier: "forget") as! ForgetViewController
            vcForget.email = emailText.text
        navigationController?.pushViewController(vcForget, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func login() {
        view.endEditing(true)
        guard
        let email = emailText.text, email == "rio@dycode.com",
        let password = PasswordText.text, password == "a"
        else {
            let alert = UIAlertController(title: "Error", message: "Inavlid Email or Password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "home")
        navigationController?.pushViewController(vc!, animated: true)
    }


}

