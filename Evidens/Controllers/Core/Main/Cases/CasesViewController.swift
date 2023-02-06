//
//  CasesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/9/22.
//

import UIKit
import Firebase
import MessageUI

private let loadingHeaderCellReuseIdentifier = "LoadingHeaderCellReuseIdentifier"
private let exploreHeaderCellReuseIdentifier = "ExploreHeaderCellReuseIdentifier"
private let separatorCellReuseIdentifier = "SeparatorCellReuseIdentifier"
private let exploreCellReuseIdentifier = "ExploreCellReuseIdentifier"
private let filterCellReuseIdentifier = "FilterCellReuseIdentifier"
private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"
private let caseSkeletonCellReuseIdentifier = "CaseSkeletonCellReuseIdentifier"

class CasesViewController: NavigationBarViewController, UINavigationControllerDelegate {
    var users = [User]()
    private var cases = [Case]()
    
    private var casesLoaded = false
    
    var displaysExploringWindow = false
    var displaysFilteredWindow = false
    
    private var displayState: DisplayState = .none
    
    var casesLastSnapshot: QueryDocumentSnapshot?
    
    private var zoomTransitioning = ZoomTransitioning()
    var selectedImage: UIImageView!
    
    private var casesCollectionView: UICollectionView!
    
    private var magicalValue: CGFloat = 0
    
    private let exploreCasesToolbar: ExploreCasesToolbar = {
        let toolbar = ExploreCasesToolbar(frame: .zero)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    enum filterCategories: String, CaseIterable {
        case all = "All"
        case recents = "Recently uploaded"
    }
    
    private var indexSelected: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFirstGroupOfCases()
        configureCollectionView()
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        casesCollectionView.refreshControl = refresher
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self

        if !casesLoaded {
            casesCollectionView.reloadData()
        }
    }
    
    private func fetchFirstGroupOfCases() {
        if displaysFilteredWindow {
            
            CaseService.fetchCasesWithProfession(lastSnapshot: nil, profession: navigationItem.title!) { snapshot in
                self.casesLastSnapshot = snapshot.documents.last
                self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                self.checkIfUserLikedCase()
                self.checkIfUserBookmarkedCase()
                self.casesCollectionView.refreshControl?.endRefreshing()
                self.cases.forEach { clinicalCase in
                    UserService.fetchUser(withUid: clinicalCase.ownerUid) { user in
                        self.users.append(user)
                        self.casesLoaded = true
                        self.casesCollectionView.reloadData()
                    }
                }
            }
        } else if displaysExploringWindow {
            #warning("Need to find a way to get the trending")
            CaseService.fetchClinicalCases(lastSnapshot: nil) { snapshot in
                self.casesLastSnapshot = snapshot.documents.last
                self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                self.checkIfUserLikedCase()
                self.checkIfUserBookmarkedCase()
                self.casesCollectionView.refreshControl?.endRefreshing()
                self.cases.forEach { clinicalCase in
                    UserService.fetchUser(withUid: clinicalCase.ownerUid) { user in
                        self.users.append(user)
                        self.casesLoaded = true
                        self.casesCollectionView.reloadData()
                    }
                }
            }
        } else {
            // Main cases view
            CaseService.fetchClinicalCases(lastSnapshot: nil) { snapshot in
                self.casesLastSnapshot = snapshot.documents.last
                self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                self.checkIfUserLikedCase()
                self.checkIfUserBookmarkedCase()
                self.casesCollectionView.refreshControl?.endRefreshing()
                self.cases.forEach { clinicalCase in
                    UserService.fetchUser(withUid: clinicalCase.ownerUid) { user in
                        self.users.append(user)
                        self.casesLoaded = true
                        self.casesCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    
    func checkIfUserLikedCase() {
        self.cases.forEach { clinicalCase in
            //Check if user did like
            CaseService.checkIfUserLikedCase(clinicalCase: clinicalCase) { didLike in
                //Check the postId of the current post looping
                if let index = self.cases.firstIndex(where: {$0.caseId == clinicalCase.caseId}) {
                    //Change the didLike according if user did like post
                    self.cases[index].didLike = didLike
                    self.casesCollectionView.reloadData()
                }
            }
        }
    }
    
    func checkIfUserBookmarkedCase() {
        self.cases.forEach { clinicalCase in
            CaseService.checkIfUserBookmarkedCase(clinicalCase: clinicalCase) { didBookmark in
                if let index = self.cases.firstIndex(where: { $0.caseId == clinicalCase.caseId}) {
                    self.cases[index].didBookmark = didBookmark
                    self.casesCollectionView.reloadData()

                }
            }
        }
    }
    
    private func createTwoColumnFlowLayout() -> UICollectionViewFlowLayout {
            let width = view.bounds.width
            let padding: CGFloat = 10
            let minimumItemSpacing: CGFloat = 10
            let availableWidth = width - (padding * 2) - minimumItemSpacing
            let itemWidth = availableWidth / 2
            
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.sectionInset = UIEdgeInsets(top: 10, left: padding, bottom: padding, right: padding)
            flowLayout.itemSize = CGSize(width: itemWidth, height: 350)
            
            return flowLayout
        }
    
    private func configureCollectionView() {
        casesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createTwoColumnFlowLayout())
        casesCollectionView.translatesAutoresizingMaskIntoConstraints = false

        if displaysExploringWindow || displaysFilteredWindow {
            view.addSubviews(casesCollectionView)
            casesCollectionView.frame = view.bounds
            
        } else {
            view.addSubviews(casesCollectionView, exploreCasesToolbar)
            NSLayoutConstraint.activate([
                exploreCasesToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                exploreCasesToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                exploreCasesToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                exploreCasesToolbar.heightAnchor.constraint(equalToConstant: 50),
              
                casesCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
                casesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                casesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                casesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            exploreCasesToolbar.delegate = self
            exploreCasesToolbar.exploreDelegate = self
            let appearance = UIToolbarAppearance()
            appearance.configureWithOpaqueBackground()
            exploreCasesToolbar.scrollEdgeAppearance = appearance
            exploreCasesToolbar.standardAppearance = appearance
            casesCollectionView.contentInset.top = 50
            casesCollectionView.scrollIndicatorInsets = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        }
        
        casesCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderCellReuseIdentifier)
        casesCollectionView.register(CasesFeedCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        casesCollectionView.register(ExploreHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: exploreHeaderCellReuseIdentifier)

        casesCollectionView.delegate = self
        casesCollectionView.dataSource = self
        
    }
    
    @objc func handleRefresh() {
        HapticsManager.shared.vibrate(for: .success)
        fetchFirstGroupOfCases()
    }
}

extension CasesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return casesLoaded ? cases.count : 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if casesLoaded {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: exploreHeaderCellReuseIdentifier, for: indexPath) as! ExploreHeaderCell
            header.delegate = self
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderCellReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if casesLoaded {
            return displaysExploringWindow ? CGSize(width: view.frame.width, height: 350) : CGSize.zero
        } else {
            return CGSize(width: view.frame.width, height: 55)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CasesFeedCell
        cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
        let userIndex = users.firstIndex { user in
            if user.uid == cases[indexPath.row].ownerUid {
                return true
            }
            return false
        }
        
        if let userIndex = userIndex {
            cell.set(user: users[userIndex])
        }
        
        cell.delegate = self
        return cell
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

extension CasesViewController: ExploreCasesToolbarDelegate {
    func wantsToSeeCategory(category: Case.FilterCategories) {
        switch category {
        case .explore:
            self.navigationController?.delegate = self
            let controller = CasesViewController()
            controller.controllerIsBeeingPushed = true
            controller.displaysExploringWindow = true
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            controller.title = category.rawValue
            
            navigationController?.pushViewController(controller, animated: true)
            
        case .all:
            indexSelected = 1
            CaseService.fetchClinicalCases(lastSnapshot: nil) { snapshot in
                self.casesLastSnapshot = snapshot.documents.last
                self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                self.checkIfUserLikedCase()
                self.checkIfUserBookmarkedCase()
                self.casesCollectionView.refreshControl?.endRefreshing()
                self.cases.forEach { clinicalCase in
                    UserService.fetchUser(withUid: clinicalCase.ownerUid) { user in
                        self.users.append(user)
                        self.casesLoaded = true
                        self.casesCollectionView.reloadData()
                    }
                }
            }

        case .recents:
            indexSelected = 2
            CaseService.fetchLastUploadedClinicalCases(lastSnapshot: nil) { snapshot in
                self.casesLastSnapshot = snapshot.documents.last
                self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                self.checkIfUserLikedCase()
                self.checkIfUserBookmarkedCase()
                self.casesCollectionView.refreshControl?.endRefreshing()
                self.cases.forEach { clinicalCase in
                    UserService.fetchUser(withUid: clinicalCase.ownerUid) { user in
                        self.users.append(user)
                        self.casesLoaded = true
                        self.casesCollectionView.reloadData()
                    }
                }
            }
        }
    }
}


extension CasesViewController: CaseCellDelegate {
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: Case.CaseMenuOptions) {
        switch option {
        case .delete:
            break
        case .update:
            let index = cases.firstIndex { homeCase in
                if homeCase.caseId == clinicalCase.caseId {
                    return true
                }
                return false
            }
            
            if let index = index {
                cases[index].caseUpdates = clinicalCase.caseUpdates
                casesCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        case .solved:
            let index = cases.firstIndex { homeCase in
                if homeCase.caseId == clinicalCase.caseId {
                    return true
                }
                return false
            }
            
            if let index = index {
                cases[index].stage = .resolved
                cases[index].diagnosis = clinicalCase.diagnosis
                casesCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        case .edit:
            let index = cases.firstIndex { homeCase in
                if homeCase.caseId == clinicalCase.caseId {
                    return true
                }
                return false
            }
            
            if let index = index {
                cases[index].stage = .resolved
                cases[index].diagnosis = clinicalCase.diagnosis
                casesCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        case .report:
            break
        }
    }
    
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User) {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, collectionViewFlowLayout: layout)
        controller.delegate = self
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        guard image != [] else { return }
        self.navigationController?.delegate = zoomTransitioning
        let map: [UIImage] = image.compactMap { $0.image }
        selectedImage = image[index]
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        //controller.customDelegate = self

        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .clear
        navigationItem.backBarButtonItem = backItem

        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) {
        return
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didPressThreeDotsFor clinicalCase: Case) {
        return
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }


    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) {
        guard let indexPath = casesCollectionView.indexPath(for: cell) else { return }
        HapticsManager.shared.vibrate(for: .success)
        
        switch cell {
        case is CasesFeedCell:
            let currentCell = cell as! CasesFeedCell
            
            currentCell.viewModel?.clinicalCase.didBookmark.toggle()
            
            if clinicalCase.didBookmark {
                CaseService.unbookmarkCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks - 1
                    self.cases[indexPath.row].didBookmark = false
                }
            } else {
                CaseService.bookmarkCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks + 1
                    self.cases[indexPath.row].didBookmark = true
                }
            }

        default:
            break
        }
        
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        guard let indexPath = casesCollectionView.indexPath(for: cell) else { return }
        
        HapticsManager.shared.vibrate(for: .success)
        
        switch cell {
        case is CasesFeedCell:
            let currentCell = cell as! CasesFeedCell
            
            currentCell.viewModel?.clinicalCase.didLike.toggle()
            
            if clinicalCase.didLike {
                //Unlike post here
                CaseService.unlikeCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes - 1
                    self.cases[indexPath.row].didLike = false
                    self.cases[indexPath.row].likes -= 1
                }
            } else {
                //Like post here
                CaseService.likeCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes + 1
                    self.cases[indexPath.row].didLike = true
                    self.cases[indexPath.row].likes += 1
                    NotificationService.uploadNotification(toUid: clinicalCase.ownerUid, fromUser: user, type: .likeCase, clinicalCase: clinicalCase)
                }
            }
            
        default:
            break
        }
    }
    
    func scrollCollectionViewToTop() {
        casesCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) {
        return
    }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) {
        return
    }
}

extension CasesViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return selectedImage
    }
}

extension CasesViewController {
    func getMoreCases() {
        if displaysFilteredWindow {
            CaseService.fetchCasesWithProfession(lastSnapshot: casesLastSnapshot, profession: navigationItem.title!) { snapshot in
                self.casesLastSnapshot = snapshot.documents.last
                let documents = snapshot.documents
                let newCases = documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                self.cases.append(contentsOf: newCases)
                self.checkIfUserLikedCase()
                self.checkIfUserBookmarkedCase()
                
                newCases.forEach { clinicalCase in
                    UserService.fetchUser(withUid: clinicalCase.ownerUid) { user in
                        self.users.append(user)
                        self.casesCollectionView.reloadData()
                    }
                }
            }
            #warning("Need to put an else if with DisplaysExploreWidnow to show trending")
        } else {
            
            if indexSelected == 1 {
                CaseService.fetchClinicalCases(lastSnapshot: casesLastSnapshot) { snapshot in
                    self.casesLastSnapshot = snapshot.documents.last
                    let documents = snapshot.documents
                    let newCases = documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                    self.cases.append(contentsOf: newCases)
                    self.checkIfUserLikedCase()
                    self.checkIfUserBookmarkedCase()
                    
                    newCases.forEach { clinicalCase in
                        UserService.fetchUser(withUid: clinicalCase.ownerUid) { user in
                            self.users.append(user)
                            self.casesCollectionView.reloadData()
                        }
                    }
                }
            }
            
            if indexSelected == 2 {
                // Recently uploaded
                CaseService.fetchLastUploadedClinicalCases(lastSnapshot: casesLastSnapshot) { snapshot in
                    self.casesLastSnapshot = snapshot.documents.last
                    let documents = snapshot.documents
                    let newCases = documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                    self.cases.append(contentsOf: newCases)
                    self.checkIfUserLikedCase()
                    self.checkIfUserBookmarkedCase()
                    
                    newCases.forEach { clinicalCase in
                        UserService.fetchUser(withUid: clinicalCase.ownerUid) { user in
                            self.users.append(user)
                            self.casesCollectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
        
}

extension CasesViewController: ExploreHeaderCellDelegate {
    func didTapExploreCell(forProfession profession: String) {
        self.navigationController?.delegate = self
        let controller = CasesViewController()
        controller.controllerIsBeeingPushed = true
        controller.displaysFilteredWindow = true
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        controller.title = profession
        //backItem.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 18)], for: .normal)
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension CasesViewController: DetailsCaseViewControllerDelegate {
    func didComment(forCase clinicalCase: Case) {
        return
    }
    
    func didTapLikeAction(forCase clinicalCase: Case) {
        let index = cases.firstIndex { homeCase in
            if homeCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = index {
            if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
                self.clinicalCase(cell, didLike: clinicalCase)
            }
        }
    }
    
    func didTapBookmarkAction(forCase clinicalCase: Case) {
        let index = cases.firstIndex { homeCase in
            if homeCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = index {
            if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
                self.clinicalCase(cell, didBookmark: clinicalCase)
            }
        }
    }
    
    func didAddUpdate(forCase clinicalCase: Case) {
        let index = cases.firstIndex { homeCase in
            if homeCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = index {
            cases[index].caseUpdates = clinicalCase.caseUpdates
            casesCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func didAddDiagnosis(forCase clinicalCase: Case) {
        let index = cases.firstIndex { homeCase in
            if homeCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = index {
            cases[index].stage = .resolved
            cases[index].diagnosis = clinicalCase.diagnosis
            casesCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
}

extension CasesViewController: UIToolbarDelegate {
   func position(for bar: UIBarPositioning) -> UIBarPosition {
       return .topAttached
    }
}


