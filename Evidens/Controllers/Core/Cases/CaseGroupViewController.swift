//
//  CaseGroupViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/11/23.
//

import UIKit

private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"
private let primaryEmtpyCellReuseIdentifier = "PrimaryEmtpyCellReuseIdentifier"

class CaseGroupViewController: UIViewController {
    
    private var viewModel: CaseGroupViewModel!
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
        configureNotificationObservers()
        getCases()
    }
    
    init(group: CaseGroup) {
        self.viewModel = CaseGroupViewModel(group: group)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        navigationItem.title = viewModel.getTitle()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.filter, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), style: .done, target: self, action: #selector(handleFilter))
    }
    
    private func configure() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCasesLayout())
        collectionView.register(PrimaryCaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        collectionView.register(PrimaryCaseImageCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        collectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: primaryEmtpyCellReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        
        view.addSubview(collectionView)
    }
    
    private func getCases() {
        viewModel.getCases { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
        }
    }
    
    private func getMoreCases() {
        viewModel.getMoreCases { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
        }
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
    
    private func createCasesLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            
            if strongSelf.viewModel.cases.isEmpty && strongSelf.viewModel.casesLoaded {
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
                
                if !strongSelf.viewModel.casesLoaded {
                    section.boundarySupplementaryItems = [header]
                } else {
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                }
                
                return section
            }
        }
        
        return layout
    }
    
    @objc func handleFilter() {
        let controller = CaseFiltersViewController(filter: viewModel.filter)
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}

extension CaseGroupViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.casesLoaded ? viewModel.cases.isEmpty ? 1 : viewModel.cases.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.cases.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: primaryEmtpyCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
            cell.set(withTitle: AppStrings.Content.Case.Empty.emptyFeed, withDescription: AppStrings.Content.Case.Empty.emptyFeedContent, withButtonText: AppStrings.Content.Case.Empty.share)
            cell.delegate = self
            return cell
        } else {
            let currentCase = viewModel.cases[indexPath.row]
            
            if UIDevice.isPad {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! PrimaryCaseImageCell
                cell.delegate = self
                cell.viewModel = CaseViewModel(clinicalCase: currentCase)

                guard currentCase.privacy == .regular else {
                    cell.anonymize()
                    return cell
                }
                
                if let userIndex = viewModel.users.firstIndex(where: { $0.uid == currentCase.uid }) {
                    cell.set(user: viewModel.users[userIndex])
                }
                
                return cell
            } else {
                switch currentCase.kind {
                    
                case .text:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! PrimaryCaseTextCell
                    cell.delegate = self
                    cell.viewModel = CaseViewModel(clinicalCase: currentCase)

                    guard viewModel.cases[indexPath.row].privacy == .regular else {
                        cell.anonymize()
                        return cell
                    }
                    
                    if let userIndex = viewModel.users.firstIndex(where: { $0.uid == currentCase.uid }) {
                        cell.set(user: viewModel.users[userIndex])
                    }
                    
                    return cell

                case .image:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! PrimaryCaseImageCell
                    cell.delegate = self
                    cell.viewModel = CaseViewModel(clinicalCase: currentCase)

                    guard viewModel.cases[indexPath.row].privacy == .regular else {
                        cell.anonymize()
                        return cell
                    }
                    
                    if let userIndex = viewModel.users.firstIndex(where: { $0.uid == currentCase.uid }) {
                        cell.set(user: viewModel.users[userIndex])
                    }
                    
                    return cell
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
}

extension CaseGroupViewController: CaseCellDelegate {
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
    
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) {
        return 
    }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) {
        return
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) { return }
    
    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) { return }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) { return }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) { return }

    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User?) {
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user)
       
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension CaseGroupViewController: PrimaryEmptyCellDelegate {
    func didTapEmptyAction() {
        guard let tab = tabBarController as? MainTabController else { return }
        tab.didTapUpload(content: .clinicalCase)
    }
}

extension CaseGroupViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreCases()
        }
    }
}

extension CaseGroupViewController {
    
    @objc func caseVisibleChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseVisibleChange {
            
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                viewModel.cases.remove(at: index)
                collectionView.reloadData()
            }
        }
    }

    @objc func caseLikeChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseLikeChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                let likes = viewModel.cases[index].likes
                
                viewModel.cases[index].didLike = change.didLike
                viewModel.cases[index].likes = change.didLike ? likes + 1 : likes - 1
                collectionView.reloadData()
            }
        }
    }
    
    @objc func caseBookmarkChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseBookmarkChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                viewModel.cases[index].didBookmark = change.didBookmark
                collectionView.reloadData()
            }
        }
    }
    
    @objc func caseCommentChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseCommentChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                let comments = viewModel.cases[index].numberOfComments

                switch change.action {
                    
                case .add:
                    viewModel.cases[index].numberOfComments = comments + 1
                case .remove:
                    viewModel.cases[index].numberOfComments = comments - 1
                case .edit:
                    break
                }
                
                collectionView.reloadData()
            }
        }
    }
    
    @objc func caseRevisionChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseRevisionChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                viewModel.cases[index].revision = .update
                collectionView.reloadData()
            }
        }
    }
    
    @objc func caseSolveChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseSolveChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                viewModel.cases[index].phase = .solved
                
                if let diagnosis = change.diagnosis {
                    viewModel.cases[index].revision = diagnosis
                }
                
                collectionView.reloadData()
            }
        }
    }
}

extension CaseGroupViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            if let index = viewModel.users.firstIndex(where: { $0.uid! == user.uid! }) {
                viewModel.users[index] = user
                collectionView.reloadData()
            }
        }
    }
}

extension CaseGroupViewController: CaseFiltersViewControllerDelegate {
    func didTapFilter(_ filter: CaseFilter) {
        guard filter != viewModel.filter else { return }
        viewModel.set(filter: filter)
        collectionView.reloadData()
        getCases()
    }
}


