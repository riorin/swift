//
//  UIViewControllerExtensions.swift
//  DemoApp
//
//  Created by danixsofyan on 27/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UIKit

extension UIViewController{
    
    @IBAction func backButtonTapped(_ sender: Any){
        navigationController?.popViewController(animated: true)
    }
}
