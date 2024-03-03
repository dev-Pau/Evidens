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

    weak var delegate: MainViewControllerDelegate?
    
    let mainController = MainTabController()

    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVCs()
        
        NotificationCenter.default.addObserver(self, selector: #selector(displayPermissionAlert(_:)), name: NSNotification.Name(AppPublishers.Names.permission), object: nil)
    }
    
    private func addChildVCs() {
        addChild(mainController)

        mainController.view.translatesAutoresizingMaskIntoConstraints = false
        mainController.menuDelegate = self
        mainController.didMove(toParent: self)
       
        view.addSubview(mainController.view)
        NSLayoutConstraint.activate([

            mainController.view.topAnchor.constraint(equalTo: view.topAnchor),
            mainController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainController.view.widthAnchor.constraint(equalToConstant: view.frame.width),
            mainController.view.heightAnchor.constraint(equalToConstant: view.frame.height),
        ])
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
            displayAlert(withTitle: AppStrings.Error.title, withMessage: kind.title)
        }
    }
}

extension MainViewController: MainTabControllerDelegate {
    
    func toggleScroll(_ enabled: Bool) {
        delegate?.toggleScroll(enabled)
    }
    
    func handleUserIconTap() {
        delegate?.handleUserIconTap()
    }
    
    func controllersLoaded() {
        delegate?.controllersLoaded()
    }
    
    func configureControllersWithUser(user: User) {
        delegate?.configureMenuWithUser(user: user)
    }
    
    func updateUser(user: User) {
        delegate?.updateUser(user: user)
    }
}
