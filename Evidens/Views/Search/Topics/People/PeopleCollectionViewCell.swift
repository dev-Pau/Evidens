//
//  PeopleCollectionViewCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/8/22.
//

import UIKit

private let topPeopleHeaderReuseIdentifier = "TopPeopleHeaderReuseIdentifier"
private let topPeopleCellReuseIdentifier = "TopPeopleCellReuseIdentifier"

class PeopleCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var searchedText: String? {
        didSet {
            guard let searchedText = searchedText else { return }
            fetchTopUsers(withText: searchedText)
        }
    }
    
    private var usersFetched = [SearchUser]()
    
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(), style: .grouped)
        return tableView
    }()
    
    private lazy var noResultsImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.isHidden = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!.withRenderingMode(.alwaysOriginal).withTintColor(grayColor)
        return iv
    }()
    
    private lazy var noResultsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = grayColor
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 74
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .white
        tableView.register(TopPeopleHeader.self, forHeaderFooterViewReuseIdentifier: topPeopleHeaderReuseIdentifier)
        tableView.register(TopPeopleCell.self, forCellReuseIdentifier: topPeopleCellReuseIdentifier)
        addSubviews(tableView, noResultsImageView, noResultsLabel)
        tableView.frame = bounds
        
        noResultsLabel.text = "No results found"
        
        NSLayoutConstraint.activate([
            noResultsImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            noResultsImageView.topAnchor.constraint(equalTo: topAnchor, constant: 60),
            noResultsImageView.heightAnchor.constraint(equalToConstant: 65),
            noResultsImageView.widthAnchor.constraint(equalToConstant: 65),
            
            noResultsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            noResultsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            noResultsLabel.topAnchor.constraint(equalTo: noResultsImageView.bottomAnchor, constant: 10)
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    //MARK: - Actions
    
    //MARK: - API
    
    // Fetch top users based on current user search
    
    
    func fetchTopUsers(withText text: String) {
        AlgoliaService.fetchTopUsers(withText: text) { searchUsers in
            if searchUsers.isEmpty {
                DispatchQueue.main.async {
                    self.tableView.isHidden = true
                    self.noResultsImageView.isHidden = false
                    self.noResultsLabel.isHidden = false
                }
                return
            }
            self.usersFetched = searchUsers
            DispatchQueue.main.async {
                self.tableView.isHidden = false
                self.noResultsImageView.isHidden = true
                self.noResultsLabel.isHidden = true
                self.tableView.reloadData()
            }
        }
    }
}

extension PeopleCollectionViewCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: topPeopleHeaderReuseIdentifier) as! TopPeopleHeader
        return cell
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersFetched.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: topPeopleCellReuseIdentifier, for: indexPath) as! TopPeopleCell
        cell.viewModel = TopPeopleCellViewModel(user: usersFetched[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}


extension PeopleCollectionViewCell: UITableViewDelegate {
    
}

