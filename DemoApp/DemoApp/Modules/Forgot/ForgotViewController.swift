//
//  ForgotViewController.swift
//  DemoApp
//
//  Created by Bayu Yasaputro on 26/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UIKit

class ForgotViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    
    var email: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTextfield.text = email
    }

    
    @IBAction func resetButtonTaped(_ sender: UIButton) {
        
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

extension UIViewController{
    
    func showForgetViewController(eith email: String?){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "forgot") as! ForgotViewController
        viewController.email = email
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
}
