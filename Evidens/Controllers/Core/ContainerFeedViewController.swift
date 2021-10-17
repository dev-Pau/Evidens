//
//  ContainerFeedViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/10/21.
//

import UIKit

class ContainerFeedViewController: UIViewController {
    
    //MARK: - Properties
    var feedMenu: UIViewController!
    var centerController: UIViewController!
    var isExpanded = false
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFeedController()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - Helpers
    
    func configureFeedController() {
        let feedLayout = UICollectionViewFlowLayout()
        let feedController = FeedViewController(collectionViewLayout: feedLayout)
        feedController.feedDelegate = self
        centerController = UINavigationController(rootViewController: feedController)
        
        view.addSubview(centerController.view)
        addChild(centerController)
        centerController.didMove(toParent: self)
    }
    
    func configureMenuController() {
        if feedMenu == nil {
            feedMenu = FeedMenuViewController()
            view.insertSubview(feedMenu.view, at: 0)
            addChild(feedMenu)
            feedMenu.didMove(toParent: self)
            print("did tap menu controller")
        }
    }
    
    func showMenuController(shouldExpand: Bool) {
        if shouldExpand {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.centerController.view.frame.origin.x = self.centerController.view.frame.width - 80
            }, completion: nil)
                
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.centerController.view.frame.origin.x = 0
            }, completion: nil)
            
        }
    }
}

extension ContainerFeedViewController: FeedViewControllerDelegate {
    
    func handleMenuToggle() {
        if !isExpanded {
            configureMenuController()
        }
        isExpanded = !isExpanded
        showMenuController(shouldExpand: isExpanded)
    }
    
    
}
