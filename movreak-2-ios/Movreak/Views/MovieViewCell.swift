//
//  MovieViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 8/25/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit

class MovieViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var adBadgeImageView: UIImageView!
    @IBOutlet weak var newBadgeImageView: UIImageView!
    @IBOutlet weak var featuredBadgeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    func setupViews() {
        
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        
        imageView.layer.borderColor = UIColor(white: 0.75, alpha: 0.25).cgColor
        imageView.layer.borderWidth = 1.0
    }
}
