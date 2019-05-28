//
//  EditProfileHeaderView.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 3/17/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

protocol EditProfileHeaderViewDelegate {
    
    func editProfileHeaderViewEditCoverButtonTapped(view: EditProfileHeaderView)
    func editProfileHeaderViewEditPhotoButtonTapped(view: EditProfileHeaderView)
}

class EditProfileHeaderView: GSKStretchyHeaderView {
    var delegate: EditProfileHeaderViewDelegate?
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var coverImageButton: UIButton!
    @IBOutlet weak var coverLoadingView: UIActivityIndicatorView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var profileLoadingView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    override func contentViewDidLayoutSubviews() {
        super.contentViewDidLayoutSubviews()
    }
    
    override func didChangeStretchFactor(_ stretchFactor: CGFloat) {
        super.didChangeStretchFactor(stretchFactor)
        
        let initialCoverHeight = UIScreen.main.bounds.width / kGoldenRation
        var profileImageSizeFactor = CGFloatTranslateRange(coverImageView.frame.height, 64, initialCoverHeight, 0, 1)
        profileImageSizeFactor = min(1, max(0, profileImageSizeFactor))
        let profileImageEdge = CGFloatInterpolate(profileImageSizeFactor, 44, 88)
        
        profileImageViewWidthConstraint.constant = profileImageEdge
        profileImageViewHeightConstraint.constant = profileImageEdge
        profileView.layer.cornerRadius = profileImageEdge / 2
        profileView.layer.borderColor = UIColor.white.cgColor
        profileView.layer.borderWidth = 2
        
        layoutIfNeeded()
    }
    
    // MARK: - Helpers
    
    func setupViews() {
        
        minimumContentHeight = 0
        maximumContentHeight = (UIScreen.main.bounds.width / kGoldenRation) + 75
        
        profileView.layer.cornerRadius = profileImageView.frame.width / 2
        profileView.layer.masksToBounds = true
    }
    
    // MARK: - Actions
    
    @IBAction func editCoverButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.editProfileHeaderViewEditCoverButtonTapped(view: self)
        }
    }
    
    @IBAction func editPhotoButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.editProfileHeaderViewEditPhotoButtonTapped(view: self)
        }
    }
}
