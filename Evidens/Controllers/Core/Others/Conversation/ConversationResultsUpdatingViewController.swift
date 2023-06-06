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
private let messageCellReuseIdentifier = "messageUserCellReuseIdentifier"

class ConversationResultsUpdatingViewController: UIViewController, UINavigationControllerDelegate {

    private var mainConversations = [Conversation]()
    private var mainMessages = [Message]()
    private var recentSearches = [String]()
    private var dataLoaded: Bool = false
    private var isInSearchMode: Bool = false
    private var messageToolbar = MessageToolbar()
    private var toolbarHeightAnchor: NSLayoutConstraint!
    
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
    
    private let peopleCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private let messagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
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
        peopleCollectionView.frame = CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: scrollView.frame.height)
        messagesCollectionView.frame = CGRect(x: view.frame.width * 2, y: 0, width: view.frame.width, height: scrollView.frame.height)
        
        #warning("this is when fetch data")
       
        
    }
    
    private func configureCollectionView() {
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        peopleCollectionView.delegate = self
        peopleCollectionView.dataSource = self
        messagesCollectionView.delegate = self
        messagesCollectionView.dataSource = self
        mainCollectionView.backgroundColor = .systemBackground
        peopleCollectionView.backgroundColor = .systemRed
        messagesCollectionView.backgroundColor = .systemCyan
        
        mainCollectionView.register(EmptyRecentsSearchCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        mainCollectionView.register(SearchRecentsHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchRecentsHeaderReuseIdentifier)
        mainCollectionView.register(RecentContentSearchCell.self, forCellWithReuseIdentifier: recentContentSearchReuseIdentifier)
        mainCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingSearchHeaderReuseIdentifier)
    }
    
    private func configure() {
        view.addSubviews(messageToolbar, scrollView)
        
        toolbarHeightAnchor = messageToolbar.heightAnchor.constraint(equalToConstant: 0)
        toolbarHeightAnchor.isActive = true
        
        NSLayoutConstraint.activate([
            messageToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            messageToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            //messageToolbar.heightAnchor.constraint(equalToConstant: 50),
            
            scrollView.topAnchor.constraint(equalTo: messageToolbar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        scrollView.delegate = self
        scrollView.addSubview(mainCollectionView)
        scrollView.addSubview(peopleCollectionView)
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
                let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: size)
                let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
               
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)

                let section = NSCollectionLayoutSection(group: group)
                
                if sectionNumber == 0 && !strongSelf.mainConversations.isEmpty || sectionNumber == 1 && !strongSelf.mainMessages.isEmpty {
                    section.boundarySupplementaryItems = [header]
                }
                
                return section
            } else {
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)), subitems: [item])
               
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
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
}

extension ConversationResultsUpdatingViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == mainCollectionView {
            return isInSearchMode ? 2 : 1
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == mainCollectionView {
            if isInSearchMode {
                if mainConversations.isEmpty && mainMessages.isEmpty {
                    return 0
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

        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == mainCollectionView {
            if !dataLoaded {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingSearchHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchRecentsHeaderReuseIdentifier, for: indexPath) as! SearchRecentsHeader
                //header.delegate = self
                return header
            }
        } else {
            return UICollectionReusableView()
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
                return UICollectionViewCell()
                /*
                if filteredUsers.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptySearchResultsReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
                    cell.set(withImage: UIImage(named: "message.empty")!, withTitle: "No results for \"\(searchedText)\"", withDescription: "The term you entered did not bring up any results. You may want to try using different search terms.", withButtonText: "   Start new message   ")
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversationCellReuseIdentifier, for: indexPath) as! NewConversationCell
                    cell.set(user: filteredUsers[indexPath.row])
                    return cell
                }
                 */
            }
        } else {
            return UICollectionViewCell()
        }

    }
}

extension ConversationResultsUpdatingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        messageToolbar.collectionViewDidScroll(for: scrollView.contentOffset.x)
    }
}

extension ConversationResultsUpdatingViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isInSearchMode = true
        switch scrollView.contentOffset.x {
        case 0 ... view.frame.width:
            let fetchedConversations = DataService.shared.getConversations(for: text, withLimit: 3)
            let fetchedMessages = DataService.shared.getMessages(for: text, withLimit: 3)
            mainCollectionView.reloadData()
        case view.frame.width ... 2 * view.frame.width:
            break
        default:
            break
        }
        // Send Query To CoreData
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //searchBar.showsScopeBar = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //searchBar.showsScopeBar = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        /*
        if searchText.count > 5 {
            UIView.animate(withDuration: 0.2) {
                self.toolbarHeightAnchor.constant = 0
                self.view.layoutIfNeeded()
            }

        } else {
            UIView.animate(withDuration: 0.2) {
                self.toolbarHeightAnchor.constant = 50
                self.view.layoutIfNeeded()
            }
        }
         */
    }
}



/*
extension ConversationResultsUpdatingViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
}
 */
