//
//  VisitorView.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/21/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

protocol VisitorViewDelegate: NSObjectProtocol {
    // loginClick callback
    func loginBtnWillClick()
    
    // registerClick callback
    func registerBtnWillClick()
}

class VisitorView: UIView {
    // defines a delegate for register and login buttons' clicking
    // delegate should be weak to avoid cyclic reference
    weak var delegate: VisitorViewDelegate?
    
    
    /**
     * set up unlogged-in UI
     */
    func setupVisitorInfo(isHome: Bool, imageName: String, message: String) {
        // if not home page, hide iconView
        iconView.isHidden = !isHome
        homeIcon.image = UIImage(named: imageName)
        messageLabel.text = message
        
        // whether operates RotationAnimation
        if isHome {
            startRotateAnimation()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // add widgets
        addSubview(iconView)
        addSubview(maskBGView)
        addSubview(homeIcon)
        addSubview(messageLabel)
        addSubview(loginButton)
        addSubview(registerButton)
        
        // arrange widgets
        iconView.xmg_AlignInner(type: XMG_AlignType.center, referView: self, size: nil)
        homeIcon.xmg_AlignInner(type: XMG_AlignType.center, referView: self, size: nil)
        messageLabel.xmg_AlignVertical(type: XMG_AlignType.bottomCenter, referView: iconView, size: nil)
        
        // NSLayoutConstraint's arguments: xx's aa attribute = yy's bb attribute * multiplier + constant
        let widthCons = NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 224)
        addConstraint(widthCons)
        
        // set buttons
        registerButton.xmg_AlignVertical(type: XMG_AlignType.bottomLeft, referView: messageLabel, size: CGSize(width: 100, height: 30), offset: CGPoint(x: 0, y: 20))
        loginButton.xmg_AlignVertical(type: XMG_AlignType.bottomRight, referView: messageLabel, size: CGSize(width: 100, height: 30), offset: CGPoint(x: 0, y: 20))
        
        // set HUV
        maskBGView.xmg_Fill(self)
    }
    
    // if override init(frame), then this method has to be explicitly written
    // Swift recommends that if customizing a widget, either use pure codes or xib/storyboard
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: inner control methods
    private func startRotateAnimation() {
        // Rotation animation
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue = 2 * M_PI
        anim.duration = 20
        anim.repeatCount = MAXFLOAT
        
        // isRemovedOnCompletion at default = true: once animation is done, remove animation. If set it to false, even if user turn to other views and come back, the animation is still here
        anim.isRemovedOnCompletion = false;
        
        // add the rotation animation to the iconView's layer
        iconView.layer.add(anim, forKey: nil)
    }
    
    // MARK: lazy init of child widgets
    /// turnplate
    fileprivate lazy var iconView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "visitordiscover_feed_image_smallicon"))
        return iv
    }()
    
    /// icon
    fileprivate lazy var homeIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "visitordiscover_feed_image_house"))
        return iv
    }()
    
    /// text
    fileprivate lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.darkGray
        label.text = "sldfjsljflsdkjf lsdjfdls djfkdsdvhfodiuge9rhgih"
        return label
    }()
    
    /// login button
    fileprivate lazy var loginButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Log In", for: UIControlState.normal)
        btn.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        btn.setBackgroundImage(UIImage(named:"common_button_white_disable"), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(loginClick), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    /// register button
    fileprivate lazy var registerButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Sign Up", for: UIControlState.normal)
//        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.setTitleColor(UIColor.orange, for: UIControlState.normal)
        btn.setBackgroundImage(UIImage(named:"common_button_white_disable"), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(registerClick), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    /// the mask view that covers on lower half of the "house" image
    private lazy var maskBGView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "visitordiscover_feed_mask_smallicon"))
        return iv
    }()
    
    // MARK: button's listener
    // self is a UIView and cannot modal, so use delegate
    func loginClick() {
        delegate?.loginBtnWillClick()
    }
    
    func registerClick() {
        delegate?.registerBtnWillClick()
    }
}
