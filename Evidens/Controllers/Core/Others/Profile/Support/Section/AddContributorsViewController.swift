//
//  AddContributorsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/2/23.
//

import UIKit
import Firebase

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let searchHeaderReuseIdentifier = "SearchHeaderReuseIdentifier"
private let conversationCellReuseIdentifier = "ConversationCellReuseIdentifier"
private let contributorsCellReuseIdentifier = "ContributorsCellReuseIdentifier"

protocol AddContributorsViewControllerDelegate: AnyObject {
    func didAddContributors(contributors: [User])
}

class AddContributorsViewController: UIViewController {
    
    //MARK: - Properties
    weak var delegate: AddContributorsViewControllerDelegate?
    
    private let user: User

    private var users = [User]()
    private var filteredUsers = [User]()
    private var usersSelected = [User]()
    private var usersLoaded: Bool = false

    private var collectionView: UICollectionView!
   
    //MARK: - Lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        fetchFirstGroupOfUsers()
    }
    
    init(user: User, selectedUsers: [User]? = nil) {
        self.user = user
        if let selectedUsers = selectedUsers {
            self.usersSelected = selectedUsers
        } else {
            self.usersSelected = [user]
        }

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func fetchFirstGroupOfUsers() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        UserService.fetchFollowing(forUid: uid, lastSnapshot: nil) { snapshot in
            let uids = snapshot.documents.map({ $0.documentID })
            UserService.fetchUsers(withUids: uids) { users in
                self.users = users
                self.filteredUsers = users
                self.usersLoaded = true
                self.collectionView.reloadSections(IndexSet(integer: 1))
            }
        }
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            
            if sectionNumber == 1 {
                
                
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(65)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(65)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            } else {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(55)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.25), heightDimension: .absolute(120)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header]
                section.orthogonalScrollingBehavior = .continuous
                return section
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        layout.configuration = config
        return layout
    }
    
    private func configureNavigationBar() {
        title = "Contributors"
        let rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(handleAddContributors))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(GroupSearchBarHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)
        collectionView.register(UserContributorCell.self, forCellWithReuseIdentifier: contributorsCellReuseIdentifier)
        
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(UserSelectionCell.self, forCellWithReuseIdentifier: conversationCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        
        view.backgroundColor = .systemBackground
        view.addSubviews(collectionView)
    }
    
    private func validateUsers() {
        navigationItem.rightBarButtonItem?.isEnabled = usersSelected.count > 1 ? true : false
    }
    
    @objc func handleAddContributors() {
        delegate?.didAddContributors(contributors: usersSelected)
        navigationController?.popViewController(animated: true)
    }
}

extension AddContributorsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return usersSelected.count
        } else {
            return usersLoaded ? filteredUsers.count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! GroupSearchBarHeader
        header.invalidateInstantSearch = true
        header.delegate = self
        return header
    }
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contributorsCellReuseIdentifier, for: indexPath) as! UserContributorCell
            cell.set(user: usersSelected[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversationCellReuseIdentifier, for: indexPath) as! UserSelectionCell
            cell.set(user: filteredUsers[indexPath.row])
            if usersSelected.contains(filteredUsers[indexPath.row]) {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard usersSelected[indexPath.row].uid != user.uid! else { return }
            if let index = filteredUsers.firstIndex(where: { $0.uid == usersSelected[indexPath.row].uid }) {
                usersSelected.remove(at: indexPath.row)
                collectionView.deleteItems(at: [indexPath])
                collectionView.deselectItem(at: IndexPath(item: index, section: 1), animated: true)
            } else {
                usersSelected.remove(at: indexPath.row)
                collectionView.deleteItems(at: [indexPath])
            }
            
        } else {
            guard filteredUsers.count > 0 else { return }
            let selectedUser = filteredUsers[indexPath.row]
            guard !usersSelected.contains(selectedUser) else { return }
            usersSelected.insert(selectedUser, at: 0)
            collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
        }
        validateUsers()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let selectedUser = filteredUsers[indexPath.row]
            if let index = usersSelected.firstIndex(where: { $0.uid == selectedUser.uid }) {
                usersSelected.remove(at: index)
                collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                validateUsers()
            }
        }
    }
}



extension AddContributorsViewController: GroupSearchBarHeaderDelegate {
    func didSearchText(text: String) {
        UserService.fetchUsersWithText(text: text.trimmingCharacters(in: .whitespaces)) { users in
            self.filteredUsers = users
            self.collectionView.reloadSections(IndexSet(integer: 1))
        }
    }
    
    func resetUsers() {
        filteredUsers = users
        self.collectionView.reloadSections(IndexSet(integer: 1))
    }
}