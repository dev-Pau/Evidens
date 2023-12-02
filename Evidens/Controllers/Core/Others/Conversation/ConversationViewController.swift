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
    func hideConversations()
    func toggleScroll(_ toggle: Bool)
}

class ConversationViewController: UIViewController {

    // MARK: - Properties
    
    var user: User? {
        didSet {
            guard let _ = user else { return }
            configureNavigationBar()
        }
    }

    private var viewModel = ConversationsViewModel()
    
    private var collectionView: UICollectionView!
    private var searchController: UISearchController!

    weak var delegate: ConversationViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if viewModel.didLeaveScreen {
            delegate?.toggleScroll(true)
            viewModel.didLeaveScreen = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.searchController.searchBar.searchTextField.layer.cornerRadius = strongSelf.searchController.searchBar.searchTextField.frame.height / 2
            strongSelf.searchController.searchBar.searchTextField.clipsToBounds = true
        }
    }

    // MARK: - Helpers
    
    private func conversationLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else {
                return nil
            }
            
            if strongSelf.viewModel.conversations.isEmpty {
                // Create layout for empty conversations
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(600)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(600)), subitems: [item])
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
            print(action)
            // Handle pin action
            guard let _ = self else { return }
            completion(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.togglePinConversation(at: indexPath)
            }
        }
        
        // Configure delete and pin actions
        deleteAction.image = UIImage().swipeLayout(icon: AppStrings.Icons.trash, text: AppStrings.Global.delete, size: 16)
        pinAction.image = UIImage().swipeLayout(icon: AppStrings.Icons.fillPin, text: viewModel.conversations[indexPath.item].isPinned ? AppStrings.Actions.unpin : AppStrings.Actions.pin, size: 16)
        
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction, pinAction])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
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
        searchController.delegate = self
        searchController.searchBar.placeholder = AppStrings.Search.Bar.message
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = primaryColor
        searchController.showsSearchResultsController = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
        navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), style: .done, target: self, action: #selector(didTapComposeButton))
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), style: .done, target: self, action: #selector(didTapHideConversations))
        
        backButton.title = ""
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton
    }
    
    func loadConversations() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshConversations), name: NSNotification.Name(AppPublishers.Names.loadConversations), object: nil)
        viewModel.loadConversations()
        collectionView.reloadData()
        observeConversations()
    }

    private func observeConversations() {
        viewModel.observeConversations { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
        }
    }
    
    private func togglePinConversation(at indexPath: IndexPath) {
        // Toggle the pin status of the conversation at the specified index path
        viewModel.conversations[indexPath.row].togglePin()
        
        // Get the conversation to update and save the pin status changes
        let conversationToUpdate = viewModel.conversations[indexPath.row]
        
        viewModel.edit(conversation: conversationToUpdate, set: conversationToUpdate.isPinned, forKey: "isPinned")
       
        // Create a map to sort the conversations based on the updated pin status
        let unorderedConversations = viewModel.conversations
        viewModel.sortConversations()
        let sortMap = unorderedConversations.map { viewModel.conversations.firstIndex(of: $0)!}
        
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
        let conversation = viewModel.conversations[indexPath.row]
        
        // Delete the conversation
        viewModel.deleteConversation(conversation) { [weak self] error in
            guard let strongSelf = self else { return }
            
            if let _ = error {
                // Handle the failure case and print the error message
                return
            } else {
                //DataService.shared.delete(conversation: conversation)
                
                // Perform batch updates to remove the conversation from the collection view
                strongSelf.collectionView.performBatchUpdates { [weak self] in
                    guard let strongSelf = self else { return}
                    strongSelf.viewModel.conversations.remove(at: indexPath.row)
                    if !strongSelf.viewModel.conversations.isEmpty {
                        strongSelf.collectionView.deleteItems(at: [indexPath])
                    }
                } completion: { _ in
                    strongSelf.collectionView.reloadData()
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(AppPublishers.Names.refreshUnreadConversations), object: nil)
            }
        }
    }

    // MARK: - Actions
    
    @objc func didTapComposeButton() {
        let controller = NewMessageViewController()
        controller.delegate = self
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .automatic
        present(navVC, animated: true)
    }
    
    @objc func didTapHideConversations() {
        delegate?.hideConversations()
    }
    
    @objc func refreshConversations() {
        viewModel.loadConversations()
        collectionView.reloadData()
    }
}

extension ConversationViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.conversationsLoaded ? viewModel.conversations.isEmpty ? 1 : viewModel.conversations.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.conversations.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
            cell.set(withTitle: AppStrings.Conversation.Empty.title, withDescription: AppStrings.Conversation.Empty.content, withButtonText: AppStrings.Conversation.Empty.new)
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversationCellReuseIdentifier, for: indexPath) as! ConversationCell
            cell.viewModel = ConversationViewModel(conversation: viewModel.conversations[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !viewModel.conversations.isEmpty else { return }
        let conversation = viewModel.conversations[indexPath.row]
        
        let controller = MessageViewController(conversation: conversation)
        
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
        delegate?.toggleScroll(false)
        viewModel.didLeaveScreen = true
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
    
    func updateScreenToggle() {
        viewModel.didLeaveScreen = true
    }
    
    func didTapTextToSearch(text: String) {
        // Set the text in the search bar of the search controller
        searchController.searchBar.text = text
    }
}

extension ConversationViewController: NewMessageViewControllerDelegate {
    
    func didOpenConversation(for user: User) {
        // Check if a conversation already exists for the specified user
        viewModel.conversationExists(for: user.uid!) { [weak self] exists in
            guard let strongSelf = self else { return }
            if exists {
                // If a conversation exists, find its index in the conversations array
                if let conversationIndex = strongSelf.viewModel.conversations.firstIndex(where: { $0.userId == user.uid! }) {
                    // Create and configure the MessageViewController with the existing conversation
                    let controller = MessageViewController(conversation: strongSelf.viewModel.conversations[conversationIndex], user: user)
                    controller.delegate = self
                    
                    strongSelf.navigationController?.pushViewController(controller, animated: true)
                    strongSelf.delegate?.toggleScroll(false)
                    strongSelf.viewModel.didLeaveScreen = true
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
                strongSelf.delegate?.toggleScroll(false)
                strongSelf.viewModel.didLeaveScreen = true
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
        if let conversationIndex = viewModel.conversations.firstIndex(where: { $0.userId == conversation.userId }) {
            // Update the latest message of the conversation with the new message
            viewModel.conversations[conversationIndex].changeLatestMessage(to: message)
            
            // Reload the corresponding item in the collection view to reflect the changes
            collectionView.reloadItems(at: [IndexPath(item: conversationIndex, section: 0)])
        }
    }
    
    func didReadAllMessages(for conversation: Conversation) {
        // Find the index of the conversation in the conversations array
        if let conversationIndex = viewModel.conversations.firstIndex(where: { $0.userId == conversation.userId }) {
            // Mark all messages in the conversation as read
            viewModel.conversations[conversationIndex].markMessagesAsRead()
            
            // Reload the corresponding item in the collection view to reflect the changes
            collectionView.reloadItems(at: [IndexPath(item: conversationIndex, section: 0)])
        }
    }
    
    func didReadConversation(_ conversation: Conversation, message: Message) {
        //pendingConversations.append(conversation)
        if let conversationIndex = viewModel.conversations.firstIndex(where: { $0.userId == conversation.userId }) {
            viewModel.conversations[conversationIndex].changeLatestMessage(to: message)
            collectionView.reloadItems(at: [IndexPath(item: conversationIndex, section: 0)])
            viewModel.pendingConversations.append(conversation)
        }
    }

    func deleteConversation(_ conversation: Conversation) {
        // Delete the conversation from the local data store
        DataService.shared.delete(conversation: conversation)
        
        // Find the index of the conversation in the conversations array
        if let conversationIndex = viewModel.conversations.firstIndex(of: conversation) {
            
            collectionView.performBatchUpdates { [weak self] in
                guard let strongSelf = self else { return}
                strongSelf.viewModel.conversations.remove(at: conversationIndex)
                if strongSelf.viewModel.conversations.isEmpty {

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
        // Sort the conversations based on the sorting logic
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.performBatchUpdates {
                // Insert the new conversation at the beginning of the conversations array
                strongSelf.viewModel.conversations.append(conversation)

                if strongSelf.viewModel.conversations.count == 1 {
                    strongSelf.collectionView.reloadData()
                } else {
                    strongSelf.collectionView.insertItems(at: [IndexPath(item: strongSelf.viewModel.conversations.count - 1, section: 0)])
                }
            } completion: { _ in
                strongSelf.viewModel.sortConversations()
                strongSelf.collectionView.reloadData()
            }
        }
    }
}

extension ConversationViewController: UISearchControllerDelegate {
    func willDismissSearchController(_ searchController: UISearchController) {
        delegate?.toggleScroll(true)
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        delegate?.toggleScroll(false)
    }
}

