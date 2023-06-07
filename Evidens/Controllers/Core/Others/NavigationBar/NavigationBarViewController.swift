//
//  NavigationBarViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/9/22.
//

import UIKit

protocol NavigationBarViewControllerDelegate: AnyObject {
    func didTapMenuButton()
    func didTapSearchBar()
    func didTapConversationsButton()
}

class NavigationBarViewController: UIViewController {
    
    weak var delegate: NavigationBarViewControllerDelegate?
    weak var panDelegate: DisablePanGestureDelegate?

    var controllerIsBeeingPushed: Bool = false
    //var wantsToHideSearchBar: Bool = false

    //let searchController = UISearchController(searchResultsController: nil)

    private lazy var userImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfile))
        iv.addGestureRecognizer(tap)
        iv.image = UIImage(named: "user.profile")
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let paperplaneView = PaperplaneView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name("ProfileImageUpdateIdentifier"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name("UserUpdateIdentifier"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name("UnreadMessagesUpdateIdentifier"), object: nil)
        
        if !controllerIsBeeingPushed {
            
            userImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            userImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            userImageView.layer.cornerRadius = 30 / 2
            let profileImageItem = UIBarButtonItem(customView: userImageView)

            if let profileImageUrl = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String, profileImageUrl != "" {
                userImageView.sd_setImage(with: URL(string: profileImageUrl))
                
            }
            
            navigationItem.leftBarButtonItem = profileImageItem
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "envelope", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), style: .done, target: self, action: #selector(didTapChat))


            //navigationItem.rightBarButtonItem = UIBarButtonItem(customView: paperplaneView)
            //let unread = DataService.shared.getUnreadMessage()
            //paperplaneView.setUnreadMessages(unread)
            

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        //if wantsToHideSearchBar { panDelegate?.disableRightPanGesture() }
        panDelegate?.disablePanGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //if wantsToHideSearchBar { panDelegate?.disableRightPanGesture() }
        panDelegate?.disablePanGesture()
    }

    @objc func didTapProfile() {
        delegate?.didTapMenuButton()
    }
    
    @objc func didTapChat() {
        delegate?.didTapConversationsButton()
    }
    
    @objc func didReceiveNotification(notification: NSNotification) {
        
        if let profileImageUrl = UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String, profileImageUrl != "" {
            userImageView.sd_setImage(with: URL(string: profileImageUrl))
        }
    }
}

class PaperplaneView: UIView {
    
    let paperplaneImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "envelope", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let unreadMessagesButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.isUserInteractionEnabled = false
        button.configuration?.baseBackgroundColor = .systemRed

        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.buttonSize = .mini
        button.configuration?.cornerStyle = .capsule
    
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(paperplaneImageView, unreadMessagesButton)
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: AppStrings.Assets.paperplane), for: .normal)
        //button.tintColor = .label
        //addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            paperplaneImageView.topAnchor.constraint(equalTo: topAnchor),
            paperplaneImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            paperplaneImageView.heightAnchor.constraint(equalToConstant: 27),
            paperplaneImageView.widthAnchor.constraint(equalToConstant: 27),
            paperplaneImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            paperplaneImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            unreadMessagesButton.topAnchor.constraint(equalTo: topAnchor),
            unreadMessagesButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            unreadMessagesButton.heightAnchor.constraint(equalToConstant: 10),
            unreadMessagesButton.widthAnchor.constraint(equalToConstant: 10)
        ])
    }
    
    func setUnreadMessages(_ unread: Int) {
        unreadMessagesButton.isHidden = unread == 0 ? true : false
    }
}
