//
//  NewMessageViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/1/22.
//

import UIKit
import Firebase

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let searchHeaderReuseIdentifier = "SearchHeaderReuseIdentifier"
private let conversationCellReuseIdentifier = "ConversationCellReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"

protocol NewMessageViewControllerDelegate: AnyObject {
    func didOpenConversation(for user: User)
}

class NewMessageViewController: UIViewController {
    
    //MARK: - Properties
    
    weak var delegate: NewMessageViewControllerDelegate?
    private var users = [User]()
    private var filteredUsers = [User]()
    private var usersLoaded: Bool = false
    private var isInSearchMode: Bool = false
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        configureView()
        fetchUsers()
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Title.newMessage
    }
    
    private func configureView() {
        view.addSubview(collectionView)
        view.backgroundColor = .systemBackground
    }
    
    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(SearchBarHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)
        collectionView.register(NewConversationCell.self, forCellWithReuseIdentifier: conversationCellReuseIdentifier)
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func fetchUsers() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        UserService.fetchFollowing(forUid: uid, lastSnapshot: nil) { [weak self] result in
            
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                let uids = snapshot.documents.map({ $0.documentID })
                UserService.fetchUsers(withUids: uids) { [weak self] users in
                    guard let strongSelf = self else { return }
                    strongSelf.users = users
                    strongSelf.filteredUsers = users
                    strongSelf.usersLoaded = true
                    strongSelf.collectionView.reloadData()
                }
            case .failure(let error):
                strongSelf.usersLoaded = true
                strongSelf.collectionView.reloadData()
                
                guard error != .notFound else {
                    
                    return
                }
                
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
    
    private func openConversation(with user: User) {
        dismiss(animated: true)
        delegate?.didOpenConversation(for: user)
    }
}

extension NewMessageViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 0 }
        return usersLoaded ? filteredUsers.isEmpty ? 1 : filteredUsers.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if !usersLoaded {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! SearchBarHeader
            header.invalidateInstantSearch = true
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 0 ? users.isEmpty ? CGSize.zero : CGSize(width: UIScreen.main.bounds.width, height: 55) : CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return filteredUsers.isEmpty ? CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.7) : CGSize(width: UIScreen.main.bounds.width, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if filteredUsers.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: isInSearchMode ? AppStrings.Content.User.emptyTitle : AppStrings.Content.Message.emptyTitle, description: isInSearchMode ? AppStrings.Content.Message.emptySearchTitle : AppStrings.Content.Message.emptyContent, content: .dismiss)

            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversationCellReuseIdentifier, for: indexPath) as! NewConversationCell
            cell.set(user: filteredUsers[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard filteredUsers.count > 0 else { return }
        let user = filteredUsers[indexPath.row]
        openConversation(with: user)
    }
}

extension NewMessageViewController: MESecondaryEmptyCellDelegate {
    func didTapContent(_ content: EmptyContent) {
        dismiss(animated: true)
    }
}
