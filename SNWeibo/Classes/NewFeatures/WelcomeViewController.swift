//
//  NewFeatureCollectionViewController.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/25/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit
import SDWebImage

class WelcomeViewController: UIViewController {
    
    /// bottom constraints
    var bottomCons: NSLayoutConstraint?
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(#function)
        // 1. add subviews
        view.addSubview(bgIV)
        view.addSubview(iconView)
        view.addSubview(messageLabel)
        
        // 2. layout subviews
        let _ = bgIV.xmg_Fill(view)

        let cons = iconView.xmg_AlignInner(type: XMG_AlignType.bottomCenter, referView: view, size: CGSize(width: 100, height: 100), offset: CGPoint(x: 0, y: -150))
        // profile image's bottom constraints
        bottomCons = iconView.xmg_Constraint(cons, attribute: NSLayoutAttribute.bottom)
        
        let _ = messageLabel.xmg_AlignVertical(type: XMG_AlignType.bottomCenter, referView: iconView, size: nil, offset: CGPoint(x: 0, y: 20))
        
        // 3. set user profile image
        if let iconUrl = UserAccount.unarchiveAccount()?.avatar_large
        {
            let url = URL(string: iconUrl)!
            iconView.sd_setImage(with: url)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print(#function)
        
        // -667.0 - (-150.0) = -517.0
        self.bottomCons?.constant = -UIScreen.main.bounds.height - self.bottomCons!.constant
//        print(-UIScreen.main.bounds.height)
//        print(self.bottomCons!.constant)
//        print(-UIScreen.main.bounds.height -  self.bottomCons!.constant)
        
        // 3. start animation
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
            // profile image animation            
            self.iconView.layoutIfNeeded()
            
            }) { (_) -> Void in
 
                // text animation
                UIView.animate( withDuration: 2.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                    self.messageLabel.alpha = 1.0
                    }, completion: { (_) -> Void in
                        print("Welcome back animation OK")
                        
                        // turn to home page. The notification bring along the object "true"
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: YZSwitchRootViewControllerKey), object: true)
                })
        }
        
    }
    
    // MARK: - lazy init
    private lazy var bgIV: UIImageView = UIImageView(image: UIImage(named: "ad_background"))
    
    private lazy var iconView: UIImageView = {
       let iv = UIImageView(image: UIImage(named: "avatar_default_big"))
        iv.layer.cornerRadius = 50
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var messageLabel: UILabel = {
       let label = UILabel()
        label.text = "Welcome back"
        label.sizeToFit()
        label.alpha = 0.0
        return label
    }()
}
