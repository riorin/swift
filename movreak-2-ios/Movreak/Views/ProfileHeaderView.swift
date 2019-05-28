//
//  ProfileHeaderView.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 3/15/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

protocol ProfileHeaderViewDelegate {
    func profileHeaderViewEditButtonTapped(view: ProfileHeaderView)
}

class ProfileHeaderView: GSKStretchyHeaderView {
    var delegate: ProfileHeaderViewDelegate?
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var coverImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var watchedLabel: UILabel!
    @IBOutlet weak var tabBarContainerView: UIView!
    @IBOutlet weak var tabBarBackgroundView: UIView!
    @IBOutlet weak var tabBarView: CMTabbarView!
    @IBOutlet weak var separatorView: UIView!
    
    var isCoverImageViewOnTop: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    override func contentViewDidLayoutSubviews() {
        super.contentViewDidLayoutSubviews()
        
        if isCoverImageViewOnTop {
            if profileImageView.frame.origin.y > 64 {
                isCoverImageViewOnTop = false
                contentView.sendSubview(toBack: coverImageView)
            }
        }
        else {
            if coverImageView.frame.height <= 64 {
                isCoverImageViewOnTop = true
                contentView.bringSubview(toFront: coverImageView)
                contentView.bringSubview(toFront: editButton)
            }
        }
    }
    
    override func didChangeStretchFactor(_ stretchFactor: CGFloat) {
        super.didChangeStretchFactor(stretchFactor)
        
        let coverImageViewHeight = max(64, frame.height - 197)
        let initialCoverHeight = UIScreen.main.bounds.width / kGoldenRation
        var profileImageSizeFactor = CGFloatTranslateRange(coverImageViewHeight, 64, initialCoverHeight, 0, 1)
        profileImageSizeFactor = min(1, max(0, profileImageSizeFactor))
        let profileImageEdge = CGFloatInterpolate(profileImageSizeFactor, 44, 88)
        
        coverImageViewHeightConstraint.constant = coverImageViewHeight
            
        profileImageViewWidthConstraint.constant = profileImageEdge
        profileImageViewHeightConstraint.constant = profileImageEdge
        profileImageView.layer.cornerRadius = profileImageEdge / 2
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 2
        
        layoutIfNeeded()
    }
    
    func setupViews() {
        
        backgroundColor = UIColor.clear
        
        minimumContentHeight = 114
        maximumContentHeight = (UIScreen.main.bounds.width / kGoldenRation) + 197
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.layer.masksToBounds = true
        
        editButton.layer.cornerRadius = 4
        editButton.layer.masksToBounds = true
        editButton.layer.borderColor = UIColor.white.cgColor
        editButton.layer.borderWidth = 0.5
        
        tabBarView.backgroundColor = UIColor.clear
        tabBarView.indicatorAttributes = [
            CMTabIndicatorViewHeight: 2,
            CMTabIndicatorColor: RGB(0, 122, 255),
            CMTabBoxBackgroundColor: UIColor.clear
        ]
        tabBarView.normalAttributes = [
            NSForegroundColorAttributeName: UIColor.black,
            NSFontAttributeName: kCoreSans17Font,
            NSBackgroundColorAttributeName: UIColor.clear
        ]
        tabBarView.selectedAttributes = [
            NSForegroundColorAttributeName: RGB(0, 122, 255),
            NSFontAttributeName: kCoreSans17Font,
            NSBackgroundColorAttributeName: UIColor.clear
        ]
        tabBarView.tabPadding = 0
        tabBarView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tabBarView.selectionType = .indicator
        tabBarView.scrollEnable = true
    }
    
    // MARK: - Actions
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.profileHeaderViewEditButtonTapped(view: self)
        }
    }
}

