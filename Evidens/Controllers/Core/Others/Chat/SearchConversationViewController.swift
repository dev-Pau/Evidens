//
//  SearchConversationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 25/9/22.
//

import UIKit

private let loadingSearchHeaderReuseIdentifier = "LoadingSearchHeaderReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"
private let searchRecentsHeaderReuseIdentifier = "SearchRecentsHeaderReuseIdentifier"
private let conversationCellReuseIdentifier = "ConversationCellReuseIdentifier"
private let emptySearchResultsReuseIdentifier = "EmptySearchResultsReuseIdentifier"
private let recentContentSearchReuseIdentifier = "RecentContentSearchReuseIdentifier"

protocol SearchConversationViewControllerDelegate: AnyObject {
    func didTapUser(user: User)
    func updatePan()
    func didTapTextToSearch(text: String)
}

class SearchConversationViewController: UIViewController {
    
    weak var delegate: SearchConversationViewControllerDelegate?
    
    private var recentSearches = [String]()
    private var users = [User]()
    private var filteredUsers = [User]()
    private var searchedText: String = ""
    
    private var dataLoaded: Bool = false
    private var isInSearchMode: Bool = false
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureCollectionView()
        configureUI()
        //fetchRecentSearches()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !dataLoaded { fetchRecentSearches() }
    }
    
    private func fetchRecentSearches() {
        print("start fetching")
        DatabaseManager.shared.fetchRecentMessageSearches { result in
            switch result {
            case .success(let searches):
                guard !searches.isEmpty else {
                    self.dataLoaded = true
                    print("data is empty")
                    self.collectionView.reloadData()
                    return
                }
                
                self.recentSearches = searches
                self.dataLoaded = true
                self.collectionView.reloadData()
                
            case .failure(let _):
                print("error fetching recent messages")
            }
        }
    }

    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground

        collectionView.register(MEPrimaryEmptyCell.self, forCellWithReuseIdentifier: emptySearchResultsReuseIdentifier)
        collectionView.register(EmptyRecentsSearchCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        collectionView.register(SearchRecentsHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchRecentsHeaderReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingSearchHeaderReuseIdentifier)
        collectionView.register(NewConversationCell.self, forCellWithReuseIdentifier: conversationCellReuseIdentifier)
        collectionView.register(RecentContentSearchCell.self, forCellWithReuseIdentifier: recentContentSearchReuseIdentifier)

        collectionView.keyboardDismissMode = .onDrag
    }
    
    func configureUI() {
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }
}

extension SearchConversationViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !isInSearchMode {
            return dataLoaded ? recentSearches.isEmpty ? 1 : recentSearches.count : 0
        } else {
            return dataLoaded ? filteredUsers.isEmpty ? 1 : filteredUsers.count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if !dataLoaded {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingSearchHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchRecentsHeaderReuseIdentifier, for: indexPath) as! SearchRecentsHeader
            header.delegate = self
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if !isInSearchMode {
            return recentSearches.isEmpty ? CGSize.zero : CGSize(width: view.frame.width, height: 40)
        } else {
            return dataLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !isInSearchMode {
            if recentSearches.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! EmptyRecentsSearchCell
                cell.set(title: "Try searching for people, groups or messages")
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentContentSearchReuseIdentifier, for: indexPath) as! RecentContentSearchCell
                cell.viewModel = RecentTextCellViewModel(recentText: recentSearches[indexPath.row])
                return cell
            }
        } else {
            if filteredUsers.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptySearchResultsReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
                cell.set(withTitle: "No results for \"\(searchedText)\"", withDescription: "The term you entered did not bring up any results. You may want to try using different search terms.", withButtonText: "   Start new message   ")
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversationCellReuseIdentifier, for: indexPath) as! NewConversationCell
                cell.set(user: filteredUsers[indexPath.row])
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if !isInSearchMode {
            return CGSize(width: view.frame.width, height: 40)
        } else {
            return CGSize(width: view.frame.width, height: 70)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isInSearchMode {
            guard !recentSearches.isEmpty else { return }
            let searchedText = recentSearches[indexPath.row]
            delegate?.didTapTextToSearch(text: searchedText)
            // Perform query
        }
    }
}

//MARK: - UITableViewDelegate

extension SearchConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !users.isEmpty else { return }
        let user = filteredUsers[indexPath.row]
        navigationController?.popViewController(animated: true)
        delegate?.didTapUser(user: user)
    }
}

//MARK: - UISearchBarDelegate

/*
extension SearchConversationViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            loaded = false
            tableView.reloadData()
            return
        }
        loaded = true
        filterConversations(with: text.lowercased())
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        searchBar.resignFirstResponder()
        filterConversations(with: text.lowercased())
    }
    
    func filterConversations(with text: String) {
        let result: [User] = users.filter { $0.firstName!.lowercased().contains(text) || $0.lastName!.lowercased().contains(text) }
        filteredUsers = result
        tableView.reloadData()
    }
}
 */
extension SearchConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        DatabaseManager.shared.uploadRecentMessageSearches(with: searchText) { _ in }
        recentSearches.insert(searchText, at: 0)
        isInSearchMode = true
        searchedText = searchText
        
        #warning("perform query")
        dataLoaded = true
        collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        delegate?.updatePan()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        delegate?.updatePan()
    }
}

extension SearchConversationViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            print("show recent searches vc")
            if !dataLoaded { return }
            isInSearchMode = false
            dataLoaded = true
            self.collectionView.reloadData()
            return
        }
    }
}

extension SearchConversationViewController: SearchRecentsHeaderDelegate {
    func didTapClearSearches() {
        displayMEDestructiveAlert(withTitle: "Delete recent searches", withMessage: "Are you sure you want to clear your most recent searches?", withCancelButtonText: "Cancel", withDoneButtonText: "Delete") {
            DatabaseManager.shared.deleteRecentMessageSearches { result in
                switch result {
                case .success(let _):
                    self.recentSearches.removeAll()
                    self.collectionView.reloadData()
                case .failure(let _):
                    print("could not delete recent messages due to error")
                }
            }
        }
    }
}

