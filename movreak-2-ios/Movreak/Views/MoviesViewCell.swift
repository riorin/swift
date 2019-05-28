//
//  MoviesViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 10/26/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit

protocol MoviesViewCellDelegate {
    func MoviesViewCellSeeAllButtonTapped(cell: MoviesViewCell)
}

class MoviesViewCell: UITableViewCell {
    var delegate: MoviesViewCellDelegate?

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var seeAllButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(UINib(nibName: "PosterViewCell", bundle: nil), forCellWithReuseIdentifier: "PosterCellId")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func seeAllButtonTapped(_ sender: UIButton) {
        
        if let delegate = delegate {
            delegate.MoviesViewCellSeeAllButtonTapped(cell: self)
        }
    }
}
