//
//  CustomAnimationDismiss.swift
//  InstaFake
//
//  Created by Admin on 11.09.2018.
//  Copyright © 2018 MaximMasov. All rights reserved.
//

import UIKit

class CustomAnimationDismisser: NSObject, UIViewControllerAnimatedTransitioning{
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Custom transition animation code for dismiss
        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: .from) else {return}
        guard let ToView = transitionContext.view(forKey: .to) else {return}
        containerView.addSubview(ToView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            //animation
            fromView.frame = CGRect(x: -fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
            ToView.frame = CGRect(x: 0, y: 0, width: ToView.frame.width, height: ToView.frame.height)
        }) { (_) in
            transitionContext.completeTransition(true)
        }
        
    }
    
}
