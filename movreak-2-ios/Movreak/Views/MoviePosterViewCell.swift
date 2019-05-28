//
//  MoviePosterViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 11/18/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit

class MoviePosterViewCell: UITableViewCell {

    @IBOutlet weak var imdbIconImageView: UIImageView!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationIconImageView: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var genreIconImageView: UIImageView!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var dateIconImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton!
    
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
        
        durationIconImageView.image = durationIconImageView.image?.withRenderingMode(.alwaysTemplate)
        genreIconImageView.image = genreIconImageView.image?.withRenderingMode(.alwaysTemplate)
        dateIconImageView.image = dateIconImageView.image?.withRenderingMode(.alwaysTemplate)
        
        watchedButton.layer.cornerRadius = 4
        watchedButton.layer.masksToBounds = true
        watchedButton.layer.borderColor = UIColor.white.cgColor
        watchedButton.layer.borderWidth = 1.0
    }
}
