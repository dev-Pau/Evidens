//
//  NewConversationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/1/22.
//

import UIKit
import JGProgressHUD

private let reusableIdentifier = "cell"

class NewConversationViewController: UIViewController {
    
    
    //MARK: - Properties
    
    private let spinner = JGProgressHUD()
    
    private let searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Start a new conversation"
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: reusableIdentifier)
        return table
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No results"
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissConversation))
        
        searchBar.becomeFirstResponder()
    }
    
    //MARK: - Helpers
    
    //MARK: - Actions
    
    @objc func dismissConversation() {
        dismiss(animated: true, completion: nil)
        
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
