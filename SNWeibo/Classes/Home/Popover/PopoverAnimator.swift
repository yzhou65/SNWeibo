//
//  PopoverAnimator.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/22/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

// The constants of notification names
let YZPopoverAnimatorWillPresent = "YZPopoverAnimatorWillPresent"
let YZPopoverAnimatorWillDismiss = "YZPopoverAnimatorWillDismiss"

class PopoverAnimator: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    // record the status of popover's showing or disappearing
    var isPresent: Bool = false
    
    // save the frame of popover menu
    var presentFrame = CGRect.zero
    
    /**
     * indicates what is in charge of the transitioning modal
     * iOS 8 introduces UIPresentationController as the expert for transitioning anim
     */
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let pc = PopoverPresentationController(presentedViewController: presented, presenting: presenting)
        pc.presentFrame = presentFrame // set popover menu's frame
        return pc   // PopoverPresentionController manages modal transitioning
    }
    
    // MARK: once the following methods are implemented, all detailed animation has to be manually customized because default system would not take care
    /**
     * Indicates what is in charge of transitioning animation
     */
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = true
        
        // send notification of "willPresent" to HomeTableViewController to change arrow direction
        // Before Swift 3: NSNotificationCenter.defaultCenter().postNotificationName(aName: String, object: AnyObject?)
        NotificationCenter.default.post(name: NSNotification.Name(YZPopoverAnimatorWillPresent), object: self)
        
        return self
    }
    
    /**
     * Indicates what is in charge of the disppearing animation
     */
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = false
        
        // send notification of "willDismiss" to HomeTableViewController to change arrow direction
        NotificationCenter.default.post(name: NSNotification.Name(YZPopoverAnimatorWillDismiss), object: self)
        
        return self
    }
    
    /**
     * Indicates how the animation is going on.
     * Called whenever it shows or disppears
     */
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        //        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        //        print(toVC as Any)
        //        print(fromVC as Any)
        // toVC == PopoverViewController, fromVC == MainViewController
        
        
        // toView's showing
        if isPresent {
            let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
            toView?.transform = CGAffineTransform(scaleX: 1.0, y: 0.0)
            
            // set anchorPoint
            toView?.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
            
            // add "toView" to the containerView
            transitionContext.containerView.addSubview(toView!)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                // clear transform.
                // Before Swift 3: CGAffineTransformIdentity
                toView?.transform = CGAffineTransform.identity
            }) { (_) in
                // inform system of animation completion, otherwise certain errors arise
                transitionContext.completeTransition(true)
            }
        }
        else { // toView's closing
            let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                // note: CGFloat is not precise, y:0.0 means results in no animation, so use 0.000001
                fromView?.transform = CGAffineTransform(scaleX: 1.0, y: 0.000001)
            }, completion: { (_) in
                transitionContext.completeTransition(true)
            })
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
}
