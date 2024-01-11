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

    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVCs()
        
        NotificationCenter.default.addObserver(self, selector: #selector(displayPermissionAlert(_:)), name: NSNotification.Name(AppPublishers.Names.permission), object: nil)
    }
    
    private func addChildVCs() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        
        view.addSubview(scrollView)
        addChild(mainController)
        mainController.view.translatesAutoresizingMaskIntoConstraints = false
        mainController.menuDelegate = self
        mainController.didMove(toParent: self)
        
        view.addSubview(scrollView)
        scrollView.addSubviews(mainController.view/*, conversationNavigationController.view*/)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: view.frame.width),
            scrollView.heightAnchor.constraint(equalToConstant: view.frame.height),
            
            mainController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mainController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mainController.view.widthAnchor.constraint(equalToConstant: view.frame.width),
            mainController.view.heightAnchor.constraint(equalToConstant: view.frame.height),
        ])
        
        scrollView.contentSize.width = view.frame.width
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
    
    @objc func displayPermissionAlert(_ notification: NSNotification) {
        if let kind = notification.object as? PermissionKind {
            displayAlert(withTitle: kind.title)
        }
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
        if user.phase == .verified { scrollView.isScrollEnabled = false }
        
        delegate?.configureMenuWithUser(user: user)
    }
    
    func updateUser(user: User) {
        delegate?.updateUser(user: user)
    }
}
