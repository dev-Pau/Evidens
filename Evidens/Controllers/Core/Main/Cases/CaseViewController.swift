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
    
    private var user: User
    private let contentSource: CaseSource
    
    private var users = [User]()
    private var cases = [Case]()

    private var casesLastSnapshot: QueryDocumentSnapshot?
    private var networkIssue = false
    
    private var zoomTransitioning = ZoomTransitioning()
    var selectedImage: UIImageView!
    
    private var likeDebounceTimers: [IndexPath: DispatchWorkItem] = [:]
    private var likeCaseValues: [IndexPath: Bool] = [:]
    private var likeCaseCount: [IndexPath: Int] = [:]
    
    private var bookmarkDebounceTimers: [IndexPath: DispatchWorkItem] = [:]
    private var bookmarkCaseValues: [IndexPath: Bool] = [:]
    
    private let activityIndicator = PrimaryLoadingView(frame: .zero)
    
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
    }

    private func configureUI() {
        view.backgroundColor = .systemBackground
    }
    
    private func fetchFirstGroupOfCases() {
        switch contentSource {
        case .user:
            guard let uid = user.uid else { return }
            CaseService.fetchUserCases(forUid: uid, lastSnapshot: nil) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let snapshot):
                    strongSelf.casesLastSnapshot = snapshot.documents.last
                    strongSelf.cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data() )}
                    CaseService.getCaseValuesFor(cases: strongSelf.cases) { [weak self] cases in
                        guard let strongSelf = self else { return }
                        strongSelf.cases = cases
                        strongSelf.cases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                        strongSelf.activityIndicator.stop()
                        strongSelf.collectionView.reloadData()
                        strongSelf.collectionView.isHidden = false
                    }
                case .failure(let error):
                    strongSelf.activityIndicator.stop()
                    strongSelf.collectionView.reloadData()
                    strongSelf.collectionView.isHidden = false
                    
                    guard error != .notFound else {
                        return
                    }
                    
                    if error == .network {
                        strongSelf.networkIssue = true
                    }
                    
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                }
            }
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
    
    private func configureNavigationBar() {
        if contentSource == .search { return }
        let view = CompoundNavigationBar(fullName: user.firstName!, category: AppStrings.Search.Topics.cases)
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = view
        
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.leftChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        
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
    
    private func handleLikeUnLike(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        // Toggle the like state and count
        cell.viewModel?.clinicalCase.didLike.toggle()
        self.cases[indexPath.row].didLike.toggle()
        
        cell.viewModel?.clinicalCase.likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        self.cases[indexPath.row].likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        
        // Cancel the previous debounce timer for this post, if any
        if let debounceTimer = likeDebounceTimers[indexPath] {
            debounceTimer.cancel()
        }
        
        // Store the initial like state and count
        if likeCaseValues[indexPath] == nil {
            likeCaseValues[indexPath] = clinicalCase.didLike
            likeCaseCount[indexPath] = clinicalCase.likes
        }
        
        // Create a new debounce timer with a delay of 2 seconds
        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }

            guard let likeValue = strongSelf.likeCaseValues[indexPath], let countValue = strongSelf.likeCaseCount[indexPath] else {
                return
            }

            // Prevent any database action if the value remains unchanged
            if cell.viewModel?.clinicalCase.didLike == likeValue {
                strongSelf.likeCaseValues[indexPath] = nil
                strongSelf.likeCaseCount[indexPath] = nil
                return
            }

            if clinicalCase.didLike {
                CaseService.unlikeCase(clinicalCase: clinicalCase) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        cell.viewModel?.clinicalCase.didLike = likeValue
                        strongSelf.cases[indexPath.row].didLike = likeValue
                        
                        cell.viewModel?.clinicalCase.likes = countValue
                        strongSelf.cases[indexPath.row].likes = countValue
                    }
                    
                    strongSelf.likeCaseValues[indexPath] = nil
                    strongSelf.likeCaseCount[indexPath] = nil
                }
            } else {
                CaseService.likeCase(clinicalCase: clinicalCase) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    // Revert to the previous like state and count if there's an error
                    if let _ = error {
                        cell.viewModel?.clinicalCase.didLike = likeValue
                        strongSelf.cases[indexPath.row].didLike = likeValue
                        
                        cell.viewModel?.clinicalCase.likes = countValue
                        strongSelf.cases[indexPath.row].likes = countValue
                    }
                    
                    strongSelf.likeCaseValues[indexPath] = nil
                    strongSelf.likeCaseCount[indexPath] = nil
                }
            }
            
            // Clean up the debounce timer
            strongSelf.likeDebounceTimers[indexPath] = nil
        }
        
        // Save the debounce timer
        likeDebounceTimers[indexPath] = debounceTimer
        
        // Start the debounce timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)
    }
    
    func handleBookmarkUnbookmark(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        // Toggle the bookmark state
        cell.viewModel?.clinicalCase.didBookmark.toggle()
        self.cases[indexPath.row].didBookmark.toggle()
        
        // Cancel the previous debounce timer for this post, if any
        if let debounceTimer = bookmarkDebounceTimers[indexPath] {
            debounceTimer.cancel()
        }
        
        // Store the initial bookmark state
        if bookmarkCaseValues[indexPath] == nil {
            bookmarkCaseValues[indexPath] = clinicalCase.didBookmark
        }
        
        // Create a new debounce timer with a delay of 2 seconds
        let debounceTimer = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }

            guard let bookmarkValue = strongSelf.bookmarkCaseValues[indexPath] else {
                return
            }

            // Prevent any database action if the value remains unchanged
            if cell.viewModel?.clinicalCase.didBookmark == bookmarkValue {
                strongSelf.bookmarkCaseValues[indexPath] = nil
                return
            }

            if clinicalCase.didBookmark {
                CaseService.unbookmarkCase(clinicalCase: clinicalCase) { [weak self] error in
                    guard let strongSelf = self else { return }
                    
                    if let _ = error {
                        cell.viewModel?.clinicalCase.didBookmark = bookmarkValue
                        strongSelf.cases[indexPath.row].didBookmark = bookmarkValue
                    }
                    
                    strongSelf.bookmarkCaseValues[indexPath] = nil
                }
            } else {
                CaseService.bookmarkCase(clinicalCase: clinicalCase) { [weak self] error in
                    guard let strongSelf = self else { return }

                    if let _ = error {
                        cell.viewModel?.clinicalCase.didBookmark = bookmarkValue
                        strongSelf.cases[indexPath.row].didBookmark = bookmarkValue
    
                    }
                    
                    strongSelf.bookmarkCaseValues[indexPath] = nil
                }
            }
            
            // Clean up the debounce timer
            strongSelf.bookmarkDebounceTimers[indexPath] = nil
        }
        
        // Save the debounce timer
        bookmarkDebounceTimers[indexPath] = debounceTimer
        
        // Start the debounce timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: debounceTimer)
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

        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        controller.caseDelegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: CaseMenu) {
        switch option {
        case .delete:
            #warning("Pending Deletion")
        case .revision:
            let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: user)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        case .solve:
            let controller = CaseDiagnosisViewController(clinicalCase: clinicalCase)
            controller.delegate = self
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            
        case .report:
            let controller = ReportViewController(source: .clinicalCase, contentUid: clinicalCase.uid, contentId: clinicalCase.caseId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
        }
    }

    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        let map: [UIImage] = image.compactMap { $0.image }
        selectedImage = image[index]
        navigationController?.delegate = zoomTransitioning

        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)

        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) {
        let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: user)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didPressThreeDotsFor clinicalCase: Case) { return }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) { return }
    
    
    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? CaseCellProtocol else { return }
        HapticsManager.shared.vibrate(for: .success)
        handleBookmarkUnbookmark(for: currentCell, at: indexPath)
        
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? CaseCellProtocol else { return }
        HapticsManager.shared.vibrate(for: .success)
        handleLikeUnLike(for: currentCell, at: indexPath)
    }
    
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) {
        let controller = LikesViewController(clinicalCase: clinicalCase)
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
            CaseService.fetchUserCases(forUid: uid, lastSnapshot: casesLastSnapshot) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let snapshot):
                    strongSelf.casesLastSnapshot = snapshot.documents.last
                    var cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data() )}
                    
                    CaseService.getCaseValuesFor(cases: cases) { [weak self] newCases in
                        guard let strongSelf = self else { return }
                        cases = newCases
                        cases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                        strongSelf.cases.append(contentsOf: newCases)
                        strongSelf.collectionView.reloadData()
                    }
                case .failure(_):
                    break
                }
            }
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
        if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            cases[index].phase = .solved
            if let diagnosis {
                cases[index].revision = diagnosis
            }

            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func didAddRevision(forCase clinicalCase: Case) {
        if let caseIndex = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            cases[caseIndex].revision = clinicalCase.revision
            collectionView.reloadData()
        }
    }

    func didDeleteComment(forCase clinicalCase: Case) {
        if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                cases[index].numberOfComments -= 1
                cell.viewModel?.clinicalCase.numberOfComments -= 1
            }
        }
    }

    func didTapLikeAction(forCase clinicalCase: Case) {
        if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                cases[index].didLike = clinicalCase.didLike
                cases[index].likes = clinicalCase.likes
                cell.viewModel?.clinicalCase.didLike = clinicalCase.didLike
                cell.viewModel?.clinicalCase.likes = clinicalCase.likes
            }
        }
    }
    
    func didTapBookmarkAction(forCase clinicalCase: Case) {
        if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                cases[index].didBookmark = clinicalCase.didBookmark
                cell.viewModel?.clinicalCase.didBookmark = clinicalCase.didBookmark
            }
            
        }
    }
    
    func didComment(forCase clinicalCase: Case) {
        if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                cases[index].numberOfComments += 1
                cell.viewModel?.clinicalCase.numberOfComments += 1
            }
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
        
        if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            cases[index].phase = .solved
            if let diagnosis {
                cases[index].revision = diagnosis.kind
            }

            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
}
