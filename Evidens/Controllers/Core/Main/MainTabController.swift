//
//  MainTabController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit
import Firebase
import FirebaseAuth

class MainTabController: UITabBarController {
    
    //MARK: Properties
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            configureViewControllers(withUser: user)
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(rgb: 0x79CBBF)
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

            //Change to == false for real use app, != false for testing purposes
            if (user.isVerified == true) {
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
        let feed = templateNavigationController(unselectedImage: UIImage(systemName: "house")!, selectedImage: UIImage(systemName: "house.fill")!, rootViewController: FeedViewController(collectionViewLayout: feedLayout))
        
        let search = templateNavigationController(unselectedImage: UIImage(systemName: "magnifyingglass")!, selectedImage: UIImage(systemName: "magnifyingglass")!, rootViewController: SearchViewController())
        
        let postController = UploadPostViewController(user: user)
        let post = templateNavigationController(unselectedImage: UIImage(systemName: "plus.app")!, selectedImage: UIImage(systemName: "plus.app.fill")!, rootViewController: postController)
        
        let notifications = templateNavigationController(unselectedImage: UIImage(systemName: "bell")!, selectedImage: UIImage(systemName: "bell.fill")!, rootViewController: NotificationViewController())
        
        let profileController = ProfileViewController(user: user)
        let profile = templateNavigationController(unselectedImage: UIImage(systemName: "person")!, selectedImage: UIImage(systemName: "person.fill")!, rootViewController: profileController)
        
        viewControllers = [feed, search, post, notifications, profile]
        
        tabBar.tintColor = .black
    }
    
    func templateNavigationController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = unselectedImage
        nav.tabBarItem.selectedImage = selectedImage
        nav.navigationBar.tintColor = .black
        return nav
    }
}

//MARK: - UITabBarControllerDelegate

extension MainTabController: UITabBarControllerDelegate {
    
    //Check pressed tab
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
}

