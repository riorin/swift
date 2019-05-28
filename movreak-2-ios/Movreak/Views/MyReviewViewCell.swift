//
//  MyReviewViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 3/3/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

protocol MyReviewViewCellDelegate {
    func myReviewViewCellLikeButtonTapped(cell: MyReviewViewCell)
    func myReviewViewCellCommentButtonTapped(cell: MyReviewViewCell)
    func myReviewViewCellFlagButtonTapped(cell: MyReviewViewCell)
    func myReviewViewCellDeleteButtonTapped(cell: MyReviewViewCell)
    func myReviewViewCellMovieButtonTapped(cell: MyReviewViewCell)
    func myReviewViewCellUserButtonTapped(cell: MyReviewViewCell)
}

class MyReviewViewCell: UICollectionViewCell {
    
    var delegate: MyReviewViewCellDelegate?
    
    @IBOutlet weak var userReviewView: UIView!
    @IBOutlet weak var userReviewViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var userReviewViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var userReviewViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var userReviewViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieSubtitleLabel: UILabel!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userTitleLabel: UILabel!
    @IBOutlet weak var userSubtitleLabel: UILabel!
    
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var thumbsLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var flagButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var likesCommentsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupViews()
    }
    
    // MARK: - Helpers
    
    func setupViews() {
        
        movieImageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        movieImageView.layer.borderWidth = 0.5
        
        userReviewView.layer.cornerRadius = 4.0
        userReviewView.layer.masksToBounds = true
        
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.layer.masksToBounds = true
        userImageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        userImageView.layer.borderWidth = 0.5
    }
    
    // MARK: - Actions
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.myReviewViewCellLikeButtonTapped(cell: self)
        }
    }
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.myReviewViewCellCommentButtonTapped(cell: self)
        }
    }
    
    @IBAction func flagButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.myReviewViewCellFlagButtonTapped(cell: self)
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.myReviewViewCellDeleteButtonTapped(cell: self)
        }
    }
    
    @IBAction func movieButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.myReviewViewCellMovieButtonTapped(cell: self)
        }
    }
    
    @IBAction func userButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.myReviewViewCellUserButtonTapped(cell: self)
        }
    }

}
