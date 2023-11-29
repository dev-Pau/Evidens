//
//  NavigationBarViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/9/22.
//

import UIKit

protocol NavigationBarViewControllerDelegate: AnyObject {
    func didTapIconImage()
    func didTapOpenConversations()
    func didTapAddButton()
}

class NavigationBarViewController: UIViewController {
    
    weak var delegate: NavigationBarViewControllerDelegate?
    weak var scrollDelegate: PrimaryScrollViewDelegate?

    var controllerIsBeeingPushed: Bool = false
    
    private let messageBarIcon = MessageBarView()
    
    private let userImageView = ProfileImageView(frame: .zero)
    
    var addButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapIconImage))
        userImageView.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name(        AppPublishers.Names.refreshUser), object: nil)
        
        guard !controllerIsBeeingPushed else { return }
        
        userImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        userImageView.layer.cornerRadius = 30 / 2
        
        let profileImageItem = UIBarButtonItem(customView: userImageView)
        
        if let profileImageUrl = UserDefaults.standard.value(forKey: "profileUrl") as? String, profileImageUrl != "" {
            userImageView.sd_setImage(with: URL(string: profileImageUrl))
        }
        
        addNavigationBarLogo(withTintColor: baseColor)
        
        navigationItem.leftBarButtonItem = profileImageItem
        
        if navigationController?.navigationBar.tag == 1 {
            
            let searchImage = UIImage(systemName: AppStrings.Icons.magnifyingglass, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: 27, height: 27)).withRenderingMode(.alwaysOriginal).withTintColor(.label)
            let searchImageView = UIImageView(image: searchImage)
            
            searchImageView.translatesAutoresizingMaskIntoConstraints = false
            searchImageView.clipsToBounds = true
            searchImageView.contentMode = .scaleAspectFill
            
            navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: messageBarIcon), UIBarButtonItem(customView: searchImageView)]
            navigationItem.rightBarButtonItems?[0].customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowMessages)))
            navigationItem.rightBarButtonItems?[1].customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowExplore)))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: messageBarIcon)
            navigationItem.rightBarButtonItem?.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowMessages)))
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
        
        let unread = DataService.shared.getUnreadConversations()
        messageBarIcon.setUnreadMessages(unread)
    }
    
    func configureAddButton(primaryAppearance: Bool) {
        addButton = UIButton(type: .system)
        addButton.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = primaryAppearance ? primaryColor : .label
        configuration.image = UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: view.frame.width / 14, height: view.frame.width / 14)).withRenderingMode(.alwaysOriginal).withTintColor(primaryAppearance ? .white : .systemBackground)
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
            scrollDelegate?.enable()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let tabController = tabBarController as? MainTabController, tabController.selectedIndex != 3 {
            scrollDelegate?.disable()
        }
    }
    
    @objc func didTapIconImage() {
        delegate?.didTapIconImage()
    }
    
    @objc func handleShowMessages() {
        delegate?.didTapOpenConversations()
    }
    
    @objc func handleShowExplore() {
        let controller = CaseExplorerViewController()
        navigationController?.pushViewController(controller, animated: true)
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
