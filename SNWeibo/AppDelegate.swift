//
//  AppDelegate.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/20/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

// the notification of switching rootViewController
let YZSwitchRootViewControllerKey = "YZSwitchRootViewControllerKey"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // register the notification
        NotificationCenter.default.addObserver(self, selector: #selector(switchRootViewController(_ :)), name: NSNotification.Name(rawValue: YZSwitchRootViewControllerKey), object: nil)
        
        // globally set navigationBar and tabBar's tintColor
        UINavigationBar.appearance().tintColor = UIColor.orange
        UITabBar.appearance().tintColor = UIColor.orange
        
        // create window and root controller
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        
//        window?.rootViewController = MainViewController()
        window?.rootViewController = defaultController()
        
        window?.makeKeyAndVisible()
        
        print("New version available: \(checksUpdate())")
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func switchRootViewController(_ notify: Notification) {
//        print(notify.object)
        
        if notify.object as! Bool {
            window?.rootViewController = MainViewController()
        } else {
            window?.rootViewController = WelcomeViewController()
        }
    }
    
    /**
     * Returns the default ViewController at startup
     */
    private func defaultController() -> UIViewController {
        if UserAccount.userLogin() {
            return checksUpdate() ? NewFeatureCollectionViewController() : WelcomeViewController()
        }
        return MainViewController()
    }
    
    /**
     * Checks the availability of a new update
     */
    private func checksUpdate() -> Bool {
        // get current version as a string from info.plist
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        
        // get previous version as a string from local file. If it is nil, let it be ""
        let sandboxVersion = UserDefaults.standard.object(forKey: "CFBundleShortVersionString") as? String ?? ""
        
        // compare two version numbers.
        if currentVersion.compare(sandboxVersion) == ComparisonResult.orderedDescending  {
            
            // if current > previous, new update available. Save it to UserDefaults
            UserDefaults.standard.set(currentVersion, forKey: "CFBundleShortVersionString")
//            UserDefaults.standard.synchronize()   // Since iOS 7, no need to explicitly call synchronize()
            return true
        }
        
        return false
    }

}

