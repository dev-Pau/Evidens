//
//  CasesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/7/22.
//

import UIKit

class CasesViewController: UIViewController {
    
    private let userImageView: UIImageView = {
        let iv = UIImageView()
        //iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        let atrString = NSAttributedString(string: "Search", attributes: [.font : UIFont.systemFont(ofSize: 15)])
        searchBar.searchTextField.attributedPlaceholder = atrString
        searchBar.searchTextField.tintColor = primaryColor
        searchBar.searchTextField.backgroundColor = lightColor
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "paperplane.fill"), style: .plain, target: self, action: #selector(didTapChat))
        
        navigationItem.rightBarButtonItem?.tintColor = .darkGray
        
        userImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        userImageView.layer.cornerRadius = 35 / 2
        let profileImageItem = UIBarButtonItem(customView: userImageView)
        userImageView.sd_setImage(with: URL(string: UserDefaults.standard.value(forKey: "userProfileImageUrl") as! String))
        navigationItem.leftBarButtonItem = profileImageItem
        
        navigationItem.titleView = searchBar
        
    }
    
    @objc func didTapChat() {
        
    }
}
