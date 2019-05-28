//
//  TrailerViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 1/3/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

protocol TrailerViewCellDelegate {
    func trailerViewCellPlayButtonTapped(cell: TrailerViewCell)
}

class TrailerViewCell: UITableViewCell {
    
    var delegate: TrailerViewCellDelegate?

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
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
        
        webView.scrollView.isScrollEnabled = false
        webView.allowsInlineMediaPlayback = false
        webView.mediaPlaybackRequiresUserAction = false
        
        playButton.layer.cornerRadius = playButton.frame.width / 2
        playButton.layer.masksToBounds = true
    }
    
    // MARK: - Actions
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        
        if let delegate = delegate {
            delegate.trailerViewCellPlayButtonTapped(cell: self)
        }
    }
    
}
