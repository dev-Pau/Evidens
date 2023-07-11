//
//  ContainerViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/9/22.
//

import UIKit

class ContainerViewController: UIViewController {
    
    enum MEMenuState {
        case opened
        case closed
    }
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    var panEnabled: Bool = true
    var isEditingConversation: Bool = false
    
    private var menuState: MEMenuState = .closed
    private var viewIsOnConversations: Bool = false
    
    private var viewIsOnGroupsViewController: Bool = false
    private var disableRightPan: Bool = false
    
    private var menuWidth: CGFloat = UIScreen.main.bounds.width - 50
    private var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    let menuController = SideMenuViewController()
    let mainController = MainViewController()
    
    private let appearanceMenuLauncher = AppearanceMenuLauncher()
    
    private lazy var blackBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0)
        view.isUserInteractionEnabled = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissMenu)))
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceMenuLauncher.delegate = self
        addChildVCs()
        view.backgroundColor = .systemBackground
        blackBackgroundView.frame = view.bounds
        view.addSubview(blackBackgroundView)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            view.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
    }
    
    private func addChildVCs() {

        addChild(menuController)
        menuController.view.frame = CGRect(x: 0 - view.frame.size.width, y: 0, width: menuWidth, height: view.frame.size.height)
        view.addSubview(menuController.view)
        menuController.delegate = self
        menuController.didMove(toParent: self)
        
        addChild(mainController)
        mainController.view.frame = CGRect(x: 0, y: 0, width: screenWidth * 2, height: view.frame.size.height)
        mainController.delegate = self
        view.addSubview(mainController.view)
        mainController.didMove(toParent: self)
    }
    
    private func openMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.mainController.view.frame.origin.x = self.menuWidth
            //translation.x / 500
            self.menuController.view.frame.origin.x = 0
            self.blackBackgroundView.frame.origin.x = self.mainController.view.frame.origin.x
            self.blackBackgroundView.backgroundColor = .systemBackground.withAlphaComponent(0.65)
            self.mainController.updateUserProfileImageViewAlpha(withAlfa: 1)
        } completion: { done in
            if done {
                self.blackBackgroundView.isUserInteractionEnabled = true
                self.menuState = .opened
                if self.viewIsOnGroupsViewController == true {
                    // User is in groups VC
                    self.disableRightPan = false
                }
            }
        }
    }
    
    private func closeMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.mainController.view.frame.origin.x = 0
            self.blackBackgroundView.frame.origin.x = self.mainController.view.frame.origin.x
            self.blackBackgroundView.backgroundColor = .systemBackground.withAlphaComponent(0)
            self.menuController.view.frame.origin.x = 0 - self.view.frame.size.width
            self.mainController.updateUserProfileImageViewAlpha(withAlfa: 0)
        } completion: { done in
            if done {
                self.blackBackgroundView.isUserInteractionEnabled = false
                self.menuState = .closed
                if self.viewIsOnGroupsViewController {
                    self.disableRightPan = true
                }
            }
        }
    }
    
    private func openConversation() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) { [self] in
            self.mainController.view.frame.origin.x = 0 - screenWidth
            //self.blackBackgroundView.frame.origin.x = self.mainController.view.frame.origin.x
        } completion: { done in
            if done {
                self.viewIsOnConversations = true
            }
        }
    }
    
    private func closeConversation() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.mainController.view.frame.origin.x = 0
            self.blackBackgroundView.frame.origin.x = self.mainController.view.frame.origin.x
        } completion: { done in
            if done {
                self.viewIsOnConversations = false
            }
        }
    }
    
    @objc func dismissMenu() {
        closeMenu()
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        
        // Disable right gesture at groups VC
        if translation.x < 0 && disableRightPan { return }
        
        if viewIsOnConversations {
            if recognizer.state == .ended {

                if translation.x < 0 {
                    openConversation()
                } else {
                    closeConversation()
                }
                return
            }
            
            if translation.x >= 0 - UIScreen.main.bounds.width && translation.x > 0.0 {
                self.mainController.view.frame.origin.x =  0 - screenWidth + translation.x
                
                
            }
            
          return
        }
        
        if recognizer.state == .ended {
            switch menuState {
            case .opened:
                if translation.x < 0 {
                    closeMenu()
                } else {
                    openMenu()
                }
            case .closed:
                if translation.x > 0 {
                    openMenu()
                } else {
                    closeMenu()
                    openConversation()
                }
            }
            
            return
        }
        
        switch menuState {
        case .opened:
            if translation.x >= 0 - (menuWidth) && translation.x < 0.0 {
                self.mainController.view.frame.origin.x = screenWidth - 50 + translation.x
                self.blackBackgroundView.frame.origin.x = self.mainController.view.frame.origin.x
                self.blackBackgroundView.backgroundColor = .systemBackground.withAlphaComponent(0.65 + translation.x / 500)
                self.mainController.updateUserProfileImageViewAlpha(withAlfa: 0.65 + translation.x / 500)
                self.menuController.view.frame.origin.x = translation.x
                if viewIsOnGroupsViewController { }
                
            }
        case .closed:
            if translation.x > 0.0 && translation.x <= screenWidth - 50 {
                self.mainController.view.frame.origin.x = translation.x
                self.blackBackgroundView.frame.origin.x = self.mainController.view.frame.origin.x
                self.blackBackgroundView.backgroundColor = .systemBackground.withAlphaComponent(translation.x / 500)
                self.menuController.view.frame.origin.x = 0 - menuWidth + translation.x
                self.mainController.updateUserProfileImageViewAlpha(withAlfa: translation.x / 500)
            } else {
                self.mainController.view.frame.origin.x = translation.x
            }
        }
    }
    
    
}

extension ContainerViewController: MainViewControllerDelegate {
    func configureMenuWithUser(user: User) {
        menuController.updateUserData(user: user)
    }
    
    func updateUser(user: User) {
        menuController.updateUserData()
    }
    
    func handleDisablePanWhileEditing(editing: Bool) {
        //panGestureRecognizer.isEnabled = !editing
        //isEditingConversation = editing ? true : false
    }
    
    func showConversations() {
        openConversation()
    }
    
    func handleMenu() {
        switch menuState {
        case .opened:
            closeMenu()
        case .closed:
            openMenu()
        }
    }
    
    func handleDisablePan() {
        panEnabled.toggle()
        panGestureRecognizer.isEnabled = !panEnabled
    }
    
    func hideConversations() {
        closeConversation()
    }
    
    func handleDisableRightPan() {
        viewIsOnGroupsViewController.toggle()
        disableRightPan = viewIsOnGroupsViewController
    }
}


extension ContainerViewController: SideMenuViewControllerDelegate {
    func didSelectSubMenuOption(option: SideSubMenuKind) {
        closeMenu()
        mainController.pushSubMenuOptionController(option: option)
    }
    
    func didTapAppearanceMenu() {
        appearanceMenuLauncher.showPostSettings(in: view)
        handleDisablePan()
    }
    
    func didSelectMenuOption(option: SideMenu) {
        closeMenu()
        mainController.pushMenuOptionController(option: option)
    }
    /*
    func didTapSettings() {
        closeMenu()
        mainController.pushSettingsViewController()
    }
    
    */
    func didTapMenuHeader() {
        closeMenu()
        mainController.pushUserProfileViewController()
    }
}

extension ContainerViewController: AppearanceMenuLauncherDelegate {
    func didTapAppearanceSetting(_ sw: UISwitch, setting: Appearance) {
        menuController.updateAppearanceSettings(sw, appearance: setting)
    }
    
    func didCloseMenu() {
        handleDisablePan()
    }
}


extension ContainerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if viewIsOnConversations {
            if let currentGesture = otherGestureRecognizer as? UIPanGestureRecognizer {
                if currentGesture.translation(in: self.view).x < 0 {
                    return true
                }
                return false
            }
        }
        return false
    }
}
