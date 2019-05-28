//
//  MovieTableViewCell.swift
//  TableViewDemo
//
//  Created by Bayu Yasaputro on 28/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UIKit

protocol MovieTableViewCellDelegate {
    func movieTableViewCellReviewButtonTapped(cell: MovieTableViewCell)
}

class MovieTableViewCell: UITableViewCell {
    var delegate: MovieTableViewCellDelegate?
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func reviewButtonTapped(_ sender: UIButton) {
        delegate?.movieTableViewCellReviewButtonTapped(cell: self)
    }
}
