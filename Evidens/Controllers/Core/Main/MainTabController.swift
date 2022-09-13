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
}

class MainTabController: UITabBarController {
    
    //MARK: Properties
    
    private var postMenuLauncher = PostBottomMenuLauncher()
    var menu = PostPrivacyMenuLauncher()
    
    weak var menuDelegate: MainTabControllerDelegate?
    
    var user: User? {
        didSet {
            //guard let controller = viewControllers?[0] as? ContainerViewController else { return }
            guard let user = user else { return }
            configureViewControllers(withUser: user)
            //controller.user = user
        }
    }
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            self.navigationController?.navigationBar.isTranslucent = true  // pass "true" for fixing iOS 15.0 black bg issue
            self.navigationController?.navigationBar.tintColor = UIColor.white // We need to set tintcolor for iOS 15.0
            //appearance.shadowColor = .black    // navigationbar 1 px bottom border.
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
         

        view.backgroundColor = .white
        self.tabBar.isHidden = true
        
        postMenuLauncher.delegate = self
        checkIfUserIsLoggedIn()
        fetchUser()
    }
    
    //MARK: - API
    
    func fetchUser() {
        //Get the uid of current user
        print("user is logged in")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //Fetch user with user uid
        UserService.fetchUser(withUid: uid) { user in
            //Set user property
            self.user = user
                        
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
                let controller = WaitingVerificationViewController(user: user)
                let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
                
            case .verified:
                print("main tab bar controller")
                
                UserDefaults.standard.set(user.uid, forKey: "uid")
                UserDefaults.standard.set("\(user.firstName ?? "") \(user.lastName ?? "")", forKey: "name")
                UserDefaults.standard.set(user.profileImageUrl!, forKey: "userProfileImageUrl")
                
                
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.shadowColor = grayColor
                self.tabBar.isHidden = false
                self.tabBar.isTranslucent = true
                self.tabBar.backgroundColor = .white
                self.tabBar.standardAppearance = appearance
            }
        }
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let controller = WelcomeViewController()
                let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.updateRootViewController(controller)
            }
        }
    }
    
    //MARK: - Helpers

    //Setup ViewControllers for the TabBarController
    func configureViewControllers(withUser: User) {
        view.backgroundColor = .white
        self.delegate = self
    
        let homeController = HomeViewController()
        homeController.delegate = self
        homeController.panDelegate = self
        
        let casesController = CasesViewController()
        casesController.delegate = self
        casesController.panDelegate = self
        
        let notificationsController = NotificationsViewController()
        notificationsController.delegate = self
        notificationsController.panDelegate = self
        
        let postController = ViewController()
        
        let home = templateNavigationController(title: "Home", unselectedImage: UIImage(systemName: "house.fill")!, selectedImage: UIImage(systemName: "house.fill")!, rootViewController: homeController)
        
        let cases = templateNavigationController(title: "Clinical Cases", unselectedImage: UIImage(systemName: "heart.text.square.fill")!, selectedImage: UIImage(systemName: "heart.text.square.fill")!, rootViewController: casesController)
  
        let post = templateNavigationController(title: "Post", unselectedImage: UIImage(systemName: "plus.circle.fill")!, selectedImage: UIImage(systemName: "plus.circle.fill")!, rootViewController: postController)
        
        
        
        
        let notifications = templateNavigationController(title: "Notifications", unselectedImage: UIImage(systemName: "bell.fill")!, selectedImage: UIImage(systemName: "bell.fill")!, rootViewController: notificationsController)
        
        viewControllers = [home, cases, post, notifications]
        
        tabBar.tintColor = .black
    }
    
    func templateNavigationController(title: String?, unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController) -> UINavigationController {
    
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = unselectedImage
        nav.tabBarItem.title = title
        nav.tabBarItem.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 12.1)], for: .normal)
        nav.tabBarItem.selectedImage = selectedImage
        nav.navigationBar.tintColor = .black
        
        return nav
    }
    
    func pushUserProfileViewController() {
        if let currentNavController = selectedViewController as? UINavigationController {
            guard let user = user else { return }
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .black
            
            let userProfileController = UserProfileViewController(user: user)

            currentNavController.navigationBar.topItem?.backBarButtonItem = backItem
            currentNavController.pushViewController(userProfileController, animated: true)
        }
    }
    
    func pushMenuOption(option: SideMenuViewController.MenuOptions) {
        if let currentNavController = selectedViewController as? UINavigationController {
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .black
            currentNavController.navigationBar.topItem?.backBarButtonItem = backItem
            
            switch option {
            case .bookmarks:
                let controller = BookmarksViewController()
                currentNavController.pushViewController(controller, animated: true)
            }
            
            
            
        }
    }
    
    func pushSettingsViewController() {
        if let currentNavController = selectedViewController as? UINavigationController {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .black
            
            let settingsController = ApplicationSettingsViewController()

            currentNavController.navigationBar.topItem?.backBarButtonItem = backItem
            currentNavController.pushViewController(settingsController, animated: true)
        }
    }
}

//MARK: - UITabBarControllerDelegate

extension MainTabController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == tabBarController.viewControllers?[2] {
            postMenuLauncher.showPostSettings(in: view)
            return false
        }
        return true
    }
}

extension MainTabController: PostBottomMenuLauncherDelegate {
    
    func didTapUploadPost() {
        guard let user = user else { return }
        
        let postController = UploadPostViewController(user: user)
        
        let nav = UINavigationController(rootViewController: postController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    
    func didTapUploadClinicalCase() {
        guard let user = user else { return }

        let clinicalCaseController = ShareClinicalCaseViewController(user: user)
        
        let nav = UINavigationController(rootViewController: clinicalCaseController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func updateUserProfileImageViewAlpha(alfa: CGFloat) {
        if let currentNavController = selectedViewController as? UINavigationController {
            currentNavController.viewControllers.last?.navigationItem.leftBarButtonItem?.customView?.alpha = 1 - 2*alfa
        }
    }
}

extension MainTabController: NavigationBarViewControllerDelegate {
    func didTapConversationsButton() {
        menuDelegate?.handleConversations()
    }
    
    func didTapSearchBar() {
        if let currentNavController = selectedViewController as? UINavigationController {
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .black
            
            let controller = SearchViewController()
            
            currentNavController.navigationBar.topItem?.backBarButtonItem = backItem
            currentNavController.pushViewController(controller, animated: true)
        }
    }
    
    func didTapMenuButton() {
        menuDelegate?.handleMenu()
    }
}

extension MainTabController: DisablePanGestureDelegate {
    func disablePanGesture() {
        menuDelegate?.handleDisablePan()
    }
    
    
}

