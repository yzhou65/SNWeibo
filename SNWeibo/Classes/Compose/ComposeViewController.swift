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
    
    private lazy var emoticonVC: EmoticonViewController = EmoticonViewController { [unowned self](emoticon) in
        self.textView.insertEmoticon(emoticon: emoticon)
    }
    
    /// toolbar's bottom constraint
    var toolbarBottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        // notification of keyboard's appearance and disappearance
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        // add the emoticon view controller as a child view controller
        addChildViewController(emoticonVC)
//        textView.inputView = emoticonVC.view
        
        setupNav()
        
        setupInputView()
        
        setupToolbar()
    }
    
    /**
     * The callback of the Keyboard's appearance or disappearance
     */
    func keyboardChange(_ notify: Notification) {
        let rect = (notify.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        // adjust the constraint:
        // pop-out: Y = 409 height = 258
        // close: Y = 667 height = 258
        // 667 - 409 = 258
        // 667 - 667 = 0
        let height = UIScreen.main.bounds.height
        toolbarBottomConstraint?.constant = -(height - rect.origin.y)
        
        // update the UI
        let duration = notify.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        
        /**
         * toolbar's bounceness is due to twice operation of animation. Therefore, must set AnimationCurve
         */
        let curve = notify.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
        UIView.animate(withDuration: duration.doubleValue) {
            UIView.setAnimationCurve(UIViewAnimationCurve.init(rawValue: curve.intValue)!)
            self.view.layoutIfNeeded()
        }
//        let anim = toolbar.layer.animation(forKey: "position")
//        print(anim?.duration)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
     * Initializes the tool bar
     */
    private func setupToolbar() {
        view.addSubview(toolbar)
        
        var items = [UIBarButtonItem]()
        let itemSettings = [["imageName": "compose_toolbar_picture", "action": "selectPicture"],
                            ["imageName": "compose_mentionbutton_background"],
                            ["imageName": "compose_trendbutton_background"],
                            ["imageName": "compose_emoticonbutton_background", "action": "inputEmoticon"],
                            ["imageName": "compose_addbutton_background"]]
        
        for dict in itemSettings {
//            let item = UIBarButtonItem.createBarButtonItem(imageName: dict["imageName"]!, target: self, action: Selector(dict["action"]!))
            let item = UIBarButtonItem(imageName: dict["imageName"]!, target: self, action: dict["action"])
            items.append(item)
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))
        }
        items.removeLast()
        toolbar.items = items
        
        // lay out the toolbar
        let width = UIScreen.main.bounds.width
        let cons = toolbar.xmg_AlignInner(type: XMG_AlignType.bottomLeft, referView: view, size: CGSize(width: width, height: 44))
        toolbarBottomConstraint = toolbar.xmg_Constraint(cons, attribute: NSLayoutAttribute.bottom)
    }
    
    /**
     * Select photos
     */
    func selectPicture() {
        
    }
    
    /**
     * Switch to emoticon keyboard
     */
    func inputEmoticon() {
//        print(textView.inputView!)   // nil if system's default keyboard, otherwise non-nil
        
        // off the keyboard
        textView.resignFirstResponder()
        
        // switch between the customized emoticon keyboard and system's default keyboard
        textView.inputView = (textView.inputView == nil) ? emoticonVC.view : nil
        textView.becomeFirstResponder()
    }
    
    /**
     * initializes the input area
     */
    private func setupInputView() {
        view.addSubview(textView)
        textView.addSubview(placeholderLabel)
        textView.alwaysBounceVertical = true
        textView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        
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
        let params = ["access_token": UserAccount.unarchiveAccount()!.access_token!, "status": textView.emoticonAttributdText()]
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

    
    // MARK: lazy initialization
    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 20)
        tv.delegate = self
        return tv
    }()
    
    fileprivate lazy var placeholderLabel: UILabel = {
        let placeholder = UILabel()
        placeholder.text = "Share news..."
        placeholder.font = UIFont.systemFont(ofSize: 20)
        placeholder.textColor = UIColor.darkGray
        return placeholder
    }()
    
    private lazy var toolbar: UIToolbar = UIToolbar()
}


extension ComposeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // note: input of default emoticon will not hide the placeholderLabel (textView does not see default emoticon as "hasText")
        placeholderLabel.isHidden = textView.hasText
        navigationItem.rightBarButtonItem?.isEnabled = textView.hasText
    }
}
