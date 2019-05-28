//
//  SearchMovieResultViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 7/5/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

protocol SearchMovieResultViewCellDelegate {
    
    func searchMovieResultViewCellDetailButtonTapped(cell: SearchMovieResultViewCell)
}

class SearchMovieResultViewCell: UITableViewCell {
    var delegate: SearchMovieResultViewCellDelegate?
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    
    
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
    }
    
    @IBAction func detailButtonTapped(_ sender: UIButton) {
        delegate?.searchMovieResultViewCellDetailButtonTapped(cell: self)
    }
}
