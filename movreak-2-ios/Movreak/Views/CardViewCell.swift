//
//  CardViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 1/11/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

protocol CardViewCellDelegate {
    func cardViewCellAddButtonTapped(cell: CardViewCell)
}

class CardViewCell: UITableViewCell {
    var delegate: CardViewCellDelegate?
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Actions
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        
        if let delegate = delegate {
            delegate.cardViewCellAddButtonTapped(cell: self)
        }
    }
}
