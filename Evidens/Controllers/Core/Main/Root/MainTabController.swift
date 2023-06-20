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
    private var postMenuLauncher = PostBottomMenuLauncher()
    weak var menuDelegate: MainTabControllerDelegate?
    private let disciplinesMenuLauncher = SearchAssistantMenuLauncher(searchOptions: Profession.getAllProfessions().map({ $0.profession }))
    private let topicsMenuLauncher = SearchAssistantMenuLauncher(searchOptions: SearchTopics.allCases.map({ $0.rawValue }))
    private var collapsed: Bool = false
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            menuDelegate?.configureControllersWithUser(user: user)
            //guard let controller = viewControllers?[0] as? ContainerViewController else { return }
            //guard let user = user else { return }
            //configureViewControllers(withUser: user)
            //controller.user = user
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.tabBar.isHidden = true
        
        postMenuLauncher.delegate = self
        disciplinesMenuLauncher.delegate = self
        topicsMenuLauncher.delegate = self
        checkIfUserIsLoggedIn()
        fetchUser()
    }
    
    //MARK: - API
    
    func fetchUser() {
        //Get the uid of current user
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //Fetch user with user uid
        UserService.fetchUser(withUid: uid) { user in
            //Set user property
            self.user = user
            self.configureViewControllers()
            
            switch user.phase {
            case .categoryPhase:
                print("User created account without giving any details")
                let controller = CategoryRegistrationViewController(user: user)
                let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
                
            case .userDetailsPhase:
                print("User gave category, profession & speciality but not name and photo")
                let controller = FullNameRegistrationViewController(user: user)
                let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
                
            case .verificationPhase:
                print("User gave all information except for the personal identification")
                let controller = VerificationRegistrationViewController(user: user)
                let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
                
            case .awaitingVerification:
                print("awaiting verification")
                UserDefaults.standard.set(user.uid, forKey: "uid")
                UserDefaults.standard.set("\(user.firstName ?? "") \(user.lastName ?? "")", forKey: "name")
                UserDefaults.standard.set(user.profileImageUrl!, forKey: "userProfileImageUrl")
                //UserDefaults.standard.set(Appearance.Theme.system.rawValue, forKey: "themeStateEnum")
                self.tabBar.isHidden = false
            case .verified:
                print("main tab bar controller")
                
                UserDefaults.standard.set(user.uid, forKey: "uid")
                UserDefaults.standard.set("\(user.firstName ?? "") \(user.lastName ?? "")", forKey: "name")
                UserDefaults.standard.set(user.profileImageUrl!, forKey: "userProfileImageUrl")
                self.tabBar.isHidden = false
                /*
                guard let appearance = UserDefaults.standard.value(forKey: "themeStateEnum") as? String, !appearance.isEmpty else {
                    UserDefaults.standard.set(Appearance.Theme.system.rawValue, forKey: "themeStateEnum")
                    return
                }
                */
                
                
                /*
                let statusBarView = UIView()
                   statusBarView.backgroundColor = .systemBackground
                   statusBarView.frame = UIApplication.shared.statusBarFrame
                   UIApplication.shared.keyWindow?.addSubview(statusBarView)
                 
                */
                //self.topBlurView.frame = UIApplication.shared.statusBarFrame
                //UIApplication.shared.keyWindow?.addSubview(self.topBlurView)
                
                //let blurEffect = UIBlurEffect(style: .prominent)
                //let blurView = UIVisualEffectView(effect: blurEffect)
                //blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                //self.topBlurView.insertSubview(blurView, at: 0)
                //blurView.frame = self.topBlurView.boundCOLLECTION_POSTS.whereFie
            }
        }
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let controller = OpeningViewController()
                let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
            }
        }
    }
    
    //MARK: - Helpers

    func configureViewControllers() {
        view.backgroundColor = .systemBackground
        self.delegate = self
        
        let homeController = HomeViewController(contentSource: .home)
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
                #warning("kek")
                print("kek")
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
    
    /*
    func pushSettingsViewController() {
        if let currentNavController = selectedViewController as? UINavigationController {
            let settingsController = ApplicationSettingsViewController()
            currentNavController.pushViewController(settingsController, animated: true)
        }
    }
    */
    func showSearchMenuLauncher(withOption option: String) {
        disciplinesMenuLauncher.showPostSettings(withOption: option, in: view)
    }
    
    func showTopicsMenuLauncher(withCategory category: String) {
        topicsMenuLauncher.showPostSettings(withOption: category, in: view)
    }
}

//MARK: - UITabBarControllerDelegate

extension MainTabController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == tabBarController.viewControllers?[2] {
            guard let user = user, user.phase == .verified else {
                let reportPopup = METopPopupView(title: "Only verified users can post content. Check back later to verify your status.", image: "xmark.circle.fill", popUpType: .regular)
                reportPopup.showTopPopup(inView: self.view)
                return false
            }
            postMenuLauncher.showPostSettings(in: view)
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
    func didTapUpload(content: ShareableContent) {
        guard let user = user, user.phase == .verified else { return }
        switch content {
        case .post:
            let postController = UploadPostViewController(user: user)
            
            let nav = UINavigationController(rootViewController: postController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        case .clinicalCase:
            //let clinicalCaseController = ShareClinicalCaseViewController(user: user)
            //let clinicalCaseController = ShareCaseViewController(user: user)
            let clinicalCaseController = ShareCaseProfessionsViewController(user: user)
            let nav = UINavigationController(rootViewController: clinicalCaseController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }
    
    func updateUserProfileImageViewAlpha(alfa: CGFloat) {
        if let currentNavController = selectedViewController as? UINavigationController {
            if collapsed { return }
            //if currentNavController.viewControllers.last?.navigationItem.leftBarButtonItem?.customView?.alpha ?? 0.0 < 0.1 { return }
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

extension MainTabController: SearchAssistantMenuLauncherDelegate {
    func didTapRestoreFilters() {
        if let currentNavController = selectedViewController as? UINavigationController {
            if let searchController = currentNavController.viewControllers.first as? SearchViewController {
                searchController.resetSearchResultsUpdatingToolbar()
                disciplinesMenuLauncher.handleDismissMenu()
                topicsMenuLauncher.handleDismissMenu()
            }
        }
    }
    
    func didTapShowResults(_ object: NSObject, forTopic topic: String) {
        if let currentObject = object as? SearchAssistantMenuLauncher {
            if currentObject == disciplinesMenuLauncher {
                if let currentNavController = selectedViewController as? UINavigationController {
                    if let searchController = currentNavController.viewControllers.first as? SearchViewController {
                        searchController.showSearchResultsFor(forTopic: topic)
                    }
                }
            } else {
                if let currentNavController = selectedViewController as? UINavigationController {
                    if let searchController = currentNavController.viewControllers.first as? SearchViewController {
                        searchController.showSearchResultsWithCategory(forCategory: topic)
                    }
                }
            }
        }
    }
}
