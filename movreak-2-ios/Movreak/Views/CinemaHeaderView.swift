//
//  CinemaHeaderView.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 6/19/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

protocol CinemaHeaderViewDelegate {
    func cinemaHeaderViewDirectionButtonTapped(view: CinemaHeaderView)
}

class CinemaHeaderView: GSKStretchyHeaderView {
    var delegate: CinemaHeaderViewDelegate?
    
    @IBOutlet weak var posterView: UIView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cineplexLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var directionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    // MARK: - Actions
    
    @IBAction func directionButtonTapped(_ sender: UIButton) {
        delegate?.cinemaHeaderViewDirectionButtonTapped(view: self)
    }
    
    func setupViews() {
        
        directionButton.centerLabelVertically()
        backgroundColor = UIColor.clear
        
        minimumContentHeight = 64
        maximumContentHeight = UIScreen.main.bounds.width / kGoldenRation
        
        let xEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xEffect.minimumRelativeValue = -15
        xEffect.maximumRelativeValue = 15
        
        let yEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        yEffect.minimumRelativeValue = -15
        yEffect.maximumRelativeValue = 15
        
        let effectGroup = UIMotionEffectGroup()
        effectGroup.motionEffects = [xEffect, yEffect]
        
        posterImageView.addMotionEffect(effectGroup)
    }
    
    override func didChangeStretchFactor(_ stretchFactor: CGFloat) {
        super.didChangeStretchFactor(stretchFactor)
        
    }
    
    override func contentViewDidLayoutSubviews() {
        super.contentViewDidLayoutSubviews()
        
        let height = posterView.frame.height
        if height < 128 {
            let delta = height - 64
            let alpha = min(1, max(0, delta / 64))
            if containerView.alpha != alpha {
                containerView.alpha = alpha
            }
        }
        else if height > maximumContentHeight {
            let delta = min(64, height - maximumContentHeight)
            let alpha = min(1, max(0, 1 - delta / 64))
            if containerView.alpha != alpha {
                containerView.alpha = alpha
            }
        }
        else {
            if containerView.alpha != 1.0 {
                containerView.alpha = 1.0
            }
        }
    }
}
