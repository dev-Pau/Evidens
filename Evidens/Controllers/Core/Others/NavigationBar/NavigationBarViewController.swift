//
//  NavigationBarViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/9/22.
//

import UIKit

protocol NavigationBarViewControllerDelegate: AnyObject {
    func didTapMenuButton()
    func didTapConversationsButton()
}

class NavigationBarViewController: UIViewController {
    
    weak var delegate: NavigationBarViewControllerDelegate?
    weak var panDelegate: DisablePanGestureDelegate?

    var controllerIsBeeingPushed: Bool = false
    private let messageBarIcon = MessageBarView()
    
    private let userImageView = ProfileImageView(frame: .zero)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfile))
        userImageView.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name("ProfileImageUpdateIdentifier"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name("UserUpdateIdentifier"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
        
        if !controllerIsBeeingPushed {
            
            userImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            userImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            userImageView.layer.cornerRadius = 30 / 2
            let profileImageItem = UIBarButtonItem(customView: userImageView)

            if let profileImageUrl = UserDefaults.standard.value(forKey: "profileUrl") as? String, profileImageUrl != "" {
                userImageView.sd_setImage(with: URL(string: profileImageUrl))
                
            }
            
            addNavigationBarLogo(withTintColor: primaryColor)
            
            navigationItem.leftBarButtonItem = profileImageItem

            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: messageBarIcon)
            navigationItem.rightBarButtonItem?.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowMessages)))
            let unread = DataService.shared.getUnreadConversations()
            messageBarIcon.setUnreadMessages(unread)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        panDelegate?.disablePanGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        panDelegate?.disablePanGesture()
    }

    @objc func didTapProfile() {
        delegate?.didTapMenuButton()
    }
    
    @objc func handleShowMessages() {
        delegate?.didTapConversationsButton()
    }
    
    @objc func didReceiveNotification(notification: NSNotification) {
        let name = notification.name.rawValue
        
        switch name {
        case AppPublishers.Names.refreshUnreadConversations:
            let unread = DataService.shared.getUnreadConversations()
            messageBarIcon.setUnreadMessages(unread)
        default:
            if let profileImageUrl = UserDefaults.standard.value(forKey: "profileUrl") as? String, profileImageUrl != "" {
                userImageView.sd_setImage(with: URL(string: profileImageUrl))
            }
        }
    }
}
