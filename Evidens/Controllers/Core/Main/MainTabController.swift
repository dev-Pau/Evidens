//
//  MainTabController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth

class MainTabController: UITabBarController {
    
    //MARK: Properties
    
    private var postMenuLauncher = PostBottomMenuLauncher()
    
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
        
        //GIDSignIn.sharedInstance.signOut()
        //AuthService.logout()

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
            print(User.UserRegistrationPhase.userDetailsPhase)
            
            
            switch user.phase {
            case .categoryPhase:
                print("User created account without giving any details")
                let controller = CategoryRegistrationViewController(user: user)
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false)
                
            case .userDetailsPhase:
                print("User gave category, profession & speciality but not name and photo")
                let controller = FullNameRegistrationViewController(user: user)
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false)
                break
            case .verificationPhase:
                print("User gave all information except for the personal identification")
                let controller = VerificationRegistrationViewController(user: user)
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false)
                break
            case .verified:
                break
            }
    
            
            /*
            switch user.phase {
                
                
            case .initialPhase:
                // User created account without giving any details
                print("User is created without giving any details yet")
                let controller = CategoryRegistrationViewController(user: user)
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false)
                
            case .fullNamePhase:
                print("Full Name Phase")
            case .documentationPhase:
                print("Documentation Phase")
            case .verified:
                print("Verified Phase")
                //Save uid to UserDefaults
                UserDefaults.standard.set(user.uid, forKey: "uid")
                UserDefaults.standard.set("\(user.firstName ?? "") \(user.lastName ?? "")", forKey: "name")
                UserDefaults.standard.set(user.profileImageUrl!, forKey: "userProfileImageUrl")
            }
            
            /*
            //Change to == false for real use app, != false for testing welcome
            if (user.isVerified != true) {
                //If user is not verified, present WelcomeViewController()
                let controller = WelcomeViewController()
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false, completion: nil)
            }
            
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.shadowColor = grayColor
            self.tabBar.isHidden = false
            self.tabBar.isTranslucent = true
            self.tabBar.backgroundColor = .white
            self.tabBar.standardAppearance = appearance
             */
             */
        }
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                print("User is not logged in")
                let controller = WelcomeViewController()
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false, completion: nil)
            }
        }
    }
    
    //MARK: - Helpers

    //Setup ViewControllers for the TabBarController
    func configureViewControllers(withUser: User) {
        view.backgroundColor = .white
        self.delegate = self
    
        let layout = UICollectionViewFlowLayout()
        let home = templateNavigationController(title: "Home", unselectedImage: UIImage(named: "home")!, selectedImage: UIImage(named: "home.fill")!, rootViewController: HomeViewController(collectionViewLayout: layout))
        
        let search = templateNavigationController(title: "Clinical Cases", unselectedImage: UIImage(named: "cases")!, selectedImage: UIImage(named: "cases.fill")!, rootViewController: CasesViewController())
        
        let postController = ViewController()
        let post = templateNavigationController(title: "Post", unselectedImage: UIImage(named: "plus.app")!, selectedImage: UIImage(named: "plus.app")!, rootViewController: postController)
        
        let notifications = templateNavigationController(title: "Notifications", unselectedImage: UIImage(named: "bell")!, selectedImage: UIImage(named: "bell.fill")!, rootViewController: NotificationViewController())
        
        viewControllers = [home, search, post, notifications]
        
        tabBar.tintColor = .black
    }
    
    func templateNavigationController(title: String?, unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController) -> UINavigationController {
    
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = unselectedImage
        nav.tabBarItem.title = title
        nav.tabBarItem.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 12.1)], for: .normal)
        nav.tabBarItem.selectedImage = selectedImage
        nav.navigationBar.tintColor = blackColor
        
        return nav
    }
}

//MARK: - UITabBarControllerDelegate

extension MainTabController: UITabBarControllerDelegate {
    
    //Check pressed tab
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == tabBarController.viewControllers?[2] {
            postMenuLauncher.showPostSettings(in: view)
            
            //guard let user = user else { return false }
            //let postController = UploadPostViewController(user: user)
            
            //let nav = UINavigationController(rootViewController: postController)
            //nav.modalPresentationStyle = .fullScreen
            //present(nav, animated: true, completion: nil)
            
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
}

