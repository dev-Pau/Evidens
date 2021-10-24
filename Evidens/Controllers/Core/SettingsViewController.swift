//
//  SettingsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/10/21.
//

import Foundation
import UIKit
import Firebase

class SettingsViewController: UIViewController {
    
    private var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.isEnabled = true
        button.setTitle("Log out", for: .normal)
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Properties
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - API
    
    //MARK: - Handlers
    
    //MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .lightGray
        
        view.addSubview(logoutButton)
        logoutButton.anchor(top: view.topAnchor, right: view.rightAnchor, paddingTop: 5, paddingRight: 10)
    }
    
    //MARK: - Actions
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
            let controller = WelcomeViewController()
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        } catch {
            print("DEBUG: Failed to logout")
        }
    }
}
