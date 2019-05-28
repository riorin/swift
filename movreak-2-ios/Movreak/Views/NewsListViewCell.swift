//
//  NewsListViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 1/17/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

class NewsListViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(UINib(nibName: "NewsViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsCellId")
    }
}
