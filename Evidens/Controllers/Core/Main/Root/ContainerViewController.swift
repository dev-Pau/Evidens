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
    
    var baseLogoView: BaseLogoView!
    private var loadingView: Bool?
    
    private var menuState: MEMenuState = .closed
    private var viewIsOnConversations: Bool = false
    
    private var isNoLongerMainView: Bool = false
    private var disableRightPan: Bool = false
    
    private var menuWidth: CGFloat = UIScreen.main.bounds.width - 50
    private var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    let menuController = SideMenuViewController()
    let mainController = MainViewController()
    
    private let appearanceMenuLauncher = AppearanceMenu()
    
    private lazy var blackBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0)
        view.isUserInteractionEnabled = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissMenu)))
        return view
    }()
    
    init(withLoadingView loadingView: Bool? = nil) {
        if let loadingView {
            self.loadingView = loadingView
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceMenuLauncher.delegate = self

        view.backgroundColor = .systemBackground
        blackBackgroundView.frame = view.bounds
        view.addSubview(blackBackgroundView)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            view.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        
        addChildVCs()
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
        
        if let _ = loadingView {
            handleDisablePan()
            baseLogoView = BaseLogoView(frame: view.bounds)
            baseLogoView.backgroundColor = baseColor
            view.addSubview(baseLogoView)
        }
    }
    
    private func openMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.mainController.view.frame.origin.x = strongSelf.menuWidth
            strongSelf.menuController.view.frame.origin.x = 0
            strongSelf.blackBackgroundView.frame.origin.x = strongSelf.mainController.view.frame.origin.x
            strongSelf.blackBackgroundView.backgroundColor = .systemBackground.withAlphaComponent(0.65)
            strongSelf.mainController.updateUserProfileImageViewAlpha(withAlfa: 1)
        } completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.blackBackgroundView.isUserInteractionEnabled = true
            strongSelf.menuState = .opened
            if strongSelf.isNoLongerMainView == true {
                strongSelf.disableRightPan = false
            }
        }
    }
    
    private func closeMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.mainController.view.frame.origin.x = 0
            strongSelf.blackBackgroundView.frame.origin.x = strongSelf.mainController.view.frame.origin.x
            strongSelf.blackBackgroundView.backgroundColor = .systemBackground.withAlphaComponent(0)
            strongSelf.menuController.view.frame.origin.x = 0 - strongSelf.view.frame.size.width
            strongSelf.mainController.updateUserProfileImageViewAlpha(withAlfa: 0)
        } completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.blackBackgroundView.isUserInteractionEnabled = false
            strongSelf.menuState = .closed
                if strongSelf.isNoLongerMainView {
                    strongSelf.disableRightPan = true
            }
        }
    }
    
    private func openConversation() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.mainController.view.frame.origin.x = 0 - strongSelf.screenWidth
        } completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.viewIsOnConversations = true
        }
    }
    
    private func closeConversation() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.mainController.view.frame.origin.x = 0
            strongSelf.blackBackgroundView.frame.origin.x = strongSelf.mainController.view.frame.origin.x
        } completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.viewIsOnConversations = false
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
                if isNoLongerMainView { }
                
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
    
    func controllersLoaded() {
        let auth = UserDefaults.getAuth()
        if let _ = loadingView {
            
            baseLogoView.removeFromSuperview()
            loadingView = nil
            handleDisablePan()
            
            if !auth {
                AuthService.logout()
                AuthService.googleLogout()
                let controller = OpeningViewController()
                let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
                return
            }
        }

        if let uid = UserDefaults.getUid() {
            DataService.shared.initialize(userId: uid)
            mainController.conversationController.loadConversations()
            NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
            getNewNotificationCount()
        }
    }
    
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
        isNoLongerMainView.toggle()
        disableRightPan = isNoLongerMainView
    }
    
    private func getNewNotificationCount() {
        let date = DataService.shared.getLastNotificationDate()
        
        NotificationService.fetchNewNotificationCount(since: date) { [weak self] results in
            guard let _ = self else { return }
            switch results {

            case .success(let notifications):
                NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadNotifications), object: nil, userInfo: ["notifications": notifications])
            case .failure(_):
                NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadNotifications), object: nil, userInfo: ["notifications": 0])
            }
        }
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

    func didTapMenuHeader() {
        closeMenu()
        mainController.pushUserProfileViewController()
    }
}

extension ContainerViewController: AppearanceMenuDelegate {
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
