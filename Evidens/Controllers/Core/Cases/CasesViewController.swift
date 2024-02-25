//
//  CasesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/9/22.
//

import UIKit
import Firebase

private let exploreHeaderReuseIdentifier = "ExploreHeaderReuseIdentifier"
private let exploreCellReuseIdentifier = "ExploreCellReuseIdentifier"
private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"
private let primaryEmtpyCellReuseIdentifier = "PrimaryEmptyCellReuseIdentifier"
private let exploreCaseCellReuseIdentifier = "ExploreCaseCellReuseIdentifier"
private let filterCellReuseIdentifier = "FilterCellReuseIdentifier"
private let networkFailureCellReuseIdentifier = "NetworkFailureCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let bodyCellReuseIdentifier = "BodyCellReuseIdentifier"

class CasesViewController: NavigationBarViewController, UINavigationControllerDelegate {
    
    private var viewModel = PrimaryCasesViewModel()
    
    private var caseToolbar = CaseToolbar()
    private var spacingView = SpacingView()
    
    private var zoomTransitioning = ZoomTransitioning()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private var forYouCollectionView: UICollectionView!
    private var latestCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        getCases()
        configureNotificationObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
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
    
    private func getCases() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        viewModel.getForYouCases(user: user) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.forYouCollectionView.refreshControl?.endRefreshing()
            strongSelf.forYouCollectionView.reloadData()
        }
    }
    
    private func getLatestCases() {
        viewModel.getLatestCases { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.latestCollectionView.refreshControl?.endRefreshing()
            strongSelf.latestCollectionView.reloadData()
        }
    }
    
    private func createForYouLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            
            if strongSelf.viewModel.forYouCases.isEmpty && strongSelf.viewModel.forYouLoaded {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(UIScreen.main.bounds.height * 0.6)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(UIScreen.main.bounds.height * 0.6)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                return section
            } else {
                let width: NSCollectionLayoutDimension = UIDevice.isPad ? .fractionalWidth(0.5) : .fractionalWidth(1.0)
                let height: NSCollectionLayoutDimension = UIDevice.isPad ? .fractionalWidth(0.4) : .estimated(300)
                
                let itemSize = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: height)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                if UIDevice.isPad {
                    group.interItemSpacing = .fixed(20)
                }

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 20
                
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: ElementKind.sectionHeader, alignment: .top)
                
                if !strongSelf.viewModel.forYouLoaded {
                    section.boundarySupplementaryItems = [header]
                } else {
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                }
                
                return section
            }
        }
        
        return layout
    }

    private func createLatestLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            
            if strongSelf.viewModel.latestCases.isEmpty && strongSelf.viewModel.latestLoaded {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(UIScreen.main.bounds.height * 0.6)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(UIScreen.main.bounds.height * 0.6)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                return section
            } else {
                let width: NSCollectionLayoutDimension = UIDevice.isPad ? .fractionalWidth(0.5) : .fractionalWidth(1.0)
                let height: NSCollectionLayoutDimension = UIDevice.isPad ? .fractionalWidth(0.4) : .estimated(300)
                
                let itemSize = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: height)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                if UIDevice.isPad {
                    group.interItemSpacing = .fixed(20)
                }

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 20
                
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: ElementKind.sectionHeader, alignment: .top)
                
                if !strongSelf.viewModel.latestLoaded {
                    section.boundarySupplementaryItems = [header]
                } else {
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                }
                
                return section
            }
        }
        
        return layout
    }
    
    private func configureCollectionView() {
        forYouCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createForYouLayout())
        latestCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLatestLayout())
        
        forYouCollectionView.delegate = self
        forYouCollectionView.dataSource = self
        latestCollectionView.delegate = self
        latestCollectionView.dataSource = self
        
        forYouCollectionView.translatesAutoresizingMaskIntoConstraints = false
        latestCollectionView.translatesAutoresizingMaskIntoConstraints = false
        spacingView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubviews(caseToolbar, scrollView)
        scrollView.addSubviews(forYouCollectionView, spacingView, latestCollectionView)
        
        NSLayoutConstraint.activate([
            caseToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            caseToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            caseToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            caseToolbar.heightAnchor.constraint(equalToConstant: 50),
            
            scrollView.topAnchor.constraint(equalTo: caseToolbar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: view.frame.width + 10),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            forYouCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            forYouCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            forYouCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            forYouCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            spacingView.topAnchor.constraint(equalTo: forYouCollectionView.topAnchor),
            spacingView.leadingAnchor.constraint(equalTo: forYouCollectionView.trailingAnchor),
            spacingView.widthAnchor.constraint(equalToConstant: 10),
            spacingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            latestCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            latestCollectionView.leadingAnchor.constraint(equalTo: spacingView.trailingAnchor),
            latestCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width),
            latestCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        configureAddButton(primaryAppearance: true)
        scrollView.contentSize.width = view.frame.width * 2 + 2 * 10
        caseToolbar.toolbarDelegate = self
        scrollView.delegate = self

        forYouCollectionView.contentInset.bottom = 85
        latestCollectionView.contentInset.bottom = 85
        
        forYouCollectionView.register(PrimaryCaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        forYouCollectionView.register(PrimaryCaseImageCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        forYouCollectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: primaryEmtpyCellReuseIdentifier)
        forYouCollectionView.register(PrimaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
        forYouCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        
        latestCollectionView.register(PrimaryCaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        latestCollectionView.register(PrimaryCaseImageCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        latestCollectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: primaryEmtpyCellReuseIdentifier)
        latestCollectionView.register(PrimaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
        latestCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
    }
    
    func casesLoaded() -> Bool {
        switch viewModel.scrollIndex {
        case 0:
            return viewModel.forYouLoaded
        case 1:
            return viewModel.latestLoaded
        default:
            return false
        }
    }
    
    private func getMoreForYouCases() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        viewModel.getMoreForYouCases(forUser: user) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.forYouCollectionView.reloadData()
        }
    }
    
    private func getMoreLatestCases() {
        viewModel.getMoreLatestCases { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.latestCollectionView.reloadData()
        }
    }
}

extension CasesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == forYouCollectionView {
            return viewModel.forYouLoaded ? viewModel.forYouNetwork ? 1 : viewModel.forYouCases.isEmpty ? 1 : viewModel.forYouCases.count : 0
        } else {
            return viewModel.latestLoaded ? viewModel.latestNetwork ? 1 : viewModel.latestCases.isEmpty ? 1 : viewModel.latestCases.count : 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == forYouCollectionView {
            if viewModel.forYouNetwork {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
                cell.set(AppStrings.Network.Issues.Case.title)
                cell.delegate = self
                return cell
            } else {
                return getCellForCase(cases: viewModel.forYouCases, users: viewModel.forYouUsers, indexPath: indexPath, collectionView: collectionView)
            }
        } else {
            if viewModel.latestNetwork {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
                cell.set(AppStrings.Network.Issues.Case.title)
                cell.delegate = self
                return cell
            } else {
                return getCellForCase(cases: viewModel.latestCases, users: viewModel.latestUsers, indexPath: indexPath, collectionView: collectionView)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    private func getCellForCase(cases: [Case], users: [User], indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        if cases.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: primaryEmtpyCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
            cell.set(withTitle: AppStrings.Content.Case.Empty.emptyFeed, withDescription: AppStrings.Content.Case.Empty.emptyFeedContent, withButtonText: AppStrings.Content.Case.Empty.share)
            cell.delegate = self
            return cell
        } else {
            
            let currentCase = cases[indexPath.row]
            
            if UIDevice.isPad {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! PrimaryCaseImageCell
                cell.delegate = self
                cell.viewModel = CaseViewModel(clinicalCase: currentCase)

                guard cases[indexPath.row].privacy == .regular else {
                    cell.anonymize()
                    return cell
                }
                
                if let userIndex = users.firstIndex(where: { $0.uid == currentCase.uid }) {
                    cell.set(user: users[userIndex])
                }
                
                return cell
            } else {
                switch currentCase.kind {
                    
                case .text:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! PrimaryCaseTextCell
                    cell.delegate = self
                    cell.viewModel = CaseViewModel(clinicalCase: currentCase)
                    
                    guard cases[indexPath.row].privacy == .regular else {
                        cell.anonymize()
                        return cell
                    }
                    
                    if let userIndex = users.firstIndex(where: { $0.uid == currentCase.uid }) {
                        cell.set(user: users[userIndex])
                    }
                    
                    return cell

                case .image:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! PrimaryCaseImageCell
                    cell.delegate = self
                    cell.viewModel = CaseViewModel(clinicalCase: currentCase)

                    guard cases[indexPath.row].privacy == .regular else {
                        cell.anonymize()
                        return cell
                    }
                    
                    if let userIndex = users.firstIndex(where: { $0.uid == currentCase.uid }) {
                        cell.set(user: users[userIndex])
                    }
                    
                    return cell
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        guard !viewModel.isScrollingHorizontally else {
            return
        }
        
        if offsetY > contentHeight - height {
            switch viewModel.scrollIndex {
            case 0:
                getMoreForYouCases()
            case 1:
                getMoreLatestCases()
            default:
                break
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView == latestCollectionView || scrollView == forYouCollectionView {
            viewModel.isScrollingHorizontally = false
            
        } else if scrollView == self.scrollView {
            viewModel.isScrollingHorizontally = true
            caseToolbar.collectionViewDidScroll(for: scrollView.contentOffset.x)
            
            if scrollView.contentOffset.x > view.frame.width * 0.2 && !viewModel.isFetchingOrDidFetchLatest {
                getLatestCases()
            }
            
            switch scrollView.contentOffset.x {
            case 0 ..< view.frame.width + 10:
                viewModel.scrollIndex = 0
            case view.frame.width + 10 ..< 2 * (view.frame.width + 10):
                viewModel.scrollIndex = 1
            default:
                break
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrollView.isUserInteractionEnabled = true
        forYouCollectionView.isScrollEnabled = true
        latestCollectionView.isScrollEnabled = true
    }
}

extension CasesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension CasesViewController: CaseToolbarDelegate {
    func didTapIndex(_ index: Int) {
        
        switch viewModel.scrollIndex {
        case 0:
            forYouCollectionView.setContentOffset(forYouCollectionView.contentOffset, animated: false)
        case 1:
            latestCollectionView.setContentOffset(latestCollectionView.contentOffset, animated: false)
        default:
            break
        }

        guard viewModel.isFirstLoad else {
            viewModel.isFirstLoad.toggle()
            scrollView.setContentOffset(CGPoint(x: index * Int(view.frame.width) + index * 10, y: 0), animated: true)
            viewModel.scrollIndex = index
            return
        }
        
        self.scrollView.isUserInteractionEnabled = false
        forYouCollectionView.isScrollEnabled = false
        latestCollectionView.isScrollEnabled = false
        
        scrollView.setContentOffset(CGPoint(x: index * Int(view.frame.width) + index * 10, y: 0), animated: true)
        viewModel.scrollIndex = index
    }
}

extension CasesViewController: CaseCellDelegate {
    func clinicalCase(didTapMenuOptionsFor clinicalCase: Case, option: CaseMenu) {
        switch option {
        case .delete, .revision, .solve: break
        case .report:
            let controller = ReportViewController(source: .clinicalCase, userId: clinicalCase.uid, contentId: clinicalCase.caseId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
        }
    }
    
    func clinicalCase(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User?) {
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user)
       
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) { return }

    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) { return }
   
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }

    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) { return }
    
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) { return }
    
    func scrollCollectionViewToTop() {
        
        switch viewModel.scrollIndex {
        case 0:
            forYouCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        case 1:
            latestCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        default:
            break
        }
    }
    
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) { return }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) { return }
}

extension CasesViewController: PrimaryEmptyCellDelegate {
    func didTapEmptyAction() {
        guard let tab = tabBarController as? MainTabController else { return }
        tab.didTapUpload(content: .clinicalCase)
    }
}

extension CasesViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        switch viewModel.scrollIndex {
        case 0:
            viewModel.forYouNetwork = false
            viewModel.forYouLoaded = false
            forYouCollectionView.reloadData()
            
            guard let tab = tabBarController as? MainTabController else { return }
            guard let user = tab.user else { return }
            
            viewModel.getForYouCases(user: user) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.forYouCollectionView.refreshControl?.endRefreshing()
                strongSelf.forYouCollectionView.reloadData()
            }
        case 1:
            viewModel.latestNetwork = false
            viewModel.latestLoaded = false
            latestCollectionView.reloadData()
            
            viewModel.getLatestCases { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.latestCollectionView.refreshControl?.endRefreshing()
                strongSelf.latestCollectionView.reloadData()
            }
        default:
            break
        }
    }
}

extension CasesViewController {
    
    @objc func caseVisibleChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseVisibleChange {
            
            if let index = viewModel.forYouCases.firstIndex(where: { $0.caseId == change.caseId }) {
                viewModel.forYouCases.remove(at: index)
                forYouCollectionView.reloadData()
            }
            
            if let index = viewModel.latestCases.firstIndex(where: { $0.caseId == change.caseId }) {
                viewModel.latestCases.remove(at: index)
                latestCollectionView.reloadData()
            }
        }
    }

    @objc func caseLikeChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseLikeChange {
            if let index = viewModel.forYouCases.firstIndex(where: { $0.caseId == change.caseId }) {
                let likes = viewModel.forYouCases[index].likes
                
                viewModel.forYouCases[index].didLike = change.didLike
                viewModel.forYouCases[index].likes = change.didLike ? likes + 1 : likes - 1
                forYouCollectionView.reloadData()
            }
            
            if let index = viewModel.latestCases.firstIndex(where: { $0.caseId == change.caseId }) {
                let likes = viewModel.latestCases[index].likes
                
                viewModel.latestCases[index].didLike = change.didLike
                viewModel.latestCases[index].likes = change.didLike ? likes + 1 : likes - 1
                latestCollectionView.reloadData()
            }
        }
    }
    
    @objc func caseBookmarkChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseBookmarkChange {
            if let index = viewModel.forYouCases.firstIndex(where: { $0.caseId == change.caseId }) {
                viewModel.forYouCases[index].didBookmark = change.didBookmark
                forYouCollectionView.reloadData()
            }
            
            if let index = viewModel.latestCases.firstIndex(where: { $0.caseId == change.caseId }) {
                viewModel.latestCases[index].didBookmark = change.didBookmark
                latestCollectionView.reloadData()
            }
        }
    }
    
    @objc func caseCommentChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseCommentChange {
            if let index = viewModel.forYouCases.firstIndex(where: { $0.caseId == change.caseId }) {
                let comments = viewModel.forYouCases[index].numberOfComments

                switch change.action {
                    
                case .add:
                    viewModel.forYouCases[index].numberOfComments = comments + 1
                case .remove:
                    viewModel.forYouCases[index].numberOfComments = comments - 1
                case .edit:
                    break
                }
                
                forYouCollectionView.reloadData()
            }
            
            if let index = viewModel.latestCases.firstIndex(where: { $0.caseId == change.caseId }) {
                let comments = viewModel.latestCases[index].numberOfComments

                switch change.action {
                    
                case .add:
                    viewModel.latestCases[index].numberOfComments = comments + 1
                case .remove:
                    viewModel.latestCases[index].numberOfComments = comments - 1
                case .edit:
                    break
                }
                
                latestCollectionView.reloadData()
            }
        }
    }
    
    @objc func caseRevisionChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseRevisionChange {
            if let index = viewModel.forYouCases.firstIndex(where: { $0.caseId == change.caseId }) {
                viewModel.forYouCases[index].revision = .update
                forYouCollectionView.reloadData()
            }

            if let index = viewModel.latestCases.firstIndex(where: { $0.caseId == change.caseId }) {
                viewModel.latestCases[index].revision = .update
                latestCollectionView.reloadData()
            }
        }
    }
    
    @objc func caseSolveChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseSolveChange {
            if let index = viewModel.forYouCases.firstIndex(where: { $0.caseId == change.caseId }) {
                viewModel.forYouCases[index].phase = .solved
                
                if let diagnosis = change.diagnosis {
                    viewModel.forYouCases[index].revision = diagnosis
                }
                
                forYouCollectionView.reloadData()
            }
            
            if let index = viewModel.latestCases.firstIndex(where: { $0.caseId == change.caseId }) {
                viewModel.latestCases[index].phase = .solved
                
                if let diagnosis = change.diagnosis {
                    viewModel.latestCases[index].revision = diagnosis
                }
                
                latestCollectionView.reloadData()
            }
        }
    }
}

extension CasesViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            if let index = viewModel.forYouUsers.firstIndex(where: { $0.uid! == user.uid! }) {
                viewModel.forYouUsers[index] = user
                forYouCollectionView.reloadData()
            }
            
            if let index = viewModel.latestUsers.firstIndex(where: { $0.uid! == user.uid! }) {
                viewModel.latestUsers[index] = user
                latestCollectionView.reloadData()
            }
        }
    }
}

