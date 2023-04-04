//
//  BookmarksViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/9/22.
//

import UIKit
import Firebase

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let categoriesCellReuseIdentifier = "ContentTypeCellReuseIdentifier"
private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseImageCellReuseIdentifier = "CaseImageCellReuseIdentifier"

private let postTextCellReuseIdentifier = "PostTextCellReuseIdentifier"
private let postImageCellReuseIdentifier = "PostImageCellReuseIdentifier"

private let emptyBookmarkCellCaseReuseIdentifier = "EmptyBookmarkCellCaseReuseIdentifier"

class BookmarksViewController: UIViewController {
    
    var lastCaseSnapshot: QueryDocumentSnapshot?
    var lastPostSnapshot: QueryDocumentSnapshot?
    
    enum CategoriesType: String, CaseIterable {
        case cases = "Cases"
        case posts = "Posts"
        
        var index: Int {
            switch self {
            case .cases:
                return 0
            case .posts:
                return 1
            }
        }
    }
    
    private var selectedCategory: CategoriesType = .cases
    
    private var caseLoaded = false
    private var postLoaded = false
    
    private var cases = [Case]()
    private var caseUsers = [User]()
    
    private var posts = [Post]()
    private var postUsers = [User]()
    
    private let categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 100, height: 30)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.bounces = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    private let contentCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .leastNonzeroMagnitude)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        //collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = true
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        configureCollectionViews()
        fetchBookmarkedClinicalCases()
    }
    
    private func fetchBookmarkedClinicalCases() {
        CaseService.fetchBookmarkedCaseDocuments(lastSnapshot: nil) { snapshot in
            if snapshot.isEmpty {
                self.caseLoaded = true
                self.contentCollectionView.reloadData()
                return
            }
            
            CaseService.fetchCases(snapshot: snapshot) { clinicalCases in
                self.lastCaseSnapshot = snapshot.documents.last
                self.cases = clinicalCases
                let ownerUids = clinicalCases.filter({ $0.privacyOptions == .visible }).map({ $0.ownerUid })
                UserService.fetchUsers(withUids: ownerUids) { users in
                    self.caseUsers = users
                    self.caseLoaded = true
                    self.contentCollectionView.reloadData()
                }
            }
        }
    }
    
    private func fetchBookmarkedPosts() {
        PostService.fetchBookmarkedPostDocuments(lastSnapshot: nil) { snapshot in
            if snapshot.isEmpty {
                self.postLoaded = true
                self.contentCollectionView.reloadData()
                return
            }
            
            PostService.fetchHomePosts(snapshot: snapshot) { posts in
                self.lastPostSnapshot = snapshot.documents.last
                self.posts = posts
                let ownerUids = posts.map({ $0.ownerUid })
                UserService.fetchUsers(withUids: ownerUids) { users in
                    self.postLoaded = true
                    self.postUsers = users
                    self.contentCollectionView.reloadData()
                }
            }
        }
    }
    
    private func configureNavigationBar() {
        title = "Bookmarks"
    }
    
    private func configureCollectionViews() {
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
        contentCollectionView.delegate = self
        contentCollectionView.dataSource = self
        
        categoriesCollectionView.register(BookmarkCategoriesCell.self, forCellWithReuseIdentifier: categoriesCellReuseIdentifier)
        
        contentCollectionView.register(BookmarksCaseCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        contentCollectionView.register(BookmarksCaseImageCell.self, forCellWithReuseIdentifier: caseImageCellReuseIdentifier)
        contentCollectionView.register(BookmarkPostCell.self, forCellWithReuseIdentifier: postTextCellReuseIdentifier)
        contentCollectionView.register(BookmarksPostImageCell.self, forCellWithReuseIdentifier: postImageCellReuseIdentifier)
        contentCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        contentCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyBookmarkCellCaseReuseIdentifier)
        
        view.addSubviews(categoriesCollectionView, separatorView, contentCollectionView)
       
        if let tabControllerShadowColor = UITabBarController().tabBar.standardAppearance.shadowColor {
            separatorView.backgroundColor = tabControllerShadowColor
        }
        /*
         if let tab = tabBarController as? MainTabController {
             separatorView.layer.borderColor = tab.tabBar.standardAppearance.shadowColor?.cgColor
         }
        */
        NSLayoutConstraint.activate([
            categoriesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: 40),
            
            separatorView.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            contentCollectionView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            contentCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreBookmarksContent()
        }
    }
    
    private func getMoreBookmarksContent() {
        switch selectedCategory {
        case .cases:
            CaseService.fetchBookmarkedCaseDocuments(lastSnapshot: lastCaseSnapshot) { snapshot in
                guard !snapshot.isEmpty else { return }
                CaseService.fetchCases(snapshot: snapshot) { newClinicalCases in
                    self.lastCaseSnapshot = snapshot.documents.last
                    self.cases.append(contentsOf: newClinicalCases)
                    let newOwnerUids = newClinicalCases.filter({ $0.privacyOptions == .visible }).map({ $0.ownerUid })
                    UserService.fetchUsers(withUids: newOwnerUids) { newUsers in
                        self.caseUsers.append(contentsOf: newUsers)
                        self.contentCollectionView.reloadData()
                    }
                }
            }
        case .posts:
            PostService.fetchBookmarkedPostDocuments(lastSnapshot: lastPostSnapshot) { snapshot in
                guard !snapshot.isEmpty else { return }
                PostService.fetchHomePosts(snapshot: snapshot) { newPosts in
                    self.lastPostSnapshot = snapshot.documents.last
                    self.posts.append(contentsOf: newPosts)
                    let newOwnerUids = newPosts.map({ $0.ownerUid })
                    UserService.fetchUsers(withUids: newOwnerUids) { newUsers in
                        self.postUsers.append(contentsOf: newUsers)
                        self.contentCollectionView.reloadData()
                    }
                }
            }
        }
    }
}

extension BookmarksViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoriesCollectionView {
            return CategoriesType.allCases.count
        } else {
            switch selectedCategory {
            case .cases:
                return caseLoaded ? (cases.count > 0 ? cases.count : 1) : 0
            case .posts:
                return postLoaded ? (posts.count > 0 ? posts.count : 1) : 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == categoriesCollectionView {
            return CGSize.zero
        } else {
            switch selectedCategory {
            case .cases:
                return caseLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 65)
            case .posts:
                return postLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 65)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoriesCollectionView {
            let cell = categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: categoriesCellReuseIdentifier, for: indexPath) as! BookmarkCategoriesCell
            cell.set(category: CategoriesType.allCases[indexPath.row].rawValue)
            if indexPath.row == 0 {
                categoriesCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
            }
            return cell
        } else {
            switch selectedCategory {
            case .cases:
                if cases.count == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyBookmarkCellCaseReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                    cell.configure(image: UIImage(named: "content.empty"), title: "No saved cases yet.", description: "Cases you save will show up here.", buttonText: EmptyCellButtonOptions.dismiss)
                    cell.delegate = self
                    return cell
                }

                if cases[indexPath.row].type == .text {
                    let cell = contentCollectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! BookmarksCaseCell

                    cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                    guard cases[indexPath.row].privacyOptions == .visible else { return cell }
                    
                    let userIndex = caseUsers.firstIndex { user in
                        if user.uid == cases[indexPath.row].ownerUid {
                            return true
                        }
                        return false
                    }
                    
                    if let userIndex = userIndex {
                        cell.set(user: caseUsers[userIndex])
                    }
                    
                    return cell
                } else {
                    
                    let cell = contentCollectionView.dequeueReusableCell(withReuseIdentifier: caseImageCellReuseIdentifier, for: indexPath) as! BookmarksCaseImageCell

                    cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                    guard cases[indexPath.row].privacyOptions == .visible else { return cell }
                    let userIndex = caseUsers.firstIndex { user in
                        if user.uid == cases[indexPath.row].ownerUid {
                            return true
                        }
                        return false
                    }
                    
                    if let userIndex = userIndex {
                        cell.set(user: caseUsers[userIndex])
                    }
                    
                    return cell
                }
            case .posts:
                if posts.count == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyBookmarkCellCaseReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                    cell.configure(image: UIImage(named: "content.empty"), title: "No saved posts yet.", description: "Posts you save will show up here.", buttonText: EmptyCellButtonOptions.dismiss)
                    cell.delegate = self
                    return cell
                }
                
                if posts[indexPath.row].type.postType == 0 {
                    let cell = contentCollectionView.dequeueReusableCell(withReuseIdentifier: postTextCellReuseIdentifier, for: indexPath) as! BookmarkPostCell
                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    
                    
                    let userIndex = postUsers.firstIndex { user in
                        if user.uid == posts[indexPath.row].ownerUid {
                            return true
                        }
                        return false
                    }
                    
                    if let userIndex = userIndex {
                        cell.set(user: postUsers[userIndex])
                    }
                    
                    return cell
                    
                } else {
                    let cell = contentCollectionView.dequeueReusableCell(withReuseIdentifier: postImageCellReuseIdentifier, for: indexPath) as! BookmarksPostImageCell

                    cell.viewModel = PostViewModel(post: posts[indexPath.row])
                    
                    let userIndex = postUsers.firstIndex { user in
                        if user.uid == posts[indexPath.row].ownerUid {
                            return true
                        }
                        return false
                    }
                    
                    if let userIndex = userIndex {
                        cell.set(user: postUsers[userIndex])
                    }
                    
                    return cell
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoriesCollectionView {

            let currentIndexSelected = selectedCategory.index
            selectedCategory = CategoriesType.allCases[indexPath.row]
            
            guard selectedCategory.index != currentIndexSelected else { return }
            
            switch selectedCategory {
            case .cases:
                contentCollectionView.reloadData()
                return
            case .posts:
                contentCollectionView.reloadData()
                fetchBookmarkedPosts()
            }
        } else {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            switch selectedCategory {
            case .cases:
                let userIndex = caseUsers.firstIndex { user in
                    if user.uid == cases[indexPath.row].ownerUid {
                        return true
                    }
                    return false
                }
                
                if let userIndex = userIndex {
                    if let _ = cases[indexPath.row].groupId {
                        let controller = DetailsCaseViewController(clinicalCase: cases[indexPath.row], user: caseUsers[userIndex], type: .group, collectionViewFlowLayout: layout)
                        controller.delegate = self
                        navigationController?.pushViewController(controller, animated: true)
                    } else {
                        let controller = DetailsCaseViewController(clinicalCase: cases[indexPath.row], user: caseUsers[userIndex], type: .regular, collectionViewFlowLayout: layout)
                        controller.delegate = self
                        navigationController?.pushViewController(controller, animated: true)
                    }
                   
                }
            case .posts:
                let userIndex = postUsers.firstIndex { user in
                    if user.uid == posts[indexPath.row].ownerUid {
                        return true
                    }
                    return false
                }
                
                if let userIndex = userIndex {
                    if let _ = posts[indexPath.row].groupId {
                        let controller = DetailsPostViewController(post: posts[indexPath.row], user: postUsers[userIndex], type: .group, collectionViewLayout: layout)
                        controller.delegate = self
                        navigationController?.pushViewController(controller, animated: true)
                    } else {
                        let controller = DetailsPostViewController(post: posts[indexPath.row], user: postUsers[userIndex], type: .regular, collectionViewLayout: layout)
                        controller.delegate = self
                        navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }
        }
    }
}

extension BookmarksViewController: MESecondaryEmptyCellDelegate {
    func didTapEmptyCellButton(option: EmptyCellButtonOptions) {
        navigationController?.popViewController(animated: true)
    }
}

extension BookmarksViewController: DetailsPostViewControllerDelegate {
    func didDeleteComment(forPost post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            let cell = contentCollectionView.cellForItem(at: IndexPath(item: postIndex, section: 0))
            switch cell {
            case is BookmarkPostCell:
                let currentCell = cell as! BookmarkPostCell
                currentCell.viewModel?.post.numberOfComments -= 1
                posts[postIndex].numberOfComments = post.numberOfComments
            case is BookmarksPostImageCell:
                let currentCell = cell as! BookmarksPostImageCell
                currentCell.viewModel?.post.numberOfComments -= 1
                posts[postIndex].numberOfComments = post.numberOfComments
            default:
                return
            }
        }
    }
    
    func didEditPost(forPost post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            posts[postIndex].postText = post.postText
            posts[postIndex].edited = true
            contentCollectionView.reloadData()
        }
    }
    
    func didTapLikeAction(forPost post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            let cell = contentCollectionView.cellForItem(at: IndexPath(item: postIndex, section: 0))
            switch cell {
            case is BookmarkPostCell:
                let currentCell = cell as! BookmarkPostCell
                currentCell.viewModel?.post.didLike.toggle()
                if post.didLike {
                    currentCell.viewModel?.post.likes = post.likes - 1
                    posts[postIndex].didLike = false
                    posts[postIndex].likes -= 1
                } else {
                    currentCell.viewModel?.post.likes = post.likes + 1
                    posts[postIndex].didLike = true
                    posts[postIndex].likes += 1
                }
            case is BookmarksPostImageCell:
                let currentCell = cell as! BookmarksPostImageCell
                currentCell.viewModel?.post.didLike.toggle()
                if post.didLike {
                    currentCell.viewModel?.post.likes = post.likes - 1
                    posts[postIndex].didLike = false
                    posts[postIndex].likes -= 1
                } else {
                    currentCell.viewModel?.post.likes = post.likes + 1
                    posts[postIndex].didLike = true
                    posts[postIndex].likes += 1
                }
                
            default:
                return
            }
        }
    }
    
    func didTapBookmarkAction(forPost post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            contentCollectionView.performBatchUpdates {
                posts.remove(at: postIndex)
                contentCollectionView.deleteItems(at: [IndexPath(item: postIndex, section: 0)])
            }
        }
    }
    
    func didComment(forPost post: Post) {
        if let postIndex = posts.firstIndex(where: { $0.postId == post.postId }) {
            let cell = contentCollectionView.cellForItem(at: IndexPath(item: postIndex, section: 0))
            switch cell {
            case is BookmarkPostCell:
                let currentCell = cell as! BookmarkPostCell
                currentCell.viewModel?.post.numberOfComments += 1
                posts[postIndex].numberOfComments = post.numberOfComments
            case is BookmarksPostImageCell:
                let currentCell = cell as! BookmarksPostImageCell
                currentCell.viewModel?.post.numberOfComments += 1
                posts[postIndex].numberOfComments = post.numberOfComments
            default:
                return
            }
        }
    }
}

extension BookmarksViewController: DetailsCaseViewControllerDelegate {
    func didDeleteComment(forCase clinicalCase: Case) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            let cell = contentCollectionView.cellForItem(at: IndexPath(item: caseIndex, section: 0))
            switch cell {
            case is BookmarkPostCell:
                let currentCell = cell as! BookmarksCaseCell
                currentCell.viewModel?.clinicalCase.numberOfComments -= 1
                cases[caseIndex].numberOfComments = clinicalCase.numberOfComments
            case is BookmarksPostImageCell:
                let currentCell = cell as! BookmarksCaseImageCell
                currentCell.viewModel?.clinicalCase.numberOfComments -= 1
                cases[caseIndex].numberOfComments = clinicalCase.numberOfComments
            default:
                return
            }
        }
    }
    
    func didTapLikeAction(forCase clinicalCase: Case) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            let cell = contentCollectionView.cellForItem(at: IndexPath(item: caseIndex, section: 0))
            switch cell {
            case is BookmarksCaseCell:
                let currentCell = cell as! BookmarksCaseCell
                if clinicalCase.didLike {
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes - 1
                    cases[caseIndex].didLike = false
                    cases[caseIndex].likes -= 1
                } else {
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes + 1
                    cases[caseIndex].didLike = true
                    cases[caseIndex].likes += 1
                }
            case is BookmarksCaseImageCell:
                let currentCell = cell as! BookmarksCaseImageCell
                if clinicalCase.didLike {
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes - 1
                    cases[caseIndex].didLike = false
                    cases[caseIndex].likes -= 1
                } else {
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes + 1
                    cases[caseIndex].didLike = true
                    cases[caseIndex].likes += 1
                }
            default:
                return
            }
        }
    }
    
    func didTapBookmarkAction(forCase clinicalCase: Case) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            contentCollectionView.performBatchUpdates {
                cases.remove(at: caseIndex)
                contentCollectionView.deleteItems(at: [IndexPath(item: caseIndex, section: 0)])
            }
        }
    }
    
    func didComment(forCase clinicalCase: Case) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            let cell = contentCollectionView.cellForItem(at: IndexPath(item: caseIndex, section: 0))
            switch cell {
            case is BookmarkPostCell:
                let currentCell = cell as! BookmarksCaseCell
                currentCell.viewModel?.clinicalCase.numberOfComments += 1
                cases[caseIndex].numberOfComments = clinicalCase.numberOfComments
            case is BookmarksPostImageCell:
                let currentCell = cell as! BookmarksCaseImageCell
                currentCell.viewModel?.clinicalCase.numberOfComments += 1
                cases[caseIndex].numberOfComments = clinicalCase.numberOfComments
            default:
                return
            }
        }
    }
    
    func didAddUpdate(forCase clinicalCase: Case) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            cases[caseIndex].caseUpdates = clinicalCase.caseUpdates
            contentCollectionView.reloadData()
        }
    }
    
    func didAddDiagnosis(forCase clinicalCase: Case) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            cases[caseIndex].diagnosis = clinicalCase.diagnosis
            contentCollectionView.reloadData()
        }
    }
}
