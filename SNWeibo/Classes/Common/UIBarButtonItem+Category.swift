//
//  UIBarButtonItem+Category.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/21/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

// Swift's category uses "extension"
extension UIBarButtonItem {
    /**
     * Quick creation of a barButtonItem.
     * class func = OC's "+" func: class function instead of object function
     */
    class func createBarButtonItem(imageName: String, target: AnyObject?, action: Selector) -> UIBarButtonItem {
        let btn = UIButton()
        btn.setImage(UIImage(named:imageName), for: UIControlState.normal)
        btn.setImage(UIImage(named:imageName + "_highlighted"), for: UIControlState.highlighted)
        btn.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        btn.sizeToFit()
        return UIBarButtonItem(customView: btn)
    }
}
