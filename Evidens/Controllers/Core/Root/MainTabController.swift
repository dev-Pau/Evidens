//
//  MainTabController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

protocol MainTabControllerDelegate: AnyObject {
    func handleUserIconTap()
    func toggleScroll(_ enabled: Bool)
    func updateUser(user: User)
    func configureControllersWithUser(user: User)
    func controllersLoaded()
}

class MainTabController: UITabBarController, UINavigationControllerDelegate {
    
    //MARK: Properties
    
    private var menuLauncher = ContentMenu()
    
    weak var menuDelegate: MainTabControllerDelegate?

    private var collapsed: Bool = false
  
    var user: User? {
        didSet {
            guard let user = user else { return }
            menuDelegate?.configureControllersWithUser(user: user)
            
            switch user.phase {
                
            case .category, .name, .username, .identity, .pending, .review, .verified:
                break
            case .deactivate:
                let controller = ActivateAccountViewController(user: user)
                let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
            case .ban:
                let controller = BanAccountViewController(user: user)
                let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
            case .deleted:
                showMainScreen()
            }
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        checkIfUserIsLoggedIn()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: - API
    
    private func configure() {
        view.backgroundColor = .systemBackground
        tabBar.isHidden = true
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.networkDelegate = self

        menuLauncher.delegate = self
    }
    
    func fetchUser() {
        
        guard let currentUser = Auth.auth().currentUser else {
            showMainScreen()
            return
        }

        UserService.fetchUser(withUid: currentUser.uid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let user):
                
                strongSelf.configureCurrentController(withUser: user)

            case .failure(let error):

                switch error {
                case .network:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.configureCurrentController()
                    }
                case .notFound, .unknown:
                    strongSelf.showMainScreen()
                }
            }
        }
    }
    
    private func checkIfUserIsLoggedIn() {
        guard UserDefaults.getAuth() == true else {
            showMainScreen()
            return
        }

        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        fetchUser()
    }
    
    private func configureCurrentController(withUser user: User? = nil) {
        
        if let user {
            setUserDefaults(for: user)
        }
        
        self.user = user

        if let user {

            refreshUser()
            
            switch user.phase {
            case .category:
                let controller = CategoryViewController(user: user)
                let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
                
            case .name:
                let controller = FullNameViewController(user: user)
                let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
            case .username:
                let controller = UsernameViewController(user: user)
                let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
                
            case .identity:
                let controller = VerificationViewController(user: user)
                let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
                
            case .pending:
                configureViewControllers(withUser: user)
                
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    NotificationService.syncPreferences(settings.authorizationStatus)
                }
                
                tabBar.isHidden = false
            case .review:
                configureViewControllers(withUser: user)
                
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    NotificationService.syncPreferences(settings.authorizationStatus)
                }
                tabBar.isHidden = false
                
            case .verified:
                configureViewControllers(withUser: user)
                
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    NotificationService.syncPreferences(settings.authorizationStatus)
                }
                
                tabBar.isHidden = false
                
            case .deactivate:
                let controller = ActivateAccountViewController(user: user)
                let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
                
            case .ban:
                let controller = BanAccountViewController(user: user)
                let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
            case .deleted:
                showMainScreen()
            }
            
            menuDelegate?.controllersLoaded()
            
        } else {
            // Here there's a network error connection we switch the UserDefaults phase and if it's not verified, deactivated or ban
            guard let phase = UserDefaults.getPhase() else {
                showMainScreen()
                return
            }
            
            switch phase {
                
            case .category, .name, .username, .identity, .deactivate, .ban, .pending, .review, .deleted:
                showMainScreen()
            case  .verified:
                menuDelegate?.controllersLoaded()
                configureViewControllers()
                tabBar.isHidden = false
            }
        }
    }
    
    //MARK: - Helpers

    func configureViewControllers(withUser: User? = nil) {
        view.backgroundColor = .systemBackground
        self.delegate = self
        
        let casesController = CasesViewController()
        casesController.delegate = self
        casesController.scrollDelegate = self
        
        let postsController = PostsViewController(source: .home)
        postsController.delegate = self
        postsController.scrollDelegate = self
        
        let notificationsController = NotificationsViewController()
        notificationsController.delegate = self
        notificationsController.scrollDelegate = self
        
        let searchController = SearchViewController()
        searchController.scrollDelegate = self
        searchController.delegate = self
        
        let cases = UINavigationController(rootViewController: casesController)
        cases.tabBarItem.image = UIImage(systemName: AppStrings.Icons.clipboard)?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        cases.tabBarItem.selectedImage = UIImage(systemName: AppStrings.Icons.clipboard)?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        cases.tabBarItem.title = AppStrings.Tab.cases

        let posts = UINavigationController(rootViewController: postsController)
        posts.tabBarItem.image = UIImage(systemName: AppStrings.Icons.network)?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        posts.tabBarItem.selectedImage = UIImage(systemName: AppStrings.Icons.network)?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        posts.tabBarItem.title = AppStrings.Tab.network
        
        let notifications = UINavigationController(rootViewController: notificationsController)
        notifications.tabBarItem.image = UIImage(systemName: AppStrings.Icons.fillBell)?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        notifications.tabBarItem.selectedImage = UIImage(systemName: AppStrings.Icons.fillBell)?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        notifications.tabBarItem.title = AppStrings.Tab.notifications
        
        let search = UINavigationController(rootViewController: searchController)
        search.tabBarItem.image = UIImage(systemName: AppStrings.Icons.magnifyingglass)?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        search.tabBarItem.selectedImage = UIImage(systemName: AppStrings.Icons.magnifyingglass)?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        search.tabBarItem.title = AppStrings.Tab.search
       
        viewControllers = [cases, posts, notifications, search]
        
        if let user {

            if user.phase == .verified {
                NotificationCenter.default.addObserver(self, selector: #selector(refreshUnreadNotifications(_:)), name: NSNotification.Name(AppPublishers.Names.refreshUnreadNotifications), object: nil)
            } else {
                guard let _ = tabBar.items else {
                    showMainScreen()
                    return
                }
            }
            
            if user.phase == .pending {
                showVerificationController()
            }
            
        } else {
            guard let phase = UserDefaults.getPhase(), phase == .verified else {
                showMainScreen()
                return
            }

            viewControllers = [cases, posts, notifications, search]
        }
    }
    
    private func showMainScreen() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.logout()
            let controller = OpeningViewController()
            let sceneDelegate = strongSelf.view.window?.windowScene?.delegate as? SceneDelegate
            sceneDelegate?.updateRootViewController(controller)
        }
    }
    
    @objc func appDidBecomeActive() {
        refreshUser()
    }
    
    private func refreshUser() {

        guard UserDefaults.getAuth() == true, let currentUser = Auth.auth().currentUser, let uid = UserDefaults.getUid(), currentUser.uid == uid else {
            showMainScreen()
            return
        }

        if let user {
            currentUser.reload { [weak self] error in
                guard let strongSelf = self else { return }
                
                if let error {
                    
                    let nsError = error as NSError
                    let errCode = AuthErrorCode(_nsError: nsError)
                    switch errCode.code {
                        
                    case .userTokenExpired:
                        strongSelf.showMainScreen()
                    default:
                        break
                    }
                } else {
                    if let email = currentUser.email, user.email != email {
                        strongSelf.user?.set(email: email)
                        UserService.updateEmail(forUserId: currentUser.uid, email: email)
                    }
                }
            }
        }
    }
    
    private func showVerificationController() {
        guard let user = user else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let strongSelf = self else { return }
            let controller = VerificationViewController(user: user, comesFromMainScreen: true)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            strongSelf.present(navVC, animated: true)
        }
    }
    
    func templateNavigationController(title: String?, unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController) -> UINavigationController {
        
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = unselectedImage.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24))
        nav.tabBarItem.title = title
        nav.tabBarItem.selectedImage = selectedImage.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24))
        return nav
    }
    
    func pushUserProfileViewController() {
        if let currentNavController = selectedViewController as? UINavigationController {
            guard let user = user else { 
                displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                return
            }
            
            currentNavController.delegate = self
            let controller = UserProfileViewController(user: user)
            currentNavController.pushViewController(controller, animated: true)
        }
    }
    
    func pushMenuOption(option: SideMenu) {
        if let currentNavController = selectedViewController as? UINavigationController {
            
            switch option {
            case .profile:
                pushUserProfileViewController()
            case .bookmark:
                let controller = BookmarksViewController()
                currentNavController.delegate = self
                currentNavController.pushViewController(controller, animated: true)
            case .create:
                if let phase = UserDefaults.getPhase(), phase == .verified {
                    menuLauncher.showPostSettings(in: view)
                } else {
                    ContentManager.shared.permissionAlert(kind: .share)
                }
            case .draft:
                let controller = DraftsViewController()
                currentNavController.pushViewController(controller, animated: true)
            }
        }
    }

    func pushSubMenuOption(option: SideSubMenuKind) {
        if let currentNavController = selectedViewController as? UINavigationController {
            switch option {
            case .settings:
                let controller = SettingsViewController()
                currentNavController.pushViewController(controller, animated: true)
            case .legal:
                let controller = LegalInquiresViewController()
                currentNavController.pushViewController(controller, animated: true)
            case .app:
                let controller = AboutUsViewController()
                controller.hidesBottomBarWhenPushed = true
                currentNavController.pushViewController(controller, animated: true)
            case .contact:
                let controller = ContactUsViewController()
                currentNavController.pushViewController(controller, animated: true)
            }
        }
    }
    
    func updateUser(user: User) {
        self.user = user
        menuDelegate?.updateUser(user: user)
    }

    @objc func refreshUnreadNotifications(_ notification: NSNotification) {
        if let notifications = notification.userInfo?["notifications"] as? Int {

            let notificationIndex = 2

            if let viewControllers = viewControllers, notificationIndex < viewControllers.count {
                viewControllers[2].tabBarItem.badgeValue = notifications > 0 ? String(notifications) : nil
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if (traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory) {
                guard let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate else {
                    return
                }

                sceneDelegate.updateViewController(ContainerViewController(withLoadingView: true))
            }
        }
    }
}

//MARK: - UITabBarControllerDelegate

extension MainTabController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        if viewController == tabBarController.viewControllers?[1] {
            if let currentNavController = selectedViewController as? UINavigationController {
                if currentNavController.viewControllers.count == 1 {
                    if let controller = currentNavController.viewControllers.first as? PostsViewController, controller.postsLoaded() == true {
                        controller.scrollCollectionViewToTop()
                        return false
                    }
                    return true
                }
                return true
            }
            return true
        } else if viewController == tabBarController.viewControllers?[0] {
            if let currentNavController = selectedViewController as? UINavigationController {
                if currentNavController.viewControllers.count == 1 {
                    if let controller = currentNavController.viewControllers.first as? CasesViewController, controller.casesLoaded() == true {
                        controller.scrollCollectionViewToTop()
                        return false
                    }
                    return true
                }
                return true
            }
            return true
        } else if viewController == tabBarController.viewControllers?[2] {
            if let currentNavController = selectedViewController as? UINavigationController {
                if currentNavController.viewControllers.count == 1 {
                    if let controller = currentNavController.viewControllers.first as? NotificationsViewController, controller.notificationsLoaded() == true {
                        controller.scrollCollectionViewToTop()
                        return false
                    }
                    return true
                }
                return true
            }
            return true
        } else if viewController == tabBarController.viewControllers?[3] {
            if let currentNavController = selectedViewController as? UINavigationController {
                if currentNavController.viewControllers.count == 1 {
                    if let controller = currentNavController.viewControllers.first as? SearchViewController, controller.searchLoaded() == true {
                        controller.scrollCollectionViewToTop()
                        return false
                    }
                    return true
                }
                return true
            }
            return true
        }
        return true
    }
}

extension MainTabController: PostBottomMenuLauncherDelegate {
    func didTapUpload(content: ContentKind) {
        
        guard let user = user, user.phase == .verified else {
            displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
            return
        }
        
        switch content {
        case .post:
            let postController = ContentDisciplinesViewController(kind: .post, user: user)
            let nav = UINavigationController(rootViewController: postController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        case .clinicalCase:
            let clinicalCaseController = ContentDisciplinesViewController(kind: .clinicalCase, user: user)
            let nav = UINavigationController(rootViewController: clinicalCaseController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }
    
    func updateUserProfileImageViewAlpha(alfa: CGFloat) {
        if let currentNavController = selectedViewController as? UINavigationController {
            if collapsed { return }
            currentNavController.viewControllers.last?.navigationItem.leftBarButtonItem?.customView?.alpha = alfa
        }
    }
}

extension MainTabController: NavigationBarViewControllerDelegate {

    func didTapIconImage() {
        menuDelegate?.handleUserIconTap()
    }
    
    func didTapAddButton() {
        
        if let phase = UserDefaults.getPhase(), phase == .verified {
            menuLauncher.showPostSettings(in: view)
        } else {
            ContentManager.shared.permissionAlert(kind: .share)
        }
    }
}

extension MainTabController: PrimaryScrollViewDelegate {
    func enable() {
        menuDelegate?.toggleScroll(true)
    }
    
    func disable() {
        menuDelegate?.toggleScroll(false)
    }
}

extension MainTabController: NetworkDelegate {
    func didBecomeConnected() {

        guard let currentUser = Auth.auth().currentUser else {
            showMainScreen()
            return
        }
        
        UserService.fetchUser(withUid: currentUser.uid) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let user):
                strongSelf.refreshUser()
                strongSelf.user = user
                strongSelf.setUserDefaults(for: user)
            case .failure(let error):
                
                switch error {
                case .network:
                    break
                case .notFound, .unknown:
                    AuthService.logout()
                    AuthService.googleLogout()
                    
                    strongSelf.showMainScreen()
                }
            }
        }
    }
}
