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
    private var currentNotification: Bool = false
    private var zoomTransitioning = ZoomTransitioning()
    var selectedImage: UIImageView!
    
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
        configureNotificationObservers()
        fetchFirstGroupOfCases()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.delegate = self
    }

    private func configureUI() {
        view.backgroundColor = .systemBackground
    }
    
    private func configureNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseLike), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseBookmarkChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseBookmark), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseRevisionChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseRevision), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseSolveChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseSolve), object: nil)
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
                    
                    if error == .network {
                        strongSelf.networkIssue = true
                    }
                    
                    strongSelf.activityIndicator.stop()
                    strongSelf.collectionView.reloadData()
                    strongSelf.collectionView.isHidden = false
                    
                    guard error != .notFound else {
                        return
                    }
                }
            }
        case .search:
            CaseService.fetchUserSearchCases(user: user, lastSnapshot: nil) { [weak self] result in

                guard let strongSelf = self else { return }
                
                switch result {
                    
                case .success(let snapshot):
                    strongSelf.casesLastSnapshot = snapshot.documents.last
                    strongSelf.cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data() )}
                    
                    let uids = strongSelf.cases.filter { $0.privacy == .regular }.map { $0.uid }
                    let uniqueUids = Array(Set(uids))
                    
                    let group = DispatchGroup()
                    
                    if !uniqueUids.isEmpty {
                        group.enter()
                        UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.users = users
                            group.leave()
                        }
                    }
                    
                    
                    group.enter()
                    CaseService.getCaseValuesFor(cases: strongSelf.cases) { [weak self] cases in
                        guard let strongSelf = self else { return }
                        strongSelf.cases = cases
                        group.leave()
                    }
                    
                    group.notify(queue: .main) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.cases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                        strongSelf.activityIndicator.stop()
                        strongSelf.collectionView.reloadData()
                        strongSelf.collectionView.isHidden = false
                    }
                 
                case .failure(let error):
                    
                    if error == .network {
                        strongSelf.networkIssue = true
                    }
                    
                    strongSelf.activityIndicator.stop()
                    strongSelf.collectionView.reloadData()
                    strongSelf.collectionView.isHidden = false
                    
                    guard error != .notFound else {
                        return
                    }
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
        
        let caseId = clinicalCase.caseId
        let didLike = self.cases[indexPath.row].didLike
        caseDidChangeLike(caseId: caseId, didLike: didLike)
        
        // Toggle the like state and count
        cell.viewModel?.clinicalCase.didLike.toggle()
        self.cases[indexPath.row].didLike.toggle()
        
        cell.viewModel?.clinicalCase.likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        self.cases[indexPath.row].likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        
    }
    
    func handleBookmarkUnbookmark(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        let caseId = clinicalCase.caseId
        let didBookmark = self.cases[indexPath.row].didBookmark
        caseDidChangeBookmark(caseId: caseId, didBookmark: didBookmark)
        
        // Toggle the bookmark state
        cell.viewModel?.clinicalCase.didBookmark.toggle()
        self.cases[indexPath.row].didBookmark.toggle()
        
    }
}

extension CaseViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let clinicalCase = cases[indexPath.row]
        
        switch clinicalCase.kind {
            
        case .text:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
            cell.delegate = self
            cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
            
            switch contentSource {
            case .user:
                cell.set(user: user)
            case .search:
                if clinicalCase.privacy == .anonymous {
                    cell.anonymize()
                } else {
                    if let userIndex = users.firstIndex(where:  { $0.uid! == cases[indexPath.row].uid }) {
                        cell.set(user: users[userIndex])
                    }
                }
            }

            return cell
        case .image:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
            
            cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
            cell.delegate = self
            switch contentSource {
            case .user:
                cell.set(user: user)
            case .search:
                if clinicalCase.privacy == .anonymous {
                    cell.anonymize()
                } else {
                    if let userIndex = users.firstIndex(where:  { $0.uid! == cases[indexPath.row].uid }) {
                        cell.set(user: users[userIndex])
                    }
                }
            }

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
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: CaseMenu) {
        switch option {
        case .delete:
            #warning("Pending Deletion")
        case .revision:
            let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: user)
            navigationController?.pushViewController(controller, animated: true)
        case .solve:
            let controller = CaseDiagnosisViewController(clinicalCase: clinicalCase)
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
                    cases.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
                    
                    CaseService.getCaseValuesFor(cases: cases) { [weak self] newCases in
                        guard let strongSelf = self else { return }
                        strongSelf.cases.append(contentsOf: newCases)
                        strongSelf.collectionView.reloadData()
                    }
                case .failure(_):
                    break
                }
            }
        case .search:
            CaseService.fetchUserSearchCases(user: user, lastSnapshot: casesLastSnapshot) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let snapshot):
                    strongSelf.casesLastSnapshot = snapshot.documents.last
                    var cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data() )}
                    
                    let uids = strongSelf.cases.filter { $0.privacy == .regular }.map { $0.uid }
                    let uniqueUids = Array(Set(uids))
                    
                    let currentUids = strongSelf.users.map { $0.uid }
                    let uidsToFetch = uniqueUids.filter { !currentUids.contains($0) }
                    
                    
                    let group = DispatchGroup()
                    
                    if !uidsToFetch.isEmpty {
                        group.enter()
                        UserService.fetchUsers(withUids: uidsToFetch) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.users.append(contentsOf: users)
                            group.leave()
                        }
                    }
                    
                    group.enter()
                    CaseService.getCaseValuesFor(cases: cases) { [weak self] newCases in
                        guard let strongSelf = self else { return }
                        strongSelf.cases.append(contentsOf: newCases)
                        group.leave()
                    }
                    
                    group.notify(queue: .main) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.collectionView.reloadData()
                    }
  
                case .failure(_):
                    break
                }
            }
        }
    }
}

extension CaseViewController: CaseChangesDelegate {
    
    func caseDidChangeLike(caseId: String, didLike: Bool) {
        currentNotification = true
        ContentManager.shared.likeCaseChange(caseId: caseId, didLike: !didLike)
    }
    
    
    @objc func caseLikeChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }

        if let change = notification.object as? CaseLikeChange {
            if let index = cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)), let currentCell = cell as? CaseCellProtocol {

                    let likes = self.cases[index].likes
                    
                    self.cases[index].likes = change.didLike ? likes + 1 : likes - 1
                    self.cases[index].didLike = change.didLike
                    
                    currentCell.viewModel?.clinicalCase.didLike = change.didLike
                    currentCell.viewModel?.clinicalCase.likes = change.didLike ? likes + 1 : likes - 1
                }
            }
        }
    }
    
    func caseDidChangeBookmark(caseId: String, didBookmark: Bool) {
        currentNotification = true
        ContentManager.shared.bookmarkCaseChange(caseId: caseId, didBookmark: !didBookmark)
    }
    
    
    @objc func caseBookmarkChange(_ notification: NSNotification) {
        guard !currentNotification else {
            currentNotification.toggle()
            return
        }

        if let change = notification.object as? CaseBookmarkChange {
            if let index = cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)), let currentCell = cell as? CaseCellProtocol {

                    self.cases[index].didBookmark = change.didBookmark
                    currentCell.viewModel?.clinicalCase.didBookmark = change.didBookmark
                }
            }
        }
    }
    
    @objc func caseRevisionChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseRevisionChange {
            if let index = cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                    
                    cell.viewModel?.clinicalCase.revision = .update
                    cases[index].revision = .update
                    collectionView.reloadData()
                }
            }
        }
    }
    
    func caseDidChangeComment(caseId: String, comment: Comment, action: CommentAction) {
        fatalError()
    }

    @objc func caseCommentChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseCommentChange {
            if let index = cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                    
                    let comments = self.cases[index].numberOfComments

                    switch change.action {
                        
                    case .add:
                        cases[index].numberOfComments = comments + 1
                        cell.viewModel?.clinicalCase.numberOfComments = comments + 1
                    case .remove:
                        cases[index].numberOfComments = comments - 1
                        cell.viewModel?.clinicalCase.numberOfComments = comments - 1
                    }
                }
            }
        }
    }
    
    @objc func caseSolveChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseSolveChange {
            if let index = cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                    
                    cell.viewModel?.clinicalCase.phase = .solved
                    cases[index].phase = .solved
                    
                    if let diagnosis = change.diagnosis {
                        cases[index].revision = diagnosis
                        cell.viewModel?.clinicalCase.revision = diagnosis
                    }
                    collectionView.reloadData()
                }
            }
        }
    }
}
