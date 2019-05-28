//
//  ViewController.swift
//  DemoApp
//
//  Created by Bayu Yasaputro on 26/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var forgot: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet var password2TextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet var keyboardToolbar: UIToolbar!
    
    @IBAction func keyboardToolbarTapped(_ sender: UIBarButtonItem) {
    }
    
//    @IBOutlet weak var password2TopConstraint: NSLayoutConstraint!
    
    
    @IBAction func forgotaction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "forgot") as! ForgotViewController
        viewController.email = emailTextField.text
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    var isRegisterForm = true {
        didSet {
            if isRegisterForm {
                loginButton.setTitle("REGISTER", for: .normal)
                registerButton.setTitle("Have an account?", for: .normal)
                
                UIView.animate(withDuration: 0.25, animations: {
                    self.containerView.insertArrangedSubview(self.password2TextField, at: 2)
                })

            }
            else {
                loginButton.setTitle("LOGIN", for: .normal)
                registerButton.setTitle("Don't have an account?", for: .normal)
                
                UIView.animate(withDuration: 0.25, animations: {
                    self.password2TextField.removeFromSuperview()
                })
            }
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
     
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
        password2TextField.isSecureTextEntry = passwordTextField.isSecureTextEntry
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        isRegisterForm = !isRegisterForm
    }
    
    // MARK: - Keyboard
    
    @objc func handleKeyboard(_ sender: Notification){
        if let userInfo = sender.userInfo{
            if let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let height = UIScreen.main.bounds.height - keyboardFrame.cgRectValue.minY
                
                var duration = 0.25
                if let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double{ duration = animationDuration
                }
                scrollViewBottomConstraint.constant = height
                UIView.animate(withDuration: duration, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboard(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboard(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

