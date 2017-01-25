//
//  BaseTableViewController.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/21/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController, VisitorViewDelegate {
    // define a variable to store the status whether user is logged in
    var userLogin = UserAccount.userLogin()
    
    // define a variable to store the unlogged-in UI
    var visitorView: VisitorView?
    
    override func loadView() {
        userLogin ? super.loadView() : setupVisitorView()
    }
    
    // MARK: - inner control methods
    /**
     * set up the unlogged-in UI
     */
    fileprivate func setupVisitorView() {
        // init unlogged-in UI
        let customView = VisitorView()
        customView.delegate = self
        self.view = customView
        self.visitorView = customView
        
        // init navigation items
        // global appearance is set in AppDelegate, tintColor setting is not needed here
//        self.navigationController?.navigationBar.tintColor = UIColor.orange
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign up", style: UIBarButtonItemStyle.plain, target: self, action: #selector(registerBtnWillClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log in", style: UIBarButtonItemStyle.plain, target: self, action: #selector(registerBtnWillClick))
    }

    func loginBtnWillClick() {
        print(#function)
        
        // modally present log-in UI
        let oauthVC = OAuthViewController()
        let nav = UINavigationController(rootViewController: oauthVC)
        present(nav, animated: true, completion: nil)
//        present(oauthVC, animated: true, completion: nil)
    }
    
    func registerBtnWillClick() {
//        print(#function)
//        print("http://www.yahoo.com/yz.plist".cacheDir())
        
    }
}
