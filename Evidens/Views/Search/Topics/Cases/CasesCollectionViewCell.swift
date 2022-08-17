//
//  CasesCollectionViewCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/8/22.
//

import UIKit

private let topCaseHeaderReuseIdentifier = "TopHeaderCaseReuseIdentifier"
private let topCaseImageCellReuseIdentifier = "TopCaseImageCellReuseIdentifier"
private let topCaseTextCellReuseIdentifier = "TopCaseTextCellReuseIdentifier"

class CasesCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    private var casesFetched = [Case]()
    
    /*
     var viewModel: UserCellViewModel? {
     didSet {
     configure()
     }
     }
     */
    
    // Top users fetched based on current user search
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(), style: .grouped)
        return tableView
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fetchCases()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TopCaseHeader.self, forHeaderFooterViewReuseIdentifier: topCaseHeaderReuseIdentifier)
        tableView.register(TopCaseImageCell.self, forCellReuseIdentifier: topCaseImageCellReuseIdentifier)
        tableView.register(TopCaseTextCell.self, forCellReuseIdentifier: topCaseTextCellReuseIdentifier)
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
    
    // Fetch top users based on current user search
    
    func fetchCases() {
        CaseService.fetchCases { cases in
            self.casesFetched = cases
            self.tableView.reloadData()
        }
    }
}

extension CasesCollectionViewCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: topCaseHeaderReuseIdentifier) as! TopCaseHeader
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return casesFetched.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if casesFetched[indexPath.row].type == .text {
            let cell = tableView.dequeueReusableCell(withIdentifier: topCaseTextCellReuseIdentifier, for: indexPath) as! TopCaseTextCell
            cell.viewModel = CaseViewModel(clinicalCase: casesFetched[indexPath.row])
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: topCaseImageCellReuseIdentifier, for: indexPath) as! TopCaseImageCell
            cell.viewModel = CaseViewModel(clinicalCase: casesFetched[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}


extension CasesCollectionViewCell: UITableViewDelegate {
    
}
