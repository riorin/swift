//
//  MovieHeaderView.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 4/5/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

class MovieHeaderView: GSKStretchyHeaderView {
    
    @IBOutlet weak var posterView: UIView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreView: UIView!
    @IBOutlet weak var genreIconImageView: UIImageView!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var imdbRatingView: UIView!
    @IBOutlet weak var imdbIconImageView: UIImageView!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var durationIconImageView: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateIconImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tabBarContainerView: UIView!
    @IBOutlet weak var tabBarBackgroundView: UIView!
    @IBOutlet weak var tabBarView: CMTabbarView!
    @IBOutlet weak var separatorView: UIView!
    
    var posterImage: UIImage? {
        didSet {
            posterImageView.image = posterImage
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    func setupViews() {
        
        backgroundColor = UIColor.clear
        
        minimumContentHeight = 114
        maximumContentHeight = UIScreen.main.bounds.width + 64 + 50
        
        durationIconImageView.image = durationIconImageView.image?.withRenderingMode(.alwaysTemplate)
        genreIconImageView.image = genreIconImageView.image?.withRenderingMode(.alwaysTemplate)
        dateIconImageView.image = dateIconImageView.image?.withRenderingMode(.alwaysTemplate)
        
        let xEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xEffect.minimumRelativeValue = -15
        xEffect.maximumRelativeValue = 15
        
        let yEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        yEffect.minimumRelativeValue = -15
        yEffect.maximumRelativeValue = 15
        
        let effectGroup = UIMotionEffectGroup()
        effectGroup.motionEffects = [xEffect, yEffect]
        
        posterImageView.addMotionEffect(effectGroup)
        
        tabBarView.backgroundColor = UIColor.clear
        tabBarView.indicatorAttributes = [
            CMTabIndicatorViewHeight: 2,
            CMTabIndicatorColor: RGB(0, 122, 255),
            CMTabBoxBackgroundColor: UIColor.clear
        ]
        tabBarView.normalAttributes = [
            NSForegroundColorAttributeName: UIColor.black,
            NSFontAttributeName: kCoreSans17Font,
            NSBackgroundColorAttributeName: UIColor.clear
        ]
        tabBarView.selectedAttributes = [
            NSForegroundColorAttributeName: RGB(0, 122, 255),
            NSFontAttributeName: kCoreSans17Font,
            NSBackgroundColorAttributeName: UIColor.clear
        ]
        tabBarView.tabPadding = 0
        tabBarView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tabBarView.selectionType = .indicator
        tabBarView.scrollEnable = true
        
    }
    
    func setContentColor(color: UIColor) {
        
        titleLabel.textColor = color
        genreIconImageView.tintColor = color
        genreIconImageView.image = genreIconImageView.image?.withRenderingMode(.alwaysTemplate)
        genreLabel.textColor = color
        durationIconImageView.tintColor = color
        durationIconImageView.image = durationIconImageView.image?.withRenderingMode(.alwaysTemplate)
        durationLabel.textColor = color
        dateIconImageView.tintColor = color
        dateIconImageView.image = dateIconImageView.image?.withRenderingMode(.alwaysTemplate)
        dateLabel.textColor = color
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
