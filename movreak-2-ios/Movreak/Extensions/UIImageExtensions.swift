//
//  UIImageExtensions.swift
//  Movreak
//
//  Created by Bayu Yasaputro on 11/8/16.
//  Copyright © 2016 DyCode. All rights reserved.
//

import UIKit
import CoreImage

extension UIImage {
    
    func cropCenterAndResize(to size: CGSize, offsetX: CGFloat = 0, offsetY: CGFloat = 0) -> UIImage {
        guard let cgImage = self.cgImage else { return self }
        
        let contextImage: UIImage = UIImage(cgImage: cgImage)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        let cropAspect: CGFloat = size.width / size.height
        
        var cropWidth: CGFloat = size.width
        var cropHeight: CGFloat = size.height
        
        if size.width > size.height { //Landscape
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            posY = (contextSize.height - cropHeight) / 2 + offsetY
        } else if size.width < size.height { //Portrait
            cropHeight = contextSize.height
            cropWidth = contextSize.height * cropAspect
            posX = (contextSize.width - cropWidth) / 2 + offsetX
        } else { //Square
            if contextSize.width >= contextSize.height { //Square on landscape (or square)
                cropHeight = contextSize.height
                cropWidth = contextSize.height * cropAspect
                posX = (contextSize.width - cropWidth) / 2 + offsetX
            } else { //Square on portrait
                cropWidth = contextSize.width
                cropHeight = contextSize.width / cropAspect
                posY = (contextSize.height - cropHeight) / 2 + offsetY
            }
        }
        
        // Create bitmap image from context using the rect
        if let cgImage = contextImage.cgImage {
            
            let rect: CGRect = CGRect(x: posX, y: posY, width: cropWidth, height: cropHeight)
            let imageRef: CGImage = cgImage.cropping(to: rect)!
            
            // Create a new image based on the imageRef and rotate back to the original orientation
            let cropped: UIImage = UIImage(cgImage: imageRef, scale: scale, orientation: imageOrientation)
            
            UIGraphicsBeginImageContextWithOptions(size, true, scale)
            cropped.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
            let resized = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let resized = resized {
                return resized
            }
        }
        
        return self
    }
}
