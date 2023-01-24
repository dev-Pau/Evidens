//
//  PendingCasesCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/1/23.
//

import UIKit

private let skeletonPostTextCellReuseIdentifier = "SkeletonPostTextCellReuseIdentifier"
private let skeletonPostImageCellReuseIdentifier = "SkeletonPostImageCellReuseIdentifier"

private let emptyPostsCellReuseIdentifier = "EmptyPostsCellReuseIdentifier"

class PendingCasesCell: UICollectionViewCell {
    
    private var clinicalCases = [Case]()
    
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
        collectionView.isHidden = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    let spinner: UIActivityIndicatorView = {
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
        addSubviews(collectionView, spinner)
        collectionView.frame = bounds
        spinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyPostsCellReuseIdentifier)
        collectionView.register(SkeletonTextHomeCell.self, forCellWithReuseIdentifier: skeletonPostTextCellReuseIdentifier)
        collectionView.register(SkeletonImageTextHomeCell.self, forCellWithReuseIdentifier: skeletonPostImageCellReuseIdentifier)
        
        spinner.startAnimating()
    }
    
    func fetchPendingPosts(group: Group) {
        //guard let group = group else { return }
        if group.permissions == .all || group.permissions == .review {
            // Group needs to review posts  cases
            // Fetch posts to be reviewed
            groupNeedsToReviewContent = true
            loaded = true
            spinner.stopAnimating()
            collectionView.isHidden = false
            collectionView.isScrollEnabled = true
            collectionView.reloadData()
        } else {
            loaded = true
            collectionView.isScrollEnabled = true
            collectionView.isHidden = false
            spinner.stopAnimating()
            collectionView.reloadData()
        }
    }
}

extension PendingCasesCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  loaded ? (groupNeedsToReviewContent ? (clinicalCases.isEmpty ? 1 : clinicalCases.count) : 1) : 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !loaded {
            
            #warning("no es veuen les skeletoncell")
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: skeletonPostTextCellReuseIdentifier, for: indexPath) as! SkeletonTextHomeCell
                return cell
            
        }
        else {
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
            // Dequeue posts
            return UICollectionViewCell()
        }
        
    }
}


