//
//  StartUpSegue.swift
//  Nexus
//
//  Created by Clifford Yin on 2/11/19.
//  Copyright © 2019 Clifford Yin. All rights reserved.
//

import UIKit
import QuartzCore

enum StarUpCustomSegueAnimation {
    case Push
    case SwipeDown
    case GrowScale
    case CornerRotate
}

/* Utilizing this for the slide-down animation */
class StartUpCustomSegue: UIStoryboardSegue {
    
    var animationType = CustomSegueAnimation.SwipeDown
    
    override func perform() {
        switch animationType {
        case .Push:
            animatePush()
        case .SwipeDown:
            animateSwipeDown()
        case .GrowScale:
            animateGrowScale()
        case .CornerRotate:
            animateCornerRotate()
        }
    }
    
    private func animatePush() {
        let toViewController = destination
        let fromViewController = source
        
        let containerView = fromViewController.view.superview
        let screenBounds = UIScreen.main.bounds
        
        let finalToFrame = screenBounds
        let finalFromFrame = finalToFrame.offsetBy(dx: -screenBounds.size.width, dy: 0)
        
        toViewController.view.frame = finalToFrame.offsetBy(dx: screenBounds.size.width, dy: 0)
        containerView?.addSubview(toViewController.view)
        
        UIView.animate(withDuration: 0.5, animations: {
            toViewController.view.frame = finalToFrame
            fromViewController.view.frame = finalFromFrame
        }, completion: { finished in
            let fromVC = self.source
            let toVC = self.destination
            fromVC.present(toVC, animated: false, completion: nil)
        })
    }
    
    private func animateSwipeDown() {
        let toViewController = destination
        let fromViewController = source
        
        let containerView = fromViewController.view.superview
        let screenBounds = UIScreen.main.bounds
        
        let finalToFrame = screenBounds
        let finalFromFrame = finalToFrame.offsetBy(dx: 0, dy: screenBounds.size.height)
        
        toViewController.view.frame = finalToFrame.offsetBy(dx: 0, dy: -screenBounds.size.height)
        containerView?.addSubview(toViewController.view)
        
        UIView.animate(withDuration: 0.5, animations: {
            toViewController.view.frame = finalToFrame
            fromViewController.view.frame = finalFromFrame
        }, completion: { finished in
            let fromVC = self.source
            let toVC = self.destination
            fromVC.present(toVC, animated: false, completion: nil)
        })
    }
    
    private func animateGrowScale() {
        let toViewController = destination
        let fromViewController = source
        
        let containerView = fromViewController.view.superview
        let originalCenter = fromViewController.view.center
        
        toViewController.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        toViewController.view.center = originalCenter
        
        containerView?.addSubview(toViewController.view)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            toViewController.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: { finished in
            let fromVC = self.source
            let toVC = self.destination
            fromVC.present(toVC, animated: false, completion: nil)
        })
    }
    
    private func animateCornerRotate() {
        let toViewController = destination
        let fromViewController = source
        
        toViewController.view.layer.anchorPoint = CGPoint.zero
        fromViewController.view.layer.anchorPoint = CGPoint.zero
        
        toViewController.view.layer.position = CGPoint.zero
        fromViewController.view.layer.position = CGPoint.zero
        
        let containerView: UIView? = fromViewController.view.superview
        toViewController.view.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        containerView?.addSubview(toViewController.view)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [], animations: {
            fromViewController.view.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
            toViewController.view.transform = CGAffineTransform.identity
        }, completion: { finished in
            let fromVC: UIViewController = self.source
            let toVC: UIViewController = self.destination
            fromVC.present(toVC, animated: false, completion: nil)
        })
    }
}
