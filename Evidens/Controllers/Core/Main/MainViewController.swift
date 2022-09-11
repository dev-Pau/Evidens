//
//  MainViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/9/22.
//

import UIKit

protocol MainViewControllerDelegate: AnyObject {
    func handleMenu()
    func handleDisablePan()
}

class MainViewController: UIViewController {
    
    weak var delegate: MainViewControllerDelegate?
    
    let mainController = MainTabController()
    let conversationNavigationController = UINavigationController(rootViewController: ConversationViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVCs()
    }
    
    private func addChildVCs() {

        mainController.view.frame = CGRect(x: 0, y: 0, width: 0, height: view.frame.size.height)
        addChild(mainController)
        
        mainController.menuDelegate = self
        view.addSubview(mainController.view)
        mainController.didMove(toParent: self)
        
        conversationNavigationController.view.frame = CGRect(x: UIScreen.main.bounds.width, y: 0, width: 0, height: view.frame.size.height)
        addChild(conversationNavigationController)
        view.addSubview(conversationNavigationController.view)
        conversationNavigationController.didMove(toParent: self)
    }
    
    func updateRootViewControllerToConversation() {
        self.navigationController?.pushViewController(conversationNavigationController, animated: false)
    }
    
    func updateRootViewControllerToTabController() {
        
    }
    
    func pushUserProfileViewController() {
        mainController.pushUserProfileViewController()
    }
    
    func updateUserProfileImageViewAlpha(withAlfa alfa: CGFloat) {
        mainController.updateUserProfileImageViewAlpha(alfa: alfa)
    }
}

extension MainViewController: MainTabControllerDelegate {
    func handleMenu() {
        delegate?.handleMenu()
    }
    
    func handleDisablePan() {
        delegate?.handleDisablePan()
    }
}
