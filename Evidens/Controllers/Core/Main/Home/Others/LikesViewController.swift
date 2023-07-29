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

class LikesViewController: UIViewController {
    
    //MARK: - Properties
    
    private let kind: ContentKind
    private let post: Post?
    private let clinicalCase: Case?
    
    private var users = [User]()
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
        configureCollectionView()
        configure()
        fetchLikes()
    }
    
    init(post: Post) {
        self.post = post
        self.clinicalCase = nil
        self.kind = .post
        super.init(nibName: nil, bundle: nil)
    }
    
    init(clinicalCase: Case) {
        self.clinicalCase = clinicalCase
        self.post = nil
        self.kind = .clinicalCase
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers
    
    private func configureNavigationBar() {
        title = "Likes"
    }
    
    private func configureCollectionView() {
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(HomeLikesCell.self, forCellWithReuseIdentifier: likesCellReuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
    }
    
    private func fetchLikes() {
        switch kind {
        case .post:
            guard let post = post else { return }
            PostService.getAllLikesFor(post: post, lastSnapshot: nil) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let snapshot):
                    strongSelf.lastLikesSnapshot = snapshot.documents.last
                    let newUids = snapshot.documents.map({ $0.documentID })
                    let uniqueUids = Array(Set(newUids))
                    
                    UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users = users
                        strongSelf.likesLoaded = true
                        strongSelf.collectionView.reloadData()
                        
                    }
                case .failure(let error):
                    strongSelf.likesLoaded = true
                    strongSelf.collectionView.reloadData()

                    guard error != .notFound else {
                        return
                    }
                    
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                }
            }
        case .clinicalCase:
            break
        }
    }
    
    private func getMoreLikes() {
        switch kind {
            
        case .post:
            guard let post = post else { return }
            PostService.getAllLikesFor(post: post, lastSnapshot: lastLikesSnapshot) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let snapshot):
                    strongSelf.lastLikesSnapshot = snapshot.documents.last
                    let uids = snapshot.documents.map({ $0.documentID })
                    let currentUids = strongSelf.users.map { $0.uid }
                    let newUids = uids.filter { !currentUids.contains($0) }
                    
                    UserService.fetchUsers(withUids: newUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users.append(contentsOf: users)
                        strongSelf.collectionView.reloadData()
                        
                    }
                case .failure(let error):
                    strongSelf.likesLoaded = true
                    strongSelf.collectionView.reloadData()
                    
                    guard error != .notFound else {
                        return
                    }
                    
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                }
            }
        case .clinicalCase:
            #warning("copoiar per case")
            break
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

extension LikesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
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
        return CGSize(width: view.frame.width, height: 73)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = UserProfileViewController(user: users[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}
