//
//  CardItemsViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 5/27/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

protocol CardItemsViewCellDelegate {
    func cardItemsViewCellSeeAllButtonTapped(cell: CardItemsViewCell)
    func cardItemsViewCellDeleteButtonTapped(cell: CardItemsViewCell)
}

class CardItemsViewCell: WiggleableViewCell {
    var delegate: CardItemsViewCellDelegate?
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var type: CardItemType = .movie {
        didSet {
            switch type {
            case .movieList:
                pageControl.isHidden = true
                collectionView.isPagingEnabled = false
                
            default:
                pageControl.isHidden = false
                collectionView.isPagingEnabled = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupViews()
    }
    
    func setupViews() {
        collectionView.register(UINib(nibName: "CardItemViewCell", bundle: nil), forCellWithReuseIdentifier: "CardItemCellId")
        
        cardView.layer.cornerRadius = 4
        cardView.layer.masksToBounds = true
    }
    
    @IBAction func seeAllButtonTapped(_ sender: UIButton) {
        delegate?.cardItemsViewCellSeeAllButtonTapped(cell: self)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        delegate?.cardItemsViewCellDeleteButtonTapped(cell: self)
    }
    
    override func viewForWiggling() -> UIView {
        return cardView
    }
    
    override func didStartWiggling() {
        deleteButton.isHidden = false
    }
    
    override func didStopWiggling() {
        deleteButton.isHidden = true
    }
}
