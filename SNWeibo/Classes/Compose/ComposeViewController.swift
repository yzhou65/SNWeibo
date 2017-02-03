//
//  ComposeViewController.swift
//  SNWeibo
//
//  Created by Yue Zhou on 2/2/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit
import SVProgressHUD

class ComposeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        setupNav()
        
        setupInputView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // explicitly pop out the keyboard
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // explicitly hide the keyboard
        textView.resignFirstResponder()
    }
    
    /**
     * initializes navigation bar
     */
    private func setupNav() {
        // left button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        // right button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.plain, target: self, action: #selector(sendStatus))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        // middle view
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        let titleLabel = UILabel()
        titleLabel.text = "Edit Weibo"
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.sizeToFit()
        titleView.addSubview(titleLabel)
        
        let nameLabel = UILabel()
        nameLabel.text = UserAccount.unarchiveAccount()?.screen_name
        nameLabel.textColor = UIColor.darkGray
        nameLabel.font = UIFont.systemFont(ofSize: 13)
        nameLabel.sizeToFit()
        titleView.addSubview(nameLabel)
        
        _ = titleLabel.xmg_AlignInner(type: XMG_AlignType.topCenter, referView: titleView, size: nil)
        _ = nameLabel.xmg_AlignInner(type: XMG_AlignType.bottomCenter, referView: titleView, size: nil)
        navigationItem.titleView = titleView
    }
    
    /**
     * initializes input area
     */
    private func setupInputView() {
        view.addSubview(textView)
        textView.addSubview(placeholderLabel)
        
        // lay out child views
        _ = textView.xmg_Fill(view)
        _ = placeholderLabel.xmg_AlignInner(type: XMG_AlignType.topLeft, referView: textView, size: nil, offset: CGPoint(x: 5, y: 7))
    }
    
    /**
     * "Back" button's callback
     */
    func back() {
        dismiss(animated: true, completion: nil)
    }
    
    /**
     * "Send" button's callback
     * Send a weibo status
     */
    func sendStatus() {
        print(#function)
        
        let path = "2/statuses/update.json"
        let params = ["access_token": UserAccount.unarchiveAccount()?.access_token!, "status": textView.text]
        NetworkTools.sharedNetworkTools().post(path, parameters: params, progress: nil, success: { (_, json) in
            SVProgressHUD.showSuccess(withStatus: "Status sent")
            SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
            
            // close the sending view
            self.back()
            
        }) { (_, error) in
            print(error)
            SVProgressHUD.showError(withStatus: "Status failed to be sent")
            SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        }
    }

    
    // MARK: lazy init
    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.delegate = self
        return tv
    }()
    
    fileprivate lazy var placeholderLabel: UILabel = {
        let placeholder = UILabel()
        placeholder.text = "Share news..."
        placeholder.font = UIFont.systemFont(ofSize: 13)
        placeholder.textColor = UIColor.darkGray
        return placeholder
    }()
}


extension ComposeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = textView.hasText
        navigationItem.rightBarButtonItem?.isEnabled = textView.hasText
    }
}
