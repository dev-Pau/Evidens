//
//  DraftsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/9/22.
//

import UIKit
import Firebase

private let categoriesCellReuseIdentifier = "ContentTypeCellReuseIdentifier"
private let postDraftTextReuseIdentifier = "PostDraftTextReuseIdentifier"
private let postDrafImageReuseIdentifier = "postDrafImageReuseIdentifier"

private let postEmptyDraftCell = "PostEmptyDraftCell"

class DraftsViewController: UIViewController {
    
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
    
    private var draftCases = [Case]()
    private var draftPosts = [Post]()
    
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
    
    private let contentTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = lightColor
        tableView.estimatedRowHeight = 74
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = lightColor
        configureNavigationBar()
        configureCollectionViews()
    }
    
    private func fetchDraftClinicalCases() {
        CaseService.fetchDraftCases(lastSnapshot: nil) { snapshot in
            if snapshot.count == 0 {
                self.contentTableView.isHidden = true
            } else {
                self.lastSnapshot = snapshot.documents.last
            }
        }
    }
    
    private func fetchDraftPosts() {
        PostService.fetchDraftPost(lastSnapshot: nil) { snapshot in
            self.lastSnapshot = snapshot.documents.last
            self.draftPosts = snapshot.documents.map({ Post(postId: $0.documentID, dictionary: $0.data() )})
            self.contentTableView.reloadData()
            
        }
    }
    
    private func configureNavigationBar() {
        title = "Drafts"
    }
    
    private func configureCollectionViews() {
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
        contentTableView.delegate = self
        contentTableView.dataSource = self
        
        categoriesCollectionView.register(BookmarkCategoriesCell.self, forCellWithReuseIdentifier: categoriesCellReuseIdentifier)
        
        contentTableView.register(DraftPostCell.self, forCellReuseIdentifier: postDraftTextReuseIdentifier)
        contentTableView.register(DraftPostImageCell.self, forCellReuseIdentifier: postDrafImageReuseIdentifier)
        contentTableView.register(EmptyDraftCell.self, forCellReuseIdentifier: postEmptyDraftCell)
        //contentCollectionView.register(BookmarksCaseCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        //contentCollectionView.register(BookmarksCaseImageCell.self, forCellWithReuseIdentifier: caseImageCellReuseIdentifier)
        //contentCollectionView.register(BookmarkPostCell.self, forCellWithReuseIdentifier: postTextCellReuseIdentifier)
        //contentCollectionView.register(BookmarksPostImageCell.self, forCellWithReuseIdentifier: postImageCellReuseIdentifier)
        
        view.addSubviews(categoriesCollectionView, contentTableView)
        
        NSLayoutConstraint.activate([
            categoriesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: 50),
            
            contentTableView.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor, constant: 1),
            contentTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension DraftsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CategoriesType.allCases.count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: categoriesCellReuseIdentifier, for: indexPath) as! BookmarkCategoriesCell
        cell.set(category: CategoriesType.allCases[indexPath.row].rawValue)
        if indexPath.row == 0 {
            categoriesCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.isSelected = true
        selectedCategory = CategoriesType.allCases[indexPath.row].index
        if selectedCategory == 1 && draftPosts.isEmpty {
            lastSnapshot = nil
            fetchDraftPosts()
            return
        }
        contentTableView.reloadData()
    }
}

extension DraftsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedCategory == 0 {
            return draftCases.count > 0 ? draftCases.count : 1
        } else {
            return draftPosts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedCategory == 0 {
            // Cases
            if draftCases.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: postEmptyDraftCell, for: indexPath) as! EmptyDraftCell
                cell.set(title: "No draft cases yet", description: "Cases you save will show up here.")
                return cell
                
            } else {
                return UITableViewCell()
            }
        } else {
            // Posts
            if draftPosts.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: postEmptyDraftCell, for: indexPath) as! EmptyDraftCell
                cell.set(title: "No draft posts yet", description: "Posts you save will show up here.")
                return cell
            }
            
            if draftPosts[indexPath.row].type == .plainText {
                let cell = tableView.dequeueReusableCell(withIdentifier: postDraftTextReuseIdentifier, for: indexPath) as! DraftPostCell
                cell.viewModel = PostViewModel(post: draftPosts[indexPath.row])
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: postDrafImageReuseIdentifier , for: indexPath) as! DraftPostImageCell
                cell.viewModel = PostViewModel(post: draftPosts[indexPath.row])
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(draftPosts[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
}
