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



class NewMessageViewController: UIViewController {
    
    //MARK: - Properties
    
    private var conversations: [Conversation]
    private var users = [User]()
    private var filteredUsers = [User]()
    private var usersLoaded: Bool = false
    
    private var usersLastSnapshot: QueryDocumentSnapshot?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        return collectionView
    }()
    
    //MARK: - Lifecycle
    
    init(conversations: [Conversation]) {
        self.conversations = conversations
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
        fetchFirstGroupOfUsers()
    }
    
    //MARK: - Helpers
    
    private func fetchFirstGroupOfUsers() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        UserService.fetchFollowing(forUid: uid, lastSnapshot: nil) { snapshot in
            self.usersLastSnapshot = snapshot.documents.last!
            let uids = snapshot.documents.map({ $0.documentID })
            UserService.fetchUsers(withUids: uids) { users in
                self.users = users
                self.filteredUsers = users
                self.usersLoaded = true
                self.collectionView.reloadData()
            }
        }
    }
    
    private func configureNavigationBar() {
        title = "New message"
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubviews(collectionView)
        collectionView.frame = view.bounds
    }
    
    private func configureCollectionView() {
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(GroupSearchBarHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier)
        collectionView.register(NewConversationCell.self, forCellWithReuseIdentifier: conversationCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func openOrCreateConversationWithUser(_ user: User) {
        if let targetConversation = conversations.first(where: {
            $0.otherUserUid == user.uid
        }) {
            // User already has a conversation
            print("Conversation exists")
            let controller = ChatViewController(with: user, id: targetConversation.id, creationDate: targetConversation.creationDate)
            controller.isNewConversation = false
            controller.delegate = self
            controller.title = user.firstName! + " " + user.lastName!
            
            let backItem = UIBarButtonItem()
            backItem.tintColor = .label
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            if var navigationArray = navigationController?.viewControllers {
                navigationArray.removeLast()
                navigationArray.append(controller)
                self.navigationController?.setViewControllers(navigationArray, animated: true)
            }
        } else {
            // Create new conversation with user
            print("conversation does not exist")
            print("We don't have conversation with this user, we create one")
            createNewConversation(result: user)
        }
    }
    
    private func createNewConversation(result: User) {
        let user = result
        let name = result.firstName! + " " + result.lastName!
        let uid = result.uid
        //Check in database if conversation with this users exists
        //If it does, reuse conversationID
        
        DatabaseManager.shared.conversationExists(with: uid!) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let conversationId):
                print("Conversation exists with the user")
                //Conversation exists, open the conversation with conversationID found
                let controller = ChatViewController(with: user, id: conversationId, creationDate: nil)
                
                controller.isNewConversation = false
                controller.delegate = self
                controller.title = name
                
                let backItem = UIBarButtonItem()
                backItem.tintColor = .label
                backItem.title = ""
                
                strongSelf.navigationItem.backBarButtonItem = backItem
                
                strongSelf.navigationController?.pushViewController(controller, animated: true)
                
            case .failure(_):
                print("Conversation does not exist with this user, we push a new chat")
                //There's no conversation that exists, Hi new conversation with id
                let controller = ChatViewController(with: user, id: nil, creationDate: nil)
                controller.delegate = self
                controller.isNewConversation = true
                controller.title = name
                
                let backItem = UIBarButtonItem()
                backItem.tintColor = .label
                backItem.title = ""
                
                strongSelf.navigationItem.backBarButtonItem = backItem
                
                if var navigationArray = strongSelf.navigationController?.viewControllers {
                    navigationArray.removeLast()
                    navigationArray.append(controller)
                    strongSelf.navigationController?.setViewControllers(navigationArray, animated: true)
                }
            }
        }
    }
}

extension NewMessageViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 0 }
        return usersLoaded ? filteredUsers.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if !usersLoaded {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchHeaderReuseIdentifier, for: indexPath) as! GroupSearchBarHeader
            header.invalidateInstantSearch = true
            header.delegate = self
            return header
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: UIScreen.main.bounds.width, height: 55)
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversationCellReuseIdentifier, for: indexPath) as! NewConversationCell
        cell.set(user: filteredUsers[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard filteredUsers.count > 0 else { return }
        let user = filteredUsers[indexPath.row]
        openOrCreateConversationWithUser(user)
    }
}



extension NewMessageViewController: GroupSearchBarHeaderDelegate {
    func didSearchText(text: String) {
        UserService.fetchUsersWithText(text: text.trimmingCharacters(in: .whitespaces)) { users in
            self.filteredUsers = users
            self.collectionView.reloadSections(IndexSet(integer: 1))
        }
    }
    
    func resetUsers() {
        filteredUsers = users
        collectionView.reloadSections(IndexSet(integer: 1))
    }
}


extension NewMessageViewController: ChatViewControllerDelegate {
    func didDeleteConversation(withUser user: User, withConversationId id: String) {
#warning("pass this with a delegate to conversationviewcontroller and call the delete ufnction inside the controller that already has implemented")
    }
    
}
