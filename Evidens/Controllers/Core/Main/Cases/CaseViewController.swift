//
//  CaseViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/7/22.
//

import UIKit
import Firebase

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"

class CaseViewController: UIViewController, UINavigationControllerDelegate {
    
    private var viewModel: SecondaryCasesViewModel

    private var zoomTransitioning = ZoomTransitioning()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing  = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .leastNonzeroMagnitude)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    init(user: User, contentSource: CaseSource) {
        self.viewModel = SecondaryCasesViewModel(user: user, contentSource: contentSource)
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
        NotificationCenter.default.addObserver(self, selector: #selector(caseVisibleChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseVisibility), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseLikeChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseLike), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseBookmarkChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseBookmark), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseCommentChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseComment), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseRevisionChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseRevision), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseSolveChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseSolve), object: nil)
    }
    
    private func reloadData() {
        collectionView.reloadData()
    }
    
    private func fetchFirstGroupOfCases() {
        viewModel.getFirstGroupOfCases { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.reloadData()
        }
    }
    
    private func configureNavigationBar() {
        if viewModel.contentSource == .search { return }
        title = AppStrings.Search.Topics.cases
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.leftChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.white).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func configureCollectionView() {
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(CaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        collectionView.register(CaseTextImageCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.frame = view.bounds
       
        view.addSubviews(collectionView)
    }
    
    private func deleteCase(withId id: String, privacy: CasePrivacy, at indexPath: IndexPath) {
        displayAlert(withTitle: AppStrings.Alerts.Title.deleteCase, withMessage: AppStrings.Alerts.Subtitle.deleteCase, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            
            guard let strongSelf
                    = self else { return }
            
            strongSelf.viewModel.deleteCase(withId: id, privacy: privacy) { [weak self] error in
                guard let strongSelf = self else { return }
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    strongSelf.caseDidChangeVisible(caseId: id)
                    
                    strongSelf.viewModel.cases.remove(at: indexPath.item)
                    if strongSelf.viewModel.cases.isEmpty {
                        strongSelf.collectionView.reloadData()
                    } else {
                        strongSelf.collectionView.deleteItems(at: [indexPath])
                    }
                }
            }
        }
    }
    
    private func handleLikeUnLike(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        let caseId = clinicalCase.caseId
        let didLike = viewModel.cases[indexPath.row].didLike
        caseDidChangeLike(caseId: caseId, didLike: didLike)

        cell.viewModel?.clinicalCase.didLike.toggle()
        viewModel.cases[indexPath.row].didLike.toggle()
        
        cell.viewModel?.clinicalCase.likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
        viewModel.cases[indexPath.row].likes = clinicalCase.didLike ? clinicalCase.likes - 1 : clinicalCase.likes + 1
    }
    
    func handleBookmarkUnbookmark(for cell: CaseCellProtocol, at indexPath: IndexPath) {
        guard let clinicalCase = cell.viewModel?.clinicalCase else { return }
        
        let caseId = clinicalCase.caseId
        let didBookmark = viewModel.cases[indexPath.row].didBookmark
        caseDidChangeBookmark(caseId: caseId, didBookmark: didBookmark)

        cell.viewModel?.clinicalCase.didBookmark.toggle()
        viewModel.cases[indexPath.row].didBookmark.toggle()
    }
}

extension CaseViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.loaded ? viewModel.cases.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return viewModel.loaded ? CGSize.zero : CGSize(width: view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let clinicalCase = viewModel.cases[indexPath.row]
        
        switch clinicalCase.kind {
            
        case .text:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseTextCell
            cell.delegate = self
            cell.viewModel = CaseViewModel(clinicalCase: viewModel.cases[indexPath.row])
            
            switch viewModel.contentSource {
            
            case .search:
                if clinicalCase.privacy == .anonymous {
                    cell.anonymize()
                } else {
                    if let userIndex = viewModel.users.firstIndex(where:  { $0.uid! == viewModel.cases[indexPath.row].uid }) {
                        cell.set(user: viewModel.users[userIndex])
                    }
                }
            }

            return cell
        case .image:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseTextImageCell
            
            cell.viewModel = CaseViewModel(clinicalCase: viewModel.cases[indexPath.row])
            cell.delegate = self
            switch viewModel.contentSource {
            
            case .search:
                if clinicalCase.privacy == .anonymous {
                    cell.anonymize()
                } else {
                    if let userIndex = viewModel.users.firstIndex(where:  { $0.uid! == viewModel.cases[indexPath.row].uid }) {
                        cell.set(user: viewModel.users[userIndex])
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
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: .leastNonzeroMagnitude)
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
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                deleteCase(withId: clinicalCase.caseId, privacy: clinicalCase.privacy, at: IndexPath(item: index , section: 0))
            }

        case .revision:
            let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: viewModel.user)
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
        viewModel.selectedImage = image[index]
        navigationController?.delegate = zoomTransitioning

        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)

        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) {
        let controller = CaseRevisionViewController(clinicalCase: clinicalCase, user: viewModel.user)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) { return }
    
    
    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? CaseCellProtocol else { return }
        handleBookmarkUnbookmark(for: currentCell, at: indexPath)
        
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) {
        guard let indexPath = collectionView.indexPath(for: cell), let currentCell = cell as? CaseCellProtocol else { return }
        handleLikeUnLike(for: currentCell, at: indexPath)
    }
    
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) {
        let controller = LikesViewController(clinicalCase: clinicalCase)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: .leastNonzeroMagnitude)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, collectionViewFlowLayout: layout)

        navigationController?.pushViewController(controller, animated: true)
    }
}

extension CaseViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return viewModel.selectedImage
    }
}

extension CaseViewController {
    func getMoreCases() {
        viewModel.getMoreCases { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
        }
    }
}

extension CaseViewController: CaseChangesDelegate {

    func caseDidChangeVisible(caseId: String) {
        viewModel.currentNotification = true
        ContentManager.shared.visibleCaseChange(caseId: caseId)
    }
    
    @objc func caseVisibleChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }
        
        if let change = notification.object as? CaseVisibleChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                
                viewModel.cases.remove(at: index)
                if viewModel.cases.isEmpty {
                    collectionView.reloadData()
                } else {
                    collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                }
            }
        }
    }

    func caseDidChangeLike(caseId: String, didLike: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.likeCaseChange(caseId: caseId, didLike: !didLike)
    }
    
    
    @objc func caseLikeChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }

        if let change = notification.object as? CaseLikeChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)), let currentCell = cell as? CaseCellProtocol {

                    let likes = viewModel.cases[index].likes
                    
                    viewModel.cases[index].likes = change.didLike ? likes + 1 : likes - 1
                    viewModel.cases[index].didLike = change.didLike
                    
                    currentCell.viewModel?.clinicalCase.didLike = change.didLike
                    currentCell.viewModel?.clinicalCase.likes = change.didLike ? likes + 1 : likes - 1
                }
            }
        }
    }
    
    func caseDidChangeBookmark(caseId: String, didBookmark: Bool) {
        viewModel.currentNotification = true
        ContentManager.shared.bookmarkCaseChange(caseId: caseId, didBookmark: !didBookmark)
    }
    
    
    @objc func caseBookmarkChange(_ notification: NSNotification) {
        guard !viewModel.currentNotification else {
            viewModel.currentNotification.toggle()
            return
        }

        if let change = notification.object as? CaseBookmarkChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)), let currentCell = cell as? CaseCellProtocol {

                    viewModel.cases[index].didBookmark = change.didBookmark
                    currentCell.viewModel?.clinicalCase.didBookmark = change.didBookmark
                }
            }
        }
    }
    
    @objc func caseRevisionChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseRevisionChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                    
                    cell.viewModel?.clinicalCase.revision = .update
                    viewModel.cases[index].revision = .update
                    collectionView.reloadData()
                }
            }
        }
    }

    func caseDidChangeComment(caseId: String, path: [String], comment: Comment, action: CommentAction) {
        fatalError()
    }
    

    @objc func caseCommentChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseCommentChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }), change.path.isEmpty {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                    
                    let comments = viewModel.cases[index].numberOfComments

                    switch change.action {
                        
                    case .add:
                        viewModel.cases[index].numberOfComments = comments + 1
                        cell.viewModel?.clinicalCase.numberOfComments = comments + 1
                    case .remove:
                        viewModel.cases[index].numberOfComments = comments - 1
                        cell.viewModel?.clinicalCase.numberOfComments = comments - 1
                    }
                }
            }
        }
    }
    
    @objc func caseSolveChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseSolveChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                    
                    cell.viewModel?.clinicalCase.phase = .solved
                    viewModel.cases[index].phase = .solved
                    
                    if let diagnosis = change.diagnosis {
                        viewModel.cases[index].revision = diagnosis
                        cell.viewModel?.clinicalCase.revision = diagnosis
                    }
                    collectionView.reloadData()
                }
            }
        }
    }
}


extension CaseViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            
            switch viewModel.contentSource {
                
            case .search:
                if let index = viewModel.users.firstIndex(where: { $0.uid! == user.uid! }) {
                    viewModel.users[index] = user
                    collectionView.reloadData()
                }
            }
        }
    }
}

