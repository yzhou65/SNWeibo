//
//  PopoverPresentationController.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/21/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

class PopoverPresentationController: UIPresentationController {
    
    // save the frame of popover menu
    var presentFrame = CGRect.zero

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        // presentingViewController is a wild pointer after iOS 7
        
    }
    
    /**
     * Called when about to layout
     */
    override func containerViewWillLayoutSubviews() {
        // 1. change presentedView's dimension
        if presentFrame == CGRect.zero {
            presentedView?.frame = CGRect(x: 100, y: 56, width: 200, height: 200)
        } else {
            presentedView?.frame = presentFrame
        }
        
        // 2. insert an HUD between presentedView and HomeTableView to inform user of other pages' current disabled status
        containerView?.insertSubview(coverView, at: 0)
    }
    
    // MARK: lazy init
    private lazy var coverView: UIView = {
        // create a view as HUD
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
        view.frame = UIScreen.main.bounds
        
        // add a listener so that tapping the view closes the presentedView
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    // MARK: listener
    /**
     * Dismisses the presentedViewController
     */
    func close() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
