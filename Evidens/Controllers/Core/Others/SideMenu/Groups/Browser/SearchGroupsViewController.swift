//
//  SearchGroupsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/3/23.
//

import UIKit
import Firebase

private let loadingSearchHeaderReuseIdentifier = "LoadingSearchHeaderReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"
private let searchRecentsHeaderReuseIdentifier = "SearchRecentsHeaderReuseIdentifier"
private let emptySearchResultsReuseIdentifier = "EmptySearchResultsReuseIdentifier"
private let recentContentSearchReuseIdentifier = "RecentContentSearchReuseIdentifier"
private let groupCellReuseIdentifier = "GroupCellReuseIdentifier"

protocol SearchGroupsViewControllerDelegate: AnyObject {
    func didTapTextToSearch(text: String)
}

class SearchGroupsViewController: UIViewController {
    weak var delegate: SearchGroupsViewControllerDelegate?
    
    private var user: User
    private var recentSearches = [String]()
    private var groups = [Group]()
    private var lastGroupSnapshot: QueryDocumentSnapshot?
    private var searchedText: String = ""
    private var arraySearchedText = [String]()
    
    private var dataLoaded: Bool = false
    private var isInSearchMode: Bool = false
    
    private var collectionView: UICollectionView!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureCollectionView()
        configureUI()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !dataLoaded { fetchRecentGroupSearches() }
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection? in
            if self.isInSearchMode {
                // Job Search
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(55))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: self.groups.count == 0 ? .fractionalHeight(1) : .estimated(65)))
                
                item.contentInsets.leading = 10
                item.contentInsets.trailing = 10
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: self.groups.count == 0 ? .fractionalHeight(0.9) : .estimated(65)), subitems: [item])
              
                let section = NSCollectionLayoutSection(group: group)
                if !self.dataLoaded { section.boundarySupplementaryItems = [header] }
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                
                return section
            } else {
                // Recents
                    let recentsIsEmpty = self.recentSearches.isEmpty
                    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40))
                    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                
                    let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), subitems: [item])
                    
                    let section = NSCollectionLayoutSection(group: group)
                    section.interGroupSpacing = 0
                    if !recentsIsEmpty { section.boundarySupplementaryItems = [header] }
                    
                    return section
                }
            }
        return layout
    }
    
    private func fetchRecentGroupSearches() {
        DatabaseManager.shared.fetchRecentGroupSearches { result in
            switch result {
            case .success(let searches):
                guard !searches.isEmpty else {
                    self.dataLoaded = true
                    self.collectionView.reloadData()
                    return
                }
                self.recentSearches = searches
                self.dataLoaded = true
                self.collectionView.reloadData()
                
            case .failure(_):
                print("error fetching recent messages")
            }
        }
    }

    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.frame = view.bounds

        collectionView.register(MEPrimaryEmptyCell.self, forCellWithReuseIdentifier: emptySearchResultsReuseIdentifier)
        collectionView.register(EmptyRecentsSearchCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        collectionView.register(SearchRecentsHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: searchRecentsHeaderReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingSearchHeaderReuseIdentifier)
        collectionView.register(RecentContentSearchCell.self, forCellWithReuseIdentifier: recentContentSearchReuseIdentifier)

        collectionView.register(GroupCell.self, forCellWithReuseIdentifier: groupCellReuseIdentifier)
    }
    
    func configureUI() {
        view.backgroundColor = .systemBackground
    }
    
    @objc func fetchGroupsWithSearchedText(_ searchedText: [String]) {
        groups.removeAll()
        GroupService.fetchGroupsWithText(searchedText, lastSnapshot: nil) { snapshot in
            guard !snapshot.isEmpty else {
                self.dataLoaded = true
                self.collectionView.reloadData()
                return
            }
            
            self.lastGroupSnapshot = snapshot.documents.last
            let groups = snapshot.documents.map({ Group(groupId: $0.documentID, dictionary: $0.data()) })
            self.groups = groups
            self.dataLoaded = true
            self.collectionView.reloadData()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreGroups()
        }
    }
    
    private func getMoreGroups() {
        GroupService.fetchGroupsWithText(arraySearchedText, lastSnapshot: lastGroupSnapshot) { snapshot in
            guard !snapshot.isEmpty else { return }
            self.lastGroupSnapshot = snapshot.documents.last
            let groups = snapshot.documents.map({ Group(groupId: $0.documentID, dictionary: $0.data()) })
            self.groups.append(contentsOf: groups)
            self.collectionView.reloadData()
        }
    }
}

extension SearchGroupsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !isInSearchMode {
            return dataLoaded ? recentSearches.isEmpty ? 1 : recentSearches.count : 0
        } else {
            return dataLoaded ? groups.isEmpty ? 1 : groups.count : 0
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
                cell.set(title: "Try searching for group names")
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentContentSearchReuseIdentifier, for: indexPath) as! RecentContentSearchCell
                cell.viewModel = RecentTextCellViewModel(recentText: recentSearches[indexPath.row])
                return cell
            }
        } else {
            if groups.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptySearchResultsReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
                cell.set(withImage: UIImage(named: "message.empty")!, withTitle: "No results for \"\(searchedText)\"", withDescription: "The term you entered did not bring up any results. You may want to try using different search terms.", withButtonText: "   Remove filters   ")
                cell.delegate = self
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupCellReuseIdentifier, for: indexPath) as! GroupCell
                cell.viewModel = GroupViewModel(group: groups[indexPath.row])
                //if indexPath.row == groups.count
                return cell
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isInSearchMode {
            guard !recentSearches.isEmpty else { return }
            let searchedText = recentSearches[indexPath.row]
            isInSearchMode = true
            dataLoaded = false
            collectionView.reloadData()
            formatTextToSearch(searchText: searchedText)
            delegate?.didTapTextToSearch(text: searchedText)
        } else {
            guard !groups.isEmpty else { return }
            let groupSelected = groups[indexPath.row]
            let controller = GroupPageViewController(group: groupSelected)
            
            let backItem = UIBarButtonItem()
            backItem.tintColor = .label
            backItem.title = ""
            
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension SearchGroupsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        DatabaseManager.shared.uploadRecentGroupSearches(with: searchText) { _ in }
        recentSearches.insert(searchText, at: 0)
        isInSearchMode = true
        searchedText = searchText
        dataLoaded = false
        collectionView.reloadData()
        formatTextToSearch(searchText: searchText)
    }
    
    func formatTextToSearch(searchText: String) {
        let trimmedText = searchText.trimmingCharacters(in: .whitespaces)
        let arrayTextToSearch = trimmedText.split(separator: " ").map({ $0.lowercased() }).map({ $0.capitalized })
        arraySearchedText = arrayTextToSearch
        fetchGroupsWithSearchedText(arraySearchedText)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            isInSearchMode = false
            dataLoaded = true
            collectionView.reloadData()
            return
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //delegate?.updatePan()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //delegate?.updatePan()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.resignFirstResponder()
        isInSearchMode = false
        dataLoaded = true
        collectionView.reloadData()
    }
}

extension SearchGroupsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        /*
        guard let text = searchController.searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            if !dataLoaded { return }
            isInSearchMode = false
            dataLoaded = true
            self.collectionView.reloadData()
            return
        }
         */
    }
}

extension SearchGroupsViewController: SearchRecentsHeaderDelegate {
    func didTapClearSearches() {
        displayMEDestructiveAlert(withTitle: "Delete recent searches", withMessage: "Are you sure you want to clear your most group recent searches?", withCancelButtonText: "Cancel", withDoneButtonText: "Delete") {
            DatabaseManager.shared.deleteRecentMessageSearches { result in
                switch result {
                case .success(_):
                    self.recentSearches.removeAll()
                    self.collectionView.reloadData()
                case .failure(_):
                    print("could not delete recent messages due to error")
                }
            }
        }
    }
}

extension SearchGroupsViewController: EmptyGroupCellDelegate {
    func didTapDiscoverGroup() {
        isInSearchMode = false
        dataLoaded = true
        collectionView.reloadData()
        delegate?.didTapTextToSearch(text: "")
        return
    }
}
