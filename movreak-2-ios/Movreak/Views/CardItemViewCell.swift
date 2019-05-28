//
//  CardItemViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 5/27/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

enum CardItemType {
    case movie
    case movieList
    case news
    case review
    case theater
    case trailer
}

class CardItemViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var movieLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            let view = UIView(frame: imageView.bounds)
            view.tag = 101
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.backgroundColor = UIColor(white: 0, alpha: 0.5)
            imageView.addSubview(view)
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var subtitleLabelBottomConstraint: NSLayoutConstraint!
    
    var type: CardItemType = .movie {
        didSet {
            
            imageView.viewWithTag(101)?.isHidden = false
            subtitleLabelBottomConstraint.constant = 30
            profileImageView.isHidden = true
            nameLabel.isHidden = true
            movieLabel.isHidden = true
            reviewLabel.isHidden = true
            
            switch type {
                
            case .movie:
                imageView.viewWithTag(101)?.isHidden = true

            case .movieList:
                subtitleLabelBottomConstraint.constant = 15
                
            case .review:
                profileImageView.isHidden = false
                nameLabel.isHidden = false
                movieLabel.isHidden = false
                reviewLabel.isHidden = false
                
            default:
                break
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupViews()
    }

    func setupViews() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 2.0
    }
}
