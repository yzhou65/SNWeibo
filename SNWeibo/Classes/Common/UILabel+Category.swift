//
//  UILabel+Category.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/26/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

extension UILabel {
    /**
     * Quick creation of a UILabel
     */
    class func createLabel(color: UIColor, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.textColor = color
        label.font = UIFont.systemFont(ofSize: fontSize)
        return label
    }
}

