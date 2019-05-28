//
//  DCPathItemButtonExtensions.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 1/6/17.
//  Copyright © 2017 DyCode. All rights reserved.
//

import Foundation

extension DCPathItemButton {
    
    convenience init(image: UIImage, index: UInt) {
        self.init(image: image, highlightedImage: image, backgroundImage: nil, backgroundHighlightedImage: nil)
        self.index = index
    }
}
