//
//  SearchMoviesViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 7/4/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

class SearchMoviesViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
