//
//  TransitionManager.swift
//  Nexus
//
//  Created by Clifford Yin on 1/29/18.
//  Copyright © 2018 Clifford Yin. All rights reserved.
//

import UIKit

/* For the custom transitions */
class TransitionManager: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate  {
    
    var presenting: Bool = true
    
    // MARK: UIViewControllerAnimatedTransitioning protocol methods
    
    // Animate a change from one viewcontroller to another
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Animate a change from one viewcontroller to another
        // Get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            
        // Set up from 2D transforms that we'll use in the animation
        // Set up from 2D transforms that we'll use in the animation
        let π : CGFloat = 3.14159265359
        let offScreenRotateIn = CGAffineTransform(rotationAngle: -π/2)
        let offScreenRotateOut = CGAffineTransform(rotationAngle: π/2)
        
        // Set the start location of toView depending if we're presenting or not
        toView.transform = self.presenting ? offScreenRotateIn : offScreenRotateOut
        
        // Set the anchor point so that rotations happen from the top-left corner
        toView.layer.anchorPoint = CGPoint(x:0, y:0)
        fromView.layer.anchorPoint = CGPoint(x:0, y:0)
        
        // Updating the anchor point also moves the position to we have to move the center position to the top-left to compensate
        toView.layer.position = CGPoint(x:0, y:0)
        fromView.layer.position = CGPoint(x:0, y:0)
        
        // Add the both views to our view controller
        container.addSubview(toView)
        container.addSubview(fromView)
            
        // Get the duration of the animation
        let duration = self.transitionDuration(using: transitionContext)
            
        // Perform the animation
        // Also use the block animation usingSpringWithDamping for a little bounce
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [], animations: {}, completion: { finished in
            // Tell our transitionContext object that we've finished animating
            transitionContext.completeTransition(true)
            })
    }
    
    // How many seconds the transiton animation will take
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    // MARK: UIViewControllerTransitioningDelegate protocol methods
    
    // Return the animataor when presenting a viewcontroller
    // An animator (or animation controller) is any object that aheres to the UIViewControllerAnimatedTransitioning protocol
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    // Return the animator used when dismissing from a viewcontroller
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
}
