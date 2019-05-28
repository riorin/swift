//
//  UIButtonExtensions.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 10/10/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit

extension UIButton {
    
    func centerLabelVertically(withSpacing spacing: CGFloat = 4.0) {
        
        // update positioning of image and title
        if let imageView = imageView,
            let image = imageView.image,
            let titleLabel = titleLabel,
            let title = titleLabel.text {
            
            let imageSize = image.size
            let titleRect = NSString(string: title).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: titleLabel.font], context: nil)
            let titleSize = titleRect.size
            
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0)
            imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0, bottom: 0, right: -titleSize.width)
            
            // reset contentInset, so intrinsicContentSize() is still accurate
            let trueContentSize = titleRect.union(imageView.frame).size
            let oldContentSize = intrinsicContentSize
            let heightDelta = trueContentSize.height - oldContentSize.height
            let widthDelta = trueContentSize.width - oldContentSize.width
            contentEdgeInsets = UIEdgeInsets(top: heightDelta / 2.0, left: widthDelta / 2.0, bottom: heightDelta / 2.0, right: widthDelta / 2.0)
        }
    }
}

