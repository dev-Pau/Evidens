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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name("ProfileImageUpdateIdentifier"), object: nil)
        
        if !controllerIsBeeingPushed {
            
            userImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            userImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            userImageView.layer.cornerRadius = 30 / 2
            let profileImageItem = UIBarButtonItem(customView: userImageView)
            userImageView.sd_setImage(with: URL(string: UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String ?? ""))
            navigationItem.leftBarButtonItem = profileImageItem
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "paperplane")?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)), style: .done, target: self, action: #selector(didTapChat))

            navigationItem.rightBarButtonItem?.tintColor = .label
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
        print("navigation bar received notification :)")
        userImageView.sd_setImage(with: URL(string: UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String ?? ""))
    }
}
