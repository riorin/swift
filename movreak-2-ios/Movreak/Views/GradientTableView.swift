//
//  GradientTableView.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 4/20/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

class GradientTableView: UITableView {
    
    override open class var layerClass: AnyClass {
        get {
            return CAGradientLayer.classForCoder()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if let gradientLayer = layer as? CAGradientLayer {
            gradientLayer.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        }
    }
}
