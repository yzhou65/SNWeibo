//
//  StatusForwardTableViewCell.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/28/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

class StatusForwardTableViewCell: StatusTableViewCell {
    
    override func setupUI() {
        super.setupUI()
        
        // add subviews
        contentView.insertSubview(forwardButton, belowSubview: pictureView)
        contentView.insertSubview(forwardLabel, aboveSubview: forwardButton)
        
        // lay out subviews
        _ = forwardButton.xmg_AlignVertical(type: XMG_AlignType.bottomLeft, referView: contentLabel, size: nil, offset: CGPoint(x: -10, y: 10))
        _ = forwardButton.xmg_AlignVertical(type: XMG_AlignType.topRight, referView: footerView, size: nil)
        
        forwardLabel.text = "dadjfaksdjfladjlvyugfygnbf,mls"
        _ = forwardLabel.xmg_AlignInner(type: XMG_AlignType.topLeft, referView: forwardButton, size: nil, offset: CGPoint(x: 10, y: 10))
        
        // re-adjust pictureView's location
        let cons = pictureView.xmg_AlignVertical(type: XMG_AlignType.bottomLeft, referView: forwardLabel, size: CGSize(width: 290, height: 290), offset: CGPoint(x: 0, y: 10))
        
        pictureWidthCons = pictureView.xmg_Constraint(cons, attribute: NSLayoutAttribute.width)
        pictureHeightCons = pictureView.xmg_Constraint(cons, attribute: NSLayoutAttribute.height)
        pictureTopCons = pictureView.xmg_Constraint(cons, attribute: NSLayoutAttribute.top)
    }

    // MARK: lazy init
    private lazy var forwardLabel: UILabel = {
        let label = UILabel.createLabel(color: UIColor.darkGray, fontSize: 15)
        label.numberOfLines = 15
        label.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 20
        return label
    }()
    
    private lazy var forwardButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        return btn
    }()
}
