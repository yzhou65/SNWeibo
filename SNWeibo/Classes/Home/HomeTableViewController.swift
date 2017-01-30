//
//  HomeTableViewController.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/20/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit
import SVProgressHUD

let YZHomeCellReuseIdentifier = "YZHomeCellReuseIdentifier"

class HomeTableViewController: BaseTableViewController {
    /// array of weibo statuses(posts)
    var statuses: [Status]? {
        didSet {
            // once the variable is assigned data, reload the tableView
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // user is not loggined in, set VisitorView
        if !userLogin {
            self.visitorView?.setupVisitorInfo(isHome: true, imageName: "visitordiscover_feed_image_house", message: "Follow friends and what they are going on with")
            return
        }
        
        // init navigationBar
        setupNav()
        
        // MARK: Cell and notification registration
        // Registers notification and spy on the popover menu and its arrow.
        // Argument "object": the notification sender
        NotificationCenter.default.addObserver(self, selector: #selector(changeArrow), name: NSNotification.Name(YZPopoverAnimatorWillPresent), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeArrow), name: NSNotification.Name(YZPopoverAnimatorWillDismiss), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showPhotoBrowser), name: NSNotification.Name(YZStatusPictureViewSelected), object: nil)
        
        // register two types of cells: original status cell, shared status cell
        tableView.register(StatusNormalTableViewCell.self, forCellReuseIdentifier: StatusTableViewCellType.NormalCell.rawValue)
        tableView.register(StatusForwardTableViewCell.self, forCellReuseIdentifier: StatusTableViewCellType.ForwardCell.rawValue)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        // add pull-down refresh
        refreshControl = HomeRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadData), for: UIControlEvents.valueChanged)
        
        // load weibo data
        loadData()
    }
    
    /**
     * Upon receiving the notification, modally present a photoBrowser controller
     */
    func showPhotoBrowser(notify: Notification) {
//        print(notify.userInfo)
        
        // Normally passing data thru notification needs to check whether data passed is nil
        guard let indexPath = notify.userInfo![YZStatusPictureViewIndexKey] as? IndexPath else {
            print("No indexPath found")
            return
        }
        
        guard let urls = notify.userInfo![YZStatusPictureViewURLsKey] as? [URL] else {
            print("No picture found")
            return
        }
        
        // init and present PhotoBrowserController
        let vc = PhotoBrowserController(index: indexPath.item, urls: urls)
        present(vc, animated: true, completion: nil)
    }
    
    // == OC's dealloc
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    /// marks the refresh as pull-up or pull-down
    var pullupRefreshFlag = false
    
    // MARK: inner control methods
    /**
     * Loads the weibo statuses
     */
    @objc func loadData() {
        /**
         * At default, every request for new statuses returns 20 new ones
         since_id: the new statuses' id returned > this since_id
         max_id: the new statuses' id returned < this max_id
         
         every status has an id and id's increment
         Status listed ahead has an id > the id's of statuses listed after
         */
        var since_id = statuses?.first?.id ?? 0     // at default, it is pull-down refresh
        
        var max_id = 0
        if pullupRefreshFlag {
            since_id = 0
            max_id = statuses?.last?.id ?? 0
        }
        
        Status.loadStatuses(since_id: since_id, max_id: max_id) { (models, error) in
            self.refreshControl?.endRefreshing()
            if error != nil {
                return
            }
            
            if since_id > 0 {
                // pull-down refresh insert new statuses into the very head of statuses
                self.statuses = models! + self.statuses!
                self.showNewStatusesCount(count: models?.count ?? 0)
            } else if max_id > 0 {
                // pull-up refresh append more statuses to the original status list
                self.statuses?.append(contentsOf: models!)
            }
            else {
                //
                self.statuses = models  // this triggers the calling of statuses' didSet method
            }
        }
    }
    
    private func showNewStatusesCount(count: Int) {
        newStatusLabel.text = (count == 0) ? "No new status" : "\(count) new statuses loaded"
        newStatusLabel.alpha = 1.0
//        newStatusLabel.isHidden = false
        let height = newStatusLabel.frame.height
        
        UIView.animate(withDuration: 2, animations: {
            self.newStatusLabel.transform = self.newStatusLabel.transform.translatedBy(x: 0, y: height)
        
        }) { (_) in
            
            UIView.animate(withDuration: 2, animations: {
                self.newStatusLabel.alpha = 0.0
                self.newStatusLabel.transform = CGAffineTransform.identity
            }, completion: { (_) in
//                self.newStatusLabel.isHidden = true
            })
        }
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
        navigationController?.navigationBar.isOpaque = true
        
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
    
    // MARK: buttons' callbacks
    /**
     * change titleBtn's status when clicked
     */
    func titleBtnClick(_ btn: TitleButton) {
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
    
    /// the label that shows new status loaded thru manual refreshing
    private lazy var newStatusLabel: UILabel = {
        let label = UILabel()
        let height: CGFloat = 44
        label.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        
        label.backgroundColor = UIColor.orange
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 14)
        
        // add this label to UI
        self.navigationController?.navigationBar.insertSubview(label, at: 0)
//        self.navigationController?.navigationBar.addSubview(label)
//        label.isHidden = true
        return label
    }()
    
    /// status row height cached as a dictionary. key is status id, value is row height
    var rowCache: [Int: CGFloat] = [Int: CGFloat]()
    
    /**
     * Once memory warning is received due to very frequent status loading
     */
    override func didReceiveMemoryWarning() {
        rowCache.removeAll()
    }
}

// MARK: - Table view data source
extension HomeTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return statuses?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let status = statuses![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: StatusTableViewCellType.cellType(status: status), for: indexPath) as! StatusTableViewCell
        cell.status = status
        
        // tests whether scolled to the last cell
        let count = statuses?.count ?? 0
        if indexPath.row == count - 1 {
            pullupRefreshFlag = true
            print("Pull-up refresh")
            loadData()
        }
        
        return cell
    }
    
    /**
     * Returns the height of a row. 
     * This method is frequently called, thus cellheight should be cached because it is wasteful to compute row height every time the row is reused
     */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let status = statuses![indexPath.row]
        
        // checks whether the row height was cached
        if let height = rowCache[status.id] {
//            print("Row height from cache")
            return height
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: StatusTableViewCellType.cellType(status: status)) as! StatusTableViewCell
        let rowHeight = cell.rowHeight(status: status)
        
        // cache the row height
        rowCache[status.id] = rowHeight
//        print("Row height re-calculated")
        
        return rowHeight
    }
}
