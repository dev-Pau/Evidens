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
    
    var searchedText: String? {
        didSet {
            guard let searchedText = searchedText else { return }
            fetchCases(withText: searchedText)
        }
    }
    
    private var casesFetched = [Case]()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(), style: .grouped)
        return tableView
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 74
        tableView.rowHeight = UITableView.automaticDimension
        
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
    
    func fetchCases(withText text: String) {
        AlgoliaService.fetchCases(withText: text) { postIDs in
            postIDs.forEach { id in
                CaseService.fetchCase(withCaseId: id) { post in
                    self.casesFetched.append(post)
                    if postIDs.count == self.casesFetched.count {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
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
}


extension CasesCollectionViewCell: UITableViewDelegate {
    
}
