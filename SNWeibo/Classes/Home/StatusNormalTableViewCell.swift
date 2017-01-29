//
//  StatusNormalTableViewCell.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/28/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

class StatusNormalTableViewCell: StatusTableViewCell {

    override func setupUI() {
        super.setupUI()
        
        let cons = pictureView.xmg_AlignVertical(type: XMG_AlignType.bottomLeft, referView: contentLabel, size: CGSize.zero, offset: CGPoint(x: 0, y: 10))
        pictureWidthCons = pictureView.xmg_Constraint(cons, attribute: NSLayoutAttribute.width)
        pictureHeightCons = pictureView.xmg_Constraint(cons, attribute: NSLayoutAttribute.height)

    }
}
