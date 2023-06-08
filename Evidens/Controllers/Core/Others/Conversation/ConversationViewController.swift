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
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(strongSelf.view.frame.width * 0.6)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(strongSelf.view.frame.width * 0.6)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                return section
            } else {
                let section = NSCollectionLayoutSection.list(using: strongSelf.createListConfiguration(), layoutEnvironment: env)
                return section
            }
        }
        return layout
    }
    
    private func createListConfiguration() -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
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
            strongSelf.deleteConversationAlert { delete in
                completion(true)
                if delete {
                    strongSelf.deleteConversation(at: indexPath)
                }
            }
        }
        
        let pinAction = UIContextualAction(style: .normal, title: nil) { [weak self] action, view, completion in
            guard let strongSelf = self else { return }
            completion(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                strongSelf.togglePinConversation(at: indexPath)
            }
        }
        
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
  
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"/*AppStrings.Icons.leftChevron*/, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), style: .done, target: self, action: #selector(didTapHideConversations))
        
        backButton.title = ""
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func loadConversations() {
        DataService.shared.editPhase()
        conversations = DataService.shared.getConversations()
        #warning("Mirar si hi ha missatges no llegits per mostrar una boleta")
        conversationsLoaded = true
        
        DatabaseManager.shared.checkForNewConversations(with: conversations.map { $0.id! }) { [weak self] unsyncedIds in
            guard let strongSelf = self else {
                return
            }
            guard !unsyncedIds.isEmpty else {
                return
            }
            // For every unsynced Id, send a query to get messages from last received date stored in core data
            // if conversation doesnt exist in core data, is either new or new but previously deleted
            // in both cases, this for each of this conversations get the date field, which is the creation date of the conversation, and get messages from the creation date and up
            let currentConversationIds = strongSelf.conversations.map { $0.id! }
            let newConversationIds = unsyncedIds.filter { !currentConversationIds.contains($0) }
            let conversationsWithNewMessages = unsyncedIds.filter { currentConversationIds.contains($0) }
            strongSelf.fetchNewConversations(withIds: newConversationIds)
            strongSelf.fetchNewMewMessages(withIds: conversationsWithNewMessages)
        }
        // Check for pending to send messages, and check if they exist in rtd, if they don't, switch state to failed.
    }
    
    private func fetchNewConversations(withIds conversationIds: [String]) {
        DatabaseManager.shared.fetchNewConversations(with: conversationIds) { newConversations in
            // continue with for each conversation, fetch user and fetch messages to create everything.
            DatabaseManager.shared.fetchMessages(for: newConversations) { [weak self] done in
                guard let strongSelf = self else { return }
                if done {
                    strongSelf.conversations = DataService.shared.getConversations()
                    strongSelf.collectionView.reloadData()
                    DatabaseManager.shared.toggleSync(for: newConversations)
                }
            }
        }
    }
    
    public func fetchNewMewMessages(withIds conversationIds: [String]) {
        let conversations = conversations.filter { conversationIds.contains($0.id!) }
        DatabaseManager.shared.fetchNewMessages(for: conversations) { [weak self] fetched in
            guard let strongSelf = self else { return }
            if fetched {
                strongSelf.conversations = DataService.shared.getConversations()
                strongSelf.collectionView.reloadData()
                DatabaseManager.shared.toggleSync(for: conversations)
            }
        }
    }
    
    private func togglePinConversation(at indexPath: IndexPath) {
        self.conversations[indexPath.row].togglePin()
        let conversationToUpdate = self.conversations[indexPath.row]
        DataService.shared.edit(conversation: conversationToUpdate, set: conversationToUpdate.isPinned, forKey: "isPinned")
        
        let unorderedConversations = self.conversations
        self.sortConversations()
        let sortMap = unorderedConversations.map { conversations.firstIndex(of: $0)!}
        
        collectionView.performBatchUpdates {
            for index in 0 ..< sortMap.count {
                if index != sortMap[index] {
                    self.collectionView.moveItem(at: IndexPath(item: index, section: 0), to: IndexPath(item: sortMap[index], section: 0))
                }
            }
        } completion: { _ in
            self.collectionView.reloadData()
        }
    }
    
    private func deleteConversation(at indexPath: IndexPath) {
        let conversation = conversations[indexPath.row]
        DatabaseManager.shared.deleteConversation(conversation) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(_):
                DataService.shared.delete(conversation: conversation)
                strongSelf.collectionView.performBatchUpdates { [weak self] in
                    guard let strongSelf = self else { return}
                    strongSelf.conversations.remove(at: indexPath.row)
                    strongSelf.collectionView.deleteItems(at: [indexPath])
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func sortConversations() {
        conversations.sort { (conversation1, conversation2) -> Bool in
            if conversation1.isPinned && !conversation2.isPinned {
                return true
            }
            
            if !conversation1.isPinned && conversation2.isPinned {
                return false
            }
            
            return conversation1.latestMessage?.sentDate ?? Date() > conversation2.latestMessage?.sentDate ?? Date()
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
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
        updatePan()
        didLeaveScreen = true
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard !indexPaths.isEmpty, !conversations.isEmpty else { return nil }
        let previewViewController = UINavigationController(rootViewController: MessageViewController(conversation: conversations[indexPaths[0].item], preview: true))
        let previewProvider: () -> UINavigationController? = { previewViewController }
       
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
        didReadAllMessages(for: conversation)
    }
    
    func sendMessage(_ message: Message, to conversation: Conversation) {
        didSendMessage(message, for: conversation)
    }
    
    func didTapConversation(_ conversation: Conversation) {
        didReadAllMessages(for: conversation)
    }
    
    func didTapRecents(_ text: String) {
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
        delegate?.handleTooglePan()
    }
    
    func didTapTextToSearch(text: String) {
        searchController.searchBar.text = text
    }
}

extension ConversationViewController: NewMessageViewControllerDelegate {
    func didOpenConversation(for user: User) {
        DataService.shared.conversationExists(for: user.uid!) { [weak self] exists in
            guard let strongSelf = self else { return }
            if exists {
                if let conversationIndex = strongSelf.conversations.firstIndex(where: { $0.userId == user.uid! }) {
                    let controller = MessageViewController(conversation: strongSelf.conversations[conversationIndex], user: user)
                    controller.delegate = self
                    let backItem = UIBarButtonItem()
                    backItem.title = ""
                    backItem.tintColor = .label
                    
                    strongSelf.navigationItem.backBarButtonItem = backItem
                    
                    strongSelf.navigationController?.pushViewController(controller, animated: true)
                    strongSelf.updatePan()
                    strongSelf.didLeaveScreen = true
                }
            } else {
                guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
                let name = user.firstName! + " " + user.lastName!
                let newConversation = Conversation(name: name, userId: user.uid!, ownerId: uid)
                let controller = MessageViewController(conversation: newConversation, user: user)
                controller.delegate = self
                let backItem = UIBarButtonItem()
                backItem.title = ""
                backItem.tintColor = .label
                
                strongSelf.navigationItem.backBarButtonItem = backItem
                strongSelf.navigationController?.pushViewController(controller, animated: true)
                strongSelf.updatePan()
                strongSelf.didLeaveScreen = true
            }
        }
    }
}

extension ConversationViewController: EmptyGroupCellDelegate {
    func didTapDiscoverGroup() {
        let controller = NewMessageViewController()
        controller.delegate = self
        let navVC = UINavigationController(rootViewController: controller)
        
        navVC.modalPresentationStyle = .automatic
        
        present(navVC, animated: true)
    }
}

extension ConversationViewController: MessageViewControllerDelegate {
    func didSendMessage(_ message: Message, for conversation: Conversation) {
        if let conversationIndex = conversations.firstIndex(where: { $0.userId == conversation.userId }) {
            conversations[conversationIndex].changeLatestMessage(to: message)
            collectionView.reloadItems(at: [IndexPath(item: conversationIndex, section: 0)])
        }
    }
    
    func didReadAllMessages(for conversation: Conversation) {
        if let conversationIndex = conversations.firstIndex(where: { $0.userId == conversation.userId }) {
            conversations[conversationIndex].markMessagesAsRead()
            collectionView.reloadItems(at: [IndexPath(item: conversationIndex, section: 0)])
        }
    }
    
    func deleteConversation(_ conversation: Conversation) {
        DataService.shared.delete(conversation: conversation)
        if let conversationIndex = conversations.firstIndex(of: conversation) {
            conversations.remove(at: conversationIndex)
            collectionView.performBatchUpdates {
                collectionView.deleteItems(at: [IndexPath(item: conversationIndex, section: 0)])
            }
        }
    }
    
    func didCreateNewConversation(_ conversation: Conversation) {
        conversations.insert(conversation, at: 0)
        sortConversations()
        
        if let conversationIndex = conversations.firstIndex(of: conversation) {
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
