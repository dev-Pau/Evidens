//
//  ContainerController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/5/22.
//

import UIKit

class ContainerController: UIViewController {
    
    private var centerController: UINavigationController!
    private var menu: MenuController!
    private var shadowView: UIView!
    private var isExpanded = false
    
    var user: User? {
        didSet {
            configureFeedController()
            //configureMenuController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configureFeedController() {
        guard centerController == nil else { return }
        guard let user = user else { return }
        
        let feed = FeedViewController(collectionViewLayout: UICollectionViewFlowLayout())
        feed.delegate = self
        feed.user = user
        
        centerController = UINavigationController(rootViewController: feed)
        view.addSubview(centerController.view)
        addChild(centerController)
        centerController.didMove(toParent: self)
    }
    
    
    
}


// MARK: - FeedControllerDelegate

extension ContainerController: FeedControllerDelegate {
    func handleMenuToggle() {
        isExpanded.toggle()
        //animateMenu(shouldExpand: isExpanded)
    }
}


