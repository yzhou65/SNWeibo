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
        // However, if appearance is set, tintColor setting is no longer needed
//        tabBar.tintColor = UIColor.orange
        
        // init all childViewControllers
        initChildViewControllers()
    }
    
    /**
     * insert the "+" shaped tabbar item in viewWillAppear 
     * Because viewDidLoad has not have other child items
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupComposeBtn()
    }
    
    fileprivate func setupComposeBtn() {
        tabBar.addSubview(composeBtn)
        
        // adjust composeBtn's location
        let width = UIScreen.main.bounds.size.width / CGFloat(viewControllers!.count)
        
        let rect = CGRect(x: 0, y: 0, width: width, height: 49)
        // Before swift 3.0: CGRectOffset(rect, x, y)
        composeBtn.frame = rect.offsetBy(dx: 2 * width, dy: 0)
    }
    
    /**
     * init all childViewControllers
     */
    fileprivate func initChildViewControllers() {
        // using json file to create childViewControllers
        // get json file
        let path = Bundle.main.path(forResource: "MainVCSettings", ofType: "json")
        if let jsonFile = path {
            let jsonData = NSData(contentsOfFile: jsonFile)
            
            // serialize the json file
            do {
                // do..try..catch is like python's try..except
                let dictArr = try JSONSerialization.jsonObject(with: jsonData as! Data, options: JSONSerialization.ReadingOptions.mutableContainers)
                
                // traverse the dictArr
                for dict in dictArr as! [[String: String]] {
                    // addChildVC method's arguments are not ?, so dict[] needs !
                    addChildVC(dict["vcName"]!, title: dict["title"]!, imageName: dict["imageName"]!)
                }
            } catch {
                print(error)
                
                // exceptions happened, locally create childViewControllers
                addChildVC("HomeTableViewController", title: "Home", imageName: "tabbar_home")
                addChildVC("MessageTableViewController", title: "Message", imageName: "tabbar_message_center")
                
                // add "+" shaped controller
                addChildVC("NullViewController", title: "", imageName: "")
                
                addChildVC("DiscoverTableViewController", title: "Discover", imageName: "tabbar_discover")
                addChildVC("ProfileTableViewController", title: "Me", imageName: "tabbar_profile")
            }
        }
    }
    
    /**
     * initialize child controllers
     */
    fileprivate func addChildVC(_ childControllerName: String, title: String, imageName:  String) {
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
    
    // MARK: - lazy init
    fileprivate lazy var composeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named:"tabbar_compose_icon_add"), for: UIControlState.normal)
        btn.setImage(UIImage(named:"tabbar_compose_icon_add_highlighted"), for: UIControlState.highlighted)
        btn.setBackgroundImage(UIImage(named:"tabbar_compose_button"), for: UIControlState.normal)
        btn.setBackgroundImage(UIImage(named:"tabbar_compose_button_highlighted"), for: UIControlState.highlighted)
        
        // btn's listener
        btn.addTarget(self, action: #selector(composeBtnClick), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    /**
     * Called when composeBtn is clicked.
     * This method cannot be private
     */
    func composeBtnClick() {
        //Before swift 3.0, #function was __FUNCTION__
        print(#function)
        
        let composeVC = ComposeViewController()
        let nav = UINavigationController(rootViewController: composeVC)
        present(nav, animated: true, completion: nil)
    }
}
