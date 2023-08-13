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

class CasesViewController: NavigationBarViewController, UINavigationControllerDelegate {
    private var contentSource: CaseDisplay
    var users = [User]()
    private var cases = [Case]()
    
    private var casesLoaded = false

    private var specialities = [Speciality]()

    var casesLastSnapshot: QueryDocumentSnapshot?
    var casesFirstSnapshot: QueryDocumentSnapshot?
    
    private var zoomTransitioning = ZoomTransitioning()
    var selectedImage: UIImageView!
    
    private var casesCollectionView: UICollectionView!
    
    private let activityIndicator = PrimaryLoadingView(frame: .zero)
    
    private let exploreCasesToolbar: ExploreCasesToolbar = {
        let toolbar = ExploreCasesToolbar(frame: .zero)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.isHidden = true
        return toolbar
    }()
    
    private lazy var lockView = MEPrimaryBlurLockView(frame: view.bounds)

    private var selectedFilter: CaseFilter = .all

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchFirstGroupOfCases()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    init(contentSource: CaseDisplay) {
        self.contentSource = contentSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
    }
    
    private func fetchFirstGroupOfCases() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        guard user.phase == .verified else {
            view.addSubview(lockView)
            return
        }

        switch contentSource {
        case .home:

            CaseService.fetchClinicalCases(lastSnapshot: nil) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let snapshot):
                    strongSelf.casesLastSnapshot = snapshot.documents.last
                    strongSelf.casesFirstSnapshot = snapshot.documents.first
                    strongSelf.cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data()) }
                    CaseService.getCaseValuesFor(cases: strongSelf.cases) { [weak self] cases in
                        guard let strongSelf = self else { return }
                        
                        strongSelf.cases = cases
                        let uids = strongSelf.cases.filter { $0.privacy == .regular }.map { $0.uid }
                        let uniqueUids = Array(Set(uids))
                        
                        guard !uniqueUids.isEmpty else {
                            strongSelf.casesLoaded = true
                            strongSelf.activityIndicator.stop()
                            strongSelf.casesCollectionView.reloadData()
                            
                            strongSelf.casesCollectionView.isHidden = false
                            strongSelf.exploreCasesToolbar.isHidden = false
                            return
                        }
                        
                        UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.users = users
                            strongSelf.casesLoaded = true
                            strongSelf.activityIndicator.stop()
                            strongSelf.casesCollectionView.reloadData()
                            
                            strongSelf.casesCollectionView.isHidden = false
                            strongSelf.exploreCasesToolbar.isHidden = false
                        }
                    }
                    
                case .failure(let error):
                    strongSelf.casesLoaded = true
                    strongSelf.casesCollectionView.refreshControl?.endRefreshing()
                    strongSelf.activityIndicator.stop()
                    strongSelf.casesCollectionView.reloadData()
                    strongSelf.casesCollectionView.isHidden = false

                    guard error != .notFound else {
                        return
                    }
                    
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                }
            }
        case .explore:
            // No cases are displayed. A collectionView with filtering options is displayed to browse disciplines & user preferences
            casesLoaded = true
            activityIndicator.stop()
            casesCollectionView.isHidden = false
            casesCollectionView.reloadData()
            
        case .filter:
            // Cases are shown based on user filtering options
            guard let discipline = navigationItem.title else { return }
#warning("uncomment and change with the discipline type or speciality")
            /*
            CaseService.fetchCasesWithDiscipline(lastSnapshot: nil, discipline: discipline) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let snapshot):
                    strongSelf.casesLastSnapshot = snapshot.documents.last
                    strongSelf.casesFirstSnapshot = snapshot.documents.first
                    strongSelf.cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data()) }
                    
                    CaseService.getCaseValuesFor(cases: strongSelf.cases) { [weak self] cases in
                        guard let strongSelf = self else { return }
                        
                        strongSelf.cases = cases
                        let uids = strongSelf.cases.filter { $0.privacy == .regular }.map { $0.uid }
                        let uniqueUids = Array(Set(uids))
                        
                        guard !uniqueUids.isEmpty else {
                            strongSelf.casesLoaded = true
                            strongSelf.activityIndicator.stop()
                            strongSelf.casesCollectionView.reloadData()
                            return
                        }
                        
                        UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.users = users
                            strongSelf.casesLoaded = true
                            strongSelf.activityIndicator.stop()
                            strongSelf.casesCollectionView.reloadData()
                            
                            //strongSelf.casesCollectionView.isHidden = false
                            //strongSelf.exploreCasesToolbar.isHidden = false
                        }
                    }
  
                case .failure(let error):
                    strongSelf.casesLoaded = true
                    strongSelf.casesCollectionView.refreshControl?.endRefreshing()
                    strongSelf.activityIndicator.stop()
                    strongSelf.casesCollectionView.reloadData()
                    strongSelf.casesCollectionView.isHidden = false

                    guard error != .notFound else {
                        return
                    }
                    
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                }
            }
             */
        }
    }
    
    private func createTwoColumnFlowCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            
            switch strongSelf.contentSource {
            case .home:
                if strongSelf.cases.isEmpty {
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
                if strongSelf.cases.isEmpty {
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
        
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            activityIndicator.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        switch contentSource {
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
     
        casesCollectionView.delegate = self
        casesCollectionView.dataSource = self
        
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user, let discipline = user.discipline else { return }
        
        specialities = discipline.specialities

        exploreCasesToolbar.selectFirstIndex()
    }
}

extension CasesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch contentSource {
        case .home:
            return 1
        case .explore:
            return 2
        case .filter:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch contentSource {
        case .home:
            return casesLoaded ? cases.isEmpty ? 1 : cases.count : 0
        case .explore:
            return section == 0 ? Discipline.allCases.count : specialities.count
        case .filter:
            return casesLoaded ? cases.isEmpty ? 1 : cases.count : 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch contentSource {
        case .home:
            if cases.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: primaryEmtpyCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                cell.set(withTitle: AppStrings.Content.Case.Empty.emptyFeed, withDescription: AppStrings.Content.Case.Empty.emptyFeedContent, withButtonText: AppStrings.Content.Case.Empty.share)
                cell.delegate = self
                return cell
            } else {
                
                let currentCase = cases[indexPath.row]
                
                switch currentCase.kind {
                    
                case .text:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! PrimaryCaseTextCell
                    cell.viewModel = CaseViewModel(clinicalCase: currentCase)
                    cell.delegate = self
                    guard cases[indexPath.row].privacy == .regular else { return cell }
                    
                    if let userIndex = users.firstIndex(where: { $0.uid == currentCase.uid }) {
                        cell.set(user: users[userIndex])
                    }
                    return cell

                case .image:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! PrimaryCaseImageCell
                    cell.viewModel = CaseViewModel(clinicalCase: currentCase)
                    cell.delegate = self
                    guard cases[indexPath.row].privacy == .regular else { return cell }
                    
                    if let userIndex = users.firstIndex(where: { $0.uid == currentCase.uid }) {
                        cell.set(user: users[userIndex])
                    }
                    return cell
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
                cell.set(speciality: specialities[indexPath.row])
                return cell
            }
        case .filter:
            if cases.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: primaryEmtpyCellReuseIdentifier, for: indexPath) as! PrimaryEmptyCell
                cell.set(withTitle: AppStrings.Content.Case.Empty.emptyFeed, withDescription: AppStrings.Content.Case.Empty.emptyFeedContent, withButtonText: AppStrings.Content.Case.Empty.share)
                cell.delegate = self
                return cell
            } else {
                let currentCase = cases[indexPath.row]
                
                switch currentCase.kind {
                    
                case .text:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! PrimaryCaseTextCell
                    cell.viewModel = CaseViewModel(clinicalCase: currentCase)
                    cell.delegate = self
                    guard cases[indexPath.row].privacy == .regular else { return cell }
                    
                    if let userIndex = users.firstIndex(where: { $0.uid == currentCase.uid }) {
                        cell.set(user: users[userIndex])
                    }
                    return cell

                case .image:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! PrimaryCaseImageCell
                    cell.viewModel = CaseViewModel(clinicalCase: currentCase)
                    cell.delegate = self
                    guard cases[indexPath.row].privacy == .regular else { return cell }
                    
                    if let userIndex = users.firstIndex(where: { $0.uid == currentCase.uid }) {
                        cell.set(user: users[userIndex])
                    }
                    return cell
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
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
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch contentSource {
        case .home, .filter:
            return
        case .explore:
            self.navigationController?.delegate = self
            let controller = CasesViewController(contentSource: .filter)
            controller.controllerIsBeeingPushed = true
            
            #warning("Check this, has to changed and the specialities or disciplines must not be the names but the actual type itself so we then can query for its raw value. there's 2 warnings where it needs to be chnaged and uncomment")
            if indexPath.section == 0 {
                let profession = Discipline.allCases[indexPath.row].name
                controller.title = profession
            } else {
                controller.title = specialities[indexPath.row].name
            }

            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        if let indexPath = collectionView.indexPathForItem(at: point), let userIndex = users.firstIndex(where: { $0.uid! == cases[indexPath.item].uid }) {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            
            let previewViewController = DetailsCaseViewController(clinicalCase: cases[indexPath.item], user: users[userIndex], collectionViewFlowLayout: layout)
            let previewProvider: () -> DetailsCaseViewController? = { previewViewController }
            return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider) { [weak self] _ in
                guard let _ = self else { return nil }
                let action1 = UIAction(title: AppStrings.Menu.reportCase, image: UIImage(systemName: AppStrings.Icons.flag)) { [weak self] action in
                    guard let strongSelf = self else { return }
                    UIMenuController.shared.hideMenu(from: strongSelf.view)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        guard let strongSelf = self else { return }
                        let controller = ReportViewController(source: .clinicalCase, contentUid: strongSelf.users[userIndex].uid!, contentId: strongSelf.cases[indexPath.item].caseId)
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
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        guard category != .explore else {
            self.navigationController?.delegate = self
            let controller = CasesViewController(contentSource: .explore)
            controller.controllerIsBeeingPushed = true
            
            controller.title = category.title
            
            navigationController?.pushViewController(controller, animated: true)
            return
        }
        
        selectedFilter = category
        casesLoaded = false
        casesCollectionView.isHidden = true
        cases.removeAll()
        users.removeAll()
        activityIndicator.start()

        CaseService.fetchCasesWithFilter(query: category, user: user, lastSnapshot: nil) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                
            case .success(let snapshot):
                strongSelf.casesFirstSnapshot = snapshot.documents.first
                strongSelf.casesLastSnapshot = snapshot.documents.last
                
                strongSelf.cases = snapshot.documents.map{ Case(caseId: $0.documentID, dictionary: $0.data()) }
                CaseService.getCaseValuesFor(cases: strongSelf.cases) { [weak self] cases in
                    guard let strongSelf = self else { return }
                    strongSelf.cases = cases
                    
                    let uids = strongSelf.cases.filter { $0.privacy == .regular }.map { $0.uid }
                    let uniqueUids = Array(Set(uids))
                    
                    guard !uniqueUids.isEmpty else {
                        strongSelf.casesLoaded = true
                        strongSelf.activityIndicator.stop()
                        strongSelf.casesCollectionView.reloadData()
                        strongSelf.casesCollectionView.isHidden = false
                        return
                    }
                    
                    UserService.fetchUsers(withUids: uniqueUids) { [weak self] users in
                        guard let strongSelf = self else { return }
                        strongSelf.users = users
                        strongSelf.casesLoaded = true
                        strongSelf.activityIndicator.stop()
                        strongSelf.casesCollectionView.reloadData()
                        strongSelf.casesCollectionView.isHidden = false
                    }
                }
            case .failure(let error):
                strongSelf.casesLoaded = true
                strongSelf.activityIndicator.stop()
                strongSelf.casesCollectionView.reloadData()
                strongSelf.casesCollectionView.isHidden = false
                
                guard error != .notFound else {
                    return
                }
                
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
}

extension CasesViewController: CaseCellDelegate {
    func clinicalCase(wantsToSeeHashtag hashtag: String) {
        let controller = HashtagViewController(hashtag: hashtag)
        controller.caseDelegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: CaseMenu) {
        switch option {
        case .delete:
            break
        case .revision:
            if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                casesCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        case .solve:
            if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
                cases[index].phase = .solved
                //cases[index].diagnosis = clinicalCase.diagnosis
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
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, collectionViewFlowLayout: layout)
        controller.delegate = self
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        guard !image.isEmpty else { return }
        self.navigationController?.delegate = zoomTransitioning
        let map: [UIImage] = image.compactMap { $0.image }
        selectedImage = image[index]
        let controller = HomeImageViewController(image: map, imageCount: image.count, index: index)
       
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) { return }
    func clinicalCase(_ cell: UICollectionViewCell, didPressThreeDotsFor clinicalCase: Case) { return }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }

    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) { return }
    
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) { return }
    
    func scrollCollectionViewToTop() { casesCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true) }
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) { return }
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) { return }
}


extension CasesViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return selectedImage
    }
}

extension CasesViewController {
    func getMoreCases() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        switch contentSource {
        case .home:
            CaseService.fetchCasesWithFilter(query: selectedFilter, user: user, lastSnapshot: casesLastSnapshot) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let snapshot):
                    strongSelf.casesLastSnapshot = snapshot.documents.last
                    let cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data()) }
                    
                    CaseService.getCaseValuesFor(cases: cases) { [weak self] newCases in
                        strongSelf.cases = newCases
                        
                        let uids = strongSelf.cases.filter { $0.privacy == .regular }.map { $0.uid }
                        let uniqueUids = Array(Set(uids))
                        
                        let currentUids = strongSelf.users.map { $0.uid }
                        let newUids = uniqueUids.filter { !currentUids.contains($0) }
                        
                        guard !newUids.isEmpty else {
                            strongSelf.casesCollectionView.reloadData()
                            return
                        }
                        
                        UserService.fetchUsers(withUids: newUids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.users.append(contentsOf: users)
                            strongSelf.casesCollectionView.reloadData()
                        }
                    }
                case .failure(_):
                    break
                }
            }
        case .explore:
            // No cases to append
            break
        case .filter:
            guard let discipline = navigationItem.title else { return }
            #warning("uncomment and change with the discipline type or speciality")
            /*
            CaseService.fetchCasesWithDiscipline(lastSnapshot: casesLastSnapshot, discipline: discipline) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let snapshot):
                    strongSelf.casesLastSnapshot = snapshot.documents.last
                    let cases = snapshot.documents.map { Case(caseId: $0.documentID, dictionary: $0.data()) }
                    
                    CaseService.getCaseValuesFor(cases: cases) { [weak self] newCases in
                        strongSelf.cases = newCases
                        
                        let uids = strongSelf.cases.filter { $0.privacy == .regular }.map { $0.uid }
                        let uniqueUids = Array(Set(uids))
                        
                        let currentUids = strongSelf.users.map { $0.uid }
                        let newUids = uniqueUids.filter { !currentUids.contains($0) }
                        
                        UserService.fetchUsers(withUids: newUids) { [weak self] users in
                            guard let strongSelf = self else { return }
                            strongSelf.users.append(contentsOf: users)
                            strongSelf.casesCollectionView.reloadData()
                        }
                    }
                    
                case .failure(_):
                    break
                }
            }
             */
        }
    }
}
        
extension CasesViewController: DetailsCaseViewControllerDelegate {
    func didSolveCase(forCase clinicalCase: Case, with diagnosis: CaseRevisionKind?) {
        if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            if let diagnosis {
                cases[index].revision = diagnosis
            }
            cases[index].phase = .solved
            casesCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func didAddRevision(forCase clinicalCase: Case) {
        if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            cases[index].revision = .update
            casesCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func didDeleteComment(forCase clinicalCase: Case) {
        if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            cases[index].numberOfComments -= 1
            casesCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func didComment(forCase clinicalCase: Case) {
        if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            cases[index].numberOfComments -= 1
            casesCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func didTapLikeAction(forCase clinicalCase: Case) {
        if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                cell.viewModel?.clinicalCase.didLike.toggle()
                cell.viewModel?.clinicalCase.likes = clinicalCase.didLike ? cases[index].likes + 1 : cases[index].likes - 1
                cases[index].didLike = clinicalCase.didLike ? false : true
                cases[index].likes = clinicalCase.didLike ? cases[index].likes + 1 : cases[index].likes - 1
            }
        }
    }
    
    func didTapBookmarkAction(forCase clinicalCase: Case) {
        if let index = cases.firstIndex(where: { $0.caseId == clinicalCase.caseId }) {
            if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CaseCellProtocol {
                cell.viewModel?.clinicalCase.didBookmark.toggle()
                cases[index].didBookmark = clinicalCase.didBookmark ? false : true
            }
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
