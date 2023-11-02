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
    func didTapAddButton()
}

class NavigationBarViewController: UIViewController {
    
    weak var delegate: NavigationBarViewControllerDelegate?
    weak var panDelegate: DisablePanGestureDelegate?

    var controllerIsBeeingPushed: Bool = false
    private let messageBarIcon = MessageBarView()
    
    private let userImageView = ProfileImageView(frame: .zero)
    
    var addButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfile))
        userImageView.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name(        AppPublishers.Names.refreshUser), object: nil)
        
        if !controllerIsBeeingPushed {
            userImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            userImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            userImageView.layer.cornerRadius = 30 / 2
            let profileImageItem = UIBarButtonItem(customView: userImageView)

            if let profileImageUrl = UserDefaults.standard.value(forKey: "profileUrl") as? String, profileImageUrl != "" {
                userImageView.sd_setImage(with: URL(string: profileImageUrl))
            }
            
            addNavigationBarLogo(withTintColor: baseColor)
            
            navigationItem.leftBarButtonItem = profileImageItem

            if let phase = getPhase(), phase == .verified {
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: messageBarIcon)
                navigationItem.rightBarButtonItem?.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowMessages)))
                
                NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
                
                let unread = DataService.shared.getUnreadConversations()
                messageBarIcon.setUnreadMessages(unread)
            }
        }
    }
    
    func configureAddButton(primaryAppearance: Bool) {
        addButton = UIButton(type: .system)
        addButton.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = primaryAppearance ? primaryColor : .label
        configuration.image = UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(primaryAppearance ? .white : .systemBackground)
        configuration.cornerStyle = .capsule

        addButton.configuration = configuration
        addButton.tintAdjustmentMode = .normal
        addButton.layer.shadowColor = UIColor.secondaryLabel.cgColor
        addButton.layer.shadowOpacity = 0.5
        addButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        addButton.layer.shadowRadius = 4
        
        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            addButton.heightAnchor.constraint(equalToConstant: view.frame.width / 7),
            addButton.widthAnchor.constraint(equalToConstant: view.frame.width / 7)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        if let tabController = tabBarController as? MainTabController, tabController.selectedIndex != 3 {
            panDelegate?.disablePanGesture()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let tabController = tabBarController as? MainTabController, tabController.selectedIndex != 3 {
            panDelegate?.disablePanGesture()
        }
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
        case AppPublishers.Names.refreshUser:
            
            if let profileImageUrl = UserDefaults.standard.value(forKey: "profileUrl") as? String, profileImageUrl != "" {
                userImageView.sd_setImage(with: URL(string: profileImageUrl))
            }
        default:
            break
        }
    }
    
    @objc func handleAdd() {
        delegate?.didTapAddButton()
    }
}
