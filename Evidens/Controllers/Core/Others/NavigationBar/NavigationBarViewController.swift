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

    let searchController = UISearchController(searchResultsController: nil)
    
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
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        let atrString = NSAttributedString(string: "Search", attributes: [.font : UIFont.systemFont(ofSize: 15)])
        searchBar.searchTextField.attributedPlaceholder = atrString
        searchBar.searchTextField.tintColor = primaryColor
        searchBar.searchTextField.backgroundColor = .tertiarySystemFill
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        return searchBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if !controllerIsBeeingPushed {
            
            
            userImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            userImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            userImageView.layer.cornerRadius = 30 / 2
            let profileImageItem = UIBarButtonItem(customView: userImageView)
            userImageView.sd_setImage(with: URL(string: UserDefaults.standard.value(forKey: "userProfileImageUrl") as? String ?? ""))
            navigationItem.leftBarButtonItem = profileImageItem
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "paperplane")?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)), style: .done, target: self, action: #selector(didTapChat))

            navigationItem.rightBarButtonItem?.tintColor = .label
                                                  
                                                  
                                                  
            let searchBarContainer = SearchBarContainerView(customSearchBar: searchBar)
            searchBarContainer.heightAnchor.constraint(equalToConstant: 44).isActive = true
            searchBarContainer.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.70).isActive = true
            navigationItem.titleView = searchBarContainer
        
            searchBar.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.resignFirstResponder()
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
}

extension NavigationBarViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        delegate?.didTapSearchBar()
        return true
    }
}


