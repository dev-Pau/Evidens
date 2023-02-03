//
//  NewMessageViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/1/22.
//

import UIKit


private let reusableIdentifier = "cell"

class NewMessageViewController: UIViewController {
    
    //MARK: - Properties
    
    public var completion: ((User) -> (Void))?
    
    //Firebase results
    private var users = [User]()
    
    private let searchLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "To:"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.backgroundColor = .systemBackground
        searchBar.setImage(nil, for: .search, state: .normal)
        searchBar.showsCancelButton = false
        return searchBar
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
    }

    //MARK: - Helpers
    
    private func configureNavigationBar() {
        title = "New message"
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground

    }
    
    private func configureCollectionView() {
        
    }
    
    //MARK: - Actions
    

}

//MARK: - UITableViewDelegate, UITableViewDataSource
/*
extension NewMessageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableIdentifier, for: indexPath) as! NewConversationCell
        cell.set(user: users[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //Start conversation
        let targetUserData = users[indexPath.row]
        
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUserData)
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        
        searchBar.resignFirstResponder()
        users.removeAll()
        UserService.fetchUsersWithText(text: text.trimmingCharacters(in: .whitespaces)) { users in
            self.users = users
            self.filterUsers()
            
        }
    }
    
    func filterUsers() {
        //Update the UI: Either show results or show no results label
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        let fetchedUsers: [User] = users.filter { user in
            if user.uid == uid { return false }
            return true
        }
        
        users = fetchedUsers
        updateUI()
    }
    
    func updateUI() {
        if users.isEmpty {
            noResultsLabel.isHidden = false
            tableView.isHidden = true
        } else {
            noResultsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
            
        }
    }
}
*/
