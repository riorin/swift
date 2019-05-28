//
//  ProfileCollectionViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 3/3/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

protocol ProfileViewCellDelegate {
    func profileViewCellEditButtonTapped(cell: ProfileViewCell)
}

class ProfileViewCell: UICollectionViewCell {
    var delegate: ProfileViewCellDelegate?
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var watchedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupViews()
    }
    
    // MARK: - Helpers
    
    func setupViews() {
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.layer.masksToBounds = true
        
        editButton.layer.cornerRadius = 4
        editButton.layer.masksToBounds = true
        editButton.layer.borderColor = UIColor.white.cgColor
        editButton.layer.borderWidth = 1.0
    }
    
    // MARK: - Actions
    
    @IBAction func editButtonTapped(sender: UIButton) {
        if let delegate = delegate {
            delegate.profileViewCellEditButtonTapped(cell: self)
        }
    }
}
