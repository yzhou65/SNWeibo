//
//  StatusTableViewCell.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/26/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit
import SDWebImage

let YZPictureViewCellReuseIdentifier = "YZPictureViewCellReuseIdentifier"

class StatusTableViewCell: UITableViewCell {
    
    /// pictureView's width and height constraints
    var pictureWidthCons: NSLayoutConstraint?
    var pictureHeightCons: NSLayoutConstraint?
    
    /// pictureView's top constraints
    var pictureTopCons: NSLayoutConstraint?
    
    /// Status object
    var status: Status? {
        didSet {
            // set topView
            topView.status = status
            
            // set status text
            contentLabel.text = status?.text
            
            // set picture's dimension
            pictureView.status = status // after assigning pictureView's status, compute and set the constraints
            
            // note: calculateImageSize() needs status object, thus pictureView's status should be set before
            let size = pictureView.calculateImageSize()
            pictureWidthCons?.constant = size.width
            pictureHeightCons?.constant = size.height
            pictureTopCons?.constant = (size.height == 0 ? 0 : 10)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // init UI
        setupUI()
    }
    
    func setupUI() {
        // add subviews
        contentView.addSubview(topView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(pictureView)
        contentView.addSubview(footerView)
        
        // lay out subviews and set their constraints
        let width = UIScreen.main.bounds.width
        _ = topView.xmg_AlignInner(type: XMG_AlignType.topLeft, referView: contentView, size: CGSize(width: width, height: 60))
        _ = contentLabel.xmg_AlignVertical(type: XMG_AlignType.bottomLeft, referView: topView, size: nil, offset: CGPoint(x: 10, y: 10))
        
        _ = footerView.xmg_AlignVertical(type: XMG_AlignType.bottomLeft, referView: pictureView, size: CGSize(width: width, height: 44), offset: CGPoint(x: -10, y: 10))
    }
    
    /**
     * get row height
     */
    func rowHeight(status: Status) -> CGFloat {
        self.status = status    // call didSet and compute pictureView's height
        
        // update ui
        self.layoutIfNeeded()
        
        return footerView.frame.maxY
    }
    
    // MARK: lazy init
    /// topView
    private lazy var topView: StatusTableViewTopView = StatusTableViewTopView()
    
    /// text
    lazy var contentLabel: UILabel = {
        let label = UILabel.createLabel(color: UIColor.darkGray, fontSize: 15)
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 20
        return label
    }()
    
    /// picture
    lazy var pictureView: StatusPictureView = StatusPictureView()
    
    /// bottom bar
    lazy var footerView: StatusTableViewBottomView = StatusTableViewBottomView()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


