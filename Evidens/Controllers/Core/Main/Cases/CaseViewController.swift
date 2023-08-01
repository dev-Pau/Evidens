//
//  CaseViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/7/22.
//

import UIKit
import Firebase

private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"

class CaseViewController: UIViewController, UINavigationControllerDelegate {
    
    var user: User
    private let contentSource: CaseSource
    
    private var users = [User]()
    private var cases = [Case]()
    
    
    var casesLastSnapshot: QueryDocumentSnapshot?
    
    private var zoomTransitioning = ZoomTransitioning()
    var selectedImage: UIImageView!

    private var displayState: DisplayState = .none
    
    #warning("this still has checkifuserliked and comment, need to remove allj of this shit")
    private let activityIndicator = PrimaryProgressIndicatorView(frame: .zero)
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing  = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .leastNonzeroMagnitude)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.bounces = true
        collectionView.isHidden = true
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    init(user: User, contentSource: CaseSource) {
        self.user = user
        self.contentSource = contentSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
        fetchFirstGroupOfCases()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.delegate = self
        
        switch displayState {
        case .none:
            break
            
        case .photo:
            break
            
        case .others:
            if contentSource == .search { return }
            let view = CompoundNavigationBar(fullName: user.firstName! + " " + user.lastName!, category: "Cases")
            view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
            navigationItem.titleView = view
            
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
    }
    
    private func fetchFirstGroupOfCases() {
        switch contentSource {
        case .user:
            guard let uid = user.uid else { return }
            CaseService.fetchUserVisibleCases(forUid: uid, lastSnapshot: nil, completion: { snapshot in
                guard !snapshot.isEmpty else {
                    //self.loaded = true
                    self.activityIndicator.stop()
                    self.collectionView.reloadData()
                    self.collectionView.isHidden = false
                    return
                }
                
                self.casesLastSnapshot = snapshot.documents.last
                self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                CaseService.getCaseValuesFor(cases: self.cases) { cases in
                    self.cases = cases
                    self.cases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    //self.loaded = true
                    self.activityIndicator.stop()
                    self.collectionView.reloadData()
                    self.collectionView.isHidden = false
                }
            })
        case .search:
            CaseService.fetchUserSearchCases(user: user, lastSnapshot: nil) { snapshot in
                self.casesLastSnapshot = snapshot.documents.last
                self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                #warning("cridar les funcions de fetch values for case")
                //self.cases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                //self.checkIfUserLikedCase()
                //self.checkIfUserBookmarkedCase()
                let uids = self.cases.map { $0.uid }
                UserService.fetchUsers(withUids: uids) { users in
                    self.users = users
                    self.collectionView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    /*
    func checkIfUserLikedCase() {
        self.cases.forEach { clinicalCase in
            //Check if user did like
            CaseService.checkIfUserLikedCase(clinicalCase: clinicalCase) { didLike in
                //Check the postId of the current post looping
                if let index = self.cases.firstIndex(where: {$0.caseId == clinicalCase.caseId }) {
                    //Change the didLike according if user did like post
                    self.cases[index].didLike = didLike
                }
            }
        }
    }
    
    func checkIfUserBookmarkedCase() {
        self.cases.forEach { clinicalCase in
            CaseService.checkIfUserBookmarkedCase(clinicalCase: clinicalCase) { didBookmark in
                if let index = self.cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                    self.cases[index].didBookmark = didBookmark
                }
            }
        }
    }
    */
    private func configureNavigationBar() {
        if contentSource == .search { return }
        let view = CompoundNavigationBar(fullName: user.firstName! + " " + user.lastName!, category: "Cases")
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = view
        
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func configureCollectionView() {
        collectionView.register(CaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        collectionView.register(CaseTextImageCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.frame = view.bounds
        view.addSubviews(activityIndicator, collectionView)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            activityIndicator.widthAnchor.constraint(equalToConstant: 200),
        ])
    }
}

extension CaseViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if cases[indexPath.row].kind == .text {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
            
            switch contentSource {
            case .user:
                cell.set(user: user)
            case .search:
                if let userIndex = users.firstIndex(where:  { $0.uid! == cases[indexPath.row].uid }) {
                    cell.set(user: users[userIndex])
                }
            }

            cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
            switch contentSource {
            case .user:
                cell.set(user: user)
            case .search:
                if let userIndex = users.firstIndex(where:  { $0.uid! == cases[indexPath.row].uid }) {
                    cell.set(user: users[userIndex])
                }
            }
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
            getMoreCases()
        }
    }
}


extension CaseViewController: CaseCellDelegate {
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, collectionViewFlowLayout: layout)
        controller.delegate = self
        displayState = .others
       
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        //controller.caseDelegate = self
        //controller.postDelegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: CaseMenu) {
        switch option {
        case .delete:
            #warning("Implement delete")
            print("delete")
        case .revision:
            let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: user)
            
#warning("Implement delegate")
            controller.delegate = self
            
            navigationController?.pushViewController(controller, animated: true)
        case .solve:
            let controller = CaseDiagnosisViewController(clinicalCase: clinicalCase)
            //controller.stageIsUpdating = true
#warning("Implement delete")
            controller.delegate = self
            //controller.caseId = clinicalCase.caseId
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        case .report:
            let reportPopup = PopUpBanner(title: "Case successfully reported", image: "checkmark.circle.fill", popUpKind: .regular)
            reportPopup.showTopPopup(inView: self.view)
        }
    }

    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        selectedImage = image[index]
        self.navigationController?.delegate = zoomTransitioning
        
        displayState = .photo
        
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
        //controller.customDelegate = self

        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .clear
        navigationItem.backBarButtonItem = backItem

        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) {

        let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: user)

        displayState = .others
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .black
        self.navigationItem.backBarButtonItem = backItem
        
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didPressThreeDotsFor clinicalCase: Case) { return }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) { return }
    
    
    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        HapticsManager.shared.vibrate(for: .success)
        
        switch cell {
        case is CaseTextCell:
            let currentCell = cell as! CaseTextCell
            currentCell.viewModel?.clinicalCase.didBookmark.toggle()
            if clinicalCase.didBookmark {
                //Unlike post here
                CaseService.unbookmarkCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks - 1
                    self.cases[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                CaseService.bookmarkCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks + 1
                    self.cases[indexPath.row].didBookmark = true
                }
            }
            
        case is CaseTextImageCell:
            let currentCell = cell as! CaseTextImageCell
            currentCell.viewModel?.clinicalCase.didBookmark.toggle()
            if clinicalCase.didBookmark {
                //Unlike post here
                CaseService.unbookmarkCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks - 1
                    self.cases[indexPath.row].didBookmark = false
                }
            } else {
                //Like post here
                CaseService.bookmarkCase(clinicalCase: clinicalCase) { _ in
                    currentCell.viewModel?.clinicalCase.numberOfBookmarks = clinicalCase.numberOfBookmarks + 1
                    self.cases[indexPath.row].didBookmark = true
                }
            }
        default:
            print("Cell not registered")
        }
        
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        HapticsManager.shared.vibrate(for: .success)
        
        
        switch cell {
        case is CaseTextCell:
            let currentCell = cell as! CaseTextCell
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
                }
            }
            
        case is CaseTextImageCell:
            let currentCell = cell as! CaseTextImageCell
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
                }
            }
        default:
            print("Cell not registered")
        }
    }
    
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) {
        let controller = LikesViewController(clinicalCase: clinicalCase)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        displayState = .others
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, collectionViewFlowLayout: layout)
        controller.delegate = self
        displayState = .others
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension CaseViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return selectedImage
    }
}

extension CaseViewController {
    func getMoreCases() {
        switch contentSource {
        case .user:
            guard let uid = user.uid else { return }
            CaseService.fetchUserVisibleCases(forUid: uid, lastSnapshot: casesLastSnapshot, completion: { snapshot in
                self.casesLastSnapshot = snapshot.documents.last
                let documents = snapshot.documents
                var newCases = documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                newCases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                self.cases.append(contentsOf: newCases)
                #warning("cridar les funcions per fer fetch case values for")
                //self.checkIfUserLikedCase()
                //self.checkIfUserBookmarkedCase()
            })
        case .search:
            CaseService.fetchUserSearchCases(user: user, lastSnapshot: casesLastSnapshot) { snapshot in
                self.casesLastSnapshot = snapshot.documents.last
                var newCases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                let newUids = newCases.map({ $0.uid })
                self.cases.append(contentsOf: newCases)
                #warning("cridar les funcions per fer fetch case values for")
                //self.checkIfUserLikedCase()
                //self.checkIfUserBookmarkedCase()
                UserService.fetchUsers(withUids: newUids) { users in
                    self.users.append(contentsOf: users)
                    self.collectionView.reloadData()
                }
            }
        }
        
    }
}

extension CaseViewController: DetailsCaseViewControllerDelegate {
    func didSolveCase(forCase clinicalCase: Case, with diagnosis: CaseRevisionKind?) {
        let index = cases.firstIndex { homeCase in
            if homeCase.caseId == clinicalCase.caseId {
                return true
            }
            
            return false
        }
        
        if let index = index {
            cases[index].phase = .solved
            if let diagnosis {
                cases[index].revision = diagnosis
            }

            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func didAddRevision(forCase clinicalCase: Case) {
        #warning("no sería $0. caseId == clinicalCase.caseId?, anbans era $0.ownerUid, si no funciona cambiar")
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            cases[caseIndex].revision = clinicalCase.revision
            collectionView.reloadData()
        }
    }

    func didDeleteComment(forCase clinicalCase: Case) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            cases[caseIndex].numberOfComments += 1
            collectionView.reloadData()
        }
    }

    func didTapLikeAction(forCase clinicalCase: Case) {
        let index = cases.firstIndex { homeCase in
            if homeCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = index {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
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
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
                self.clinicalCase(cell, didBookmark: clinicalCase)
            }
        }
    }
    
    func didComment(forCase clinicalCase: Case) {
        let caseIndex = cases.firstIndex { homeCase in
            if homeCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = caseIndex {
            cases[index].numberOfComments += 1
            collectionView.reloadData()
        }
    }
}

extension CaseViewController: CaseUpdatesViewControllerDelegate {
    func didAddRevision(to clinicalCase: Case, _ revision: CaseRevision) {
        if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            cases[index].revision = revision.kind
            collectionView.reloadData()
        }
    }
}

extension CaseViewController: CaseDiagnosisViewControllerDelegate {
    func handleSolveCase(diagnosis: CaseRevision?, clinicalCase: Case?) {
        guard let clinicalCase = clinicalCase else { return }
        let index = cases.firstIndex { homeCase in
            if homeCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = index {
            cases[index].phase = .solved
            if let diagnosis { cases[index].revision = diagnosis.kind }
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
}
