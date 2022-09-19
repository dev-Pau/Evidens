//
//  CasesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/9/22.
//

import UIKit
import Firebase

private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"
private let caseSkeletonCellReuseIdentifier = "CaseSkeletonCellReuseIdentifier"

class CasesViewController: NavigationBarViewController {
    
    var caseMenuLauncher = CaseOptionsMenuLauncher()
    
    var users = [User]()
    private var cases = [Case]()
    
    var loaded = false
    
    var casesLastSnapshot: QueryDocumentSnapshot?
    
    private var zoomTransitioning = ZoomTransitioning()
    var selectedImage: UIImageView!
 
    private var collectionView: UICollectionView!
    
    private var filterCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        return collectionView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFirstGroupOfCases()
        configureCollectionView()
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
        self.navigationController?.delegate = zoomTransitioning
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !loaded {
            collectionView.reloadData()
        }
    }
    
    private func fetchFirstGroupOfCases() {
        CaseService.fetchClinicalCases(lastSnapshot: nil) { snapshot in
            self.casesLastSnapshot = snapshot.documents.last
            self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
            self.checkIfUserLikedCase()
            self.checkIfUserBookmarkedCase()
            self.collectionView.refreshControl?.endRefreshing()
            self.cases.forEach { clinicalCase in
                UserService.fetchUser(withUid: clinicalCase.ownerUid) { user in
                    self.users.append(user)
                    self.loaded = true
                    self.collectionView.reloadData()
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
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func checkIfUserBookmarkedCase() {
        self.cases.forEach { clinicalCase in
            CaseService.checkIfUserBookmarkedCase(clinicalCase: clinicalCase) { didBookmark in
                if let index = self.cases.firstIndex(where: { $0.caseId == clinicalCase.caseId}) {
                    self.cases[index].didBookmark = didBookmark
                    self.collectionView.reloadData()

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
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createTwoColumnFlowLayout())
        
        collectionView.register(CasesFeedCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        collectionView.register(SkeletonCasesCell.self, forCellWithReuseIdentifier: caseSkeletonCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }
    
    @objc func handleRefresh() {
        HapticsManager.shared.vibrate(for: .success)
        fetchFirstGroupOfCases()
    }
}

extension CasesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !loaded {
            return 6
        }
        return cases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
}


extension CasesViewController: CaseCellDelegate {
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, collectionViewFlowLayout: layout)

        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        guard image != [] else { return }
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
        backItem.tintColor = .black
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }


    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
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
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        print(indexPath.row)
        
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
                    NotificationService.uploadNotification(toUid: clinicalCase.ownerUid, fromUser: user, type: .likePost, clinicalCase: clinicalCase)
                }
            }
            
        default:
            break
        }
    }
    
    func scrollCollectionViewToTop() {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) {
        return
    }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) {
        return
    }
}

extension CasesViewController: CaseOptionsMenuLauncherDelegate {
    func didTapFollowAction(forUid uid: String, isFollowing follow: Bool, forUserFirstName firstName: String) {
        if follow {
            // Unfollow user
            UserService.unfollow(uid: uid) { _ in
                let reportPopup = METopPopupView(title: "You unfollowed \(firstName)", image: "xmark.circle.fill")
                reportPopup.showTopPopup(inView: self.view)
            }
        } else {
            // Follow user
            UserService.follow(uid: uid) { _ in
                let reportPopup = METopPopupView(title: "You followed \(firstName)", image: "plus.circle.fill")
                reportPopup.showTopPopup(inView: self.view)
            }
        }
    }
    
    func didTapEditDiagnosis(forCaseUid uid: String, withDiagnosisText text: String) {
        let controller = CaseDiagnosisViewController(diagnosisText: text)
        controller.diagnosisIsUpdating = true
        controller.caseId = uid
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    func didTapAddDiagnosis(forCaseUid uid: String) {
        let controller = CaseDiagnosisViewController(diagnosisText: "")
        controller.diagnosisIsUpdating = true
        controller.caseId = uid
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    func didTapAddCaseUpdate(forCase clinicalCase: Case) {
        let controller = CaseUpdatesViewController(clinicalCase: clinicalCase)
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    func didTapChangeStateToSolved(forCaseUid uid: String) {
        let controller = CaseDiagnosisViewController(diagnosisText: "")
        controller.stageIsUpdating = true
        controller.caseId = uid
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    func didTapDeleteCase() {
        print("Delete Case")
    }
    
    func didTapReportCase(forCaseUid uid: String) {
        reportCaseAlert {
            DatabaseManager.shared.reportCase(forUid: uid) { reported in
                if reported {
                    let reportPopup = METopPopupView(title: "Case reported", image: "flag.fill")
                    reportPopup.showTopPopup(inView: self.view)
                }
            }
        }
    }
}

extension CasesViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return selectedImage
    }
}

extension CasesViewController {
    func getMoreCases() {
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
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

