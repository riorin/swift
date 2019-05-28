//
//  ProfileSocmedViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 2/8/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

protocol ProfileSocmedViewCellDelegate {
    func profileSocmedViewCellSwitchButtonTapped(cell: ProfileSocmedViewCell)
}

class ProfileSocmedViewCell: UITableViewCell {
    var delegate: ProfileSocmedViewCellDelegate?
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var separatorViewLeadingConstraint: NSLayoutConstraint!
    
    var isConnected: Bool = false {
        didSet {
            if isConnected {
                switchButton.setImage(UIImage(named: "icn_switch_on"), for: .normal)
            }
            else {
                switchButton.setImage(UIImage(named: "icn_switch_off"), for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func switchButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.profileSocmedViewCellSwitchButtonTapped(cell: self)
        }
    }
}
