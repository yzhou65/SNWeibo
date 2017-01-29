//
//  UIButton+Category.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/26/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

extension UIButton {
    class func createButton(imageName: String, title: String) -> UIButton {
        let btn = UIButton()
        btn.setImage(UIImage(named: imageName), for: UIControlState.normal)
        btn.setTitle(title, for: UIControlState.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        btn.setBackgroundImage(UIImage(named: "timeline_card_bottom_background"), for: UIControlState.normal)
        btn.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        return btn
    }
}
