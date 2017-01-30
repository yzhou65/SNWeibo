//
//  HomeRefreshControl.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/29/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

class HomeRefreshControl: UIRefreshControl {

    override init() {
        super.init()
        
        // set up UI
        setupUI()
    }
    
    private func setupUI() {
        // add subviews
        addSubview(refreshView)
        
        // layout subviews
        _ = refreshView.xmg_AlignInner(type: XMG_AlignType.center, referView: self, size: CGSize(width: 230, height: 60))
        
        // when pulled down at a certain degree, reverse the "arrow" image orientation
        addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.new, context: nil)
        
        // when pulled up at a certain degree, reverse the "arrow" image orientation
    }
    
    /// whether needed to reverse the direction of the "refresh arrow" image
    private var reverseArrowFlag = false
    
    /// whether the loading image rotation animation is running
    private var loadingViewAnimFlag = false
    
    /**
     * The more the view is pulled down, the lower the frame.origin.y
     */
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        print(frame.origin.y)
        if frame.origin.y >= 0 || frame.origin.y == -64 {
            return
        }
        
        if isRefreshing && !loadingViewAnimFlag {
//            print("rotating")
            loadingViewAnimFlag = true
            refreshView.startLoadingViewAnim()
            return
        }
        
        if frame.origin.y >= -50 && reverseArrowFlag {
//            print("reversed back")
            reverseArrowFlag = false
            refreshView.rotateArrow(reverseArrowFlag)
        } else if frame.origin.y < -50 && !reverseArrowFlag {
//            print("reversed")
            reverseArrowFlag = true
            refreshView.rotateArrow(reverseArrowFlag)
        }
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        
        // remove rotation loading animation and restore
        refreshView.stopLoadingViewAnim()
        loadingViewAnimFlag = false
    }
    
    // MARK: lazy init
    private lazy var refreshView: HomeRefreshView = HomeRefreshView.refreshView()
    
    deinit {
        removeObserver(self, forKeyPath: "frame")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HomeRefreshView: UIView {
    
    @IBOutlet weak var arrowIcon: UIImageView!
    
    @IBOutlet weak var hintView: UIView!
    
    @IBOutlet weak var loadingView: UIImageView!
    
    /**
     * rotate the arrow icon by 180 degree
     */
    func rotateArrow(_ reverseArrowFlag: Bool) {
        var angle = M_PI
        angle += reverseArrowFlag ? -0.01: 0.01
        UIView.animate(withDuration: 0.2) {
            print(#function)
            
            self.arrowIcon.transform = self.arrowIcon.transform.rotated(by: CGFloat(angle))
            
            // The following is wrong. TransformAnimation should be added to the current transform
            //            self.arrowIcon.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
        }
    }
    
    /**
     * Starts the rotation animation of loading
     */
    func startLoadingViewAnim() {
        hintView.isHidden = true
        
        // Rotation animation
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue = 2 * M_PI
        anim.duration = 1
        anim.repeatCount = MAXFLOAT
        
        // isRemovedOnCompletion at default = true: once animation is done, remove animation. If set it to false, even if user turn to other views and come back, the animation is still here
        anim.isRemovedOnCompletion = false;
        
        // add the rotation animation to the iconView's layer
        loadingView.layer.add(anim, forKey: nil)

    }
    
    /**
     * Ends the rotation animation of loading
     */
    func stopLoadingViewAnim() {
        hintView.isHidden = false
        loadingView.layer.removeAllAnimations()
    }
    
    class func refreshView() -> HomeRefreshView {
        return Bundle.main.loadNibNamed("HomeRefreshView", owner: nil, options: nil)?.last as! HomeRefreshView
    }
}
