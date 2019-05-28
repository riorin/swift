//
//  ShowTimesViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 10/20/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit

class ShowTimesViewCell: UITableViewCell {
    
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(UINib(nibName: "ShowTimeViewCell", bundle: nil), forCellWithReuseIdentifier: "ShowTimeCellId")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
