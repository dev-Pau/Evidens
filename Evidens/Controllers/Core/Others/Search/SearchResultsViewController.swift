//
//  DetailedSearchViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/5/22.
//

import UIKit

private let reuseIdentifier = "SearchCell"

class SearchResultsViewController: UIViewController {
    
    //MARK: - Properties
    public var searchedText = ""
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        //searchBar.searchTextField.attributedPlaceholder = atrString
        searchBar.searchTextField.backgroundColor = lightColor
        return searchBar
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["People", "Posts", "Clinical Cases"])
        sc.addTarget(self, action: #selector(segmentControlDidChange), for: .valueChanged)
        sc.backgroundColor = .clear
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        return tableView
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        configureUI()
        configureTableView()
    }
    
    //MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white

        view.addSubview(segmentedControl)
        segmentedControl.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 6)
        
        view.addSubview(tableView)
        tableView.anchor(top: segmentedControl.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    func configureSearchBar() {
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        searchBar.text = searchedText
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    @objc func segmentControlDidChange() {
        print(segmentedControl.selectedSegmentIndex)
        segmentedControl.selectedSegmentTintColor = .white
    }
}

//MARK: - UITableViewDataSource

extension SearchResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}


//MARK: - UITableViewDelegate

extension SearchResultsViewController: UITableViewDelegate {
    
}


//MARK: - UISearchBarDelegate

extension SearchResultsViewController: UISearchBarDelegate {
    
}
