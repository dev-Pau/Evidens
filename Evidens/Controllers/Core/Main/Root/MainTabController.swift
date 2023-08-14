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
            print("we did set user")
            menuDelegate?.configureControllersWithUser(user: user)
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
            UserDefaults.standard.set(false, forKey: "auth")

            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                let controller = OpeningViewController()
                let sceneDelegate = strongSelf.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
            }
            
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
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                    strongSelf.configureCurrentController()
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
    
    private func checkIfUserIsLoggedIn() {
        guard UserDefaults.getAuth() == true else {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                let controller = OpeningViewController()
                let sceneDelegate = strongSelf.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
            }
            
            return
        }
        
        fetchUser()
    }
    
    private func configureCurrentController(withUser user: User? = nil) {
        self.user = user
        self.configureViewControllers()
        
        if let user {
            setUserDefaults(for: user)
        }
        
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
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    NotificationService.syncPreferences(settings.authorizationStatus)
                }
                
                tabBar.isHidden = false
            case .review:
                
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    NotificationService.syncPreferences(settings.authorizationStatus)
                }
                tabBar.isHidden = false
            case .verified:
                
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
        } else {
            // Here there's a network error connection we switch the UserDefaults phase and if it's not verified, deactivated or ban
            guard let phase = getPhase() else {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    AuthService.logout()
                    AuthService.googleLogout()
                    
                    let controller = OpeningViewController()
                    let sceneDelegate = strongSelf.view.window?.windowScene?.delegate as? SceneDelegate
                    sceneDelegate?.updateRootViewController(controller)
                }
                
                return
            }
            
            switch phase {
                
            case .category, .details, .identity, .deactivate, .ban:
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    AuthService.logout()
                    AuthService.googleLogout()
                    
                    let controller = OpeningViewController()
                    let sceneDelegate = strongSelf.view.window?.windowScene?.delegate as? SceneDelegate
                    sceneDelegate?.updateRootViewController(controller)
                }
            case .pending, .review, .verified:
                
                tabBar.isHidden = false
            }
        }
    }
    
    //MARK: - Helpers

    func configureViewControllers() {
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
        
        let home = templateNavigationController(title: "Home", unselectedImage: UIImage(named: "home")!, selectedImage: UIImage(named: "home.selected")!, rootViewController: homeController)

        let cases = templateNavigationController(title: "Cases", unselectedImage: UIImage(named: "cases")!, selectedImage: UIImage(named: "cases.selected")!, rootViewController: casesController)
        
        let search = templateNavigationController(title: "Search", unselectedImage: UIImage(named: "search")!, selectedImage: UIImage(named: "search")!, rootViewController: searchController)
        
        let post = templateNavigationController(title: "Post", unselectedImage: UIImage(named: "post")!, selectedImage: UIImage(named: "post.selected")!, rootViewController: postController)
        
        let notifications = templateNavigationController(title: "Notifications", unselectedImage: UIImage(named: "notifications")!, selectedImage: UIImage(named: "notifications.selected")!, rootViewController: notificationsController)
        
        viewControllers = [home, cases, post, notifications, search]
    
        
        //
    }
    
    func templateNavigationController(title: String?, unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController) -> UINavigationController {
        
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = unselectedImage.scalePreservingAspectRatio(targetSize: CGSize(width: 22, height: 22)).withTintColor(.systemGray2)
        nav.tabBarItem.title = title
        nav.tabBarItem.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 12.1)], for: .normal)
        nav.tabBarItem.selectedImage = selectedImage.scalePreservingAspectRatio(targetSize: CGSize(width: 22, height: 22)).withTintColor(.label)
        tabBar.tintColor = .label
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
}

//MARK: - UITabBarControllerDelegate

extension MainTabController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == tabBarController.viewControllers?[2] {
            
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
            
        } else if viewController == tabBarController.viewControllers?[0] {
            if let currentNavController = selectedViewController as? UINavigationController {
                if currentNavController.viewControllers.count == 1 {
                    if let controller = currentNavController.viewControllers.first as? HomeViewController {
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
            let clinicalCaseController = ShareCaseProfessionsViewController(user: user)
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
        print("main tab called after didb ecome connected")
        
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
