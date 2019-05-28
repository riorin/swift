//
//  LoginViewController.swift
//  LoginDemo
//
//  Created by Bayu Yasaputro on 02/04/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        login()
    }
    
    @IBAction func forgotButtonTapped(_ sender: UIButton) {
        
        showForgotViewController(with: emailTextField.text)
//        showRegisterViewController()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        if segue.identifier == "showForgot" {
//            let vc = segue.destination as! ForgotViewController
//            vc.email = emailTextField.text
//        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loginButton.layer.cornerRadius = 6
        loginButton.layer.masksToBounds = true
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        observeKeyboard(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        observeKeyboard(false)
    }
    
    // MARK: - Helpers
    
    func observeKeyboard(_ enabled: Bool) {
        
        if enabled {
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboard(_:)), name: .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboard(_:)), name: .UIKeyboardWillHide, object: nil)
        }
        else {
            
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        }
    }
    
    @objc func handleKeyboard(_ sender: Notification) {
        
            if let userInfo = sender.userInfo {
                if let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                    
                    let height = UIScreen.main.bounds.height - frame.cgRectValue.minY
                    scrollViewBottomConstraint.constant = height
                    
                    var duration = 0.25
                    if let d = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double {
                        duration = d
                    }
                    
                    UIView.animate(withDuration: duration) {
                        self.view.layoutIfNeeded()
                    }
                }
            }
    }
    
    func login() {
        view.endEditing(true)
        
        guard let email = emailTextField.text, email == "bayu@dycode.com",
            let password = passwordTextField.text, password == "a" else {
                
                let alert = UIAlertController (title: "Error", message: "Invalid email or password", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                present(alert, animated: true, completion: nil)
                
                return
        }
        
        UserDefaults.standard.setValue(email, forKey: "kEmailKey")
        UserDefaults.standard.synchronize()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showMainViewController()
    }

    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
            
        case passwordTextField:
            login()
            
        default:
            break
        }
        
        return false
    }
}
