//
//  AppDelegate.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/20/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // globally set navigationBar and tabBar's tintColor
        UINavigationBar.appearance().tintColor = UIColor.orange
        UITabBar.appearance().tintColor = UIColor.orange
        
        // create window and root controller
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.rootViewController = MainViewController()
        
        window?.makeKeyAndVisible()
        return true
    }

}

