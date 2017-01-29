//
//  StatusTableViewBottomView.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/28/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

class StatusTableViewBottomView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // init UI
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor(white: 0.2, alpha: 0.5)
        addSubview(shareBtn)
        addSubview(likeBtn)
        addSubview(commentBtn)
        
        // lay out subviews
        _ = xmg_HorizontalTile([shareBtn, likeBtn, commentBtn], insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    // MARK: lazy init
    /// share
    private lazy var shareBtn: UIButton = UIButton.createButton(imageName: "timeline_icon_retweet", title: "Share")
    /// like
    private lazy var likeBtn: UIButton = UIButton.createButton(imageName: "timeline_icon_unlike", title: "Like")
    
    /// comment
    private lazy var commentBtn: UIButton = UIButton.createButton(imageName: "timeline_icon_comment", title: "Comment")
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
