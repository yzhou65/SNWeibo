//
//  UIImage+Category.swift
//  PhotoUploader
//
//  Created by Yue Zhou on 2/5/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

extension UIImage {
    
    /**
     * Scale an image based on the ratio of width vs height
     * param: width 
     */
    func imageWithScale(width: CGFloat) -> UIImage {
        let height = width * size.height / size.width
        
        // draw a new image based on the ratio of size.height / size.width
        let currentSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(currentSize)
        
        draw(in: CGRect(origin: CGPoint.zero, size: currentSize))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
