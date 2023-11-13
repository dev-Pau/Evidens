//
//  MainViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/9/22.
//

import UIKit

protocol MainViewControllerDelegate: AnyObject {
    func handleUserIconTap()
    func updateUser(user: User)
    func configureMenuWithUser(user: User)
    func controllersLoaded()
    func toggleScroll(_ enabled: Bool)
}

class MainViewController: UIViewController {
    
    private var scrollView: UIScrollView!
    
    weak var delegate: MainViewControllerDelegate?
    
    let mainController = MainTabController()
    let conversationController = ConversationViewController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVCs()
    }
    
    private func addChildVCs() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        
        view.addSubview(scrollView)
        //mainController.view.frame = CGRect(x: 0, y: 0, width: 0, height: view.frame.size.height)
        addChild(mainController)
        mainController.view.translatesAutoresizingMaskIntoConstraints = false
        mainController.menuDelegate = self
        //view.addSubview(mainController.view)
        mainController.didMove(toParent: self)
        
        let conversationNavigationController = UINavigationController(rootViewController: conversationController)
        //conversationNavigationController.view.frame = CGRect(x: UIScreen.main.bounds.width, y: 0, width: 0, height: view.frame.size.height)
        conversationController.delegate = self
        addChild(conversationNavigationController)
        conversationNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
        //view.addSubview(conversationNavigationController.view)
        conversationNavigationController.didMove(toParent: self)
        
        view.addSubview(scrollView)
        scrollView.addSubviews(mainController.view, conversationNavigationController.view)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: view.frame.width),
            scrollView.heightAnchor.constraint(equalToConstant: view.frame.height),
            
            mainController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mainController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mainController.view.widthAnchor.constraint(equalToConstant: view.frame.width),
            mainController.view.heightAnchor.constraint(equalToConstant: view.frame.height),
            
            conversationNavigationController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            conversationNavigationController.view.leadingAnchor.constraint(equalTo: mainController.view.trailingAnchor),
            conversationNavigationController.view.widthAnchor.constraint(equalToConstant: view.frame.width),
            conversationNavigationController.view.heightAnchor.constraint(equalToConstant: view.frame.height)
        ])
        
        scrollView.contentSize.width = 2 * view.frame.width
    }
    
    
    func pushUserProfileViewController() {
        mainController.pushUserProfileViewController()
    }

    func updateUserProfileImageViewAlpha(withAlfa alfa: CGFloat) {
        mainController.updateUserProfileImageViewAlpha(alfa: alfa)
    }
    
    func pushMenuOptionController(option: SideMenu) {
        mainController.pushMenuOption(option: option)
    }
    
    func pushSubMenuOptionController(option: SideSubMenuKind) {
        mainController.pushSubMenuOption(option: option)
    }
}

extension MainViewController: MainTabControllerDelegate {
    func toggleConversationScroll(_ enabled: Bool) {
        scrollView.isScrollEnabled = enabled
    }
    
    func toggleScroll(_ enabled: Bool) {
        scrollView.isScrollEnabled = enabled
        delegate?.toggleScroll(enabled)
    }
    
    func showConversations() {
        scrollView.setContentOffset(CGPoint(x: view.frame.width, y: 0), animated: true)
    }
    
    func handleUserIconTap() {
        delegate?.handleUserIconTap()
    }
    
    func controllersLoaded() {
        delegate?.controllersLoaded()
    }
    
    func configureControllersWithUser(user: User) {
        conversationController.user = user
        
        if user.phase == .verified { scrollView.isScrollEnabled = false }
        
        delegate?.configureMenuWithUser(user: user)
    }
    
    func updateUser(user: User) {
        delegate?.updateUser(user: user)
    }
}

extension MainViewController: ConversationViewControllerDelegate {
    func hideConversations() {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}
