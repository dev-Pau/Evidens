//
//  ConversationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/1/22.
//


import UIKit

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let emptyCellReuseIdentifier = "EmptyCellReuseIdentifier"
private let conversationCellReuseIdentifier = "ConversationCellReuseIdentifier"


protocol ConversationViewControllerDelegate: AnyObject {
    func didTapHideConversations()
    func handleTooglePan()
}

class ConversationViewController: UIViewController {

    // MARK: - Properties
    
    var user: User? {
        didSet {
            guard let _ = user else { return }
            configureNavigationBar()
        }
    }

    private lazy var lockView = MEPrimaryBlurLockView(frame: view.bounds)
    private var collectionView: UICollectionView!
    private var searchController: UISearchController!
    private var conversationsLoaded: Bool = false
    weak var delegate: ConversationViewControllerDelegate?
    private var conversations = [Conversation]()
    private var pendingConversations = [Conversation]()
    private var didLeaveScreen: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if didLeaveScreen {
            updatePan()
            didLeaveScreen.toggle()
        }
    }

    // MARK: - Helpers
    
    private func conversationLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else {
                return nil
            }
            
            if strongSelf.conversations.isEmpty {
                // Create layout for empty conversations
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(strongSelf.view.frame.width * 0.6)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(strongSelf.view.frame.width * 0.6)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                return section
            } else {
                // Create layout for non-empty conversations using list configuration
                let section = NSCollectionLayoutSection.list(using: strongSelf.createListConfiguration(), layoutEnvironment: env)
                return section
            }
        }
        return layout
    }
    
    private func createListConfiguration() -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        // Customize list configuration settings
        configuration.showsSeparators = false
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let strongSelf = self else { return nil }
            return strongSelf.createTrailingSwipeActions(for: indexPath)
        }
      
        return configuration
    }
    
    private func createTrailingSwipeActions(for indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] action, view, completion in
            guard let strongSelf = self else { return }
            strongSelf.displayAlert(withTitle: AppStrings.Alerts.Title.deleteConversation, withMessage: AppStrings.Alerts.Subtitle.deleteConversation, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
                guard let strongSelf = self else { return }
                completion(true)
                strongSelf.deleteConversation(at: indexPath)
            }
        }
        
        let pinAction = UIContextualAction(style: .normal, title: nil) { [weak self] action, view, completion in
            // Handle pin action
            guard let strongSelf = self else { return }
            completion(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                strongSelf.togglePinConversation(at: indexPath)
            }
        }
        
        // Configure delete and pin actions
        deleteAction.image = UIImage().swipeLayout(icon: AppStrings.Icons.trash, text: AppStrings.Global.delete, size: 16)
        pinAction.image = UIImage().swipeLayout(icon: AppStrings.Icons.fillPin, text: conversations[indexPath.item].isPinned ? AppStrings.Actions.unpin : AppStrings.Actions.pin, size: 16)
        return UISwipeActionsConfiguration(actions: [deleteAction, pinAction])
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: conversationLayout())
        view.addSubview(collectionView)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        collectionView.register(ConversationCell.self, forCellWithReuseIdentifier: conversationCellReuseIdentifier)
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Title.message
        
        let controller = ConversationResultsUpdatingViewController()
        controller.delegate = self
        searchController = UISearchController(searchResultsController: controller)
        searchController.searchResultsUpdater = controller
        searchController.searchBar.delegate = controller
        searchController.searchBar.placeholder = AppStrings.Search.Bar.message
        searchController.searchBar.searchTextField.layer.cornerRadius = 17
        searchController.searchBar.searchTextField.layer.masksToBounds = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = primaryColor
        searchController.showsSearchResultsController = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
        navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), style: .done, target: self, action: #selector(didTapComposeButton))
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), style: .done, target: self, action: #selector(didTapHideConversations))
        
        backButton.title = ""
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton
    }
    
    func loadConversations() {
        // Messages that have not been sent they get updated to failed
        print("i call it here")
      
        //DataService.initialize(userId: uid)
        DataService.shared.editPhase()
        // Retrieve conversations from the data service
        conversations = DataService.shared.getConversations()
        print("inside the conversationviewcontrolelr we get \(conversations.count)")
        conversationsLoaded = true
        collectionView.reloadData()
        observeConversations()
    }

    private func observeConversations() {
        // Observe current conversations
        DatabaseManager.shared.observeConversations { conversationId in
            self.conversations = DataService.shared.getConversations()
            NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
            self.collectionView.reloadData()
        }
    }
    
    private func togglePinConversation(at indexPath: IndexPath) {
        // Toggle the pin status of the conversation at the specified index path
        conversations[indexPath.row].togglePin()
        
        // Get the conversation to update and save the pin status changes
        let conversationToUpdate = self.conversations[indexPath.row]
        DataService.shared.edit(conversation: conversationToUpdate, set: conversationToUpdate.isPinned, forKey: "isPinned")
        
        // Create a map to sort the conversations based on the updated pin status
        let unorderedConversations = self.conversations
        sortConversations()
        let sortMap = unorderedConversations.map { conversations.firstIndex(of: $0)!}
        
        // Perform batch updates to move items and reload collection view
        collectionView.performBatchUpdates { [weak self] in
            guard let strongSelf = self else { return }
            for index in 0 ..< sortMap.count {
                if index != sortMap[index] {
                    strongSelf.collectionView.moveItem(at: IndexPath(item: index, section: 0), to: IndexPath(item: sortMap[index], section: 0))
                }
            }
        } completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            // Reload the collection view to ensure proper display of the updated order
            strongSelf.collectionView.reloadData()
        }
    }
    
    private func deleteConversation(at indexPath: IndexPath) {
        // Get the conversation to delete
        let conversation = conversations[indexPath.row]
        
        // Delete the conversation
        DatabaseManager.shared.deleteConversation(conversation) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(_):
                // If deletion is successful, also delete the conversation from the local data store
                DataService.shared.delete(conversation: conversation)
                
                // Perform batch updates to remove the conversation from the collection view
                strongSelf.collectionView.performBatchUpdates { [weak self] in
                    guard let strongSelf = self else { return}
                    strongSelf.conversations.remove(at: indexPath.row)
                    if strongSelf.conversations.isEmpty {
                        print("we dont have conversations")

                        //strongSelf.collectionView.reloadData()
                    } else {
                        strongSelf.collectionView.deleteItems(at: [indexPath])
                    }
                } completion: { _ in
                    strongSelf.collectionView.reloadData()
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
                
            case .failure(let error):
                // Handle the failure case and print the error message
                print(error.localizedDescription)
            }
        }
    }
    
    private func sortConversations() {
        // Sort the conversations based on the defined sorting criteria
        print("we sort conversations")
        conversations.sort { (conversation1, conversation2) -> Bool in
            /*
             If conversation1 is pinned and conversation2 is not pinned,
             conversation1 should come before conversation2
             */
            if conversation1.isPinned && !conversation2.isPinned {
                return true
            }
            
            /*
             If conversation1 is not pinned and conversation2 is pinned,
             conversation1 should come after conversation2
             */
            if !conversation1.isPinned && conversation2.isPinned {
                return false
            }
            
            /*
             If both conversations are pinned or both conversations are not pinned,
             compare their latest message sent dates to determine the order
            */
            return conversation1.latestMessage?.sentDate ?? Date() > conversation2.latestMessage?.sentDate ?? Date()
        }
    }

    // MARK: - Actions
    
    @objc func didTapComposeButton() {
        // Presents the NewMessageViewController modally
        let controller = NewMessageViewController()
        controller.delegate = self
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .automatic
        present(navVC, animated: true)
    }
    
    @objc func didTapHideConversations() {
        delegate?.didTapHideConversations()
    }
}

extension ConversationViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return conversationsLoaded ? conversations.isEmpty ? 1 : conversations.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if conversations.isEmpty {
            print("conversations is empty")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
            cell.set(withImage: nil, withTitle: "Begin Connecting.", withDescription: "Drop a line, share posts, cases and more with private conversations between you and others", withButtonText: "Start a New Conversation")
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversationCellReuseIdentifier, for: indexPath) as! ConversationCell
            cell.viewModel = ConversationViewModel(conversation: conversations[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !conversations.isEmpty else { return }
        let conversation = conversations[indexPath.row]
        
        let controller = MessageViewController(conversation: conversation)
        
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
        updatePan()
        didLeaveScreen = true
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        // Check if there are selected index paths and if conversations exist
        guard !indexPaths.isEmpty, !conversations.isEmpty else { return nil }
        
        // Create a preview view controller for the selected conversation
        let previewViewController = UINavigationController(rootViewController: MessageViewController(conversation: conversations[indexPaths[0].item], preview: true))
        let previewProvider: () -> UINavigationController? = { previewViewController }
        
        // Define the context menu configuration
        return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider) { [weak self] _ in
            guard let _ = self else { return nil }
            let deleteAction = UIAction(title: AppStrings.Alerts.Title.deleteConversation, image: UIImage(systemName: AppStrings.Icons.trash), attributes: .destructive) { [weak self] action in
                guard let strongSelf = self else { return }
                strongSelf.displayAlert(withTitle: AppStrings.Alerts.Title.deleteConversation, withMessage: AppStrings.Alerts.Subtitle.deleteConversation, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.deleteConversation(at: indexPaths[0])
                }
            }
            return UIMenu(children: [deleteAction])
        }
    }
}

extension ConversationViewController: ConversationResultsUpdatingViewControllerDelegate {
    func readMessages(for conversation: Conversation) {
        // Reads all messages in the given conversation
        didReadAllMessages(for: conversation)
    }
    
    func sendMessage(_ message: Message, to conversation: Conversation) {
        // Sends the given message to the specified conversation
        didSendMessage(message, for: conversation)
    }
    
    func didTapConversation(_ conversation: Conversation) {
        // Marks all messages in the conversation as read when the conversation is tapped
        didReadAllMessages(for: conversation)
    }
    
    func didTapRecents(_ text: String) {
        // Updates the search bar text with the provided text when tapping on any recent search
        searchController.searchBar.text = text
    }
}

extension ConversationViewController: SearchConversationViewControllerDelegate {
    func filterConversationsWithText(text: String, completion: @escaping ([User]) -> Void) {
        /*
        let result: [User] = users.filter { $0.firstName!.lowercased().contains(text) || $0.lastName!.lowercased().contains(text) }
        completion(result)
         */
    }
    
    func didTapUser(user: User) {
        /*
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
         */
    }
    
    func updatePan() {
        // Call the delegate method to handle the toggle pan
        delegate?.handleTooglePan()
    }
    
    func updateScreenToggle() {
        didLeaveScreen = true
    }
    
    func didTapTextToSearch(text: String) {
        // Set the text in the search bar of the search controller
        searchController.searchBar.text = text
    }
}

extension ConversationViewController: NewMessageViewControllerDelegate {
    func didOpenConversation(for user: User) {
        // Check if a conversation already exists for the specified user
        DataService.shared.conversationExists(for: user.uid!) { [weak self] exists in
            guard let strongSelf = self else { return }
            if exists {
                // If a conversation exists, find its index in the conversations array
                if let conversationIndex = strongSelf.conversations.firstIndex(where: { $0.userId == user.uid! }) {
                    // Create and configure the MessageViewController with the existing conversation
                    let controller = MessageViewController(conversation: strongSelf.conversations[conversationIndex], user: user)
                    controller.delegate = self
                    
                    strongSelf.navigationController?.pushViewController(controller, animated: true)
                    strongSelf.updatePan()
                    strongSelf.didLeaveScreen = true
                }
            } else {
                // If a conversation doesn't exist, create a new one
                guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
                let name = user.firstName! + " " + user.lastName!
                let newConversation = Conversation(name: name, userId: user.uid!, ownerId: uid)
                
                // Create and configure the MessageViewController with the new conversation
                let controller = MessageViewController(conversation: newConversation, user: user)
                controller.delegate = self
              
                strongSelf.navigationController?.pushViewController(controller, animated: true)
                strongSelf.updatePan()
                strongSelf.didLeaveScreen = true
            }
        }
    }
}

extension ConversationViewController: PrimaryEmptyCellDelegate {
    func didTapEmptyAction() {
        // Presents the NewMessageViewController modally
        let controller = NewMessageViewController()
        controller.delegate = self
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .automatic
        present(navVC, animated: true)
    }
}

extension ConversationViewController: MessageViewControllerDelegate {

    func didSendMessage(_ message: Message, for conversation: Conversation) {
        // Find the index of the conversation in the conversations array
        if let conversationIndex = conversations.firstIndex(where: { $0.userId == conversation.userId }) {
            // Update the latest message of the conversation with the new message
            conversations[conversationIndex].changeLatestMessage(to: message)
            
            // Reload the corresponding item in the collection view to reflect the changes
            collectionView.reloadItems(at: [IndexPath(item: conversationIndex, section: 0)])
        }
    }
    
    func didReadAllMessages(for conversation: Conversation) {
        // Find the index of the conversation in the conversations array
        if let conversationIndex = conversations.firstIndex(where: { $0.userId == conversation.userId }) {
            // Mark all messages in the conversation as read
            conversations[conversationIndex].markMessagesAsRead()
            
            // Reload the corresponding item in the collection view to reflect the changes
            collectionView.reloadItems(at: [IndexPath(item: conversationIndex, section: 0)])
        }
    }
    
    func didReadConversation(_ conversation: Conversation, message: Message) {
        //pendingConversations.append(conversation)
        if let conversationIndex = conversations.firstIndex(where: { $0.userId == conversation.userId }) {
            conversations[conversationIndex].changeLatestMessage(to: message)
            collectionView.reloadItems(at: [IndexPath(item: conversationIndex, section: 0)])
            pendingConversations.append(conversation)
            print("received message while inside convo")
        }
    }
    
    
    func deleteConversation(_ conversation: Conversation) {
        // Delete the conversation from the local data store
        DataService.shared.delete(conversation: conversation)
        
        
        // Find the index of the conversation in the conversations array
        if let conversationIndex = conversations.firstIndex(of: conversation) {
            
            collectionView.performBatchUpdates { [weak self] in
                guard let strongSelf = self else { return}
                strongSelf.conversations.remove(at: conversationIndex)
                if strongSelf.conversations.isEmpty {
                    print("we dont have conversations")

                    //strongSelf.collectionView.reloadData()
                } else {
                    strongSelf.collectionView.deleteItems(at: [IndexPath(item: conversationIndex, section: 0)])
                }
            } completion: { _ in
                self.collectionView.reloadData()
            }
        
            NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
        }

    }
    
    func didCreateNewConversation(_ conversation: Conversation) {
        print("we are here")
        // Sort the conversations based on the sorting logic
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.performBatchUpdates {
                // Insert the new conversation at the beginning of the conversations array
                strongSelf.conversations.append(conversation)

                
                if strongSelf.conversations.count == 1 {
                    strongSelf.collectionView.reloadData()
                } else {
                    strongSelf.collectionView.insertItems(at: [IndexPath(item: strongSelf.conversations.count - 1, section: 0)])
                }
            } completion: { _ in
                strongSelf.sortConversations()
                strongSelf.collectionView.reloadData()

            }
        }

        
        /*
        // Find the index of the new conversation in the conversations array
        if let conversationIndex = conversations.firstIndex(of: conversation) {
            print("aquí arriba")
            // Asynchronously perform batch updates on the collection view to insert the new item
            
        }
        */

    }
}
