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
        mainCollectionView.register(RecentContentSearchCell.self, forCellWithReuseIdentifier: recentContentSearchReuseIdentifier)
        mainCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingSearchHeaderReuseIdentifier)
        mainCollectionView.register(ConversationCell.self, forCellWithReuseIdentifier: conversationCellReuseIdentifier)
        mainCollectionView.register(MainSearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: mainSearchHeader)
        mainCollectionView.register(MEPrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        mainCollectionView.register(SearchMessageCell.self, forCellWithReuseIdentifier: messageCellReuseIdentifier)
        
        conversationCollectionView.register(MEPrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        conversationCollectionView.register(ConversationCell.self, forCellWithReuseIdentifier: conversationCellReuseIdentifier)
        conversationCollectionView.register(MainSearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: mainSearchHeader)
        
        messagesCollectionView.register(MEPrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        messagesCollectionView.register(SearchMessageCell.self, forCellWithReuseIdentifier: messageCellReuseIdentifier)
        messagesCollectionView.register(MainSearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: mainSearchHeader)
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
            strongSelf.deleteConversationAlert { delete in
                completion(true)
                if delete {
                    //strongSelf.deleteConversation(at: indexPath)
                }
            }
        }
        
        let pinAction = UIContextualAction(style: .normal, title: nil) { [weak self] action, view, completion in
            guard self != nil else { return }
            completion(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                //strongSelf.togglePinConversation(at: indexPath)
            }
        }
        
        deleteAction.image = UIImage().swipeLayout(icon: AppStrings.Icons.trash, text: AppStrings.Global.delete, size: 16)
        pinAction.image = UIImage().swipeLayout(icon: AppStrings.Icons.fillPin, text: mainConversations[indexPath.item].isPinned ? AppStrings.Actions.unpin : AppStrings.Actions.pin, size: 16)
        return UISwipeActionsConfiguration(actions: [deleteAction, pinAction])
    }
    
    
    private func fetchRecentSearches() {
        DatabaseManager.shared.fetchRecentMessageSearches { result in
            switch result {
            case .success(let searches):
                guard !searches.isEmpty else {
                    self.dataLoaded = true
                    self.mainCollectionView.reloadData()
                    return
                }
                
                self.recentSearches = searches
                self.dataLoaded = true
                self.mainCollectionView.reloadData()
                
            case .failure(_):
                print("error fetching recent messages")
            }
        }
    }
    
    private func fetchMainContent() {
        mainConversations = DataService.shared.getConversations(for: searchedText, withLimit: 3)
        mainMessages = DataService.shared.getMessages(for: searchedText, withLimit: 3)
        
        let uniqueConversationIds = Array(Set(mainMessages.map { $0.conversationId! }))
        mainMessageConversations = DataService.shared.getConversations(for: uniqueConversationIds)

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.mainCollectionView.reloadData()
        }
        
        didFetchMainContent = true
    }
    
    private func fetchConversations() {
        conversations = DataService.shared.getConversations(for: searchedText, withLimit: 15)

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.conversationCollectionView.reloadData()
        }
        
        didFetchConversations = true
    }
    
    private func fetchMessages() {
        messages = DataService.shared.getMessages(for: searchedText, withLimit: 30)
        
        let uniqueConversationIds = Array(Set(messages.map { $0.conversationId! }))
        messageConversations = DataService.shared.getConversations(for: uniqueConversationIds)
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.messagesCollectionView.reloadData()
        }
        
        didFetchMessages = true
    }
    
    private func show(conversation: Conversation, for indexPath: IndexPath, in collectionView: UICollectionView) {
        let controller = MessageViewController(conversation: conversation)
        controller.delegate = self
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""

        if let conversationViewController = presentingViewController as? ConversationViewController, let navVC = conversationViewController.navigationController {
            conversationViewController.navigationItem.backBarButtonItem = backItem

            navVC.pushViewController(controller, animated: true)
            delegate?.didTapConversation(conversation)
            
            if collectionView == mainCollectionView {
                mainConversations[indexPath.row].markMessagesAsRead()
            } else {
                conversations[indexPath.row].markMessagesAsRead()
            }

            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    private func show(conversation: Conversation, for message: Message, in collectionView: UICollectionView) {
        let controller = MessageViewController(conversation: conversation, message: message)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        if let conversationViewController = presentingViewController as? ConversationViewController, let navVC = conversationViewController.navigationController {
            conversationViewController.navigationItem.backBarButtonItem = backItem
            navVC.pushViewController(controller, animated: true)
            //delegate?.didTapConversation(conversation)
            
            //conversations[indexPath.row].markMessagesAsRead()
            //collectionView.reloadItems(at: [indexPath])
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
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: mainSearchHeader, for: indexPath) as! MainSearchHeader
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
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: mainSearchHeader, for: indexPath) as! MainSearchHeader
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
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentContentSearchReuseIdentifier, for: indexPath) as! RecentContentSearchCell
                    cell.viewModel = RecentTextCellViewModel(recentText: recentSearches[indexPath.row])
                    return cell
                }
            } else {
                if mainConversations.isEmpty && mainMessages.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
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
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
                cell.set(withTitle: "No results for \"\(searchedText)\"", withDescription: "The term you entered did not bring up any results. You may want to try using different search terms.", withButtonText: "Start a New Conversation")
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversationCellReuseIdentifier, for: indexPath) as! ConversationCell
                cell.viewModel = ConversationViewModel(conversation: conversations[indexPath.row])
                return cell
            }
        } else {
            if messages.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
                cell.set(withTitle: "No results for \"\(searchedText)\"", withDescription: "The term you entered did not bring up any results. You may want to try using different search terms.", withButtonText: "Start a New Conversation")
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
                    if let conversation = mainConversations.first(where: { $0.id == message.conversationId }) {
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
        if scrollView.contentOffset.y != 0 {
            isScrollingHorizontally = false
        }
        
        if scrollView.contentOffset.y == 0 && isScrollingHorizontally {
            messageToolbar.collectionViewDidScroll(for: scrollView.contentOffset.x)
        }
        
        if scrollView.contentOffset.y == 0 && !isScrollingHorizontally {
            isScrollingHorizontally = true
        }
        
        switch scrollView.contentOffset.x {
        case 0 ... view.frame.width:
            if !didFetchConversations { fetchConversations() }
        case view.frame.width ... 2 * view.frame.width:
            if !didFetchMessages { fetchMessages() }
        case 2 * view.frame.width ... 3 * view.frame.width:
            if !didFetchMessages {  }
        default:
            break
        }
    }
}

extension ConversationResultsUpdatingViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        DatabaseManager.shared.uploadRecentMessageSearches(with: text) { _ in }
        recentSearches.insert(text, at: 0)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.resignFirstResponder()
        searchedText = ""
        isInSearchMode = false
        toolbarHeightAnchor.constant = 0
        
        didFetchMainContent = false
        didFetchConversations = false
        didFetchMessages = false
        
        mainCollectionView.reloadData()
        messagesCollectionView.reloadData()
        conversationCollectionView.reloadData()
        
        scrollView.setContentOffset(.zero, animated: false)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        didFetchMainContent = false
        didFetchMessages = false
        didFetchConversations = false
        
        guard let text = searchBar.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchedText = ""
            isInSearchMode = false
            toolbarHeightAnchor.constant = 0
            mainCollectionView.reloadData()
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            return
        }
        
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
        displayMEDestructiveAlert(withTitle: AppStrings.Alerts.Title.clearRecents, withMessage: AppStrings.Alerts.Subtitle.clearRecents, withCancelButtonText: AppStrings.Global.cancel, withDoneButtonText: AppStrings.Global.delete) {
            DatabaseManager.shared.deleteRecentMessageSearches { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(_):
                    strongSelf.recentSearches.removeAll()
                    strongSelf.mainCollectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension ConversationResultsUpdatingViewController: MainSearchHeaderDelegate {
    func didTapSeeAll(_ header: UICollectionReusableView) {
        switch header.tag {
        case 0:
            scrollView.setContentOffset(CGPoint(x: view.frame.width, y: 0), animated: true)
        default:
            scrollView.setContentOffset(CGPoint(x: 2 * view.frame.width, y: 0), animated: true)
        }
    }
}

extension ConversationResultsUpdatingViewController: MessageToolbarDelegate {
    func didTapIndex(_ index: Int) {
        scrollView.setContentOffset(CGPoint(x: index * Int(view.frame.width), y: 0), animated: true)
    }
}

extension ConversationResultsUpdatingViewController: EmptyGroupCellDelegate {
    func didTapDiscoverGroup() {
        let controller = NewMessageViewController()
        controller.delegate = self
        let navVC = UINavigationController(rootViewController: controller)
        
        navVC.modalPresentationStyle = .automatic
        
        present(navVC, animated: true)
    }
}

extension ConversationResultsUpdatingViewController: MessageViewControllerDelegate {
    func didSendMessage(_ message: Message, for conversation: Conversation) {
        delegate?.sendMessage(message, to: conversation)
    }
    
    func didCreateNewConversation(_ conversation: Conversation) {
        #warning("implementar create new conversation tb i asaro a conversation view controller perquè l'afegeixi si la crea des d'aquí")
        
    }
    
    func deleteConversation(_ conversation: Conversation) { return }
    
    func didReadAllMessages(for conversation: Conversation) {
        delegate?.readMessages(for: conversation)
    }
}

extension ConversationResultsUpdatingViewController: NewMessageViewControllerDelegate {
    func didOpenConversation(for user: User) {
        
        DataService.shared.conversationExists(for: user.uid!) { [weak self] exists in
            guard let strongSelf = self else { return }
            if exists {
                #warning("aqui demanar al conversation la conversació i pasarla")
                if let conversationIndex = strongSelf.conversations.firstIndex(where: { $0.userId == user.uid! }) {
                    let controller = MessageViewController(conversation: strongSelf.conversations[conversationIndex], user: user)
                    controller.delegate = self
                    let backItem = UIBarButtonItem()
                    backItem.title = ""
                    backItem.tintColor = .label
                    
                    strongSelf.navigationItem.backBarButtonItem = backItem
                    
                    strongSelf.navigationController?.pushViewController(controller, animated: true)
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
            }
        }
    }
}


/*
extension ConversationResultsUpdatingViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
}
 */
