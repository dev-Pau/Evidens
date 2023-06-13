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
        loadConversations()
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
            // Handle delete action
            guard let strongSelf = self else { return }
            strongSelf.deleteConversationAlert { delete in
                completion(true)
                if delete {
                    strongSelf.deleteConversation(at: indexPath)
                }
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
        collectionView.register(MEPrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        collectionView.register(ConversationCell.self, forCellWithReuseIdentifier: conversationCellReuseIdentifier)
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Title.message

        guard let user = user else { return }
        
        if user.phase == .verified {
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
            
            navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), style: .done, target: self, action: #selector(didTapComposeButton))
        } else {
            view.addSubview(lockView)
        }
  
        let backButton = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), style: .done, target: self, action: #selector(didTapHideConversations))
        
        backButton.title = ""
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func loadConversations() {
        // Messages that have not been sent they get updated to failed
        DataService.shared.editPhase()
        // Retrieve conversations from the data service
        conversations = DataService.shared.getConversations()
        print(self.conversations.map { $0.userId })
        conversationsLoaded = true
        
        // Observe current conversations and root for new conversations
        //observeConversationRoot()
        observeConversations()
        
        /*
        // Check for new conversations and unsynced messages
        DatabaseManager.shared.checkForNewConversations(with: conversations.map { $0.id! }) { [weak self] unsyncedIds in
            guard let strongSelf = self else {
                return
            }
            
            // If there are no unsyncedIds or no conversations with new messages, return
            guard !unsyncedIds.isEmpty else {
                return
            }
            
            // Filter out conversations that are not yet present in the current conversations list
            let currentConversationIds = strongSelf.conversations.map { $0.id! }
            let newConversationIds = unsyncedIds.filter { !currentConversationIds.contains($0) }
            
            // Filter conversations with new messages from the unsyncedIds list
            let conversationsWithNewMessages = unsyncedIds.filter { currentConversationIds.contains($0) }
            
            // Filter conversations with no new messages
            let conversationsWithNoNewMessages = currentConversationIds.filter { !unsyncedIds.contains($0) }
            
            // Fetch new conversations with the provided IDs
            strongSelf.fetchNewConversations(withIds: newConversationIds)
            
            // Fetch new messages for conversations that already exist
            strongSelf.fetchNewMewMessages(withIds: conversationsWithNewMessages)
            
            strongSelf.observeConversations()

        }
         */
    }
    
    private func fetchNewConversations(withIds conversationIds: [String]) {
        // Fetch new conversations and users using the provided conversation IDs
        DatabaseManager.shared.fetchNewConversations(with: conversationIds) { newConversations in
            
            // Fetch messages for each new conversation
            DatabaseManager.shared.fetchMessages(for: newConversations) { [weak self] done in
                guard let strongSelf = self else { return }
                
                // If fetching is done, update conversations, reload collection view, toggle sync for new conversations and observe new messages
                if done {
                    strongSelf.conversations = DataService.shared.getConversations()
                    strongSelf.collectionView.reloadData()
                    DatabaseManager.shared.toggleSync(for: newConversations)
                    strongSelf.observeNewConversations(conversations: newConversations)
                    NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
                }
            }
        }
    }
    
    public func fetchNewMewMessages(withIds conversationIds: [String]) {
        // Filter conversations based on the provided conversation IDs
        let conversations = conversations.filter { conversationIds.contains($0.id!) }
        
        // Fetch new messages for the filtered conversations
        DatabaseManager.shared.fetchNewMessages(for: conversations) { [weak self] fetched in
            guard let strongSelf = self else { return }
            
            // If messages are fetched, update conversations, reload collection view, and toggle sync for conversations
            if fetched {
                strongSelf.conversations = DataService.shared.getConversations()
                strongSelf.collectionView.reloadData()
                DatabaseManager.shared.toggleSync(for: conversations)
                
            }
        }
    }
    
    private func observeConversations() {
        // Observe current conversations
        DatabaseManager.shared.observeConversations { conversationId in
            self.conversations = DataService.shared.getConversations()
            NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
            self.collectionView.reloadData()
        }
        
        /*
        DatabaseManager.shared.observeNewMessages(on: conversations) { [weak self] conversationId in
            guard let strongSelf = self else { return }
            let newConversation = DataService.shared.getConversation(with: conversationId)
            if var newConversation = newConversation, let index = strongSelf.conversations.firstIndex(where: { $0.id == conversationId }) {
                if strongSelf.pendingConversations.contains(newConversation) {
                    newConversation.markMessagesAsRead()
                    DataService.shared.readMessages(conversation: newConversation)
                    strongSelf.pendingConversations.removeAll(where: { $0.id == newConversation.id })
                }
                
                DispatchQueue.main.async {
                    strongSelf.collectionView.performBatchUpdates {
                        strongSelf.conversations[index] = newConversation
                        strongSelf.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
                DatabaseManager.shared.toggleSync(for: [newConversation])
                #warning("Faltarà mostrar popup")
            }
        }
         */
    }
    
    private func observeNewConversations(conversations: [Conversation]) {
        // Observe new conversations
        DatabaseManager.shared.observeNewMessages(on: conversations) { [weak self] conversationId in
            guard let strongSelf = self else { return }
            print("current convo observer")
            let newConversation = DataService.shared.getConversation(with: conversationId)
            if let newConversation = newConversation, let index = strongSelf.conversations.firstIndex(where: { $0.id == conversationId }) {
                
                if strongSelf.pendingConversations.contains(newConversation) {
                    DataService.shared.readMessages(conversation: newConversation)
                    strongSelf.pendingConversations.removeAll(where: { $0.id == newConversation.id })
                }
                
                DispatchQueue.main.async {
                    strongSelf.collectionView.performBatchUpdates {
                        strongSelf.conversations[index] = newConversation
                        strongSelf.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
                DatabaseManager.shared.toggleSync(for: [newConversation])
                #warning("Faltarà mostrar popup")
            }
        }
    }
    
    private func observeConversationRoot() {
        DatabaseManager.shared.observeNewConversations { newConversation in
            print("new root convo")
            print(newConversation)
            DatabaseManager.shared.fetchMessages(for: [newConversation]) { [weak self] done in
                print("we fetched root messages")
                guard let strongSelf = self else { return }

                // If fetching is done, update conversations, reload collection view, toggle sync for new conversations and observe new messages
                if done {
                    strongSelf.conversations = DataService.shared.getConversations()
                    strongSelf.collectionView.reloadData()
                    DatabaseManager.shared.toggleSync(for: [newConversation])
                    strongSelf.observeNewConversations(conversations: [newConversation])
                    NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
                }
            }
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
                    strongSelf.collectionView.deleteItems(at: [indexPath])
                }
            case .failure(let error):
                // Handle the failure case and print the error message
                print(error.localizedDescription)
            }
        }
    }
    
    private func sortConversations() {
        // Sort the conversations based on the defined sorting criteria
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
            cell.set(withImage: UIImage(named: AppStrings.Assets.emptyMessage)!, withTitle: "Welcome to your inbox.", withDescription: "Drop a line, share posts, cases and more with private conversations between you and others", withButtonText: "   Write a message   ")
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
            guard let strongSelf = self else { return nil }
            let deleteAction = UIAction(title: AppStrings.Alerts.Title.deleteConversation, image: UIImage(systemName: AppStrings.Icons.trash), attributes: .destructive) { action in
                strongSelf.deleteConversationAlert { deleted in
                    if deleted {
                        strongSelf.deleteConversation(at: indexPaths[0])
                    }
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

extension ConversationViewController: EmptyGroupCellDelegate {
    func didTapDiscoverGroup() {
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
            // Remove the conversation from the conversations array
            conversations.remove(at: conversationIndex)
            
            // Perform batch updates on the collection view to delete the corresponding item
            collectionView.performBatchUpdates {
                collectionView.deleteItems(at: [IndexPath(item: conversationIndex, section: 0)])
            }
        }
    }
    
    func didCreateNewConversation(_ conversation: Conversation) {
        // Insert the new conversation at the beginning of the conversations array
        conversations.insert(conversation, at: 0)
        
        // Sort the conversations based on the sorting logic
        sortConversations()
        
        // Find the index of the new conversation in the conversations array
        if let conversationIndex = conversations.firstIndex(of: conversation) {
            
            // Asynchronously perform batch updates on the collection view to insert the new item
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.collectionView.performBatchUpdates {
                    strongSelf.collectionView.insertItems(at: [IndexPath(item: conversationIndex, section: 0)])
                }
            }
        }
    }
}

/*
/// Controller that shows list of conversations
class ConversationViewController: UIViewController {
    
    //MARK: - Properties
    var user: User? {
        didSet {
            guard let _ = user else { return }
            configureNavigationBar()
        }
    }
    
    private var conversations = [Conversation]()
    private var users = [User]()
    private var searchController: UISearchController!
    private lazy var lockView = MEPrimaryBlurLockView(frame: view.bounds)
    
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

        guard let user = user else { return }
        
        if user.phase == .verified {
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
            
            navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), style: .done, target: self, action: #selector(didTapComposeButton))
        } else {
            view.addSubview(lockView)
        }
  
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
        guard let user = user else { return }
        
        if user.phase != .verified {
            let reportPopup = METopPopupView(title: "Only verified users can post content. Check back later to verify your status.", image: "xmark.circle.fill", popUpType: .regular)
            reportPopup.showTopPopup(inView: self.view)
        } else {
            let controller = NewMessageViewController(conversations: conversations)
            
            let backItem = UIBarButtonItem()
            backItem.tintColor = .label
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        }
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
        return conversationsLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 72)
    }
            
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if conversations.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
            cell.set(withImage: UIImage(named: "message.empty")!, withTitle: "Welcome to your inbox.", withDescription: "Drop a line, share posts, cases and more with private conversations between you and others", withButtonText: "   Write a message   ")
            cell.delegate = self
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
        return conversations.isEmpty ? CGSize(width: view.frame.width, height: UIScreen.main.bounds.height * 0.6) : CGSize(width: view.frame.width, height: 71)
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

extension ConversationViewController: EmptyGroupCellDelegate {
    func didTapDiscoverGroup() {
        let controller = NewMessageViewController(conversations: conversations)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}
*/
