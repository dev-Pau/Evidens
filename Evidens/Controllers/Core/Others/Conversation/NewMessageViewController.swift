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
    
    private var viewModel = NewMessageViewModel()
    
    weak var delegate: NewMessageViewControllerDelegate?

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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Global.cancel, style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
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
        viewModel.fetchConnections { [weak self] error in
            guard let strongSelf = self else { return }
            
            if let error, error != .notFound {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                strongSelf.collectionView.reloadData()
            }
        }
    }
    
    private func openConversation(with user: User) {
        dismiss(animated: true)
        delegate?.didOpenConversation(for: user)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}

extension NewMessageViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 0 }
        return viewModel.usersLoaded ? viewModel.filteredUsers.isEmpty ? 1 : viewModel.filteredUsers.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if !viewModel.usersLoaded {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! SearchBarHeader
            header.invalidateInstantSearch = true
            header.delegate = self
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            if !viewModel.usersLoaded {
                return CGSize(width: UIScreen.main.bounds.width, height: 55)
            } else {
                return viewModel.users.isEmpty ? CGSize.zero : CGSize(width: UIScreen.main.bounds.width, height: 55)
            }
        } else {
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.filteredUsers.isEmpty ? CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.7) : CGSize(width: UIScreen.main.bounds.width, height: 73)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.filteredUsers.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: viewModel.isInSearchMode ? AppStrings.Content.User.emptyTitle : AppStrings.Content.Message.emptyTitle, description: viewModel.isInSearchMode ? AppStrings.Content.Message.emptySearchTitle : AppStrings.Content.Message.emptyContent, content: .dismiss)

            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversationCellReuseIdentifier, for: indexPath) as! NewConversationCell
            cell.set(user: viewModel.filteredUsers[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard viewModel.filteredUsers.count > 0 else { return }
        let user = viewModel.filteredUsers[indexPath.row]
        
        guard viewModel.hasNetworkConnection else {
            displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
            return
        }

        openConversation(with: user)
    }
}

extension NewMessageViewController: MESecondaryEmptyCellDelegate {
    func didTapContent(_ content: EmptyContent) {
        dismiss(animated: true)
    }
}

extension NewMessageViewController: SearchBarHeaderDelegate {
    func didSearchText(text: String) {
        viewModel.fetchUsersWithText(text) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadSections(IndexSet(integer: 1))
        }
    }
    
    func resetUsers() {
        viewModel.filteredUsers = viewModel.users
        collectionView.reloadSections(IndexSet(integer: 1))
    }
}
