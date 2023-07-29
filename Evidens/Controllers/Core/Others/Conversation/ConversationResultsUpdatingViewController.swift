//
//  ConversationResultsUpdatingViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/5/23.
//

import UIKit

private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"
private let searchRecentsHeaderReuseIdentifier = "SearchRecentsHeaderReuseIdentifier"
private let recentContentSearchReuseIdentifier = "RecentContentSearchReuseIdentifier"
private let loadingSearchHeaderReuseIdentifier = "LoadingSearchHeaderReuseIdentifier"
private let conversationCellReuseIdentifier = "ConversationCellReuseIdentifier"
private let messageCellReuseIdentifier = "MessageUserCellReuseIdentifier"
private let mainSearchHeader = "MainSearchHeader"
private let emptyCellReuseIdentifier = "EmptyCellReuseIdentifier"

protocol ConversationResultsUpdatingViewControllerDelegate: AnyObject {
    func didTapRecents(_ text: String)
    func didTapConversation(_ conversation: Conversation)
    func sendMessage(_ message: Message, to conversation: Conversation)
    func readMessages(for conversation: Conversation)
}

class ConversationResultsUpdatingViewController: UIViewController, UINavigationControllerDelegate {
    
    weak var delegate: ConversationResultsUpdatingViewControllerDelegate?
    private var mainConversations = [Conversation]()
    private var mainMessages = [Message]()
    private var mainMessageConversations = [Conversation]()
    
    private var conversations = [Conversation]()
    
    private var messages = [Message]()
    private var messageConversations = [Conversation]()
    
    private var recentSearches = [String]()
    private var dataLoaded: Bool = false
    private var isInSearchMode: Bool = false {
        didSet {
            scrollView.isScrollEnabled = isInSearchMode
        }
    }
    private var messageToolbar = MessageToolbar()
    private var toolbarHeightAnchor: NSLayoutConstraint!
    private var searchedText = ""
    private var isScrollingHorizontally = false
    
    private var didFetchMainContent = false
    private var didFetchConversations = false
    private var didFetchMessages = false
    private var scrollIndex: Int = 0
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private lazy var mainCollectionView: UICollectionView = {
        let layout = createMainLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private lazy var conversationCollectionView: UICollectionView = {
        let layout = createSecondaryLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private lazy var messagesCollectionView: UICollectionView = {
        let layout = createTertiaryLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        configureCollectionView()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !dataLoaded { fetchRecentSearches() }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainCollectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scrollView.frame.height)
        conversationCollectionView.frame = CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: scrollView.frame.height)
        messagesCollectionView.frame = CGRect(x: view.frame.width * 2, y: 0, width: view.frame.width, height: scrollView.frame.height)
    }
    
    private func configureCollectionView() {
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        conversationCollectionView.delegate = self
        conversationCollectionView.dataSource = self
        messagesCollectionView.delegate = self
        messagesCollectionView.dataSource = self
        mainCollectionView.backgroundColor = .systemBackground
        conversationCollectionView.backgroundColor = .systemBackground
        messagesCollectionView.backgroundColor = .systemBackground
        mainCollectionView.keyboardDismissMode = .onDrag
        messagesCollectionView.keyboardDismissMode = .onDrag
        conversationCollectionView.keyboardDismissMode = .onDrag
        
        mainCollectionView.register(EmptyRecentsSearchCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        mainCollectionView.register(SearchRecentsHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: searchRecentsHeaderReuseIdentifier)
        mainCollectionView.register(RecentSearchCell.self, forCellWithReuseIdentifier: recentContentSearchReuseIdentifier)
        mainCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingSearchHeaderReuseIdentifier)
        mainCollectionView.register(ConversationCell.self, forCellWithReuseIdentifier: conversationCellReuseIdentifier)
        mainCollectionView.register(PrimarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: mainSearchHeader)
        mainCollectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        mainCollectionView.register(SearchMessageCell.self, forCellWithReuseIdentifier: messageCellReuseIdentifier)
        
        conversationCollectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        conversationCollectionView.register(ConversationCell.self, forCellWithReuseIdentifier: conversationCellReuseIdentifier)
        conversationCollectionView.register(PrimarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: mainSearchHeader)
        
        messagesCollectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        messagesCollectionView.register(SearchMessageCell.self, forCellWithReuseIdentifier: messageCellReuseIdentifier)
        messagesCollectionView.register(PrimarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: mainSearchHeader)
    }
    
    private func configure() {
        view.addSubviews(messageToolbar, scrollView)
        
        toolbarHeightAnchor = messageToolbar.heightAnchor.constraint(equalToConstant: 0)
        toolbarHeightAnchor.isActive = true
        
        NSLayoutConstraint.activate([
            messageToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            messageToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: messageToolbar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        messageToolbar.toolbarDelegate = self
        scrollView.delegate = self
        scrollView.addSubview(mainCollectionView)
        scrollView.addSubview(conversationCollectionView)
        scrollView.addSubview(messagesCollectionView)
        scrollView.contentSize.width = view.frame.width * 3
        scrollView.isScrollEnabled = false
    }
    
    private func createMainLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else {
                return nil
            }
            
            if strongSelf.isInSearchMode {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                let section = NSCollectionLayoutSection.list(using: strongSelf.createListConfiguration(), layoutEnvironment: env)
                
                if sectionNumber == 0 && !strongSelf.mainConversations.isEmpty || sectionNumber == 1 && !strongSelf.mainMessages.isEmpty {
                    section.boundarySupplementaryItems = [header]
                }
                return section
                
            } else {
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)), subitems: [item])
               
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)

                let section = NSCollectionLayoutSection(group: group)
                
                
                if !strongSelf.recentSearches.isEmpty {
                    section.boundarySupplementaryItems = [header]
                }
                return section
            }
        }
        return layout
    }
    
    private func createSecondaryLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else {
                return nil
            }
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let section = NSCollectionLayoutSection.list(using: strongSelf.createListConfiguration(), layoutEnvironment: env)
            
            if !strongSelf.conversations.isEmpty {
                section.boundarySupplementaryItems = [header]

            }
            return section
        }
        return layout
    }
    
    private func createTertiaryLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else {
                return nil
            }
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let section = NSCollectionLayoutSection.list(using: strongSelf.createListConfiguration(), layoutEnvironment: env)
            
            if !strongSelf.messages.isEmpty {
                section.boundarySupplementaryItems = [header]
            }
            return section
        }
        return layout
    }
                
    private func createListConfiguration() -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.showsSeparators = false
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let strongSelf = self else { return nil }
            guard !strongSelf.mainMessages.isEmpty, !strongSelf.mainConversations.isEmpty else { return nil }
            return strongSelf.createTrailingSwipeActions(for: indexPath)
        }
        return configuration
    }
    
    private func createTrailingSwipeActions(for indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] action, view, completion in
            guard let strongSelf = self else { return }
            
            strongSelf.displayAlert(withTitle: AppStrings.Alerts.Title.deleteConversation, withMessage: AppStrings.Alerts.Subtitle.deleteConversation, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
                guard let strongSelf = self else { return }
                #warning("to this need to be unchecked?")
                //strongSelf.deleteConversation(at: indexPath)
            }
        }
        
        let pinAction = UIContextualAction(style: .normal, title: nil) { [weak self] action, view, completion in
            guard self != nil else { return }
            completion(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            #warning("to this need to be unchecked?")
                //strongSelf.togglePinConversation(at: indexPath)
            }
        }
        
        deleteAction.image = UIImage().swipeLayout(icon: AppStrings.Icons.trash, text: AppStrings.Global.delete, size: 16)
        pinAction.image = UIImage().swipeLayout(icon: AppStrings.Icons.fillPin, text: mainConversations[indexPath.item].isPinned ? AppStrings.Actions.unpin : AppStrings.Actions.pin, size: 16)
        return UISwipeActionsConfiguration(actions: [deleteAction, pinAction])
    }
    
    
    private func fetchRecentSearches() {
        // Fetch recent message searches from the database
        DatabaseManager.shared.fetchRecentMessageSearches { result in
            switch result {
            case .success(let searches):
                // Check if the fetched searches array is empty
                guard !searches.isEmpty else {
                    self.dataLoaded = true
                    self.mainCollectionView.reloadData()
                    return
                }
                
                // Set the fetched searches to the recentSearches array
                self.recentSearches = searches
                // Mark data as loaded and reload the main collection view
                self.dataLoaded = true
                self.mainCollectionView.reloadData()
                
            case .failure(let error):
                // Print the error message if the fetch operation fails
                print(error.localizedDescription)
            }
        }
    }
    
    private func fetchMainContent() {
        // Fetch main conversations based on the searched text with a limit of 3
        mainConversations = DataService.shared.getConversations(for: searchedText, withLimit: 3, from: Date())
        // Fetch main messages based on the searched text with a limit of 3
        mainMessages = DataService.shared.getMessages(for: searchedText, withLimit: 3, from: Date())
        
        // Extract unique conversation IDs from the main messages
        let uniqueConversationIds = Array(Set(mainMessages.map { $0.conversationId! }))
        // Fetch main message conversations based on the unique conversation IDs
        mainMessageConversations = DataService.shared.getConversations(for: uniqueConversationIds)

        // Reload the main collection view on the main queue
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.mainCollectionView.reloadData()
        }
        
        // Mark that the main content has been fetched
        didFetchMainContent = true
    }
    
    private func fetchConversations() {
        // Fetch conversations based on the searched text with a limit of 15
        conversations = DataService.shared.getConversations(for: searchedText, withLimit: 15, from: Date())

        // Reload the conversation collection view on the main queue
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.conversationCollectionView.reloadData()
        }
        
        didFetchConversations = true
    }
    
    private func fetchMessages() {
        // Fetch messages based on the searched text with a limit of 30
        messages = DataService.shared.getMessages(for: searchedText, withLimit: 30, from: Date())
        
        // Retrieve unique conversation IDs from the fetched messages
        let uniqueConversationIds = Array(Set(messages.map { $0.conversationId! }))
        
        // Fetch conversations for the unique conversation IDs
        messageConversations = DataService.shared.getConversations(for: uniqueConversationIds)
        
        // Reload the messages collection view on the main queue
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.messagesCollectionView.reloadData()
        }
        
        // Mark that the messages have been fetched
        didFetchMessages = true
    }
    
    private func fetchMoreConversations() {
        // Fetch conversations based on the searched text with a limit of 15 and starting from last conversation date recorded
        guard let latestConversation = conversations.last, let creationDate = latestConversation.date else { return }
        conversations.append(contentsOf: DataService.shared.getConversations(for: searchedText, withLimit: 15, from: creationDate))

        // Reload the conversation collection view on the main queue
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.conversationCollectionView.reloadData()
        }
    }
    
    private func fetchMoreMessages() {
        guard let latestMessage = messages.last else { return }
        
        // Fetch messages based on the searched text with a limit of 30 and starting from last sent date recorded
        let newMessages = DataService.shared.getMessages(for: searchedText, withLimit: 30, from: latestMessage.sentDate)
        messages.append(contentsOf: newMessages)
        
        // Retrieve unique conversation IDs from the fetched messages
        let uniqueConversationIds = Array(Set(newMessages.map { $0.conversationId! }))
        
        // Fetch conversations for the unique conversation IDs
        messageConversations.append(contentsOf: DataService.shared.getConversations(for: uniqueConversationIds))
        
        // Reload the messages collection view on the main queue
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.messagesCollectionView.reloadData()
        }
    }
    
    private func show(conversation: Conversation, for indexPath: IndexPath, in collectionView: UICollectionView) {
        // Create an instance of MessageViewController for the selected conversation
        let controller = MessageViewController(conversation: conversation)
        controller.delegate = self
       
        // Check if the presenting view controller is ConversationViewController and retrieve its navigation controller
        if let conversationViewController = presentingViewController as? ConversationViewController, let navVC = conversationViewController.navigationController {
            conversationViewController.updatePan()
            conversationViewController.updateScreenToggle()
            navVC.pushViewController(controller, animated: true)
            delegate?.didTapConversation(conversation)

            // Mark the messages of the selected conversation as read
            if collectionView == mainCollectionView {
                mainConversations[indexPath.row].markMessagesAsRead()
            } else {
                conversations[indexPath.row].markMessagesAsRead()
            }

            // Reload the item at the selected index path to update its appearance
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    private func show(conversation: Conversation, for message: Message, in collectionView: UICollectionView) {
        // Create an instance of MessageViewController for the selected conversation and message
        let controller = MessageViewController(conversation: conversation, message: message)
        
        // Check if the presenting view controller is ConversationViewController and retrieve its navigation controller
        if let conversationViewController = presentingViewController as? ConversationViewController, let navVC = conversationViewController.navigationController {
            conversationViewController.updatePan()
            conversationViewController.updateScreenToggle()
            navVC.pushViewController(controller, animated: true)
        }
    }
}

extension ConversationResultsUpdatingViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == mainCollectionView {
            return isInSearchMode ? mainConversations.isEmpty && mainMessages.isEmpty ? 1 : 2 : 1
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == mainCollectionView {
            if isInSearchMode {
                if mainConversations.isEmpty && mainMessages.isEmpty {
                    return 1
                } else {
                    if section == 0 {
                        return mainConversations.count
                    } else {
                        return mainMessages.count
                    }
                }
            } else {
                return dataLoaded ? recentSearches.isEmpty ? 1 : recentSearches.count : 0
            }

        } else if collectionView == conversationCollectionView {
            return conversations.isEmpty ? 1 : conversations.count
        } else {
            return messages.isEmpty ? 1 : messages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == mainCollectionView {
            if !isInSearchMode {
                if !dataLoaded {
                    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingSearchHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                    return header
                } else {
                    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchRecentsHeaderReuseIdentifier, for: indexPath) as! SearchRecentsHeader
                    header.delegate = self
                    return header
                }
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: mainSearchHeader, for: indexPath) as! PrimarySearchHeader
                header.tag = indexPath.section
                header.delegate = self
                if indexPath.section == 0 {
                    header.configureWith(title: "Conversations", linkText: "See All")
                } else {
                    header.configureWith(title: "Messages", linkText: "See All")
                }
                return header
            }
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: mainSearchHeader, for: indexPath) as! PrimarySearchHeader
            if collectionView == conversationCollectionView {
                header.configureWith(title: "Conversations", linkText: nil)
            } else {
                header.configureWith(title: "Messages", linkText: nil)
            }
            
            return header
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == mainCollectionView {
            if !isInSearchMode {
                if recentSearches.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! EmptyRecentsSearchCell
                    cell.set(title: "Try searching for people or messages")
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentContentSearchReuseIdentifier, for: indexPath) as! RecentSearchCell
                    cell.viewModel = RecentTextViewModel(recentText: recentSearches[indexPath.row])
                    return cell
                }
            } else {
                if mainConversations.isEmpty && mainMessages.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                    cell.set(withTitle: "No results for \"\(searchedText)\"", withDescription: "The term you entered did not bring up any results. You may want to try using different search terms.", withButtonText: "Start a New Conversation")
                    cell.delegate = self
                    return cell
                } else {
                    if indexPath.section == 0 {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversationCellReuseIdentifier, for: indexPath) as! ConversationCell
                        cell.viewModel = ConversationViewModel(conversation: mainConversations[indexPath.row])
                        return cell
                    } else {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageCellReuseIdentifier, for: indexPath) as! SearchMessageCell
                        cell.searchedText = searchedText
                        cell.viewModel = MessageViewModel(message: mainMessages[indexPath.row])
                        cell.set(conversation: mainMessageConversations.first(where: { $0.id == mainMessages[indexPath.row].conversationId }))
                        return cell
                    }
                }
            }
        } else if collectionView == conversationCollectionView {
            if conversations.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                cell.set(withTitle: "No results for \"\(searchedText)\"", withDescription: "The term you entered did not bring up any results. You may want to try using different search terms.", withButtonText: "Start a New Conversation")
                cell.delegate = self
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversationCellReuseIdentifier, for: indexPath) as! ConversationCell
                cell.viewModel = ConversationViewModel(conversation: conversations[indexPath.row])
                return cell
            }
        } else {
            if messages.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                cell.set(withTitle: "No results for \"\(searchedText)\"", withDescription: "The term you entered did not bring up any results. You may want to try using different search terms.", withButtonText: "Start a New Conversation")
                cell.delegate = self
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageCellReuseIdentifier, for: indexPath) as! SearchMessageCell
                cell.searchedText = searchedText
                cell.viewModel = MessageViewModel(message: messages[indexPath.row])
                cell.set(conversation: messageConversations.first(where: { $0.id == messages[indexPath.row].conversationId }))
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == mainCollectionView {
            if !isInSearchMode {
                guard !recentSearches.isEmpty else { return }
                let text = recentSearches[indexPath.row]
                searchedText = text
                delegate?.didTapRecents(text)
                isInSearchMode = true
                toolbarHeightAnchor.constant = 50
                fetchMainContent()
                fetchConversations()
            } else {
                if indexPath.section == 0 {
                    guard !mainConversations.isEmpty else { return }
                    let conversation = mainConversations[indexPath.row]
                    show(conversation: conversation, for: indexPath, in: collectionView)
                } else {
                    guard !mainMessages.isEmpty else { return }
                    let message = mainMessages[indexPath.row]
                    if let conversation = mainMessageConversations.first(where: { $0.id == message.conversationId }) {
                        show(conversation: conversation, for: message, in: collectionView)
                    }
                }
            }
            
        } else if collectionView == conversationCollectionView {
            guard !conversations.isEmpty else { return }
            let conversation = conversations[indexPath.row]
            show(conversation: conversation, for: indexPath, in: collectionView)
            
        } else if collectionView == messagesCollectionView {
            guard !messages.isEmpty else { return }
            let message = messages[indexPath.row]
            if let conversation = messageConversations.first(where: { $0.id == message.conversationId }) {
                show(conversation: conversation, for: message, in: collectionView)
            }
        }
    }
}

extension ConversationResultsUpdatingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Check if the scrollView is scrolling vertically
        if scrollView.contentOffset.y != 0 {
            isScrollingHorizontally = false
        }
        
        // Check if the scrollView is scrolling horizontally and at the top
        if scrollView.contentOffset.y == 0 && isScrollingHorizontally {
            // Notify the messageToolbar that the collectionView did scroll horizontally
            messageToolbar.collectionViewDidScroll(for: scrollView.contentOffset.x)
        }
        
        // Check if the scrollView is scrolling horizontally and not at the top
        if scrollView.contentOffset.y == 0 && !isScrollingHorizontally {
            isScrollingHorizontally = true
            return
        }
        
        // Determine the current horizontal scrolling position
        switch scrollView.contentOffset.x {
        case 0 ..< view.frame.width:
            // Fetch conversations if not already fetched
            if !didFetchConversations { fetchConversations() }
            if isScrollingHorizontally { scrollIndex = 0 }
        case view.frame.width ..< 2 * view.frame.width:
            // Fetch messages if not already fetched
            if !didFetchMessages { fetchMessages() }
            if isScrollingHorizontally { scrollIndex = 1 }
        case 2 * view.frame.width ... 3 * view.frame.width:
            // Perform necessary actions for the specific horizontal scrolling position
            if !didFetchMessages { /* Perform additional actions if needed */ }
            if isScrollingHorizontally { scrollIndex = 2 }
        default:
            break
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        if offsetY > contentHeight - height {
            switch scrollIndex {
            case 0:
                break
            case 1:
                fetchMoreConversations()
            case 2:
                fetchMoreMessages()
            default:
                break
            }
        }
    }
}

extension ConversationResultsUpdatingViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) { /* Perform additional actions if needed */ }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Check if the search text is not empty
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        
        // Upload recent message searches to the database
        DatabaseManager.shared.uploadRecentMessageSearches(with: text) { _ in }
        
        // Insert the search text at the beginning of the recentSearches array
        recentSearches.insert(text, at: 0)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Resign first responder to dismiss the keyboard
        searchBar.searchTextField.resignFirstResponder()
        
        // Reset the search related properties
        searchedText = ""
        isInSearchMode = false
        toolbarHeightAnchor.constant = 0
        conversations.removeAll()
        mainMessages.removeAll()
        mainConversations.removeAll()
        messages.removeAll()
        
        // Reset the fetch flags
        didFetchMainContent = false
        didFetchConversations = false
        didFetchMessages = false

        // Reload collection views
        mainCollectionView.reloadData()
        messagesCollectionView.reloadData()
        conversationCollectionView.reloadData()
        
        // Reset scroll offset
        scrollView.setContentOffset(.zero, animated: false)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Reset the fetch flags to fetch new data
        didFetchMainContent = false
        didFetchMessages = false
        didFetchConversations = false
        
        // Check if the search text is empty or contains only whitespace
        guard let text = searchBar.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            // Reset the search related properties
            searchedText = ""
            isInSearchMode = false
            toolbarHeightAnchor.constant = 0
            conversations.removeAll()
            mainMessages.removeAll()
            mainConversations.removeAll()
            messages.removeAll()
            
            // Reset the fetch flags
            didFetchMainContent = false
            didFetchConversations = false
            didFetchMessages = false

            // Reload collection views
            mainCollectionView.reloadData()
            messagesCollectionView.reloadData()
            conversationCollectionView.reloadData()
            
            // Reset scroll offset
            scrollView.setContentOffset(.zero, animated: false)
            return
        }
        
        // Update search related properties and perform search based on the content offset
        isInSearchMode = true
        toolbarHeightAnchor.constant = 50
        searchedText = text
        
        switch scrollView.contentOffset.x {
        case 0 ..< view.frame.width:
            fetchMainContent()
        case view.frame.width ..< 2 * view.frame.width:
            fetchConversations()
        default:
            fetchMessages()
        }
    }
}

extension ConversationResultsUpdatingViewController: SearchRecentsHeaderDelegate {
    func didTapClearSearches() {
        displayAlert(withTitle: AppStrings.Alerts.Title.clearRecents, withMessage: AppStrings.Alerts.Subtitle.clearRecents, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) {
            [weak self] in
            guard let _ = self else { return }
            DatabaseManager.shared.deleteRecentMessageSearches { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(_):
                    // Clear the recent searches and reload the main collection view
                    strongSelf.recentSearches.removeAll()
                    strongSelf.mainCollectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension ConversationResultsUpdatingViewController: PrimarySearchHeaderDelegate {
    func didTapSeeAll(_ header: UICollectionReusableView) {
        switch header.tag {
        case 0:
            // Scroll to the conversations section
            scrollView.setContentOffset(CGPoint(x: view.frame.width, y: 0), animated: true)
            scrollIndex = 1
        default:
            // Scroll to the messages section
            scrollView.setContentOffset(CGPoint(x: 2 * view.frame.width, y: 0), animated: true)
            scrollIndex = 2
        }
    }
}

extension ConversationResultsUpdatingViewController: MessageToolbarDelegate {
    func didTapIndex(_ index: Int) {
        // Set the content offset of the scroll view based on the tapped index
        scrollView.setContentOffset(CGPoint(x: index * Int(view.frame.width), y: 0), animated: true)
        scrollIndex = index
    }
}

extension ConversationResultsUpdatingViewController: PrimaryEmptyCellDelegate {
    func didTapEmptyAction() {
        // Presents the NewMessageViewController modally
        let controller = NewMessageViewController()
        controller.delegate = self
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .automatic
        present(navVC, animated: true)
    }
}

extension ConversationResultsUpdatingViewController: MessageViewControllerDelegate {
    func didReadConversation(_ conversation: Conversation, message: Message) {
        if let conversationViewController = presentingViewController as? ConversationViewController {
            conversationViewController.didReadConversation(conversation, message: message)
        }
    }
    
    func didSendMessage(_ message: Message, for conversation: Conversation) {
        delegate?.sendMessage(message, to: conversation)
    }
    
    func didCreateNewConversation(_ conversation: Conversation) {
        if let conversationViewController = presentingViewController as? ConversationViewController {
            conversationViewController.didCreateNewConversation(conversation)
        }
    }
    
    func deleteConversation(_ conversation: Conversation) { return }
    
    func didReadAllMessages(for conversation: Conversation) {
        delegate?.readMessages(for: conversation)
    }
}

extension ConversationResultsUpdatingViewController: NewMessageViewControllerDelegate {
    func didOpenConversation(for user: User) {
        // Check if a conversation exists for the given user ID
        DataService.shared.conversationExists(for: user.uid!) { [weak self] exists in
            guard let strongSelf = self else { return }
            if exists {
                // Find the index of the conversation for the user in the conversations array
                if let conversationIndex = strongSelf.conversations.firstIndex(where: { $0.userId == user.uid! }) {
                    // Create a MessageViewController with the existing conversation
                    let controller = MessageViewController(conversation: strongSelf.conversations[conversationIndex], user: user)
                    controller.delegate = self
                    strongSelf.navigationController?.pushViewController(controller, animated: true)
                }
            } else {
                guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
                let name = user.firstName! + " " + user.lastName!
                
                // Create a new conversation with the user
                let newConversation = Conversation(name: name, userId: user.uid!, ownerId: uid)
                let controller = MessageViewController(conversation: newConversation, user: user)
                controller.delegate = self
                strongSelf.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}
