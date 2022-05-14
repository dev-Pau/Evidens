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
    
    var lastIndex = 0
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            configureViewControllers(withUser: user)
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
            appearance.shadowColor = grayColor    // navigationbar 1 px bottom border.
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        //GIDSignIn.sharedInstance.signOut()
        //AuthService.logout()
        view.backgroundColor = primaryColor
        self.tabBar.isHidden = true
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
    
            //Save uid to UserDefaults
            UserDefaults.standard.set(user.uid, forKey: "uid")
            UserDefaults.standard.set("\(user.firstName ?? "") \(user.lastName ?? "")", forKey: "name")
            UserDefaults.standard.set(user.profileImageUrl!, forKey: "userProfileImageUrl")

            //Change to == false for real use app, != false for testing welcome
            if (user.isVerified != true) {
                //If user is not verified, present WelcomeViewController()
                let controller = WelcomeViewController()
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false, completion: nil)
            }
            self.tabBar.isHidden = false
        }
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let controller = WelcomeViewController()
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false, completion: nil)
            }
        }
    }
    
    //MARK: - Helpers

    //Setup ViewControllers for the TabBarController
    func configureViewControllers(withUser user: User) {
        view.backgroundColor = .white
        self.delegate = self
    
        let feedLayout = UICollectionViewFlowLayout()
        let feed = templateNavigationController(title: "Home", unselectedImage: UIImage(named: "home")!, selectedImage: UIImage(named: "home.fill")!, rootViewController: FeedViewController(collectionViewLayout: feedLayout))
        
        //feed.navigationBar.tintColor = .white
        //feed.navigationBar.isTranslucent = false
        
        let search = templateNavigationController(title: "Clinical Cases", unselectedImage: UIImage(named: "cases")!, selectedImage: UIImage(named: "cases")!, rootViewController: SearchViewController())
        
        let postController = ViewController()
        let post = templateNavigationController(title: "Post", unselectedImage: UIImage(systemName: "plus.app")!, selectedImage: UIImage(systemName: "plus.app.fill")!, rootViewController: postController)
        
        let notifications = templateNavigationController(title: "Notifications", unselectedImage: UIImage(named: "bell")!, selectedImage: UIImage(named: "bell")!, rootViewController: NotificationViewController())
        
        let profileController = ProfileViewController(user: user)
        let profile = templateNavigationController(title: nil, unselectedImage: UIImage(named: "cases")!, selectedImage: UIImage(named: "cases")!, rootViewController: profileController)
        
        viewControllers = [feed, search, post, notifications, profile]
        
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
}

//MARK: - UITabBarControllerDelegate

extension MainTabController: UITabBarControllerDelegate {
    
    //Check pressed tab
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == tabBarController.viewControllers?[2] {
            print("Is the post VC")
            guard let user = user else { return false }
            let postController = UploadPostViewController(user: user)
            let nav = UINavigationController(rootViewController: postController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
    }
}

