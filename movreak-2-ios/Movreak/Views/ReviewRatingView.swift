//
//  ReviewRatingView.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 2/23/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

class ReviewRatingView: UIView {

    var thumbsOnImage: UIImage {
        if isPositiveRating {
            return UIImage(named: "icn_review_thumbs_up")!.withRenderingMode(.alwaysOriginal)
        }
        else {
            return UIImage(named: "icn_review_thumbs_down")!.withRenderingMode(.alwaysOriginal)
        }
    }
    var thumbsOffImage: UIImage {
        if isPositiveRating {
            return UIImage(named: "icn_review_thumbs_up")!.withRenderingMode(.alwaysTemplate)
        }
        else {
            return UIImage(named: "icn_review_thumbs_down")!.withRenderingMode(.alwaysTemplate)
        }
    }
    
    var thumb1Button: UIButton {
        return viewWithTag(101) as! UIButton
    }
    var thumb2Button: UIButton {
        return viewWithTag(102) as! UIButton
    }
    var thumb3Button: UIButton {
        return viewWithTag(103) as! UIButton
    }
    var thumb4Button: UIButton {
        return viewWithTag(104) as! UIButton
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumb1Button.addTarget(self, action: #selector(ReviewRatingView.thumbButtonTapped(sender:)), for: .touchUpInside)
        thumb2Button.addTarget(self, action: #selector(ReviewRatingView.thumbButtonTapped(sender:)), for: .touchUpInside)
        thumb3Button.addTarget(self, action: #selector(ReviewRatingView.thumbButtonTapped(sender:)), for: .touchUpInside)
        thumb4Button.addTarget(self, action: #selector(ReviewRatingView.thumbButtonTapped(sender:)), for: .touchUpInside)
        
        rating = 0.0
    }
    
    var isPositiveRating: Bool = true {
        didSet {
            rating = 0.0
        }
    }
    
    var rating: Double = 0.0 {
        didSet {
            
            thumb1Button.setImage(thumbsOffImage, for: .normal)
            thumb2Button.setImage(thumbsOffImage, for: .normal)
            thumb3Button.setImage(thumbsOffImage, for: .normal)
            thumb4Button.setImage(thumbsOffImage, for: .normal)
            
            if rating > 0 {
                thumb1Button.setImage(thumbsOnImage, for: .normal)
            }
            if rating > 1 {
                thumb2Button.setImage(thumbsOnImage, for: .normal)
            }
            if rating > 2 {
                thumb3Button.setImage(thumbsOnImage, for: .normal)
            }
            if rating > 3 {
                thumb4Button.setImage(thumbsOnImage, for: .normal)
            }
        }
    }
    
    func thumbButtonTapped(sender: UIButton) {
        rating = Double(sender.tag - 100)
    }
}
