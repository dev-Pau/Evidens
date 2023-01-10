//
//  CasesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/9/22.
//

import UIKit
import Firebase
import MessageUI

private let exploreHeaderCellReuseIdentifier = "ExploreHeaderCellReuseIdentifier"
private let separatorCellReuseIdentifier = "SeparatorCellReuseIdentifier"
private let exploreCellReuseIdentifier = "ExploreCellReuseIdentifier"
private let filterCellReuseIdentifier = "FilterCellReuseIdentifier"
private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"
private let caseSkeletonCellReuseIdentifier = "CaseSkeletonCellReuseIdentifier"

class CasesViewController: NavigationBarViewController, UINavigationControllerDelegate {
    var users = [User]()
    private var cases = [Case]()
    
    var loaded = false
    
    var displaysExploringWindow = false
    var displaysFilteredWindow = false
    
    private var displayState: DisplayState = .none
    
    private var lastIndexPath: IndexPath?
    private var lastFilterSelected: String?
    
    var casesLastSnapshot: QueryDocumentSnapshot?
    
    private var zoomTransitioning = ZoomTransitioning()
    var selectedImage: UIImageView!
    
    private var casesCollectionView: UICollectionView!
    
    private var filterCollectionView: UICollectionView!
    
    enum filterCategories: String, CaseIterable {
        case all = "All"
        case recents = "Recently uploaded"
    }
    
    private var indexSelected: Int = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFirstGroupOfCases()
        configureCollectionView()
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        casesCollectionView.refreshControl = refresher
        filterCollectionView.selectItem(at: IndexPath(item: 2, section: 0), animated: true, scrollPosition: [])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
       
        if !loaded {
            casesCollectionView.reloadData()
        }
    }

    private func fetchFirstGroupOfCases() {
        CaseService.fetchClinicalCases(lastSnapshot: nil) { snapshot in
            self.casesLastSnapshot = snapshot.documents.last
            self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
            self.checkIfUserLikedCase()
            self.checkIfUserBookmarkedCase()
            self.casesCollectionView.refreshControl?.endRefreshing()
            self.cases.forEach { clinicalCase in
                UserService.fetchUser(withUid: clinicalCase.ownerUid) { user in
                    self.users.append(user)
                    self.loaded = true
                    self.casesCollectionView.reloadData()
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
            flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
            flowLayout.itemSize = CGSize(width: itemWidth, height: 350)
            
            return flowLayout
        }
    
    private func createFilterCellLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in

                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(45), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(45), heightDimension: .absolute(30)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
                return section
        }
        return layout
    }
    
    private func configureCollectionView() {
        casesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createTwoColumnFlowLayout())
        filterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createFilterCellLayout())
        casesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        filterCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        if displaysExploringWindow || displaysFilteredWindow {
            view.addSubviews(casesCollectionView)
            NSLayoutConstraint.activate([
                casesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                casesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                casesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                casesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
        } else {
            view.addSubviews(filterCollectionView, casesCollectionView)
            NSLayoutConstraint.activate([
                filterCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                filterCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                filterCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                filterCollectionView.heightAnchor.constraint(equalToConstant: 50),
                
                casesCollectionView.topAnchor.constraint(equalTo: filterCollectionView.bottomAnchor),
                casesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                casesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                casesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        casesCollectionView.register(CasesFeedCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        casesCollectionView.register(SkeletonCasesCell.self, forCellWithReuseIdentifier: caseSkeletonCellReuseIdentifier)
        casesCollectionView.register(ExploreHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: exploreHeaderCellReuseIdentifier)
        
        filterCollectionView.register(FilterCasesCell.self, forCellWithReuseIdentifier: filterCellReuseIdentifier)
        filterCollectionView.register(ExploreCasesCell.self, forCellWithReuseIdentifier: exploreCellReuseIdentifier)
        filterCollectionView.register(SeparatorCell.self, forCellWithReuseIdentifier: separatorCellReuseIdentifier)
        
        filterCollectionView.allowsSelection = true
        filterCollectionView.allowsMultipleSelection = false
        
        filterCollectionView.dataSource = self
        filterCollectionView.delegate = self
        
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
        if collectionView == filterCollectionView {
            return filterCategories.allCases.count + 2
        }
        
        if !loaded {
            return 6
        }
        return cases.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if displaysExploringWindow {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: exploreHeaderCellReuseIdentifier, for: indexPath) as! ExploreHeaderCell
            header.delegate = self
            return header
        }
        
        return UICollectionReusableView()
    }
     
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if displaysExploringWindow {
            return CGSize(width: view.frame.width, height: 350)
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == filterCollectionView {
            
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: exploreCellReuseIdentifier, for: indexPath) as! ExploreCasesCell
                return cell
            }
            
            if indexPath.row == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: separatorCellReuseIdentifier, for: indexPath) as! SeparatorCell
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellReuseIdentifier, for: indexPath) as! FilterCasesCell
            cell.tagsLabel.text = filterCategories.allCases[indexPath.row - 2].rawValue
            cell.delegate = self
            return cell
        }
        
        
        if !loaded {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseSkeletonCellReuseIdentifier, for: indexPath) as! SkeletonCasesCell
            return cell
        }
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == filterCollectionView {
            
            if indexPath.row == 0 {
                // Explore
                collectionView.selectItem(at: IndexPath(item: indexSelected, section: 0), animated: true, scrollPosition: [])
                self.navigationController?.delegate = self
                let controller = CasesViewController()
                controller.controllerIsBeeingPushed = true
                controller.displaysExploringWindow = true
                
                let backItem = UIBarButtonItem()
                backItem.title = "Explore"
                backItem.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 18)], for: .normal)
                backItem.tintColor = .black
                navigationItem.backBarButtonItem = backItem
                
                navigationController?.pushViewController(controller, animated: true)
                return
            }
            
            if indexPath.row == 1 { return }
            
            casesCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)

            let selection = filterCategories.allCases[indexPath.row - 2]
            
            switch selection {
                
            case .all:
                print(indexPath.row)
                print(indexSelected)
                if indexPath.row == indexSelected { return }

                indexSelected = indexPath.row
                loaded = false
                casesCollectionView.reloadData()
                
                CaseService.fetchClinicalCases(lastSnapshot: nil) { snapshot in
                    self.casesLastSnapshot = snapshot.documents.last
                    self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                    self.checkIfUserLikedCase()
                    self.checkIfUserBookmarkedCase()
                    self.casesCollectionView.refreshControl?.endRefreshing()
                    self.cases.forEach { clinicalCase in
                        UserService.fetchUser(withUid: clinicalCase.ownerUid) { user in
                            self.users.append(user)
                            self.loaded = true
                            self.casesCollectionView.reloadData()
                        }
                    }
                }

                break

                //CaseService.fetchCasesWithDetailsFilter(fieldToQuery: "details", valueToQuery: "Teaching interest")
            case .recents:

                if indexPath.row == indexSelected { return }
                indexSelected = indexPath.row
                loaded = false
                casesCollectionView.reloadData()
                
                CaseService.fetchLastUploadedClinicalCases(lastSnapshot: nil) { snapshot in
                    self.casesLastSnapshot = snapshot.documents.last
                    self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                    self.checkIfUserLikedCase()
                    self.checkIfUserBookmarkedCase()
                    self.casesCollectionView.refreshControl?.endRefreshing()
                    self.cases.forEach { clinicalCase in
                        UserService.fetchUser(withUid: clinicalCase.ownerUid) { user in
                            self.users.append(user)
                            self.loaded = true
                            self.casesCollectionView.reloadData()
                        }
                    }
                }

                break
            }
        }
    }
    /*
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let selectedIndexPath = IndexPath(item: 2, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: true, scrollPosition: [])
    }
     */
}


extension CasesViewController: CaseCellDelegate {
    
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
                    //currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes - 1
                    self.cases[indexPath.row].didLike = false
                }
            } else {
                //Like post here
                CaseService.likeCase(clinicalCase: clinicalCase) { _ in
                    //currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes + 1
                    self.cases[indexPath.row].didLike = true
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
        if indexSelected == 2 {
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
        
        if indexSelected == 3 {
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

extension CasesViewController: FilterCasesCellDelegate {
    func didTapFilterImage(_ cell: UICollectionViewCell) {
        if let indexPath = filterCollectionView.indexPath(for: cell) {
            if let cell = filterCollectionView.cellForItem(at: indexPath) as? FilterCasesCell {
                let optionTapped = filterCategories.allCases[indexPath.row]
                if cell.isSelected {
                    print("Clear filter here")
                    return
                }
                print("Open options")
                switch optionTapped {

                case .all:
                    break
                /*
                case .trending:
                    break
                case .specialities:
                    break
                case .details:
                   
                    let controller = ClinicalTypeViewController(selectedTypes: [""])
                    controller.controllerIsPresented = true
                    controller.delegate = self
                    let nav = UINavigationController(rootViewController: controller)
                    nav.modalPresentationStyle = .fullScreen
                    present(nav, animated: true, completion: nil)
                 */
                case .recents:
                    
                    break
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
        backItem.title = profession
        backItem.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 18)], for: .normal)
        backItem.tintColor = .black
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


