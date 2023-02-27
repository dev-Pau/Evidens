//
//  SearchResultsUpdatingViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/2/23.
//

import UIKit

private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"

class SearchResultsUpdatingViewController: UIViewController {
    
    var toolbarHeightAnchor: NSLayoutConstraint!
    
    private var dataLoaded: Bool = false
    private var isInSearchMode: Bool = false
    
    private var recentSearches = [String]()
    private var recentUserSearches = [String]()
    
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
                    case .failure(let error):
                        print(error)
                    }
                    
                    // fetch users i reload
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection? in

                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))

                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90), heightDimension: .absolute(260)), subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
                return section
        }
        
        return layout
    }
    
    private func configureUI() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.backgroundColor = .systemBackground
        view.addSubviews(categoriesToolbar, collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolbarHeightAnchor = categoriesToolbar.heightAnchor.constraint(equalToConstant: 50)
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
        collectionView.register(EmptyRecentsSearchCell.self, forCellWithReuseIdentifier: emptyContentCellReuseIdentifier)
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
    }
}

extension SearchResultsUpdatingViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "kek", for: indexPath)
        cell.backgroundColor = .systemPink
        return cell
    }
    
}
