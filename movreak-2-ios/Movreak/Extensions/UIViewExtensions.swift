//
//  UIViewExtensions.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 10/20/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit


let wiggleBounceY = 2.0
let wiggleBounceDuration = 0.12
let wiggleBounceDurationVariance = 0.025

let wiggleRotateAngle = 0.02
let wiggleRotateDuration = 0.10
let wiggleRotateDurationVariance = 0.025

extension UIView {
    
    var collectionViewCell: UICollectionViewCell? {
        
        if superview != nil {
            if let view = self.superview as? UICollectionViewCell {
                return view
            }
            else {
                return superview?.collectionViewCell
            }
        }
        return nil
    }
    
    var tableViewCell: UITableViewCell? {
        
        if superview != nil {
            if let view = superview as? UITableViewCell {
                return view
            }
            else {
                return superview?.tableViewCell
            }
        }
        return nil
    }
}
