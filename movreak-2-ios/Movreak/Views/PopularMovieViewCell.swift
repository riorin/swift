//
//  PopularMovieViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 6/14/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

class PopularMovieViewCell: UITableViewCell {

    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var watchedLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupViews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupViews() {
        
        movieImageView.layer.borderColor = UIColor.darkGray.cgColor
        movieImageView.layer.borderWidth = 0.5
        
        scoreLabel.layer.borderColor = UIColor.darkGray.cgColor
        scoreLabel.layer.borderWidth = 0.5
        
        watchedLabel.layer.borderColor = UIColor.darkGray.cgColor
        watchedLabel.layer.borderWidth = 0.5
    }
}
