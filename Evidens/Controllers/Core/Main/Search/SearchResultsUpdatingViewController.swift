//
//  SearchResultsUpdatingViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/2/23.
//

import UIKit

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"
private let searchRecentsHeaderReuseIdentifier = "SearchRecentsHeaderReuseIdentifier"
private let recentSearchesUserCellReuseIdentifier = "RecentSearchesUserCellReuseIdentifier"

class SearchResultsUpdatingViewController: UIViewController {
    
    var toolbarHeightAnchor: NSLayoutConstraint!
    
    private var dataLoaded: Bool = false
    private var isInSearchMode: Bool = false
    
    private var recentSearches = [String]()
    private var recentUserSearches = [String]()
    private var users = [User]()
    
    private var searchedText: String = ""

    private var collectionView: UICollectionView!
    
    private let categoriesToolbar: MESearchToolbar = {
        let toolbar = MESearchToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !dataLoaded { fetchRecentSearches() }
    }
    
    private func fetchRecentSearches() {
        DatabaseManager.shared.fetchRecentSearches { recents in
            switch recents {
            case .success(let recentSearches):
                self.recentSearches = recentSearches
                DatabaseManager.shared.fetchRecentUserSearches { userRecents in
                    switch userRecents {
                    case .success(let recentUserSearches):
                        self.recentUserSearches = recentUserSearches
                        UserService.fetchUsers(withUids: recentUserSearches) { users in
                            self.users = users
                            self.toolbarHeightAnchor.constant = 50
                            self.dataLoaded = true
                            self.collectionView.reloadData()
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection? in
            
            if self.isInSearchMode {
                
            } else {

            }
            if sectionNumber == 0 {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .absolute(100)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)
                //if self.dataLoaded == false {
                    section.boundarySupplementaryItems = [header]
                //}

                return section
            } else {
               
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                //section.orthogonalScrollingBehavior = .groupPagingCentered
                section.interGroupSpacing = 10
                //section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
               
                return section
            }
           
        }
        
        return layout
    }
    
    private func configureUI() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.backgroundColor = .systemBackground
        view.addSubviews(categoriesToolbar, collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolbarHeightAnchor = categoriesToolbar.heightAnchor.constraint(equalToConstant: 0)
        toolbarHeightAnchor.isActive = true
        
        NSLayoutConstraint.activate([
            categoriesToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoriesToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoriesToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            collectionView.topAnchor.constraint(equalTo: categoriesToolbar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
         
        ])
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(EmptyRecentsSearchCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
        collectionView.register(SearchRecentsHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: searchRecentsHeaderReuseIdentifier)
        collectionView.register(RecentSearchesUserCell.self, forCellWithReuseIdentifier: recentSearchesUserCellReuseIdentifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "kek")
        
    }
}

extension SearchResultsUpdatingViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
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

extension SearchResultsUpdatingViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return isInSearchMode ? 1 : 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isInSearchMode {
            return 20
        } else {
            if section == 0 {
                return users.count
            } else {
                // tornar 0 si data no està loaded bro
                return 4
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if dataLoaded {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: searchRecentsHeaderReuseIdentifier, for: indexPath) as! SearchRecentsHeader
            //header.delegate = self
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recentSearchesUserCellReuseIdentifier, for: indexPath) as! RecentSearchesUserCell
            cell.configureWithUser(user: users[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "kek", for: indexPath)
            cell.backgroundColor = .systemPink
            return cell
        }
       
    }
    
}
