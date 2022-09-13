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

class BookmarksViewController: UIViewController {
    
    var casesLastSnapshot: QueryDocumentSnapshot?
    
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
    
    private var cases = [Case]() {
        didSet { contentCollectionView.reloadData() }
    }
    
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
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 200)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
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
    
    private func fetchBookmarkedClinicalCases() {
        CaseService.fetchBookmarkedCaseDocuments(lastSnapshot: nil) { snapshot in
            CaseService.fetchBookmarkedCases(snapshot: snapshot) { clinicalCases in
                self.casesLastSnapshot = snapshot.documents.last
                self.cases = clinicalCases
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
        
        contentCollectionView.register(UserProfileCaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        contentCollectionView.register(UserProfileCaseImageCell.self, forCellWithReuseIdentifier: caseImageCellReuseIdentifier)
        
        view.addSubviews(categoriesCollectionView, contentCollectionView)
        
        NSLayoutConstraint.activate([
            categoriesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: 50),
            
            contentCollectionView.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor, constant: 10),
            contentCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            print("Get more cases")
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
                return 0
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
                    let cell = contentCollectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! UserProfileCaseTextCell
                    cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                    return cell
                } else {
                    let cell = contentCollectionView.dequeueReusableCell(withReuseIdentifier: caseImageCellReuseIdentifier, for: indexPath) as! UserProfileCaseImageCell
                    cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                    return cell
                }
            } else {
                let cell = contentCollectionView.dequeueReusableCell(withReuseIdentifier: caseImageCellReuseIdentifier, for: indexPath) as! UserProfileCaseImageCell
                cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.isSelected = true
        selectedCategory = CategoriesType.allCases[indexPath.row].index
    }
}

extension BookmarksViewController {
    func getMoreCases() {
        CaseService.fetchBookmarkedCaseDocuments(lastSnapshot: casesLastSnapshot) { snapshot in
            CaseService.fetchBookmarkedCases(snapshot: snapshot) { clinicalCases in
                self.casesLastSnapshot = snapshot.documents.last
                self.cases = clinicalCases
            }
        }
    }
}
