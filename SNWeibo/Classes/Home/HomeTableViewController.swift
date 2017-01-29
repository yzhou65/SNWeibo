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
        
        // register notification and spy on the popover menu and its arrow
        NotificationCenter.default.addObserver(self, selector: #selector(changeArrow), name: NSNotification.Name(YZPopoverAnimatorWillPresent), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeArrow), name: NSNotification.Name(YZPopoverAnimatorWillDismiss), object: nil)
        
        // register the cell
        tableView.register(StatusNormalTableViewCell.self, forCellReuseIdentifier: YZHomeCellReuseIdentifier)
        
        // set row height with an estimate height and auto-dimension
//        tableView.estimatedRowHeight = 200
//        tableView.rowHeight = UITableViewAutomaticDimension
        
//        tableView.rowHeight = 300
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        // load weibo data
        loadData()
    }
    
    // == OC's dealloc
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: inner control methods
    /**
     * Loads the weibo statuses
     */
    private func loadData() {
        Status.loadStatuses { (models, error) in
            if error != nil {
                return
            }
            self.statuses = models  // this triggers the calling of statuses' didSet method
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
        let cell = tableView.dequeueReusableCell(withIdentifier: YZHomeCellReuseIdentifier, for: indexPath) as! StatusTableViewCell
        cell.status = statuses![indexPath.row]
        
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
            print("Row height from cache")
            return height
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: YZHomeCellReuseIdentifier) as! StatusTableViewCell
        let rowHeight = cell.rowHeight(status: status)
        
        // cache the row height
        rowCache[status.id] = rowHeight
        print("Row height re-calculated")
        
        return rowHeight
    }
}
