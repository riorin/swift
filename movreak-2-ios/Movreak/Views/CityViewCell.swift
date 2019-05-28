//
//  CityViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 10/19/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit

class CityViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selectedIndicatorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        selectedIndicatorLabel.isHidden = !selected
    }
}
