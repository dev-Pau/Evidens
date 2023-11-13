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
    
    private var viewModel = ConversationResultsUpdatingViewModel()
    weak var delegate: ConversationResultsUpdatingViewControllerDelegate?

    private var isInSearchMode: Bool = false {
        didSet {
            scrollView.isScrollEnabled = isInSearchMode
        }
    }
    
    private var messageToolbar = MessageToolbar()
    private var toolbarHeightAnchor: NSLayoutConstraint!
   
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
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
        if !viewModel.dataLoaded { fetchRecentSearches() }
        /*
        if let conversationViewController = presentingViewController as? ConversationViewController {
            conversationViewController.updatePan()
            conversationViewController.updateScreenToggle()
        }
         */
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        /*
        if let conversationViewController = presentingViewController as? ConversationViewController {
            conversationViewController.updatePan()
        }
         */
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
        mainCollectionView.register(RecentTextCell.self, forCellWithReuseIdentifier: recentContentSearchReuseIdentifier)
        mainCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingSearchHeaderReuseIdentifier)
        mainCollectionView.register(ConversationCell.self, forCellWithReuseIdentifier: conversationCellReuseIdentifier)
        mainCollectionView.register(PrimarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: mainSearchHeader)
        mainCollectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        mainCollectionView.register(SearchMessageCell.self, forCellWithReuseIdentifier: messageCellReuseIdentifier)
        
        conversationCollectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        conversationCollectionView.register(ConversationCell.self, forCellWithReuseIdentifier: conversationCellReuseIdentifier)
        conversationCollectionView.register(PrimarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: mainSearchHeader)
        conversationCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingSearchHeaderReuseIdentifier)
        
        messagesCollectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        messagesCollectionView.register(SearchMessageCell.self, forCellWithReuseIdentifier: messageCellReuseIdentifier)
        messagesCollectionView.register(PrimarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: mainSearchHeader)
        messagesCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingSearchHeaderReuseIdentifier)
    }
    
    private func configure() {
        
        toolbarHeightAnchor = messageToolbar.heightAnchor.constraint(equalToConstant: 0)
        toolbarHeightAnchor.isActive = true
        
        view.addSubviews(messageToolbar, scrollView)
        scrollView.addSubviews(mainCollectionView, conversationCollectionView, messagesCollectionView)
        
        NSLayoutConstraint.activate([
            messageToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            messageToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: messageToolbar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            mainCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mainCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mainCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            
            conversationCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            conversationCollectionView.leadingAnchor.constraint(equalTo: mainCollectionView.trailingAnchor),
            conversationCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            conversationCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            
            messagesCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            messagesCollectionView.leadingAnchor.constraint(equalTo: conversationCollectionView.trailingAnchor),
            messagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            messagesCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width)
        ])
        
        messageToolbar.toolbarDelegate = self
        scrollView.delegate = self
        scrollView.contentSize.width = view.frame.width * 3
        scrollView.isScrollEnabled = false
    }
    
    private func createMainLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            
            if strongSelf.isInSearchMode {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                let section = NSCollectionLayoutSection.list(using: strongSelf.createListConfiguration(), layoutEnvironment: env)
                
                if sectionNumber == 0 && !strongSelf.viewModel.mainConversations.isEmpty || sectionNumber == 1 && !strongSelf.viewModel.mainMessages.isEmpty {
                    section.boundarySupplementaryItems = [header]
                }
                return section
                
            } else {
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)), subitems: [item])
               
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)

                let section = NSCollectionLayoutSection(group: group)
                
                
                if !strongSelf.viewModel.recentSearches.isEmpty {
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
            
            if !strongSelf.viewModel.conversations.isEmpty || !strongSelf.viewModel.conversationsLoaded {
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
            
            if !strongSelf.viewModel.messages.isEmpty || !strongSelf.viewModel.conversationsLoaded {
                section.boundarySupplementaryItems = [header]
            }
            return section
        }
        return layout
    }
                
    private func createListConfiguration() -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.showsSeparators = false
        return configuration
    }
    
    private func fetchRecentSearches() {
        viewModel.getRecentSearches { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.mainCollectionView.reloadData()
        }
    }
    
    private func fetchMainContent() {
        viewModel.getMainContent()
        mainCollectionView.reloadData()
    }
    
    private func fetchConversations() {
        viewModel.getConversations()
        conversationCollectionView.reloadData()
    }
    
    private func fetchMessages() {
        viewModel.getMessages()
        messagesCollectionView.reloadData()
    }
    
    private func fetchMoreConversations() {
        let moreConversations = viewModel.getMoreConversations()
        if moreConversations { conversationCollectionView.reloadData() }

    }
    
    private func fetchMoreMessages() {
        let moreMessages = viewModel.getMoreMessages()
        if moreMessages { messagesCollectionView.reloadData() }
    }
    
    private func show(conversation: Conversation, for indexPath: IndexPath, in collectionView: UICollectionView) {
        let controller = MessageViewController(conversation: conversation)
        controller.delegate = self

        if let conversationViewController = presentingViewController as? ConversationViewController, let navVC = conversationViewController.navigationController {

            navVC.pushViewController(controller, animated: true)
            delegate?.didTapConversation(conversation)

            if collectionView == mainCollectionView {
                viewModel.mainConversations[indexPath.row].markMessagesAsRead()
            } else {
                viewModel.conversations[indexPath.row].markMessagesAsRead()
            }

            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    private func show(conversation: Conversation, for message: Message, in collectionView: UICollectionView) {
        let controller = MessageViewController(conversation: conversation, message: message)

        if let conversationViewController = presentingViewController as? ConversationViewController, let navVC = conversationViewController.navigationController {
            navVC.pushViewController(controller, animated: true)
        }
    }
}

extension ConversationResultsUpdatingViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == mainCollectionView {
            return isInSearchMode ? viewModel.mainConversations.isEmpty && viewModel.mainMessages.isEmpty ? 1 : 2 : 1
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == mainCollectionView {
            if isInSearchMode {
                if viewModel.mainConversations.isEmpty && viewModel.mainMessages.isEmpty {
                    return 1
                } else {
                    if section == 0 {
                        return viewModel.mainConversations.count
                    } else {
                        return viewModel.mainMessages.count
                    }
                }
            } else {
                return viewModel.dataLoaded ? viewModel.recentSearches.isEmpty ? 1 : viewModel.recentSearches.count : 0
            }

        } else if collectionView == conversationCollectionView {
            return viewModel.conversationsLoaded ? viewModel.conversations.isEmpty ? 1 : viewModel.conversations.count : 0
        } else {
            return viewModel.messasgesLoaded ? viewModel.messages.isEmpty ? 1 : viewModel.messages.count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == mainCollectionView {
            if !isInSearchMode {
                if !viewModel.dataLoaded {
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
                    header.configureWith(title: AppStrings.Title.conversation, linkText: AppStrings.Content.Search.seeAll)
                } else {
                    header.configureWith(title: AppStrings.Title.message, linkText: AppStrings.Content.Search.seeAll)
                }
                return header
            }
        } else if collectionView == conversationCollectionView {
            if viewModel.conversationsLoaded {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: mainSearchHeader, for: indexPath) as! PrimarySearchHeader
                header.configureWith(title: AppStrings.Title.conversation, linkText: nil)
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingSearchHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            }
        } else {
            if viewModel.messasgesLoaded {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: mainSearchHeader, for: indexPath) as! PrimarySearchHeader
                header.configureWith(title: AppStrings.Title.message, linkText: nil)
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingSearchHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == mainCollectionView {
            if !isInSearchMode {
                if viewModel.recentSearches.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! EmptyRecentsSearchCell
                    cell.set(title: AppStrings.Conversation.Empty.trySearch)
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentContentSearchReuseIdentifier, for: indexPath) as! RecentTextCell
                    cell.viewModel = RecentTextViewModel(recentText: viewModel.recentSearches[indexPath.row])
                    return cell
                }
            } else {
                if viewModel.mainConversations.isEmpty && viewModel.mainMessages.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                    cell.set(withTitle: AppStrings.Conversation.Empty.results + " " + "\"\(viewModel.searchedText)\"", withDescription: AppStrings.Conversation.Empty.term, withButtonText: AppStrings.Conversation.Empty.new)
                    cell.delegate = self
                    return cell
                } else {
                    if indexPath.section == 0 {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversationCellReuseIdentifier, for: indexPath) as! ConversationCell
                        cell.viewModel = ConversationViewModel(conversation: viewModel.mainConversations[indexPath.row])
                        return cell
                    } else {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageCellReuseIdentifier, for: indexPath) as! SearchMessageCell
                        cell.searchedText = viewModel.searchedText
                        cell.viewModel = MessageViewModel(message: viewModel.mainMessages[indexPath.row])
                        cell.set(conversation: viewModel.mainMessageConversations.first(where: { $0.id == viewModel.mainMessages[indexPath.row].conversationId }))
                        return cell
                    }
                }
            }
        } else if collectionView == conversationCollectionView {
            if viewModel.conversations.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                cell.set(withTitle: AppStrings.Conversation.Empty.results + " " + "\"\(viewModel.searchedText)\"", withDescription: AppStrings.Conversation.Empty.term, withButtonText: AppStrings.Conversation.Empty.new)
                cell.delegate = self
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversationCellReuseIdentifier, for: indexPath) as! ConversationCell
                cell.viewModel = ConversationViewModel(conversation: viewModel.conversations[indexPath.row])
                return cell
            }
        } else {
            if viewModel.messages.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                cell.set(withTitle: AppStrings.Conversation.Empty.results + " " + "\"\(viewModel.searchedText)\"", withDescription: AppStrings.Conversation.Empty.term, withButtonText: AppStrings.Conversation.Empty.new)
                cell.delegate = self
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageCellReuseIdentifier, for: indexPath) as! SearchMessageCell
                cell.searchedText = viewModel.searchedText
                cell.viewModel = MessageViewModel(message: viewModel.messages[indexPath.row])
                cell.set(conversation: viewModel.messageConversations.first(where: { $0.id == viewModel.messages[indexPath.row].conversationId }))
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == mainCollectionView {
            if !isInSearchMode {
                guard !viewModel.recentSearches.isEmpty else { return }
                let text = viewModel.recentSearches[indexPath.row]
                viewModel.searchedText = text
                delegate?.didTapRecents(text)
                isInSearchMode = true
                toolbarHeightAnchor.constant = 50
                fetchMainContent()
                fetchConversations()
            } else {
                if indexPath.section == 0 {
                    guard !viewModel.mainConversations.isEmpty else { return }
                    let conversation = viewModel.mainConversations[indexPath.row]
                    show(conversation: conversation, for: indexPath, in: collectionView)
                } else {
                    guard !viewModel.mainMessages.isEmpty else { return }
                    let message = viewModel.mainMessages[indexPath.row]
                    if let conversation = viewModel.mainMessageConversations.first(where: { $0.id == message.conversationId }) {
                        show(conversation: conversation, for: message, in: collectionView)
                    }
                }
            }
            
        } else if collectionView == conversationCollectionView {
            guard !viewModel.conversations.isEmpty else { return }
            let conversation = viewModel.conversations[indexPath.row]
            show(conversation: conversation, for: indexPath, in: collectionView)
            
        } else if collectionView == messagesCollectionView {
            guard !viewModel.messages.isEmpty else { return }
            let message = viewModel.messages[indexPath.row]
            if let conversation = viewModel.messageConversations.first(where: { $0.id == message.conversationId }) {
                show(conversation: conversation, for: message, in: collectionView)
            }
        }
    }
}

extension ConversationResultsUpdatingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mainCollectionView || scrollView == conversationCollectionView || scrollView == messagesCollectionView {
            viewModel.isScrollingHorizontally = false
            
        } else if scrollView == self.scrollView {
            viewModel.isScrollingHorizontally = true
            messageToolbar.collectionViewDidScroll(for: scrollView.contentOffset.x)
            
            if scrollView.contentOffset.x > view.frame.width * 0.2 && !viewModel.didFetchConversations {
                fetchConversations()
            }
            
            if scrollView.contentOffset.x > view.frame.width * 1.2 && !viewModel.didFetchMessages {
                fetchMessages()
            }
            
            switch scrollView.contentOffset.x {
            case 0 ..< view.frame.width:
                viewModel.scrollIndex = 0
            case view.frame.width ..< 2 * view.frame.width:
                viewModel.scrollIndex = 1
            case 2 * view.frame.width ... 3 * view.frame.width:
                viewModel.scrollIndex = 2
            default:
                break
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        guard !viewModel.isScrollingHorizontally else {
            return
        }
        
        if offsetY > contentHeight - height {
            switch viewModel.scrollIndex {
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
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrollView.isUserInteractionEnabled = true
        messagesCollectionView.isScrollEnabled = true
        conversationCollectionView.isScrollEnabled = true
        mainCollectionView.isScrollEnabled = true
    }
}

extension ConversationResultsUpdatingViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) { /* Perform additional actions if needed */ }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Check if the search text is not empty
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        
        // Upload recent message searches to the database
        DatabaseManager.shared.addRecentMessageSearches(with: text)
        
        // Insert the search text at the beginning of the recentSearches array
        viewModel.recentSearches.insert(text, at: 0)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Resign first responder to dismiss the keyboard
        searchBar.searchTextField.resignFirstResponder()
        
        // Reset the search related properties
        viewModel.searchedText = ""
        isInSearchMode = false
        toolbarHeightAnchor.constant = 0
        viewModel.conversations.removeAll()
        viewModel.mainMessages.removeAll()
        viewModel.mainConversations.removeAll()
        viewModel.messages.removeAll()
        
        // Reset the fetch flags
        viewModel.didFetchMainContent = false
        viewModel.didFetchConversations = false
        viewModel.didFetchMessages = false
        viewModel.conversationsLoaded = false
        viewModel.messasgesLoaded = false

        // Reload collection views
        mainCollectionView.reloadData()
        messagesCollectionView.reloadData()
        conversationCollectionView.reloadData()
        
        // Reset scroll offset
        scrollView.setContentOffset(.zero, animated: false)
        messageToolbar.collectionViewDidScroll(for: 0)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Reset the fetch flags to fetch new data
        viewModel.didFetchMainContent = false
        viewModel.didFetchMessages = false
        viewModel.didFetchConversations = false
        viewModel.conversationsLoaded = false
        viewModel.messasgesLoaded = false
        
        // Check if the search text is empty or contains only whitespace
        guard let text = searchBar.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            // Reset the search related properties
            viewModel.searchedText = ""
            isInSearchMode = false
            toolbarHeightAnchor.constant = 0
            viewModel.conversations.removeAll()
            viewModel.mainMessages.removeAll()
            viewModel.mainConversations.removeAll()
            viewModel.messages.removeAll()
            
            // Reset the fetch flags
            viewModel.didFetchMainContent = false
            viewModel.didFetchConversations = false
            viewModel.didFetchMessages = false
            viewModel.conversationsLoaded = false
            viewModel.messasgesLoaded = false

            // Reload collection views
            mainCollectionView.reloadData()
            messagesCollectionView.reloadData()
            conversationCollectionView.reloadData()
            
            // Reset scroll offset
            scrollView.setContentOffset(.zero, animated: false)
            messageToolbar.collectionViewDidScroll(for: 0)
            return
        }
        
        // Update search related properties and perform search based on the content offset
        isInSearchMode = true
        toolbarHeightAnchor.constant = 50
        viewModel.searchedText = text
        
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
            DatabaseManager.shared.deleteRecentMessageSearches { [weak self] error in
                guard let strongSelf = self else { return }
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    strongSelf.viewModel.recentSearches.removeAll()
                    strongSelf.mainCollectionView.reloadData()
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
            viewModel.scrollIndex = 1
        default:
            // Scroll to the messages section
            scrollView.setContentOffset(CGPoint(x: 2 * view.frame.width, y: 0), animated: true)
            viewModel.scrollIndex = 2
        }
    }
}

extension ConversationResultsUpdatingViewController: MessageToolbarDelegate {
    func didTapIndex(_ index: Int) {
        
        switch viewModel.scrollIndex {
        case 0:
            mainCollectionView.setContentOffset(mainCollectionView.contentOffset, animated: false)
        case 1:
            conversationCollectionView.setContentOffset(conversationCollectionView.contentOffset, animated: false)
        case 2:
            messagesCollectionView.setContentOffset(messagesCollectionView.contentOffset, animated: false)
        default:
            break
        }
        
        guard viewModel.isFirstLoad else {
            viewModel.isFirstLoad.toggle()
            scrollView.setContentOffset(CGPoint(x: index * Int(view.frame.width) + index * 10, y: 0), animated: true)
            viewModel.scrollIndex = index
            return
        }
        
        mainCollectionView.isScrollEnabled = false
        conversationCollectionView.isScrollEnabled = false
        messagesCollectionView.isScrollEnabled = false
        self.scrollView.isUserInteractionEnabled = false
        
        scrollView.setContentOffset(CGPoint(x: index * Int(view.frame.width), y: 0), animated: true)
        viewModel.scrollIndex = index
        
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
                if let conversationIndex = strongSelf.viewModel.conversations.firstIndex(where: { $0.userId == user.uid! }) {
                    // Create a MessageViewController with the existing conversation
                    let controller = MessageViewController(conversation: strongSelf.viewModel.conversations[conversationIndex], user: user)
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
