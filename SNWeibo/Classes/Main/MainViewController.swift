//
//  MainViewController.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/20/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set tabbar's tintColor, otherwise tabbar items will be blue at default
        // before iOS 7, tintColor only affects item title, not item image 
        tabBar.tintColor = UIColor.orange
        
        // create home page
        addChildVC("HomeTableViewController", title: "Home", imageName: "tabbar_home")
        addChildVC("MessageTableViewController", title: "Message", imageName: "tabbar_message_center")
        addChildVC("DiscoverTableViewController", title: "Discover", imageName: "tabbar_discover")
        addChildVC("ProfileTableViewController", title: "Me", imageName: "tabbar_profile")
    }
    
    /**
     * initialize child controllers
     */
    private func addChildVC(_ childControllerName: String, title: String, imageName:  String) {
        // string -> class
        // namespace is at default = project name, but it can be changed by changing the product name in "Build setting".
        // get namespace (Swift 2.0: NSBundle.mainBundle())
        let ns = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        
        let cls: AnyClass? = NSClassFromString(ns + "." + childControllerName)
        
        // AnyClass -> UIViewController type
        let vcCls = cls as! UIViewController.Type
        let vc = vcCls.init()
        
        // set tabbar and navigation bar
        vc.tabBarItem.image = UIImage(named: imageName)
        vc.tabBarItem.selectedImage = UIImage(named: imageName + "_highlighted")
        //        vc.tabBarItem.title = "Home"
        //        vc.navigationItem.title = "Home"
        vc.title = title
        
        // encapsulate a navigation controller
        let nav = UINavigationController()
        nav.addChildViewController(vc)
        
        addChildViewController(nav)
    }
    
}
