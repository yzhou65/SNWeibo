//
//  OAuthViewController.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/23/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD

class OAuthViewController: UIViewController {

    let WB_APP_KEY = "730516003"
    let WB_APP_SECRET = "0ff4ea694bec6049346ebc2a828afcab"
    let WB_REDIRECT_URI = "http://www.520it.com"
    
    override func loadView() {
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init navigation bar
        navigationItem.title = "SNWeibo"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Exit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(close))

        // get unauthorized requestToken
        let urlStr = "https://api.weibo.com/oauth2/authorize?client_id=\(WB_APP_KEY)&redirect_uri=\(WB_REDIRECT_URI)"
        let url = URL(string: urlStr)
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
    }
    
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: lazy init
    private lazy var webView: UIWebView = {
        let wv = UIWebView()
        wv.delegate = self
        return wv
    }()
}

extension OAuthViewController: UIWebViewDelegate {
    /**
     * Called when webView is loading requests
     */
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        // load authorization page: "https://api.weibo.com/oauth2/authorize?client_id=730516003&redirect_uri=http://www.520it.com"
        // authorization page: "https://api.weibo.com/oauth2/authorize"
        // authorization success: "http://www.520it.com/?code=f67942231fbf392a9c6c51eb6f0f29e6"
        // cancel authorization: "http://www.520it.com/error_uri=....."
//        print(request.url?.absoluteString as Any)
        
        // checks whether it is authorization page
        let urlStr = request.url!.absoluteString
        if !urlStr.hasPrefix(WB_REDIRECT_URI) { // if urlStr does not contain "http://www.520.it.com", request is still going on and the web page may still stay on the log-in page
            // continue to load
            return true
        }
        
        // checks whether it is authorization success
        let codeStr = "code="
        if request.url!.query!.hasPrefix(codeStr) {
            // authorization successful
            print("authorization successful")
            let code = request.url!.query!.substring(from: codeStr.endIndex)
            
            // get accessToken with authorized requestToken
            loadAccessToken(code: code)
        }
        else {  // authorization cancelled
            print("cancel authorize")
            // close the page
            close()
        }
        return false
    }
    
    /**
     * get AccessToken with authorized requestToken
     */
    private func loadAccessToken(code: String) {
        let path = "oauth2/access_token"
        let params = ["client_id": WB_APP_KEY, "client_secret": WB_APP_SECRET, "grant_type": "authorization_code", "code": code, "redirect_uri": WB_REDIRECT_URI]
        
        // send POST request
        NetworkTools.sharedNetworkTools().post(path, parameters: params, progress: nil, success: { (_, JSON) in
            print(JSON!)
            /* "access_token" = "2.00todcvC0LaK8n44f09858c6P2Q8UB". For one user, multiple authorization generates the same accessToken, which has an expiration date:
             1. If one authorizes himself, expiration is in 5 years
             2. If others authorizes one, expiration is in 3 days
            */
            
            /**
             * Save an object:
             * plist: can only save system data
             * preferenced: plist
             * object -> json -> file
             * database: save big data and is efficient
             * archive
             */
            let account = UserAccount(dict: JSON as! [String: AnyObject])
            
            // get account information. Note: this method sends network request in a child thread, so archiving the account cannnot be done at the following, instead at the success closure of GET request
            account.loadUserInfo(completed: { (account, error) in
                if account != nil {
                    account!.archiveAccount()
                    
                    // turn to welcome page. The notification bring along the object "false"
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: YZSwitchRootViewControllerKey), object: false)
                }
                else {
                    print(error as Any)
                    SVProgressHUD.showInfo(withStatus: "Network error")
                    SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
                }
            })

        }) { (_, error) in
            print(error)
        }
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        // show HUD of loading
        SVProgressHUD.showInfo(withStatus: "Loading")
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
}
