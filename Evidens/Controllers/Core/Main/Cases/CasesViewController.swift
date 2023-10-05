//
//  CasesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/9/22.
//

import UIKit
import Firebase
import MessageUI

private let exploreHeaderReuseIdentifier = "ExploreHeaderReuseIdentifier"
private let exploreCellReuseIdentifier = "ExploreCellReuseIdentifier"
private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"
private let primaryEmtpyCellReuseIdentifier = "PrimaryEmptyCellReuseIdentifier"
private let exploreCaseCellReuseIdentifier = "ExploreCaseCellReuseIdentifier"
private let filterCellReuseIdentifier = "FilterCellReuseIdentifier"
private let networkFailureCellReuseIdentifier = "NetworkFailureCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"

class CasesViewController: NavigationBarViewController, UINavigationControllerDelegate {
    
    private var viewModel: PrimaryCasesViewModel

    private var zoomTransitioning = ZoomTransitioning()

    private var casesCollectionView: UICollectionView!
    
    private let activityIndicator = PrimaryLoadingView(frame: .zero)

    private let exploreCasesToolbar: ExploreCasesToolbar = {
        let toolbar = ExploreCasesToolbar(frame: .zero)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.isHidden = true
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchFirstGroupOfCases()
        configureNotificationObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    init(contentSource: CaseDisplay) {
        viewModel = PrimaryCasesViewModel(contentSource: contentSource)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    private func reloadData() {
        casesCollectionView.refreshControl?.endRefreshing()
        activityIndicator.stop()
        casesCollectionView.reloadData()
        casesCollectionView.isHidden = false
        exploreCasesToolbar.isHidden = false
    }
    
    private func fetchFirstGroupOfCases() {
        print("first gruop of cases")
        viewModel.fetchFirstGroupOfCases { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.reloadData()
        }
    }
    
    private func createTwoColumnFlowCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            
            switch strongSelf.viewModel.contentSource {
            case .home:
                if sectionNumber == 0 {
                    if strongSelf.viewModel.cases.isEmpty {
                        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(UIScreen.main.bounds.height * 0.6)))
                        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(UIScreen.main.bounds.height * 0.6)), subitems: [item])
                        let section = NSCollectionLayoutSection(group: group)
                        return section
                    } else {
                        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300))
                        let item = NSCollectionLayoutItem(layoutSize: itemSize)
                        
                        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
                        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                        let section = NSCollectionLayoutSection(group: group)
                        
                        section.interGroupSpacing = 20
                        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                        
                        return section
                    }
                } else {
                    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)))
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
                    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)), elementKind: ElementKind.sectionHeader, alignment: .top)
                    let section = NSCollectionLayoutSection(group: group)
                    section.boundarySupplementaryItems = [header]
                    return section
                }
                
            case .explore:
                if sectionNumber == 0 {
                    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                    
                    let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
                    let tripleVerticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.35),
                                                                                                                  heightDimension: .absolute(280)), subitem: item, count: 3)
                    
                    tripleVerticalGroup.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)
                    
                    let section = NSCollectionLayoutSection(group: tripleVerticalGroup)
                    section.interGroupSpacing = 10
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)
                    section.orthogonalScrollingBehavior = .continuous
                    section.boundarySupplementaryItems = [header]
                    return section
                } else {
                    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                    let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(320), heightDimension: .absolute(40))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)), subitems: [item])
                    group.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)
                    let section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 15, trailing: 10)
                    section.interGroupSpacing = 10
                    
                    section.boundarySupplementaryItems = [header]
                    
                    return section
                }
            case .filter:
                if strongSelf.viewModel.cases.isEmpty {
                    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(UIScreen.main.bounds.height * 0.6)))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(UIScreen.main.bounds.height * 0.6)), subitems: [item])
                    let section = NSCollectionLayoutSection(group: group)
                    return section
                } else {
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                    let section = NSCollectionLayoutSection(group: group)
                    
                    section.interGroupSpacing = 20
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                    
                    return section
                }
            }
        }
        return layout
    }
    
    private func configureCollectionView() {
        casesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createTwoColumnFlowCompositionalLayout())
        casesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        casesCollectionView.isHidden = true
        
        view.addSubviews(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            activityIndicator.widthAnchor.constraint(equalToConstant: 200),
        ])
        
        switch viewModel.contentSource {
        case .home:
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
        case .explore:
            view.addSubviews(casesCollectionView)
            casesCollectionView.frame = view.bounds
        case .filter:
            view.addSubviews(casesCollectionView)
            casesCollectionView.frame = view.bounds
        }
        
        casesCollectionView.register(PrimaryCaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        casesCollectionView.register(PrimaryCaseImageCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        casesCollectionView.register(PrimaryEmptyCell.self, forCellWithReuseIdentifier: primaryEmtpyCellReuseIdentifier)
        casesCollectionView.register(CaseExploreCell.self, forCellWithReuseIdentifier: exploreCellReuseIdentifier)
        casesCollectionView.register(ChoiceCell.self, forCellWithReuseIdentifier: filterCellReuseIdentifier)
        casesCollectionView.register(SecondarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: exploreHeaderReuseIdentifier)
        casesCollectionView.register(PrimaryNetworkFailureCell.self, forCellWithReuseIdentifier: networkFailureCellReuseIdentifier)
        casesCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        
        casesCollectionView.delegate = self
        casesCollectionView.dataSource = self
        
        exploreCasesToolbar.selectFirstIndex()
        
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user, let discipline = user.discipline else { return }
        viewModel.specialities = discipline.specialities
    }
    
    func casesLoaded() -> Bool {
        return viewModel.casesLoaded
    }
    
    private func showBottomSpinner() {
        viewModel.isFetchingMoreCases = true
    }
    
    private func hideBottomSpinner() {
        viewModel.isFetchingMoreCases = false
    }
}

extension CasesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch viewModel.contentSource {
        case .home:
            return 1
        case .explore:
            return viewModel.specialities.isEmpty ? 1 : 2
        case .filter:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch viewModel.contentSource {
        case .home:
            if section == 0 {
                return viewModel.networkError ? 1 : viewModel.casesLoaded ? viewModel.cases.isEmpty ? 1 : viewModel.cases.count : 0
            } else {
                return 0
            }
        case .explore:
            return section == 0 ? Discipline.allCases.count : viewModel.specialities.count
        case .filter:
            if section == 0 {
                return viewModel.networkError ? 1 : viewModel.casesLoaded ? viewModel.cases.isEmpty ? 1 : viewModel.cases.count : 0
            } else {
                return 0
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewModel.contentSource {
        case .home:
            if viewModel.networkError {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
                cell.delegate = self
                return cell
            } else {
                if viewModel.cases.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: primaryEmtpyCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                    cell.set(withTitle: AppStrings.Content.Case.Empty.emptyFeed, withDescription: AppStrings.Content.Case.Empty.emptyFeedContent, withButtonText: AppStrings.Content.Case.Empty.share)
                    cell.delegate = self
                    return cell
                } else {
                    
                    let currentCase = viewModel.cases[indexPath.row]
                    
                    switch currentCase.kind {
                        
                    case .text:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! PrimaryCaseTextCell
                        cell.viewModel = CaseViewModel(clinicalCase: currentCase)
                        cell.delegate = self
                        
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
                        cell.viewModel = CaseViewModel(clinicalCase: currentCase)
                        cell.delegate = self
                        
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
            
        case .explore:
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: exploreCellReuseIdentifier, for: indexPath) as! CaseExploreCell
                cell.set(discipline: Discipline.allCases[indexPath.row])
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellReuseIdentifier, for: indexPath) as! ChoiceCell
                cell.isSelectable = false
                cell.set(speciality: viewModel.specialities[indexPath.row])
                return cell
            }
        case .filter:
            if viewModel.networkError {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: networkFailureCellReuseIdentifier, for: indexPath) as! PrimaryNetworkFailureCell
                cell.delegate = self
                return cell
            } else {
                if viewModel.cases.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: primaryEmtpyCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                    cell.set(withTitle: AppStrings.Content.Case.Empty.emptyFeed, withDescription: AppStrings.Content.Case.Empty.emptyFeedContent, withButtonText: AppStrings.Content.Case.Empty.share)
                    cell.delegate = self
                    return cell
                } else {
                    let currentCase = viewModel.cases[indexPath.row]
                    
                    switch currentCase.kind {
                        
                    case .text:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! PrimaryCaseTextCell
                        cell.viewModel = CaseViewModel(clinicalCase: currentCase)
                        cell.delegate = self
                        guard viewModel.cases[indexPath.row].privacy == .regular else { return cell }
                        
                        if let userIndex = viewModel.users.firstIndex(where: { $0.uid == currentCase.uid }) {
                            cell.set(user: viewModel.users[userIndex])
                        }
                        return cell

                    case .image:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! PrimaryCaseImageCell
                        cell.viewModel = CaseViewModel(clinicalCase: currentCase)
                        cell.delegate = self
                        guard viewModel.cases[indexPath.row].privacy == .regular else { return cell }
                        
                        if let userIndex = viewModel.users.firstIndex(where: { $0.uid == currentCase.uid }) {
                            cell.set(user: viewModel.users[userIndex])
                        }
                        return cell
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch viewModel.contentSource {
            
        case .home:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        case .explore:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: exploreHeaderReuseIdentifier, for: indexPath) as! SecondarySearchHeader
            if indexPath.section == 0 {
                header.configureWith(title: AppStrings.Content.Case.Filter.disciplines, linkText: "")
                header.separatorView.isHidden = true
            } else {
                header.configureWith(title: AppStrings.Content.Case.Filter.you, linkText: "")
                header.hideSeeAllButton()
                header.separatorView.isHidden = false
            }
            return header
        case .filter:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
            return header
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch viewModel.contentSource {
        case .home, .filter:
            return
        case .explore:
            self.navigationController?.delegate = self
            let controller = CasesViewController(contentSource: .filter)
            controller.controllerIsBeeingPushed = true
          
            if indexPath.section == 0 {
                let discipline = Discipline.allCases[indexPath.row]
                controller.title = discipline.name
                controller.viewModel.discipline = discipline
            } else {
                let speciality = viewModel.specialities[indexPath.row]
                controller.title = speciality.name
                controller.viewModel.speciality = speciality
            }

            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard !viewModel.cases.isEmpty else { return nil }
        if let indexPath = collectionView.indexPathForItem(at: point) {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            
            let clinicalCase = viewModel.cases[indexPath.item]
            var previewViewController: DetailsCaseViewController!
            
            switch clinicalCase.privacy {
            case .regular:
                if let index = viewModel.users.firstIndex(where: { $0.uid == clinicalCase.uid }) {
                    previewViewController = DetailsCaseViewController(clinicalCase: viewModel.cases[indexPath.item], user: viewModel.users[index], collectionViewFlowLayout: layout)
                } else {
                    return nil
                }
            case .anonymous:
                previewViewController = DetailsCaseViewController(clinicalCase: viewModel.cases[indexPath.item], collectionViewFlowLayout: layout)
            }

            let previewProvider: () -> DetailsCaseViewController? = { previewViewController }
            return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider) { [weak self] _ in
                guard let _ = self else { return nil }
                let action1 = UIAction(title: AppStrings.Menu.reportCase, image: UIImage(systemName: AppStrings.Icons.flag)) { [weak self] action in
                    guard let strongSelf = self else { return }
                    UIMenuController.shared.hideMenu(from: strongSelf.view)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        guard let strongSelf = self else { return }
                        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
                        let controller = ReportViewController(source: .clinicalCase, contentUid: uid, contentId: strongSelf.viewModel.cases[indexPath.item].caseId)
                        let navVC = UINavigationController(rootViewController: controller)
                        navVC.modalPresentationStyle = .fullScreen
                        strongSelf.present(navVC, animated: true)
                    }
                }
                return UIMenu(children: [action1])
            }
        }
        
        return nil
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
    
    func wantsToSeeCategory(category: CaseFilter) {
        
        switch category {
        case .explore:
            self.navigationController?.delegate = self
            let controller = CasesViewController(contentSource: .explore)
            controller.controllerIsBeeingPushed = true
            
            controller.title = category.title
            
            navigationController?.pushViewController(controller, animated: true)
        case .all, .recents, .you, .solved, .unsolved:
            guard let tab = tabBarController as? MainTabController else { return }
            guard let user = tab.user else { return }
            
            viewModel.selectedFilter = category
            
            casesCollectionView.isHidden = true
            casesCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            activityIndicator.start()
            
            viewModel.getFilteredCases(forUser: user) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.casesCollectionView.refreshControl?.endRefreshing()
                strongSelf.activityIndicator.stop()
                strongSelf.casesCollectionView.reloadData()
                strongSelf.casesCollectionView.isHidden = false
            }
        }
    }
}

extension CasesViewController: CaseCellDelegate {
    func clinicalCase(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: CaseMenu) {
        switch option {
        case .delete:
            break
        case .revision:
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                casesCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        case .solve:
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                viewModel.cases[index].phase = .solved
                casesCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        case .report:
            let controller = ReportViewController(source: .clinicalCase, contentUid: clinicalCase.uid, contentId: clinicalCase.caseId)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true)
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: .leastNonzeroMagnitude)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, collectionViewFlowLayout: layout)
       
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        guard !image.isEmpty else { return }
        self.navigationController?.delegate = zoomTransitioning
        let map: [UIImage] = image.compactMap { $0.image }
        viewModel.selectedImage = image[index]
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
       
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) { return }
   
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }

    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) { return }
    
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) { return }
    
    func scrollCollectionViewToTop() { casesCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true) }
    
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) { return }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) { return }
}


extension CasesViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return viewModel.selectedImage
    }
}

extension CasesViewController {
    
    func getMoreCases() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        viewModel.getMoreCases(forUser: user) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.casesCollectionView.reloadData()
        }
    }
}

extension CasesViewController: UIToolbarDelegate {
   func position(for bar: UIBarPositioning) -> UIBarPosition {
       return .topAttached
    }
}

extension CasesViewController: PrimaryEmptyCellDelegate {
    func didTapEmptyAction() {
        guard let tab = tabBarController as? MainTabController else { return }
        tab.didTapUpload(content: .clinicalCase)
    }
}

extension CasesViewController: NetworkFailureCellDelegate {
    func didTapRefresh() {
        viewModel.networkError = false
        activityIndicator.start()
        casesCollectionView.isHidden = true
        exploreCasesToolbar.isHidden = true
        wantsToSeeCategory(category: viewModel.selectedFilter)
    }
}

extension CasesViewController {
    
    @objc func caseVisibleChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseVisibleChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                viewModel.cases.remove(at: index)
                if viewModel.cases.isEmpty {
                    casesCollectionView.reloadData()
                } else {
                    casesCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                }
            }
        }
    }

    @objc func caseLikeChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseLikeChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                    
                    let likes = viewModel.cases[index].likes
                    
                    viewModel.cases[index].didLike = change.didLike
                    viewModel.cases[index].likes = change.didLike ? likes + 1 : likes - 1
                    
                    cell.viewModel?.clinicalCase.didLike = change.didLike
                    cell.viewModel?.clinicalCase.likes = change.didLike ? likes + 1 : likes - 1
                }
            }
        }
    }
    
    @objc func caseBookmarkChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseBookmarkChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                    
                    cell.viewModel?.clinicalCase.didBookmark = change.didBookmark
                    viewModel.cases[index].didBookmark = change.didBookmark
                }
            }
        }
    }
    
    @objc func caseCommentChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseCommentChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                    
                    let comments = self.viewModel.cases[index].numberOfComments

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
    
    @objc func caseRevisionChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseRevisionChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                    
                    cell.viewModel?.clinicalCase.revision = .update
                    viewModel.cases[index].revision = .update
                    casesCollectionView.reloadData()
                }
            }

        }
    }
    
    @objc func caseSolveChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseSolveChange {
            if let index = viewModel.cases.firstIndex(where: { $0.caseId == change.caseId }) {
                if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                    
                    cell.viewModel?.clinicalCase.phase = .solved
                    viewModel.cases[index].phase = .solved
                    
                    if let diagnosis = change.diagnosis {
                        viewModel.cases[index].revision = diagnosis
                        cell.viewModel?.clinicalCase.revision = diagnosis
                    }
                    casesCollectionView.reloadData()
                }
            }
        }
    }
}

extension CasesViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            if let index = viewModel.users.firstIndex(where: { $0.uid! == user.uid! }) {
                viewModel.users[index] = user
                casesCollectionView.reloadData()
            }
        }
    }
}

