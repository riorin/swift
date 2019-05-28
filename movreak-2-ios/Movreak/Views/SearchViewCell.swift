//
//  SearchViewCell.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 6/25/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import UIKit

class SearchViewCell: UICollectionViewCell {
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            if searchBar != nil {
                if let aClass = NSClassFromString("UISearchBarBackground"),
                    let subviews = searchBar.subviews.last?.subviews {
                    for view in subviews {
                        if view.isKind(of: aClass) {
                            view.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
}
