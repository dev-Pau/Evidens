//
//  DetailedSearchViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/5/22.
//

import UIKit

class SearchResultsViewController: UIViewController {
    
    //MARK: - Properties
    public var searchedText = ""
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        //searchBar.searchTextField.attributedPlaceholder = atrString
        searchBar.searchTextField.backgroundColor = lightColor
        return searchBar
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        view.backgroundColor = .yellow
        searchBar.text = searchedText
    }
}

extension SearchResultsViewController: UISearchBarDelegate {
    
}
