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
        // before iOS 7, tintColor only affects title
        tabBar.tintColor = UIColor.orange
        
        // create home page
        addChildVC(HomeTableViewController(), title: "Home", imageName: "tabbar_home")
        addChildVC(MessageTableViewController(), title: "Message", imageName: "tabbar_message_center")
        addChildVC(DiscoverTableViewController(), title: "Discover", imageName: "tabbar_discover")
        addChildVC(ProfileTableViewController(), title: "Me", imageName: "tabbar_profile")
    }
    
    /**
     * initialize child controllers
     */
    private func addChildVC(_ childController: UIViewController, title:String, imageName: String) {
        // set tabbar and navigation bar
        childController.tabBarItem.image = UIImage(named: imageName)
        childController.tabBarItem.selectedImage = UIImage(named: imageName + "_highlighted")
        //        childController.tabBarItem.title = "Home"
        //        childController.navigationItem.title = "Home"
        childController.title = title
        
        // encapsulate a navigation controller
        let nav = UINavigationController()
        nav.addChildViewController(childController)
        
        addChildViewController(nav)
    }
    
}
