//
//  UIColor+Category.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/30/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func randomColor() -> UIColor {
        return UIColor(red: randomNumber(), green: randomNumber(), blue: randomNumber(), alpha: 1.0)
    }
    
    class func randomNumber() -> CGFloat {
        return CGFloat(arc4random_uniform(256)) / 255.0
    }
}
