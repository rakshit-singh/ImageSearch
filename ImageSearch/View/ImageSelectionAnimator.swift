//
//  ImageSelectionAnimator.swift
//  ImageSearch
//
//  Created by Rakshit Singh on 16/08/22.
//

import UIKit

class ImageSelectionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    
    let animationDuration = 0.8
    var presenting = true
    var originFrame = CGRect.zero
    

    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        guard let toView = transitionContext.view(forKey: .to),
              let fromView = transitionContext.view(forKey: .from)
        else { return }
        
        // singleImageView represents the view containing a single image in each page
        let singleImageView = presenting ? toView : fromView
        
        let initialFrame = presenting ? originFrame : toView.frame
        let finalFrame = presenting ? singleImageView.frame : originFrame
        
        let xScaleMultiplier = presenting ? (initialFrame.width/finalFrame.width) : (finalFrame.width/initialFrame.width)
        let yScaleMultiplier = presenting ? (initialFrame.height/finalFrame.height) : (finalFrame.height/initialFrame.height)
        
        if presenting{
            singleImageView.transform = CGAffineTransform(scaleX: xScaleMultiplier, y: yScaleMultiplier)
            singleImageView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
            singleImageView.clipsToBounds = true
        }
        
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(singleImageView)
        
        UIView.animate(withDuration: animationDuration,
            delay:0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.2,
            animations: { 
            singleImageView.transform = self.presenting ? CGAffineTransform(scaleX: 1.0, y: 1.0) : CGAffineTransform(scaleX: xScaleMultiplier, y: yScaleMultiplier)
            singleImageView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
        
    }
    

    
    
}
