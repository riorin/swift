//
//  ProfileTextFieldViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 2/8/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

class ProfileTextFieldViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var separatorViewLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
