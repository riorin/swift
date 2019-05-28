//
//  NewsViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 9/15/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit

protocol NewsViewCellDelegate {
    func newsViewCellShareButtonTapped(cell: NewsViewCell)
}

class NewsViewCell: UICollectionViewCell {
    var delegate: NewsViewCellDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    // MARK: - Helpers
    
    func setupViews() {
        
        layer.cornerRadius = 4.0
        layer.masksToBounds = true
        
//        shareButton.setImage(shareButton.currentImage?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    // MARK: - Actions
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        
        if let delegate = delegate {
            delegate.newsViewCellShareButtonTapped(cell: self)
        }
    }
}
