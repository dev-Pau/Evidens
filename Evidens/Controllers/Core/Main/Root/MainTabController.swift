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
    func toggleConversationScroll(_ enabled: Bool)
    func showConversations()
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
                
            case .category, .details, .identity, .pending, .review, .verified:
                break
            case .deactivate:
                let controller = ActivateAccountViewController(user: user)
                let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
            case .ban:
                let controller = BanAccountViewController(user: user)
                let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
            }
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        checkIfUserIsLoggedIn()
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

        //Fetch user with user uid
        UserService.fetchUser(withUid: currentUser.uid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let user):
                if let email = currentUser.email, email != user.email {
                    UserService.updateEmail(email: email)
                }
                
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

        fetchUser()
    }
    
    private func configureCurrentController(withUser user: User? = nil) {
        
        if let user {
            setUserDefaults(for: user)
        }
        
        self.user = user

        if let user {
            
            switch user.phase {
            case .category:
                let controller = CategoryViewController(user: user)
                let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
                
            case .details:
                let controller = FullNameViewController(user: user)
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
            }
            
            menuDelegate?.controllersLoaded()
            
        } else {
            // Here there's a network error connection we switch the UserDefaults phase and if it's not verified, deactivated or ban
            guard let phase = getPhase() else {
                showMainScreen()
                return
            }
            
            switch phase {
                
            case .category, .details, .identity, .deactivate, .ban, .pending, .review:
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
        
        let homeController = PostsViewController(source: .home)
        homeController.delegate = self
        homeController.scrollDelegate = self
        
        let casesController = CasesViewController()
        casesController.delegate = self
        casesController.scrollDelegate = self
        
        let notificationsController = NotificationsViewController()
        notificationsController.delegate = self
        notificationsController.scrollDelegate = self
        
        let searchController = SearchViewController()
        searchController.scrollDelegate = self
        searchController.delegate = self
        
        let home = templateNavigationController(title: AppStrings.Tab.home, unselectedImage: UIImage(named: AppStrings.Assets.home)!, selectedImage: UIImage(named: AppStrings.Assets.selectedHome)!, rootViewController: homeController)

        let cases = templateNavigationController(title: AppStrings.Tab.cases, unselectedImage: UIImage(named: AppStrings.Assets.cases)!, selectedImage: UIImage(named: AppStrings.Assets.selectedCases)!, rootViewController: casesController)
        cases.navigationBar.tag = 1
        
        let search = UINavigationController(rootViewController: searchController)
        search.tabBarItem.image = UIImage(systemName: AppStrings.Icons.magnifyingglass)?.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        search.tabBarItem.selectedImage = UIImage(systemName: AppStrings.Icons.magnifyingglass, withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        search.tabBarItem.title = AppStrings.Tab.search
       
        let notifications = templateNavigationController(title: AppStrings.Tab.notifications, unselectedImage: UIImage(named: AppStrings.Assets.notification)!, selectedImage: UIImage(named: AppStrings.Assets.selectedNotification)!, rootViewController: notificationsController)
        
        
        if let user {
            
            if user.phase == .verified {
                viewControllers = [home, cases, notifications, search]
                NotificationCenter.default.addObserver(self, selector: #selector(refreshUnreadNotifications(_:)), name: NSNotification.Name(AppPublishers.Names.refreshUnreadNotifications), object: nil)
            } else {
                menuDelegate?.toggleConversationScroll(false)
                viewControllers = [home]
            }
            
            if user.phase == .pending {
                showVerificationController()
            }
        } else {
            guard let phase = getPhase(), phase == .verified else {
                showMainScreen()
                return
            }

            viewControllers = [home, cases, notifications, search]
        } 
    }
    
    private func showMainScreen() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            UserDefaults.standard.set(false, forKey: "auth")
            let controller = OpeningViewController()
            let sceneDelegate = strongSelf.view.window?.windowScene?.delegate as? SceneDelegate
            sceneDelegate?.updateRootViewController(controller)
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
            guard let user = user else { return }
            currentNavController.delegate = self
            let controller = UserProfileViewController(user: user)
            currentNavController.pushViewController(controller, animated: true)
        }
    }
    
    func pushMenuOption(option: SideMenu) {
        if let currentNavController = selectedViewController as? UINavigationController {
            
            switch option {
            case .profile:
                guard let _ = user else { return }
                pushUserProfileViewController()
            case .bookmark:
                let controller = BookmarksViewController()
                currentNavController.delegate = self
                currentNavController.pushViewController(controller, animated: true)
            case .create:
                menuLauncher.showPostSettings(in: view)
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
}

//MARK: - UITabBarControllerDelegate

extension MainTabController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController == tabBarController.viewControllers?[0] {
            if let currentNavController = selectedViewController as? UINavigationController {
                if currentNavController.viewControllers.count == 1 {
                    if let controller = currentNavController.viewControllers.first as? PostsViewController {
                        controller.scrollCollectionViewToTop()
                        return false
                    }
                    return true
                }
                return true
            }
            return true
        } else if viewController == tabBarController.viewControllers?[1] {
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
        }
        return true
    }
}

extension MainTabController: PostBottomMenuLauncherDelegate {
    func didTapUpload(content: ContentKind) {
        guard let user = user, user.phase == .verified else { return }
        switch content {
        case .post:
            let postController = AddPostViewController(user: user)
            
            let nav = UINavigationController(rootViewController: postController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        case .clinicalCase:
            let clinicalCaseController = ShareCaseDisciplinesViewController(user: user)
            let nav = UINavigationController(rootViewController: clinicalCaseController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }
    
    func updateUserProfileImageViewAlpha(alfa: CGFloat) {
        if let currentNavController = selectedViewController as? UINavigationController {
            if collapsed { return }
            currentNavController.viewControllers.last?.navigationItem.leftBarButtonItem?.customView?.alpha = alfa /*1 - 2*alfa*/
        }
    }
}

extension MainTabController: NavigationBarViewControllerDelegate {
    
    func didTapOpenConversations() {
        menuDelegate?.showConversations()
    }
    
    func didTapIconImage() {
        menuDelegate?.handleUserIconTap()
    }
    
    func didTapAddButton() {
        menuLauncher.showPostSettings(in: view)
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
                
                if let email = currentUser.email, email != user.email {
                    UserService.updateEmail(email: email)
                }

                strongSelf.user = user

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
