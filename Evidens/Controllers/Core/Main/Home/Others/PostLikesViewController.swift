//
//  PostLikesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/6/22.
//

import UIKit
import Firebase

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let likesCellReuseIdentifier = "LikesCellReuseIdentifier"

class PostLikesViewController: UIViewController {
    
    //MARK: - Properties
    
    private var contentType: Any
    
    private var users: [User] = []
    private var likesLoaded: Bool = false
    private var lastLikesSnapshot: QueryDocumentSnapshot?
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        configureUI()
    }
    
    init(contentType: Any) {
        self.contentType = contentType
        super.init(nibName: nil, bundle: nil)
        let type = type(of: contentType)
        if type == Post.self {
            PostService.getAllLikesFor(post: contentType as! Post, lastSnapshot: nil) { snapshot in
                self.lastLikesSnapshot = snapshot.documents.last
                let uids = snapshot.documents.map({ $0.documentID })
                UserService.fetchUsers(withUids: uids) { users in
                    self.users = users
                    self.likesLoaded = true
                    self.collectionView.reloadData()
                }
            }
        } else {
            CaseService.getAllLikesFor(clinicalCase: contentType as! Case, lastSnapshot: nil) { snapshot in
                self.lastLikesSnapshot = snapshot.documents.last
                let uids = snapshot.documents.map({ $0.documentID })
                UserService.fetchUsers(withUids: uids) { users in
                    self.users = users
                    self.likesLoaded = true
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers
    
    private func configureNavigationBar() {
        title = "Likes"
    }
    
    private func configureTableView() {
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(HomeLikesCell.self, forCellWithReuseIdentifier: likesCellReuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
    }
    
    private func getMoreLikes() {
        let type = type(of: contentType)
        if type == Post.self {
            PostService.getAllLikesFor(post: contentType as! Post, lastSnapshot: lastLikesSnapshot) { snapshot in
                if snapshot.isEmpty { return }
                else {
                    self.lastLikesSnapshot = snapshot.documents.last
                    let newUids = snapshot.documents.map({ $0.documentID })
                    UserService.fetchUsers(withUids: newUids) { users in
                        self.users.append(contentsOf: users)
                        self.collectionView.reloadData()
                    }
                }
            }
        } else {
            CaseService.getAllLikesFor(clinicalCase: contentType as! Case, lastSnapshot: lastLikesSnapshot) { snapshot in
                if snapshot.isEmpty { return }
                else {
                    self.lastLikesSnapshot = snapshot.documents.last
                    let newUids = snapshot.documents.map({ $0.documentID })
                    UserService.fetchUsers(withUids: newUids) { users in
                        self.users.append(contentsOf: users)
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreLikes()
        }
    }
}

extension PostLikesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likesLoaded ? users.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: likesCellReuseIdentifier, for: indexPath) as! HomeLikesCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return likesLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = UserProfileViewController(user: users[indexPath.row])
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}
