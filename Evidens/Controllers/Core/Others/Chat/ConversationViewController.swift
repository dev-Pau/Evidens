//
//  ConversationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/1/22.
//

import UIKit

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let emptyCellReuseIdentifier = "EmptyCellReuseIdentifier"
private let messageCellReuseIdentifier = "messageUserCellReuseIdentifier"

protocol ConversationViewControllerDelegate: AnyObject {
    func didTapHideConversations()
    func handleTooglePan()
}

/// Controller that shows list of conversations
class ConversationViewController: UIViewController {
    
    //MARK: - Properties
    
    private var conversations = [Conversation]()
    private var users = [User]()
    private var searchController: UISearchController!
    
    private var conversationsLoaded: Bool = false
    
    weak var delegate: ConversationViewControllerDelegate?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        return collectionView
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
        startListeningForConversations()
      
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    //MARK: - Helpers
    
    private func configureNavigationBar() {
        title = "Messages"
        let controller = SearchConversationViewController()
        controller.delegate = self
        searchController = UISearchController(searchResultsController: controller)
        searchController.searchResultsUpdater = controller
        searchController.searchBar.delegate = controller
        searchController.searchBar.placeholder = "Search conversations"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = primaryColor
        searchController.showsSearchResultsController = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
       
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), style: .done, target: self, action: #selector(didTapComposeButton))
    
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), style: .done, target: self, action: #selector(didTapHideConversations))
        
        backButton.title = ""
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton
    }
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }
        
    private func startListeningForConversations() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }

        DatabaseManager.shared.getAllConversations(forUid: uid, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    self.conversationsLoaded = true
                    self.collectionView.reloadData()
                    return
                }
                self.conversations = conversations
                self.conversations.sort(by: { $0.latestMessage.date > $1.latestMessage.date })
                self.users.removeAll()
                conversations.forEach { conversation in
                    UserService.fetchUser(withUid: conversation.otherUserUid) { user in
                        self.users.append(user)
                        self.conversationsLoaded = true
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
                
            case .failure(let error):
                print("failed to get conversations: \(error)")
            }
        })
    }
    
    private func configureCollectionView() {
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(MEPrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: messageCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    //MARK: - Actions
    
    //Creates a new conversation
    @objc private func didTapComposeButton() {
        /*
        let vc = NewMessageViewController()
        vc.completion = { [weak self] user in
            //Check if user conversation already exists
            guard let strongSelf = self else { return }
            
            let currentConversation = strongSelf.conversations
            //Search if target conversation already exists in current conversations
            if let targetConversations = currentConversation.first(where: {
                $0.otherUserUid == user.uid
            }) {
                //Present the existing conversation with targetID already created in database
                print("We have already a conversation with the user")
                let controller = ChatViewController(with: user, id: targetConversations.id, creationDate: targetConversations.creationDate)
                controller.isNewConversation = false
                controller.delegate = self
                controller.title = targetConversations.name
                controller.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(controller, animated: true)
            } else {
                //Create and present a new conversation
                print("We don't have conversation with this user, we create one")
                strongSelf.createNewConversation(result: user)
            }
        }
        
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
         */
    }
    
    @objc func didTapHideConversations() {
        delegate?.didTapHideConversations()
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
                
                controller.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(controller, animated: true)
                
            case .failure(_):
                print("Conversation does not exist with this user, we push a new chat")
                //There's no conversation that exists, Hi new conversation with id
                let controller = ChatViewController(with: user, id: nil, creationDate: nil)
                controller.delegate = self
                controller.isNewConversation = true
                controller.title = name
                controller.navigationItem.largeTitleDisplayMode = .never
                let backItem = UIBarButtonItem()
                backItem.tintColor = .label
                backItem.title = ""
                
                strongSelf.navigationItem.backBarButtonItem = backItem
                
                strongSelf.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
                       
extension ConversationViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return conversationsLoaded ? conversations.isEmpty ? 1 : conversations.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return conversationsLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 70)
    }
            
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if conversations.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
            cell.set(withTitle: "Welcome to your inbox.", withDescription: "Drop a line, share posts, cases and more with private conversations between you and others", withButtonText: "   Write a message   ")
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageCellReuseIdentifier, for: indexPath) as! ChatCell
          
            cell.viewModel = ConversationViewModel(conversation: conversations[indexPath.row])
            
            let userIndex = users.firstIndex { user in
                if user.uid == conversations[indexPath.row].otherUserUid {
                    return true
                }
                return false
            }
            if let userIndex = userIndex {
                cell.set(user: users[userIndex])
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if conversations.isEmpty { return }
        let model = conversations[indexPath.row]
        
        let userIndex = users.firstIndex { user in
            if user.uid == conversations[indexPath.row].otherUserUid {
                return true
            }
            return false
        }
        
        if let userIndex = userIndex {
            let user = users[userIndex]
            openConversation(with: user, with: model)
        }
    }
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        
        let userIndex = users.firstIndex { user in
            if user.uid == conversations[indexPath.row].otherUserUid {
                return true
            }
            return false
        }
        
        if let userIndex = userIndex {
            let user = users[userIndex]
            openConversation(with: user, with: model)
        }
        
    }
     */
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return conversations.isEmpty ? CGSize(width: view.frame.width, height: view.frame.width) : CGSize(width: view.frame.width, height: 71)
    }
    
    func openConversation(with user: User, with model: Conversation) {
        let controller = ChatViewController(with: user, id: model.id, creationDate: model.creationDate)
        controller.delegate = self
        controller.title = user.firstName! + " " + user.lastName!

        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ConversationViewController: UISearchBarDelegate {
    /*
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        
        let controller = SearchConversationViewController(users: users)
        controller.delegate = self

        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
        
    }
     */
}

extension ConversationViewController: SearchConversationViewControllerDelegate {
    func didTapUser(user: User) {
        let userIndex = conversations.firstIndex { conversation in
            if conversation.otherUserUid == user.uid {
                return true
            }
            return false
        }
        
        if let userIndex = userIndex {
            let conversation = conversations[userIndex]
            openConversation(with: user, with: conversation)
        }
    }
    
    func updatePan() {
        delegate?.handleTooglePan()
    }
    
    func didTapTextToSearch(text: String) {
        searchController.searchBar.text = text
    }
}

extension ConversationViewController: ChatViewControllerDelegate {
    func didDeleteConversation(withUser user: User, withConversationId id: String) {
        let conversationIndex = conversations.firstIndex { conversation in
            if conversation.id == id {
                return true

            }
            return false
        }
        
        let userIndex = users.firstIndex { currentUser in
            if currentUser.uid == user.uid {
                return true
            }
            return false
        }
        
        if let conversationIndex = conversationIndex, let userIndex = userIndex {
            collectionView.performBatchUpdates {
                conversations.remove(at: conversationIndex)
                users.remove(at: userIndex)
                collectionView.deleteItems(at: [IndexPath(item: conversationIndex, section: 0)])
            }
           
            //Delete the conversation in the database
            
            DatabaseManager.shared.deleteConversation(conversationId: id) { success in
                if !success {
                    print("Failed to delete conversation")
                }
                print("Conversation deleted")
            }

        } else {
            return
        }
    }
}
/*
 extension ConversationViewController: UISearchResultsUpdating {
 func updateSearchResults(for searchController: UISearchController) {
 guard let text = searchController.searchBar.text else { return }
 
 }
 
 
 
 func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
 delegate?.handleTooglePan()
 }
 
 func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
 delegate?.handleTooglePan()
 }
 
 
 }
 */
