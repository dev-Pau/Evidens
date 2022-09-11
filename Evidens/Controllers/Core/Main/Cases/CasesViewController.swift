//
//  CasesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/7/22.
//

import UIKit
import Firebase

private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"

class CasesViewController: UIViewController {
    
    var caseMenuLauncher = CaseOptionsMenuLauncher()
    
    var user: User?
    
    var casesLastSnapshot: QueryDocumentSnapshot?
    
    private var zoomTransitioning = ZoomTransitioning()
    var selectedImage: UIImageView!
    var controllerIsBeeingPushed: Bool = false
    
    private var cases = [Case]() {
        didSet { collectionView.reloadData() }
    }
    
    private lazy var userImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfile))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        let atrString = NSAttributedString(string: "Search", attributes: [.font : UIFont.systemFont(ofSize: 15)])
        searchBar.searchTextField.attributedPlaceholder = atrString
        searchBar.searchTextField.tintColor = primaryColor
        searchBar.searchTextField.backgroundColor = lightColor
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing  = 10
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 600)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = lightColor
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFirstGroupOfCases()
        configureNavigationBar()
        configureCollectionView()
        configureUI()
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
        
        self.navigationController?.delegate = zoomTransitioning
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.resignFirstResponder()
        
    }
    
    private func fetchFirstGroupOfCases() {
        if !controllerIsBeeingPushed {
            CaseService.fetchClinicalCases(lastSnapshot: nil) { snapshot in
                self.casesLastSnapshot = snapshot.documents.last
                self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                self.checkIfUserLikedCase()
                self.checkIfUserBookmarkedCase()
                self.collectionView.refreshControl?.endRefreshing()
            }
        } else {
            guard let uid = user?.uid else { return }
            CaseService.fetchCases(forUser: uid) { cases in
                self.cases = cases
                self.checkIfUserLikedCase()
                self.checkIfUserBookmarkedCase()
                self.collectionView.refreshControl?.endRefreshing()
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
                }
            }
        }
    }
    
    func checkIfUserBookmarkedCase() {
        self.cases.forEach { clinicalCase in
            CaseService.checkIfUserBookmarkedCase(clinicalCase: clinicalCase) { didBookmark in
                if let index = self.cases.firstIndex(where: { $0.caseId == clinicalCase.caseId}) {
                    self.cases[index].didBookmark = didBookmark
                }
            }
        }
    }
    
    private func configureNavigationBar() {
        if !controllerIsBeeingPushed {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "paperplane", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), style: .plain, target: self, action: #selector(didTapChat))
            
            navigationItem.rightBarButtonItem?.tintColor = .black
            
            userImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
            userImageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
            userImageView.layer.cornerRadius = 35 / 2
            let profileImageItem = UIBarButtonItem(customView: userImageView)
            userImageView.sd_setImage(with: URL(string: UserDefaults.standard.value(forKey: "userProfileImageUrl") as! String))
            navigationItem.leftBarButtonItem = profileImageItem
            
            navigationItem.titleView = searchBar
        } else {
            navigationItem.titleView = searchBar
            navigationItem.titleView?.isHidden = true
            navigationItem.titleView?.isUserInteractionEnabled = false
        }
    }
    
    private func configureUI() {
        searchBar.delegate = self
    }
    
    private func createTwoColumnFlowLayout() -> UICollectionViewFlowLayout {
            let width = view.bounds.width
            let padding: CGFloat = 110
            let minimumItemSpacing: CGFloat = 10
            let availableWidth = width - (padding * 2) - minimumItemSpacing
            let itemWidth = availableWidth / 2
            
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
            flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth + 40)
            
            return flowLayout
        }
    
    private func configureCollectionView() {
        
        collectionView.register(CaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        collectionView.register(CaseTextImageCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(collectionView)
    }
    
    @objc func didTapProfile() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        let controller = UserProfileViewController(user: user)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        backItem.tintColor = .black
        
        navigationController?.pushViewController(controller, animated: true)
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }
    
    @objc func didTapChat() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .black
        
        navigationItem.backBarButtonItem = backItem
        
        let controller = ConversationViewController()
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleRefresh() {
        HapticsManager.shared.vibrate(for: .success)
        cases.removeAll()
        casesLastSnapshot = nil
        fetchFirstGroupOfCases()
    }
}

extension CasesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if cases[indexPath.row].type.rawValue == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
            cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
            cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
            cell.delegate = self
            return cell
        }
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

//MARK: - UISearchBarDelegate

extension CasesViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .black
        
        navigationItem.backBarButtonItem = backItem
        
        let controller = SearchViewController()
        navigationController?.pushViewController(controller, animated: true)
        
        return true
    }
}

extension CasesViewController: CaseCellDelegate {
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, collectionViewFlowLayout: layout)

        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        selectedImage = image[index]
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        controller.customDelegate = self

        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .clear
        navigationItem.backBarButtonItem = backItem

        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) {
        let controller = CaseUpdatesViewController(clinicalCase: clinicalCase)
        controller.controllerIsPushed = true
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .black
        self.navigationItem.backBarButtonItem = backItem
        
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didPressThreeDotsFor clinicalCase: Case) {
        caseMenuLauncher.clinicalCase = clinicalCase
        caseMenuLauncher.delegate = self
        caseMenuLauncher.showImageSettings(in: view)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor uid: String) {
        UserService.fetchUser(withUid: uid) { user in
            let controller = UserProfileViewController(user: user)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .black
            self.navigationItem.backBarButtonItem = backItem
            
            self.navigationController?.pushViewController(controller, animated: true)
            DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
        }
    }
    
    
    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) {
        HapticsManager.shared.vibrate(for: .success)
        
        switch cell {
        case is CaseTextCell:
            let currentCell = cell as! CaseTextCell
            currentCell.viewModel?.clinicalCase.didBookmark.toggle()
            if clinicalCase.didBookmark {
                //Unlike post here
                CaseService.unbookmarkCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks - 1
                }
            } else {
                //Like post here
                CaseService.bookmarkCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks + 1
                    //NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                }
            }
            
        case is CaseTextImageCell:
            let currentCell = cell as! CaseTextImageCell
            currentCell.viewModel?.clinicalCase.didBookmark.toggle()
            if clinicalCase.didBookmark {
                //Unlike post here
                CaseService.unbookmarkCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks - 1
                }
            } else {
                //Like post here
                CaseService.bookmarkCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks + 1
                    //NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .likePost, post: post)
                }
            }
        default:
            print("Cell not registered")
        }
        
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        HapticsManager.shared.vibrate(for: .success)
        
        switch cell {
        case is CaseTextCell:
            let currentCell = cell as! CaseTextCell
            currentCell.viewModel?.clinicalCase.didLike.toggle()
            if clinicalCase.didLike {
                //Unlike post here
                CaseService.unlikeCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes - 1
                }
            } else {
                //Like post here
                CaseService.likeCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes + 1
                    NotificationService.uploadNotification(toUid: clinicalCase.ownerUid, fromUser: user, type: .likeCase, clinicalCase: clinicalCase)
                }
            }
            
        case is CaseTextImageCell:
            let currentCell = cell as! CaseTextImageCell
            currentCell.viewModel?.clinicalCase.didLike.toggle()
            if clinicalCase.didLike {
                //Unlike post here
                CaseService.unlikeCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes - 1
                }
            } else {
                //Like post here
                CaseService.likeCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.likes = clinicalCase.likes + 1
                    NotificationService.uploadNotification(toUid: clinicalCase.ownerUid, fromUser: user, type: .likeCase, clinicalCase: clinicalCase)
                }
            }
        default:
            print("Cell not registered")
        }
    }
    
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) {
        CaseService.getAllLikesFor(clinicalCase: clinicalCase) { uids in
            
            let controller = PostLikesViewController(uid: uids)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case) {
        let controller = CommentCaseViewController(clinicalCase: clinicalCase)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem

        navigationController?.pushViewController(controller, animated: true)
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

extension CasesViewController: HomeImageViewControllerDelegate {
    func updateVisibleImageInScrollView(_ image: UIImageView) {
        selectedImage = image
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
        }
    }
}

