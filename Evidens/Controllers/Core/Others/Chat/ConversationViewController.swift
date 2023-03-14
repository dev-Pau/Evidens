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
        
     
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), style: .done, target: self, action: #selector(didTapComposeButton))
    
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
        let controller = NewMessageViewController(conversations: conversations)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func didTapHideConversations() {
        delegate?.didTapHideConversations()
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
            cell.set(withImage: UIImage(named: "message.empty")!, withTitle: "Welcome to your inbox.", withDescription: "Drop a line, share posts, cases and more with private conversations between you and others", withButtonText: "   Write a message   ")
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
        if conversations.isEmpty { return }
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
        
        searchController.isActive = false
        
    }
}

extension ConversationViewController: SearchConversationViewControllerDelegate {
    func filterConversationsWithText(text: String, completion: @escaping ([User]) -> Void) {
        let result: [User] = users.filter { $0.firstName!.lowercased().contains(text) || $0.lastName!.lowercased().contains(text) }
        completion(result)
    }
    
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
                let reportPopup = METopPopupView(title:"Conversation with \(user.firstName!) has been deleted", image: "checkmark.circle.fill", popUpType: .regular)
                reportPopup.showTopPopup(inView: self.view)
                return
            }
        } else {
            return
        }
    }
}
