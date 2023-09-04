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
    func handleMenu()
    func handleDisablePan()
    func handleConversations()
    func handleDisableRightPan()
    func updateUser(user: User)
    func configureControllersWithUser(user: User)
    func controllersLoaded()
}

class MainTabController: UITabBarController {
    
    //MARK: Properties
    
    private var menuLauncher = ContentMenu()
    weak var menuDelegate: MainTabControllerDelegate?
    
    private let disciplinesMenuLauncher = SearchMenu(kind: .disciplines)
    private let topicsMenuLauncher = SearchMenu(kind: .topics)
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
        disciplinesMenuLauncher.delegate = self
        topicsMenuLauncher.delegate = self
    }
    
    func fetchUser() {
        
        guard let currentUser = Auth.auth().currentUser else {
            showMainScreen()
            return
        }
        print("we have current user")
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
        
        print("user is logged")
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
            print("we have network error so we look at the phase")
            // Here there's a network error connection we switch the UserDefaults phase and if it's not verified, deactivated or ban
            guard let phase = getPhase() else {
                showMainScreen()
                return
            }
            
            switch phase {
                
            case .category, .details, .identity, .deactivate, .ban, .pending, .review:
                showMainScreen()
            case  .verified:
                print("configure for verieied")
                menuDelegate?.controllersLoaded()
                configureViewControllers()

                tabBar.isHidden = false
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    print("users is verified we load")
                    //strongSelf.menuDelegate?.controllersLoaded()
                }
            }
        }
    }
    
    //MARK: - Helpers

    func configureViewControllers(withUser: User? = nil) {
        view.backgroundColor = .systemBackground
        self.delegate = self
        
        let homeController = HomeViewController(source: .home)
        homeController.delegate = self
        homeController.scrollDelegate = self
        homeController.panDelegate = self
        
        let casesController = CasesViewController(contentSource: .home)
        casesController.delegate = self
        casesController.panDelegate = self
        
        let notificationsController = NotificationsViewController()
        notificationsController.delegate = self
        notificationsController.panDelegate = self
        
        let postController = ViewController()
        
        let searchController = SearchViewController()
        searchController.panDelegate = self
        searchController.delegate = self
        
        let home = templateNavigationController(title: AppStrings.Tab.home, unselectedImage: UIImage(named: AppStrings.Assets.home)!, selectedImage: UIImage(named: AppStrings.Assets.selectedHome)!, rootViewController: homeController)

        let cases = templateNavigationController(title: AppStrings.Tab.cases, unselectedImage: UIImage(named: AppStrings.Assets.cases)!, selectedImage: UIImage(named: AppStrings.Assets.selectedCases)!, rootViewController: casesController)
        
        let search = templateNavigationController(title: AppStrings.Tab.search, unselectedImage: UIImage(named: AppStrings.Assets.search)!, selectedImage: UIImage(named: AppStrings.Assets.search)!, rootViewController: searchController)
        
        let post = templateNavigationController(title: AppStrings.Tab.create, unselectedImage: UIImage(named: AppStrings.Assets.post)!, selectedImage: UIImage(named: AppStrings.Assets.selectedPost)!, rootViewController: postController)
        
        let notifications = templateNavigationController(title: AppStrings.Tab.notifications, unselectedImage: UIImage(named: AppStrings.Assets.notification)!, selectedImage: UIImage(named: AppStrings.Assets.selectedNotification)!, rootViewController: notificationsController)
        
        
        if let user {
            
            if user.phase == .verified {
                viewControllers = [home, cases, post, notifications, search]
                NotificationCenter.default.addObserver(self, selector: #selector(refreshUnreadNotifications(_:)), name: NSNotification.Name(AppPublishers.Names.refreshUnreadNotifications), object: nil)
            } else {
                menuDelegate?.handleDisableRightPan()
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

            print("view controllers are set")
            viewControllers = [home, cases, post, notifications, search]
            
        } 
    }
    
    private func showMainScreen() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            UserDefaults.standard.set(false, forKey: "auth")
            strongSelf.menuDelegate?.controllersLoaded()
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
        nav.tabBarItem.image = unselectedImage.scalePreservingAspectRatio(targetSize: CGSize(width: 22, height: 22))
        nav.tabBarItem.title = title
        nav.tabBarItem.selectedImage = selectedImage.scalePreservingAspectRatio(targetSize: CGSize(width: 22, height: 22))
        return nav
    }
    
    func pushUserProfileViewController() {
        if let currentNavController = selectedViewController as? UINavigationController {
            guard let user = user else { return }
            
            let userProfileController = UserProfileViewController(user: user)
            currentNavController.pushViewController(userProfileController, animated: true)
        }
    }
    
    func pushMenuOption(option: SideMenu) {
        if let currentNavController = selectedViewController as? UINavigationController {
            
            switch option {
            case .profile:
                guard let user = user else { return }
                let userProfileController = UserProfileViewController(user: user)
                currentNavController.pushViewController(userProfileController, animated: true)
            case .bookmark:
                let controller = BookmarksViewController()
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

    func showSearchMenu(withDisciplie discipline: Discipline) {
        disciplinesMenuLauncher.showMenu(withDiscipline: discipline, in: view)
    }
    
    func showSearchMenu(withSearchTopic topic: SearchTopics) {
        topicsMenuLauncher.showMenu(withTopic: topic, in: view)
    }
    
    @objc func refreshUnreadNotifications(_ notification: NSNotification) {
        if let notifications = notification.userInfo?["notifications"] as? Int {

            let notificationIndex = 3

            if let viewControllers = viewControllers, notificationIndex < viewControllers.count {
                viewControllers[3].tabBarItem.badgeValue = notifications > 0 ? String(notifications) : nil
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
                    if let controller = currentNavController.viewControllers.first as? HomeViewController {
                        controller.scrollCollectionViewToTop()
                        return false
                    }
                    return true
                }/* else {
                    if let controller = currentNavController.topViewController as? HomeViewController {
                        currentNavController.popToRootViewController(animated: true)
                    }
                }
                  */
                return true
            }
            return true
        } else if viewController == tabBarController.viewControllers?[2] {
            
            guard NetworkMonitor.shared.isConnected else {
                displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.network)
                return false
            }
            
            guard let user = user else {
                displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                return false
            }
            
            guard user.phase == .verified else {
                displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.verified)
                return false
            }
            
            menuLauncher.showPostSettings(in: view)
            return false
            
        } else if viewController == tabBarController.viewControllers?[1] {
            if let currentNavController = selectedViewController as? UINavigationController {
                if currentNavController.viewControllers.count == 1 {
                    if let controller = currentNavController.viewControllers.first as? CasesViewController {
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
            currentNavController.viewControllers.last?.navigationItem.leftBarButtonItem?.customView?.alpha = 1 - 2*alfa
        }
    }
}

extension MainTabController: NavigationBarViewControllerDelegate {

    func didTapConversationsButton() {
        menuDelegate?.handleConversations()
    }
    
    func didTapMenuButton() {
        menuDelegate?.handleMenu()
    }
}

extension MainTabController: DisablePanGestureDelegate {
    func disableRightPanGesture() {
        menuDelegate?.handleDisableRightPan()
    }
    
    func disablePanGesture() {
        menuDelegate?.handleDisablePan()
    }
}

extension MainTabController: HomeViewControllerDelegate {
    func updateAlpha(alpha: CGFloat) {
        if let currentNavController = selectedViewController as? UINavigationController {
            collapsed = alpha < -1 ? true : false
            currentNavController.viewControllers.last?.navigationItem.leftBarButtonItem?.customView?.alpha = alpha
            currentNavController.viewControllers.last?.navigationItem.rightBarButtonItem?.tintColor = .label.withAlphaComponent(alpha > 1 ? 1 : alpha)
        }
    }
}

extension MainTabController: SearchMenuDelegate {
    func didTapShowResults(forTopic topic: SearchTopics) {
        if let currentNavController = selectedViewController as? UINavigationController {
            if let searchController = currentNavController.viewControllers.first as? SearchViewController {
                searchController.showSearchResults(forTopic: topic)
            }
        }
    }
    
    func didTapShowResults(forDiscipline discipline: Discipline) {
        if let currentNavController = selectedViewController as? UINavigationController {
            if let searchController = currentNavController.viewControllers.first as? SearchViewController {
                searchController.showSearchResults(forDiscipline: discipline)
            }
        }
    }
    
    func didTapRestoreFilters() {
        if let currentNavController = selectedViewController as? UINavigationController {
            if let searchController = currentNavController.viewControllers.first as? SearchViewController {
                searchController.resetSearchResultsUpdatingToolbar()
                disciplinesMenuLauncher.handleDismissMenu()
                topicsMenuLauncher.handleDismissMenu()
            }
        }
    }
}

extension MainTabController: NetworkDelegate {
    func didBecomeConnected() {

        guard let currentUser = Auth.auth().currentUser else {
            UserDefaults.standard.set(false, forKey: "auth")

            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                let controller = OpeningViewController()
                let sceneDelegate = strongSelf.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
            }
            
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
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        let controller = OpeningViewController()
                        let sceneDelegate = strongSelf.view.window?.windowScene?.delegate as? SceneDelegate
                        sceneDelegate?.updateRootViewController(controller)
                    }
                }
            }
        }
    }
}
