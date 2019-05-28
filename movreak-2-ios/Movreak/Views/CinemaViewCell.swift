//
//  CinemaViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 1/24/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

class CinemaViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ratingContainerView: UIView!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var cineplexLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    // MARK: - Helpers
    
    func setupViews() {
        
        layer.cornerRadius = 4.0
        layer.masksToBounds = true
        
        ratingContainerView.layer.cornerRadius = 4.0
        ratingContainerView.layer.masksToBounds = true
    }
    
}
