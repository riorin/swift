//
//  UserReviewViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 2/1/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

protocol UserReviewViewCellDelegate {
    func userReviewViewCellLikeButtonTapped(cell: UserReviewViewCell)
    func userReviewViewCellCommentButtonTapped(cell: UserReviewViewCell)
    func userReviewViewCellFlagButtonTapped(cell: UserReviewViewCell)
    func userReviewViewCellDeleteButtonTapped(cell: UserReviewViewCell)
    func userReviewViewCellMovieButtonTapped(cell: UserReviewViewCell)
    func userReviewViewCellUserButtonTapped(cell: UserReviewViewCell)
}

class UserReviewViewCell: UITableViewCell {
    var delegate: UserReviewViewCellDelegate?
    
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
            delegate.userReviewViewCellLikeButtonTapped(cell: self)
        }
    }
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.userReviewViewCellCommentButtonTapped(cell: self)
        }
    }
    
    @IBAction func flagButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.userReviewViewCellFlagButtonTapped(cell: self)
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.userReviewViewCellDeleteButtonTapped(cell: self)
        }
    }
    
    @IBAction func movieButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.userReviewViewCellMovieButtonTapped(cell: self)
        }
    }
    
    @IBAction func userButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.userReviewViewCellUserButtonTapped(cell: self)
        }
    }
}
