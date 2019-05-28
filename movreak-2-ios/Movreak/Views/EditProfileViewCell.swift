//
//  EditProfileViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 2/8/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

protocol EditProfileViewCellDelegate {
    func editProfileViewCellChangeCoverButtonTapped(cell: EditProfileViewCell)
    func editProfileViewCellChangePhotoButtonTapped(cell: EditProfileViewCell)
}

class EditProfileViewCell: UITableViewCell {
    var delegate: EditProfileViewCellDelegate?
    
    @IBOutlet weak var changeCoverButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var separatorViewLeadingConstraint: NSLayoutConstraint!
    
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
        
        photoImageView.layer.cornerRadius = photoImageView.frame.width / 2
        photoImageView.layer.masksToBounds = true
    }
    
    // MARK: - Actions
    
    @IBAction func changeCoverButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.editProfileViewCellChangeCoverButtonTapped(cell: self)
        }
    }
    
    @IBAction func changePhotoButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.editProfileViewCellChangePhotoButtonTapped(cell: self)
        }
    }
}
