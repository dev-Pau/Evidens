//
//  UserCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/10/21.
//

import UIKit
import SDWebImage

private let testIdentifier = "test"
private let topHeaderReuseIdentifier = "TopHeaderReuseIdentifier"

class TopCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    /*
    var viewModel: UserCellViewModel? {
        didSet {
            configure()
        }
    }
     */
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TopHeaderCell.self, forHeaderFooterViewReuseIdentifier: topHeaderReuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: testIdentifier)
        
        addSubview(tableView)
        tableView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    /*
    func configure() {
        guard let viewModel = viewModel else { return }
        fullNameLabel.text = viewModel.firstName + " " + viewModel.lastName
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
    }
     */
    
    //MARK: - Actions
    
    //MARK: - API
}

extension TopCollectionViewCell: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: topHeaderReuseIdentifier) as! TopHeaderCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: testIdentifier, for: indexPath)
        cell.backgroundColor = .red
        return cell
    }
}

extension TopCollectionViewCell: UITableViewDelegate {
    
}
