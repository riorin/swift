//
//  RatingView.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 11/18/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit

class RatingView: UIView {

    var fullStarImage: UIImage {
        return UIImage(named: "icn_star_full")!
    }
    var halfStarImage: UIImage {
        return UIImage(named: "icn_star_half")!
    }
    var emptyStarImage: UIImage {
        return UIImage(named: "icn_star_empty")!
    }
    
    var star1ImageView: UIImageView {
        return viewWithTag(101) as! UIImageView
    }
    var star2ImageView: UIImageView {
        return viewWithTag(102) as! UIImageView
    }
    var star3ImageView: UIImageView {
        return viewWithTag(103) as! UIImageView
    }
    var star4ImageView: UIImageView {
        return viewWithTag(104) as! UIImageView
    }
    var star5ImageView: UIImageView {
        return viewWithTag(105) as! UIImageView
    }
    
    var rating: Double = 0.0 {
        didSet {
            
            star1ImageView.image = emptyStarImage
            star2ImageView.image = emptyStarImage
            star3ImageView.image = emptyStarImage
            star4ImageView.image = emptyStarImage
            star5ImageView.image = emptyStarImage
            
            if rating > 0 {
                if rating < 1 { star1ImageView.image = halfStarImage }
                else { star1ImageView.image = fullStarImage }
            }
            if rating > 1 {
                if rating < 2 { star2ImageView.image = halfStarImage }
                else { star2ImageView.image = fullStarImage }
            }
            if rating > 2 {
                if rating < 3 { star3ImageView.image = halfStarImage }
                else { star3ImageView.image = fullStarImage }
            }
            if rating > 3 {
                if rating < 4 { star4ImageView.image = halfStarImage }
                else { star4ImageView.image = fullStarImage }
            }
            if rating > 4 {
                if rating < 5 { star5ImageView.image = halfStarImage }
                else { star5ImageView.image = fullStarImage }
            }
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
