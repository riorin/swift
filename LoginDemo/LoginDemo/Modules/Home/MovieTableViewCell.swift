//
//  MovieTableViewCell.swift
//  LoginDemo
//
//  Created by Bayu Yasaputro on 04/04/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UIKit

protocol MovieTableViewCellDelegate {
    func movieTableViewCellReButtontapped(cell: MovieTableViewCell)
}

class MovieTableViewCell: UITableViewCell {
    var delegate: MovieTableViewCellDelegate?

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBAction func reButtonTapped(_ sender: UIButton) {
        delegate?.movieTableViewCellReButtontapped(cell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
