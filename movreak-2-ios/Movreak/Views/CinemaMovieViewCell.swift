//
//  CinemaMovieViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 1/26/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

protocol CinemaMovieViewCellDelegate {
    func cinemaMovieViewCellMovieButtonTapped(cell: CinemaMovieViewCell)
}

class CinemaMovieViewCell: UITableViewCell {
    var delegate: CinemaMovieViewCellDelegate?
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
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
        collectionView.register(UINib(nibName: "ShowTimeViewCell", bundle: nil), forCellWithReuseIdentifier: "ShowTimeCellId")
        posterImageView.layer.borderColor = UIColor.darkGray.cgColor
        posterImageView.layer.borderWidth = 0.5
    }

    @IBAction func movieButtonTapped(_ sender: UIButton) {
        delegate?.cinemaMovieViewCellMovieButtonTapped(cell: self)
    }
}
