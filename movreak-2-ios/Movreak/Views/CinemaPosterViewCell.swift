//
//  CinemaPosterViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 1/26/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

protocol CinemaPosterViewCellDelegate {
    func cinemaPosterViewCellDirectionButtonTapped(cell: CinemaPosterViewCell)
}

class CinemaPosterViewCell: UITableViewCell {
    var delegate: CinemaPosterViewCellDelegate?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cineplexLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var directionButton: UIButton!
    
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
        directionButton.centerLabelVertically()
    }
    
    // MARK: - Actions
    
    @IBAction func directionButtonTapped(_ sender: UIButton) {
        
        if let delegate = delegate {
            delegate.cinemaPosterViewCellDirectionButtonTapped(cell: self)
        }
    }
}
