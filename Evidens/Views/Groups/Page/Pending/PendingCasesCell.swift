//
//  PendingCasesCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/1/23.
//

import UIKit


private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"

private let emptyPostsCellReuseIdentifier = "EmptyPostsCellReuseIdentifier"

class PendingCasesCell: UICollectionViewCell {
    
    private var clinicalCases = [Case]()
    private var users = [User]()
    
    private var loaded: Bool = false
    private var groupNeedsToReviewContent: Bool = false
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .leastNonzeroMagnitude)
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isHidden = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(collectionView, activityIndicator)
        collectionView.frame = bounds
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyPostsCellReuseIdentifier)
        
        collectionView.register(CaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        collectionView.register(CaseTextImageCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        
        activityIndicator.startAnimating()
    }
    
    func fetchPendingPosts(group: Group) {
        if group.permissions == .all || group.permissions == .review {
            groupNeedsToReviewContent = true
            DatabaseManager.shared.fetchPendingCasesForGroup(withGroupId: group.groupId) { pendingCases in
                let postIds = pendingCases.map({ $0.id })
                if pendingCases.isEmpty {
                    self.activityIndicator.stopAnimating()
                    self.collectionView.isHidden = false
                    self.collectionView.isScrollEnabled = true
                    self.collectionView.reloadData()
                    return
                }
                postIds.forEach { id in
                    CaseService.fetchGroupCase(withGroupId: group.groupId, withCaseId: id) { clinicalCase in
                        self.clinicalCases.append(clinicalCase)
                        if self.clinicalCases.count == pendingCases.count {
                            // Fetch user info
                            self.clinicalCases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                            let uniqueOwnerUids = Array(Set(self.clinicalCases.map({ $0.ownerUid })))
                            UserService.fetchUsers(withUids: uniqueOwnerUids) { users in
                                self.users = users
                                self.activityIndicator.stopAnimating()
                                self.collectionView.isHidden = false
                                self.collectionView.isScrollEnabled = true
                                self.collectionView.reloadData()
                                return
                            }
                        }
                    }
                }
            }
        } else {
            groupNeedsToReviewContent = false
            activityIndicator.stopAnimating()
            collectionView.isHidden = false
            collectionView.isScrollEnabled = true
            collectionView.reloadData()
        }
    }
    
    private func getUserForCase(clinicalCase: Case) -> User {
        let userIndex = users.firstIndex { user in
            if user.uid == clinicalCase.ownerUid {
                return true
            }
            
            return false
        }
        
        if let userIndex = userIndex {
            return users[userIndex]
        } else {
            return User(dictionary: [:])
        }
    }
}

extension PendingCasesCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  groupNeedsToReviewContent ? (clinicalCases.isEmpty ? 1 : clinicalCases.count) : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if !groupNeedsToReviewContent {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyPostsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: nil, title: "Cases don't require admin review", description: "Group owners can activate the ability to review all group cases before they are shared with members.", buttonText: "Learn more")
            return cell
        }
        
        if clinicalCases.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyPostsCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: nil, title: "No pending cases.", description: "Check back for all the new posts that need review.", buttonText: "Go to group")
            return cell
        }
        // Dequeue cases
        if clinicalCases[indexPath.row].type.rawValue == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell

            cell.viewModel = CaseViewModel(clinicalCase: clinicalCases[indexPath.row])
            cell.set(user: getUserForCase(clinicalCase: clinicalCases[indexPath.row]))
            cell.configureWithReviewOptions()
            //cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell

            cell.viewModel = CaseViewModel(clinicalCase: clinicalCases[indexPath.row])
            cell.set(user: getUserForCase(clinicalCase: clinicalCases[indexPath.row]))
            cell.configureWithReviewOptions()
            //cell.delegate = self
            return cell
        }
    }
}


