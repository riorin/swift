//
//  ShowTimeViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 10/20/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit

protocol ShowTimeViewCellDelegate {
    func showTimeViewCellTimeButtontapped(cell: ShowTimeViewCell)
}

class ShowTimeViewCell: UICollectionViewCell {
    
    var delegate: ShowTimeViewCellDelegate?
    @IBOutlet weak var timeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    func setupViews() {
        timeButton.layer.cornerRadius = 4
        timeButton.layer.masksToBounds = true
    }
    
    @IBAction func timeButtonTapped(_ sender: UIButton) {
        delegate?.showTimeViewCellTimeButtontapped(cell: self)
    }
}
