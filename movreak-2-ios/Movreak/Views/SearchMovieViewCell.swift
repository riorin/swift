//
//  SearchMovieViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 7/4/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import UIImageColors

protocol SearchMovieViewCellDelegate {
    func searchMovieViewCellSeeAllButtonTapped(cell: SearchMovieViewCell)
    func searchMovieViewCellDetailButtonTapped(cell: SearchMovieViewCell)
}

class SearchMovieViewCell: UICollectionViewCell {
    var delegate: SearchMovieViewCellDelegate?
    
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet private weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    
    private weak var titleViewLayer: CAGradientLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    var imageColors: UIImageColors? {
        didSet {
            
            if let imageColors = imageColors {
                
                self.titleLabel.textColor = imageColors.primary
                self.detailButton.tintColor = imageColors.detail
                self.detailButton.backgroundColor = imageColors.background.withAlphaComponent(0.25)
                self.detailButton.layer.cornerRadius = self.detailButton.frame.width / 2
                self.detailButton.layer.borderColor = imageColors.detail.cgColor
                self.detailButton.layer.borderWidth = kBorderWidth
                self.detailButton.layer.shadowColor = imageColors.background.cgColor
                self.detailButton.layer.shadowOffset = kShadowOffset
                self.detailButton.layer.shadowRadius = kShadowRadius
                self.detailButton.layer.shadowOpacity = kShadowOpacity
                self.detailButton.layer.masksToBounds = false
                
                var layer: CAGradientLayer!
                if let titleViewLayer = self.titleViewLayer {
                    layer = titleViewLayer
                }
                else {
                    
                    // See xib or storyboard
                    let width: CGFloat = 160
                    let height: CGFloat = 58
                    
                    layer = CAGradientLayer()
                    layer.frame = CGRect(x: 0, y: 0, width: width, height: height)
                    self.titleView.layer.insertSublayer(layer, at: 0)
                    self.titleViewLayer = layer
                }
                
                if let components = imageColors.background.cgColor.components,
                    components.count > 2, layer.name != "\(self.tag)" {
                    
                    layer.name = "\(self.tag)"
                    
                    let bgColor0 = UIColor(
                        red: components[0],
                        green: components[1],
                        blue: components[2],
                        alpha: 0.25
                    )
                    
                    
                    let bgColor1 = UIColor(
                        red: components[0],
                        green: components[1],
                        blue: components[2],
                        alpha: 0.5
                    )
                    
                    let bgColor2 = UIColor(
                        red: components[0],
                        green: components[1],
                        blue: components[2],
                        alpha: 0.75
                    )
                    
                    
                    let bgColor3 = UIColor(
                        red: components[0],
                        green: components[1],
                        blue: components[2],
                        alpha: 0.9
                    )
                    
                    layer.colors = [
                        UIColor.clear.cgColor,
                        bgColor0.cgColor,
                        bgColor1.cgColor,
                        bgColor2.cgColor,
                        bgColor3.cgColor,
                        bgColor3.cgColor,
                        bgColor3.cgColor,
                        bgColor3.cgColor
                    ]
                }
            }
        }
    }
    
    func setupViews() {
        containerView.layer.cornerRadius = 4
        containerView.layer.masksToBounds = true
    }
    
    @IBAction func seeAllButtonTapped(_ sender: UIButton) {
        delegate?.searchMovieViewCellSeeAllButtonTapped(cell: self)
    }
    
    @IBAction func detailButtonTapped(_ sender: UIButton) {
        delegate?.searchMovieViewCellDetailButtonTapped(cell: self)
    }
}
