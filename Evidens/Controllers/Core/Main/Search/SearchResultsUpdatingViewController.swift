//
//  SearchResultsUpdatingViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/2/23.
//

import UIKit

class SearchResultsUpdatingViewController: UIViewController {
    var toolbarHeightAnchor: NSLayoutConstraint!
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        return collectionView
    }()
    
    private let categoriesToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
    }
    
    private func configureNavigationBar() {
        
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubviews(categoriesToolbar, collectionView)
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
        
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
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
