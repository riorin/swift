//
//  MovieCardViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 6/16/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit
import UIImageColors

class MovieCardViewCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var adBadgeImageView: UIImageView!
    @IBOutlet weak var newBadgeImageView: UIImageView!
    @IBOutlet weak var featuredBadgeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet private weak var titleView: UIView!
    private weak var titleViewLayer: CAGradientLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    var imageColors: UIImageColors? {
        didSet {
            
            if let imageColors = imageColors {
                
                self.titleLabel.textColor = imageColors.primary
                self.subtitleLabel.textColor = imageColors.detail
                
                var layer: CAGradientLayer!
                if let titleViewLayer = self.titleViewLayer {
                    layer = titleViewLayer
                }
                else {
                    
                    let width: CGFloat = (UIScreen.main.bounds.width - 45) / 2.0
                    let height: CGFloat = 91.5
                
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
        
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
    }
}
