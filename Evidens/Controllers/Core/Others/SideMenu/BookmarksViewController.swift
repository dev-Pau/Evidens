//
//  BookmarksViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/9/22.
//

import UIKit
import Firebase

private let categoriesCellReuseIdentifier = "ContentTypeCellReuseIdentifier"
private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseImageCellReuseIdentifier = "CaseImageCellReuseIdentifier"

private let postTextCellReuseIdentifier = "PostTextCellReuseIdentifier"
private let postImageCellReuseIdentifier = "PostImageCellReuseIdentifier"

private let skeletonCaseImageCell = "SkeletonCaseImageCell"
private let skeletonCaseTextCell = "SkeletonCaseTextCell"

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

    private var selectedCategory: Int = 0
    
    private var caseLoaded = false
    private var postLoaded = false
    
    private var cases = [Case]()
    
    private var caseUsers = [User]()

    private var postUsers = [User]()

    private var posts = [Post]()
    
    private let categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 100, height: 40)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
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
        layout.minimumLineSpacing = 10
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 150)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = lightColor
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = lightColor
        configureNavigationBar()
        configureCollectionViews()
        fetchBookmarkedClinicalCases()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if selectedCategory == 0 {

            if cases.count == 1 {
                caseLoaded = false
                cases.removeAll()
                fetchBookmarkedClinicalCases()
            }

        } else {
            if posts.count == 1 {
                postLoaded = false
                posts.removeAll()
                fetchBookmarkedPosts()
            }
        }
        contentCollectionView.reloadData()
    }
    
    private func fetchBookmarkedClinicalCases() {
        CaseService.fetchBookmarkedCaseDocuments(lastSnapshot: nil) { snapshot in
            if snapshot.count == 0 {
                self.caseLoaded = true
                self.contentCollectionView.isScrollEnabled = true
                self.contentCollectionView.reloadData()
                return
            }

            CaseService.fetchBookmarkedCases(snapshot: snapshot) { clinicalCases in
                self.lastCaseSnapshot = snapshot.documents.last
                self.cases = clinicalCases
                
                clinicalCases.forEach { clinicalCaseFetched in
                    UserService.fetchUser(withUid: clinicalCaseFetched.ownerUid) { user in
                        self.caseLoaded = true
                        self.caseUsers.append(user)
                        self.contentCollectionView.isScrollEnabled = true
                        self.contentCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    private func fetchBookmarkedPosts() {
        PostService.fetchBookmarkedPostDocuments(lastSnapshot: nil) { snapshot in
            if snapshot.count == 0 {
                self.postLoaded = true
                self.contentCollectionView.isScrollEnabled = true
                self.contentCollectionView.reloadData()
                return
            }
            
            PostService.fetchBookmarkedPosts(snapshot: snapshot) { posts in
                self.lastPostSnapshot = snapshot.documents.last
                self.posts = posts
                
                posts.forEach { postFetched in
                    UserService.fetchUser(withUid: postFetched.ownerUid) { user in
                        self.postLoaded = true
                        self.postUsers.append(user)
                        self.contentCollectionView.isScrollEnabled = true
                        self.contentCollectionView.reloadData()
                    }
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
        contentCollectionView.register(SekeletonCaseBookmarksImageTextCell.self, forCellWithReuseIdentifier: skeletonCaseImageCell)
        contentCollectionView.register(SekeletonCaseBookmarksTextCell.self, forCellWithReuseIdentifier: skeletonCaseTextCell)
        
        contentCollectionView.register(EmptyBookmarkCell.self, forCellWithReuseIdentifier: emptyBookmarkCellCaseReuseIdentifier)
        
        view.addSubviews(categoriesCollectionView, contentCollectionView)
        
        NSLayoutConstraint.activate([
            categoriesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: 50),
        
            contentCollectionView.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor, constant: 1),
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
            getMoreCases()
        }
    }
}

extension BookmarksViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoriesCollectionView {
            return CategoriesType.allCases.count
        } else {
            if selectedCategory == 0 {
                return caseLoaded ? (cases.count > 0 ? cases.count : 1) : 10

            } else {
                return postLoaded ? (posts.count > 0 ? posts.count : 1) : 10
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
            if selectedCategory == 0 {
                // Cases
                if !caseLoaded {
                    if indexPath.row == 0 {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: skeletonCaseImageCell, for: indexPath) as! SekeletonCaseBookmarksImageTextCell
                        return cell
                    } else {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: skeletonCaseTextCell, for: indexPath) as! SekeletonCaseBookmarksTextCell
                        return cell
                    }
                }
                
                if cases.count == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyBookmarkCellCaseReuseIdentifier, for: indexPath) as! EmptyBookmarkCell
                    cell.set(title: "No saved cases yet", description: "Cases you save will show up here.")
                    return cell
                }

                if cases[indexPath.row].type == .text {
                    let cell = contentCollectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! BookmarksCaseCell

                    cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                    
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
            } else {
                
                if !postLoaded {
                    if indexPath.row == 0 {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: skeletonCaseImageCell, for: indexPath) as! SekeletonCaseBookmarksImageTextCell
                        return cell
                    } else {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: skeletonCaseTextCell, for: indexPath) as! SekeletonCaseBookmarksTextCell
                        return cell
                    }
                }
                
                if posts.count == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyBookmarkCellCaseReuseIdentifier, for: indexPath) as! EmptyBookmarkCell
                    cell.set(title: "No saved posts yet", description: "Posts you save will show up here.")
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
            collectionView.cellForItem(at: indexPath)?.isSelected = true
            selectedCategory = CategoriesType.allCases[indexPath.row].index
            if selectedCategory == 1 && posts.isEmpty {
                fetchBookmarkedPosts()
                contentCollectionView.reloadData()
                return
            }
            contentCollectionView.reloadData()
        } else {
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
         
            if selectedCategory == 0 {
                
                let userIndex = caseUsers.firstIndex { user in
                    if user.uid == cases[indexPath.row].ownerUid {
                        return true
                    }
                    return false
                }
                
                if let userIndex = userIndex {
                    let controller = DetailsCaseViewController(clinicalCase: cases[indexPath.row], user: caseUsers[userIndex], collectionViewFlowLayout: layout)
                    navigationController?.pushViewController(controller, animated: true)
                }
            } else {
                
                let userIndex = postUsers.firstIndex { user in
                    if user.uid == posts[indexPath.row].ownerUid {
                        return true
                    }
                    return false
                }
                
                if let userIndex = userIndex {
                    let controller = DetailsPostViewController(post: posts[indexPath.row], user: postUsers[userIndex], collectionViewLayout: layout)
                    navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
}

extension BookmarksViewController {
    func getMoreCases() {
        if selectedCategory == 0 {
            CaseService.fetchBookmarkedCaseDocuments(lastSnapshot: lastCaseSnapshot) { snapshot in
                CaseService.fetchBookmarkedCases(snapshot: snapshot) { clinicalCases in
                    self.lastCaseSnapshot = snapshot.documents.last
                    self.cases.append(contentsOf: clinicalCases)
                    clinicalCases.forEach { clinicalCaseFetched in
                        UserService.fetchUser(withUid: clinicalCaseFetched.ownerUid) { user in
                            self.caseUsers.append(user)
                        }
                    }
                }
            }
        } else {
            PostService.fetchBookmarkedPostDocuments(lastSnapshot: lastPostSnapshot) { snapshot in
                PostService.fetchBookmarkedPosts(snapshot: snapshot) { posts in
                    self.lastPostSnapshot = snapshot.documents.last
                    self.posts.append(contentsOf: posts)
                    posts.forEach { postFetched in
                        UserService.fetchUser(withUid: postFetched.ownerUid) { user in
                            self.postUsers.append(user)
                        }
                    }
                }
            }
        }
        
    }
}
