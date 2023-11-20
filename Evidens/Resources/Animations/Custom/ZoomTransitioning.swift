//
//  ZoomTransitioning.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/7/22.
//

import UIKit

protocol ZoomTransitioningDelegate: AnyObject {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView?
}

enum TransitionState {
    case initial
    case final
}

class ZoomTransitioning: NSObject {
    
    var transitionDuration = 0.5
    var operation: UINavigationController.Operation = .none

    private let backgroundScale: CGFloat = 0.7

    
    typealias ZoomingViews = (otherView: UIView, imageView: UIView)
    
    func configureViews(for state: TransitionState, containerView: UIView, backgroundViewController: UIViewController, viewsInBackground: ZoomingViews, viewsInForeground: ZoomingViews, snapshotViews: ZoomingViews) {
        
        switch state {
        case .initial:
            let startingFrame = viewsInBackground.imageView.convert(viewsInBackground.imageView.bounds, to: nil)
            
            backgroundViewController.view.transform = CGAffineTransform.identity
            backgroundViewController.view.alpha = 1
            snapshotViews.imageView.frame = startingFrame
            snapshotViews.imageView.layer.maskedCorners = viewsInBackground.imageView.layer.maskedCorners
            snapshotViews.imageView.layer.cornerRadius = viewsInBackground.imageView.layer.cornerRadius
            
        case .final:
            backgroundViewController.view.transform = CGAffineTransform.identity
            backgroundViewController.view.alpha = 0
            snapshotViews.imageView.frame = viewsInForeground.imageView.convert(viewsInForeground.imageView.bounds, to: nil)
            snapshotViews.imageView.layer.cornerRadius = 0
        }
    }
}

extension ZoomTransitioning: UIViewControllerAnimatedTransitioning {
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toViewController = transitionContext.viewController(forKey: .to)!
        let containerView = transitionContext.containerView
        
        var backgroundViewController = fromViewController
        var foregroundViewController = toViewController
        
        if operation == .pop {
            backgroundViewController = toViewController
            foregroundViewController = fromViewController
        }
        
        let maybeBackgroundImageView = (backgroundViewController as? ZoomTransitioningDelegate)?.zoomingImageView(for: self)
        let maybeForegroundImageView = (foregroundViewController as? ZoomTransitioningDelegate)?.zoomingImageView(for: self)
        
        if maybeBackgroundImageView == nil || maybeForegroundImageView == nil {

            return
        }
        
        let backgroundImageView = maybeBackgroundImageView!
        let foregroundImageView = maybeForegroundImageView!
        
        let imageViewSnapshot = UIImageView(image: backgroundImageView.image)
        imageViewSnapshot.contentMode = .scaleAspectFill
        imageViewSnapshot.layer.masksToBounds = true
        
        backgroundImageView.isHidden = true
        foregroundImageView.isHidden = true
        
        let foregroundViewBackgroundColor = foregroundViewController.view.backgroundColor
        foregroundViewController.view.backgroundColor = .clear
        containerView.backgroundColor = .black
        
        containerView.addSubviews(backgroundViewController.view, foregroundViewController.view, imageViewSnapshot)
        
        var preTransitionState = TransitionState.initial
        var postTransitionState = TransitionState.final
        
        if operation == .pop {
            preTransitionState = .final
            postTransitionState = .initial
        }
        
        configureViews(for: preTransitionState, containerView: containerView, backgroundViewController: backgroundViewController, viewsInBackground: (backgroundImageView, backgroundImageView), viewsInForeground: (foregroundImageView, foregroundImageView), snapshotViews: (imageViewSnapshot, imageViewSnapshot))
        
        foregroundViewController.view.layoutIfNeeded()
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseOut) {
            
            self.configureViews(for: postTransitionState, containerView: containerView, backgroundViewController: backgroundViewController, viewsInBackground: (backgroundImageView, backgroundImageView), viewsInForeground: (foregroundImageView, foregroundImageView), snapshotViews: (imageViewSnapshot, imageViewSnapshot))
        } completion: { finished in
            
            backgroundViewController.view.transform = CGAffineTransform.identity
            imageViewSnapshot.removeFromSuperview()
            backgroundImageView.isHidden = false
            foregroundImageView.isHidden = false
            foregroundViewController.view.backgroundColor = foregroundViewBackgroundColor
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
}

//MARK: - UINavigationControllerDelegate

extension ZoomTransitioning: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC is ZoomTransitioningDelegate && toVC is ZoomTransitioningDelegate {
            self.operation = operation
            return self
        }
        return nil
    }
}
