//
//  HomeTableViewController.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/20/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

class HomeTableViewController: BaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.showInfo(withStatus: "Hello, my friend")

        // user is not loggined in, set VisitorView
        if !userLogin {
            self.visitorView?.setupVisitorInfo(isHome: true, imageName: "visitordiscover_feed_image_house", message: "Follow friends and what they are going on with")
            return
        }
        
        // init navigationBar
        setupNav()
        
        // register notification and spy on the popover menu and its arrow
        NotificationCenter.default.addObserver(self, selector: #selector(changeArrow), name: NSNotification.Name(YZPopoverAnimatorWillPresent), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeArrow), name: NSNotification.Name(YZPopoverAnimatorWillDismiss), object: nil)
    }
    
    // == OC's dealloc
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     * Changes arrow's direction
     */
    func changeArrow() {
        let titleBtn = navigationItem.titleView as! TitleButton
        titleBtn.isSelected = !titleBtn.isSelected
        
    }

    /**
     * initializes navigation bar
     */
    private func setupNav() {
        // 1. init left/right button
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem(imageName: "navigationbar_friendattention", target: self, action: #selector(leftItemClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem.createBarButtonItem(imageName: "navigationbar_pop", target: self, action: #selector(rightItemClick))
        
        // 2. init title button with target
        let titleBtn = TitleButton()
        // name must be underlined by using NSAttributedString
        let attrs = [NSForegroundColorAttributeName: UIColor.darkGray, NSUnderlineStyleAttributeName: 1] as [String : Any]
        let buttonTitleStr = NSAttributedString(string: "Barney8812 ", attributes: attrs)
        titleBtn.setAttributedTitle(buttonTitleStr, for: UIControlState.normal)
        
        titleBtn.addTarget(self, action: #selector(titleBtnClick(_ :)), for: UIControlEvents.touchUpInside)
        navigationItem.titleView = titleBtn
    }
    
    // MARK: buttons' listeners
    /**
     * change titleBtn's status when clicked
     */
    func titleBtnClick(_ btn: TitleButton) {
        // change arrow direction. Due to the notification registered and the "changeArrow" method, no need to write this here, otherwise arrow direction will be changed twice
//        btn.isSelected = !btn.isSelected
        
        // pop out the popover
        let sb = UIStoryboard(name: "PopoverViewController", bundle: nil)
        let vc = sb.instantiateInitialViewController()
        
        // popover tableView does not come out from bottom, so vc's modal transition has to be specified
        // Using system's default modal, previous controllerViews will be replaced by the presentedView. Customizing the modal can save previous views
        vc?.transitioningDelegate = popoverAnimator
        vc?.modalPresentationStyle = UIModalPresentationStyle.custom
        present(vc!, animated: true, completion: nil)
    }
    
    func leftItemClick() {
        print(#function)
    }
    
    func rightItemClick() {
        let sb = UIStoryboard(name: "QRCodeViewController", bundle: nil)
        let vc = sb.instantiateInitialViewController()
        present(vc!, animated: true, completion: nil)
    }
    
    // MARK: inner control methods
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    // MARK: lazy init
    /**
     * defines a variable for animation transitioning delegate
     * if vc.transitioningDelegate = PopoverAnimator(), errors would arise
     */
    private lazy var popoverAnimator: PopoverAnimator = {
        let pa = PopoverAnimator()
        // popover menu's frame should be decided by HomeTableViewController
        pa.presentFrame = CGRect(x: 100, y: 56, width: 200, height: 350)
        return pa
    }()

}
