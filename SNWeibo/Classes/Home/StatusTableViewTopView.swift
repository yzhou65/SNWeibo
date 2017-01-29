//
//  StatusTableViewTopView.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/28/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

class StatusTableViewTopView: UIView {
    
    /// Status object
    var status: Status? {
        didSet {
            // set nick name
            nameLabel.text = status?.user?.name
            
            // set users' profile images
            if let url = status?.user?.imageURL {
                iconView.sd_setImage(with: url)
            }
            
            // set verified icon
            verifiedView.image = status?.user?.verified_image
            
            // set membership icon
            vipView.image = status?.user?.mbrank_image
            
            // set source. Source's format is a link: <a href="http://xxxx" rel="dsfsf">Yahoo</a>
            sourceLabel.text = status?.source
            
            // set status creation time
            timeLabel.text = status?.created_at
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // init UI
        setupUI()
    }
    
    private func setupUI() {
        // add subviews
        addSubview(iconView)
        addSubview(verifiedView)
        addSubview(nameLabel)
        addSubview(vipView)
        addSubview(timeLabel)
        addSubview(sourceLabel)
        
        // lay out subviews
        _ = iconView.xmg_AlignInner(type: XMG_AlignType.topLeft, referView: self, size: CGSize(width: 50, height: 50), offset: CGPoint(x: 10, y: 10))
        _ = verifiedView.xmg_AlignInner(type: XMG_AlignType.bottomRight, referView: iconView, size: CGSize(width: 14, height: 14), offset: CGPoint(x: 5, y: 5))
        _ = nameLabel.xmg_AlignHorizontal(type: XMG_AlignType.topRight, referView: iconView, size: nil, offset: CGPoint(x: 10, y: 0))
        _ = vipView.xmg_AlignHorizontal(type: XMG_AlignType.topRight, referView: nameLabel, size: CGSize(width: 14, height: 14), offset: CGPoint(x: 10, y: 0))
        _ = timeLabel.xmg_AlignHorizontal(type: XMG_AlignType.bottomRight, referView: iconView, size: nil, offset: CGPoint(x: 10, y: 0))
        _ = sourceLabel.xmg_AlignHorizontal(type: XMG_AlignType.bottomRight, referView: timeLabel, size: nil, offset: CGPoint(x: 10, y: 0))
    }
    
    // MARK: lazy init
    /// profile image
    private lazy var iconView: UIImageView = UIImageView(image: UIImage(named: "avatar_default_big"))
    
    /// verified icon
    private lazy var verifiedView: UIImageView = UIImageView(image: UIImage(named: "avatar_enterprise_vip"))
    
    /// nick name
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    /// membership icon
    private lazy var vipView: UIImageView = UIImageView(image: UIImage(named: "common_icon_membership"))
    
    /// time
    private lazy var timeLabel: UILabel = UILabel.createLabel(color: UIColor.darkGray, fontSize: 14)
    /// source
    private lazy var sourceLabel: UILabel = UILabel.createLabel(color: UIColor.darkGray, fontSize: 14)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
