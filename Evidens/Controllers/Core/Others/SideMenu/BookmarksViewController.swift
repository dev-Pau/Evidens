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

class BookmarksViewController: UIViewController {
    
    var lastSnapshot: QueryDocumentSnapshot?
    
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
    
    private var cases = [Case]()
    
    private var caseUsers = [User]() {
        didSet {
            contentCollectionView.reloadData()
        }
    }
    private var postUsers = [User]() {
        didSet {
            contentCollectionView.reloadData()
        }
    }
    
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
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .zero)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = lightColor
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private let postsBookmarksView = EmptyBookmarksView(bookmarkTitle: "No saved posts yet", bookmarkDescription: "Posts you save will show up here.")
    private let casesBookmarksView = EmptyBookmarksView(bookmarkTitle: "No saved cases yet", bookmarkDescription: "Cases you save will show up here.")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = lightColor
        configureNavigationBar()
        configureCollectionViews()
        fetchBookmarkedClinicalCases()
    }
    
    private func fetchBookmarkedClinicalCases() {
        CaseService.fetchBookmarkedCaseDocuments(lastSnapshot: nil) { snapshot in
            if snapshot.count == 0 {
                self.contentCollectionView.isHidden = true
                self.casesBookmarksView.isHidden = false
            } else {
                CaseService.fetchBookmarkedCases(snapshot: snapshot) { clinicalCases in
                    self.lastSnapshot = snapshot.documents.last
                    self.cases = clinicalCases
                    clinicalCases.forEach { clinicalCaseFetched in
                        UserService.fetchUser(withUid: clinicalCaseFetched.ownerUid) { user in
                            self.caseUsers.append(user)
                        }
                    }
                }
            }
        }
    }
    
    private func fetchBookmarkedPosts() {
        PostService.fetchBookmarkedPostDocuments(lastSnapshot: nil) { snapshot in
            PostService.fetchBookmarkedPosts(snapshot: snapshot) { posts in
                self.lastSnapshot = snapshot.documents.last
                self.posts = posts
                posts.forEach { postFetched in
                    UserService.fetchUser(withUid: postFetched.ownerUid) { user in
                        self.postUsers.append(user)
                    }
                }
            }
        }
    }
    
    private func configureNavigationBar() {
        title = "Bookmarks"
    }
    
    
    
    private func configureCollectionViews() {
        postsBookmarksView.translatesAutoresizingMaskIntoConstraints = false
        casesBookmarksView.translatesAutoresizingMaskIntoConstraints = false
        postsBookmarksView.isHidden = true
        casesBookmarksView.isHidden = true
        
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
        contentCollectionView.delegate = self
        contentCollectionView.dataSource = self
        
        categoriesCollectionView.register(BookmarkCategoriesCell.self, forCellWithReuseIdentifier: categoriesCellReuseIdentifier)
        
        contentCollectionView.register(BookmarksCaseCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        contentCollectionView.register(BookmarksCaseImageCell.self, forCellWithReuseIdentifier: caseImageCellReuseIdentifier)
        contentCollectionView.register(BookmarkPostCell.self, forCellWithReuseIdentifier: postTextCellReuseIdentifier)
        contentCollectionView.register(BookmarksPostImageCell.self, forCellWithReuseIdentifier: postImageCellReuseIdentifier)
        
        view.addSubviews(categoriesCollectionView, contentCollectionView, postsBookmarksView, casesBookmarksView)
        
        NSLayoutConstraint.activate([
            categoriesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: 50),
        
            contentCollectionView.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor, constant: 1),
            contentCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            postsBookmarksView.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor, constant: 1),
            postsBookmarksView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postsBookmarksView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postsBookmarksView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            casesBookmarksView.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor, constant: 1),
            casesBookmarksView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            casesBookmarksView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            casesBookmarksView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            
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
                return cases.count
            } else {
                return posts.count
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
                lastSnapshot = nil
                fetchBookmarkedPosts()
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
                    #warning("IMPLEMENT DetailsCaseViewController with a user same as DetailsPost")
                    let controller = DetailsCaseViewController(clinicalCase: cases[indexPath.row], collectionViewFlowLayout: layout)
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
            CaseService.fetchBookmarkedCaseDocuments(lastSnapshot: lastSnapshot) { snapshot in
                CaseService.fetchBookmarkedCases(snapshot: snapshot) { clinicalCases in
                    self.lastSnapshot = snapshot.documents.last
                    self.cases.append(contentsOf: clinicalCases)
                    clinicalCases.forEach { clinicalCaseFetched in
                        UserService.fetchUser(withUid: clinicalCaseFetched.ownerUid) { user in
                            self.caseUsers.append(user)
                        }
                    }
                }
            }
        } else {
            PostService.fetchBookmarkedPostDocuments(lastSnapshot: lastSnapshot) { snapshot in
                PostService.fetchBookmarkedPosts(snapshot: snapshot) { posts in
                    self.lastSnapshot = snapshot.documents.last
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
