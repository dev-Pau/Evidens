//
//  UserCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/10/21.
//

import UIKit
import SDWebImage
import InstantSearch


private let topPeopleCellIdentifier = "TopCellIdentifier"
private let topPeopleHeaderReuseIdentifier = "TopHeaderReuseIdentifier"
private let topPostHeaderReuseIdentifier = "TopPostHeaderReuseIdentifier"
private let topPostImageCellReuseIdentifier = "TopPostImageCellReuseIdentifier"
private let topCaseHeaderReuseIdentifier = "TopHeaderCaseReuseIdentifier"
private let topPostTextCellReuseIdentifier = "TopPostTextCellReuseIdentifier"
private let topCaseImageCellReuseIdentifier = "TopCaseImageCellReuseIdentifier"
private let topCaseTextCellReuseIdentifier = "TopCaseTextCellReuseIdentifier"

private let emptyContentCellReuseIdentifier = "EmptyContentCellReuseIdentifier"

protocol TopCollectionViewCellDelegate: AnyObject {
    func handleProfileTap(user: User)
}

class TopCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    weak var delegate: TopCollectionViewCellDelegate?
    
    var searchedText: String? {
        didSet {
            guard let searchedText = searchedText else { return }
            fetchTopUsers(withText: searchedText)
            //fetchTopPosts(withText: searchedText)
            //fetchTopCases(withText: searchedText)
        }
    }
    
    private var topUsersFetched = [User]()
    private var topPostsFetched = [Post]()
    private var topCasesFetched = [Case]()
    
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
        
        
        tableView.register(TopPeopleHeader.self, forHeaderFooterViewReuseIdentifier: topPeopleHeaderReuseIdentifier)
        tableView.register(TopPeopleCell.self, forCellReuseIdentifier: topPeopleCellIdentifier)
        tableView.register(TopPostHeader.self, forHeaderFooterViewReuseIdentifier: topPostHeaderReuseIdentifier)
        tableView.register(TopPostTextCell.self, forCellReuseIdentifier: topPostTextCellReuseIdentifier)
        tableView.register(TopPostImageCell.self, forCellReuseIdentifier: topPostImageCellReuseIdentifier)
        tableView.register(TopCaseHeader.self, forHeaderFooterViewReuseIdentifier: topCaseHeaderReuseIdentifier)
        tableView.register(TopCaseImageCell.self, forCellReuseIdentifier: topCaseImageCellReuseIdentifier)
        tableView.register(TopCaseTextCell.self, forCellReuseIdentifier: topCaseTextCellReuseIdentifier)
        
        tableView.register(EmptyContentCell.self, forCellReuseIdentifier: emptyContentCellReuseIdentifier)
        addSubview(tableView)
        tableView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    //MARK: - Actions
    
    //MARK: - API
    func fetchTopUsers(withText text: String) {
        UserService.fetchUsersWithText(text: text.capitalized) { users in
            self.topUsersFetched = users
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        /*
        AlgoliaService.fetchTopUsers(withText: text) { searchUsers in
            self.topUsersFetched = searchUsers
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
         */
    }
    /*
    func fetchTopPosts(withText text: String) {
        AlgoliaService.fetchTopPosts(withText: text) { postIDs in
            postIDs.forEach { id in
                PostService.fetchPost(withPostId: id) { post in
                    self.topPostsFetched.append(post)
                    if postIDs.count == self.topPostsFetched.count {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func fetchTopCases(withText text: String) {
        AlgoliaService.fetchTopCases(withText: text) { caseIDs in
            caseIDs.forEach { id in
                CaseService.fetchCase(withCaseId: id) { clinicalCase in
                    self.topCasesFetched.append(clinicalCase)
                    if caseIDs.count == self.topCasesFetched.count {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
     */
}

extension TopCollectionViewCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: topPeopleHeaderReuseIdentifier) as! TopPeopleHeader
            return cell
        } else if section == 1 {
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: topPostHeaderReuseIdentifier) as! TopPostHeader
            return cell
        } else {
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: topCaseHeaderReuseIdentifier) as! TopCaseHeader
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if topUsersFetched.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! EmptyContentCell
                cell.selectionStyle = .none
                cell.set(title: "No users found for \(searchedText!)", description: "Try searching for something else.")
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: topPeopleCellIdentifier, for: indexPath) as! TopPeopleCell
            cell.selectionStyle = .none
            cell.user = topUsersFetched[indexPath.row]
            return cell
            
        } else if indexPath.section == 1 {
            
            if topPostsFetched.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! EmptyContentCell
                cell.selectionStyle = .none
                cell.set(title: "No posts found for \(searchedText!)", description: "Try searching for something else.")
                return cell
            }
            
            
            if topPostsFetched[indexPath.row].type == .plainText {
                let cell = tableView.dequeueReusableCell(withIdentifier: topPostTextCellReuseIdentifier, for: indexPath) as! TopPostTextCell
                cell.viewModel = PostViewModel(post: topPostsFetched[indexPath.row])
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: topPostImageCellReuseIdentifier, for: indexPath) as! TopPostImageCell
                cell.viewModel = PostViewModel(post: topPostsFetched[indexPath.row])
                cell.selectionStyle = .none
                return cell
            }
            
        } else {
            if topCasesFetched.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: emptyContentCellReuseIdentifier, for: indexPath) as! EmptyContentCell
                cell.selectionStyle = .none
                cell.set(title: "No cases found for \(searchedText!)", description: "Try searching for something else.")
                return cell
            }
            
            
            if topCasesFetched[indexPath.row].type == .text {
                let cell = tableView.dequeueReusableCell(withIdentifier: topCaseTextCellReuseIdentifier, for: indexPath) as! TopCaseTextCell
                cell.viewModel = CaseViewModel(clinicalCase: topCasesFetched[indexPath.row])
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: topCaseImageCellReuseIdentifier, for: indexPath) as! TopCaseImageCell
                cell.viewModel = CaseViewModel(clinicalCase: topCasesFetched[indexPath.row])
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            delegate?.handleProfileTap(user: topUsersFetched[indexPath.row])
        }
    }
}

extension TopCollectionViewCell: UITableViewDelegate {
    
}
