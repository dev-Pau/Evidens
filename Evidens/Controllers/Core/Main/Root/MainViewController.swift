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
    func hideConversations()
    func showConversations()
    func handleDisableRightPan()
    func handleDisablePanWhileEditing(editing: Bool)
    func updateUser(user: User)
    func configureMenuWithUser(user: User)
}

class MainViewController: UIViewController {
    
    weak var delegate: MainViewControllerDelegate?
    
    let mainController = MainTabController()
    let conversationController = ConversationViewController()

    
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
        
        let conversationNavigationController = UINavigationController(rootViewController: conversationController)
        conversationNavigationController.view.frame = CGRect(x: UIScreen.main.bounds.width, y: 0, width: 0, height: view.frame.size.height)
        conversationController.delegate = self
        addChild(conversationNavigationController)
        view.addSubview(conversationNavigationController.view)
        conversationNavigationController.didMove(toParent: self)
    }
    
    
    func pushUserProfileViewController() {
        mainController.pushUserProfileViewController()
    }
    
    func pushSettingsViewController() {
        mainController.pushSettingsViewController()
    }
    
    func updateUserProfileImageViewAlpha(withAlfa alfa: CGFloat) {
        mainController.updateUserProfileImageViewAlpha(alfa: alfa)
    }
    
    func pushMenuOptionController(option: SideMenuViewController.MenuOptions) {
        mainController.pushMenuOption(option: option)
    }
}

extension MainViewController: MainTabControllerDelegate {
    func configureControllersWithUser(user: User) {
        conversationController.user = user
        delegate?.configureMenuWithUser(user: user)
    }
    
    func updateUser(user: User) {
        delegate?.updateUser(user: user)
    }
    
    func handleConversations() {
        delegate?.showConversations()
    }
    
    func handleMenu() {
        delegate?.handleMenu()
    }
    
    func handleDisablePan() {
        delegate?.handleDisablePan()
    }
    
    func handleDisableRightPan() {
        delegate?.handleDisableRightPan()
    }
}

extension MainViewController: ConversationViewControllerDelegate {
    func handleTooglePan() {
        delegate?.handleDisablePan()
    }

    func didTapHideConversations() {
        delegate?.hideConversations()
    }
}
