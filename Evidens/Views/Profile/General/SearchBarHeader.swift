//
//  SearchBarHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/1/23.
//

import UIKit

protocol SearchBarHeaderDelegate: AnyObject {
    func didSearchText(text: String)
    func resetUsers()
}

class SearchBarHeader: UICollectionReusableView {
    
    weak var delegate: SearchBarHeaderDelegate?
    
    var invalidateInstantSearch: Bool = false
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = AppStrings.Search.Bar.members
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .systemBackground
        searchBar.delegate = self
        addSubviews(searchBar)
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            searchBar.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
}

extension SearchBarHeader: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            delegate?.resetUsers()
            return
        }
        if invalidateInstantSearch { return }
        delegate?.didSearchText(text: text.lowercased())
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        delegate?.resetUsers()
    }
    
    func setSearchBarPlaceholder(text: String) {
        searchBar.placeholder = text
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        searchBar.resignFirstResponder()
        delegate?.didSearchText(text: text.lowercased())
    }
}
