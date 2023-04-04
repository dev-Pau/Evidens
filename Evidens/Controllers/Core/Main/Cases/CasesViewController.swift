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
    private var contentSource: Case.FeedContentSource
    var users = [User]()
    private var cases = [Case]()
    
    private var casesLoaded = false
    
    private var exploringInterestHeaders = [String]()
    private var dataCategoryHeaders = [String]()

    private var displayState: DisplayState = .none
    
    var casesLastSnapshot: QueryDocumentSnapshot?
    var casesFirstSnapshot: QueryDocumentSnapshot?
    
    private var zoomTransitioning = ZoomTransitioning()
    var selectedImage: UIImageView!
    
    private var casesCollectionView: UICollectionView!
    
    private let activityIndicator = MEProgressHUD(frame: .zero)
    
    private let exploreCasesToolbar: ExploreCasesToolbar = {
        let toolbar = ExploreCasesToolbar(frame: .zero)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.isHidden = true
        return toolbar
    }()
    
    private lazy var lockView = MEPrimaryBlurLockView(frame: view.bounds)
    
    private var indexSelected: Int = 1
    private var casesCategorySelected: Case.FilterCategories = .all

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchFirstGroupOfCases()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    init(contentSource: Case.FeedContentSource) {
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
        
        switch contentSource {
            
        case .home:
            // Main Cases navigation view. Displayed cases are random & do not follow any specific query
            CaseService.fetchClinicalCases(lastSnapshot: nil) { snapshot in
                if snapshot.isEmpty {
                    self.casesLoaded = true
                    self.activityIndicator.stop()
                    if user.phase != .verified {
                        self.view.addSubview(self.lockView)
                    }
                    self.casesCollectionView.reloadData()
                    self.casesCollectionView.isHidden = false
                    self.exploreCasesToolbar.isHidden = false
                    
                } else {
                    self.casesLastSnapshot = snapshot.documents.last
                    self.casesFirstSnapshot = snapshot.documents.first
                    self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                    CaseService.getCaseValuesFor(cases: self.cases) { cases in
                        self.cases = cases
                        let visibleUserUids = self.cases.filter({ $0.privacyOptions == .visible }).map({ $0.ownerUid })
                        UserService.fetchUsers(withUids: visibleUserUids) { users in
                            self.users = users
                            self.casesLoaded = true
                            self.activityIndicator.stop()
                            self.casesCollectionView.reloadData()
                            
                            if user.phase != .verified {
                                self.view.addSubview(self.lockView)
                            }
                            self.casesCollectionView.isHidden = false
                            self.exploreCasesToolbar.isHidden = false
                        }
                    }
                }
            }
        
        case .explore:
            // No cases are displayed. A collectionView with filtering options is displayed to browse disciplines & user preferences
            self.casesLoaded = true
            self.activityIndicator.stop()
            //self.casesCollectionView.refreshControl?.endRefreshing()
            self.casesCollectionView.isHidden = false
            self.casesCollectionView.reloadData()
            return
        case .filter:
            // Cases are shown based on user filtering options
             CaseService.fetchCasesWithProfession(lastSnapshot: nil, profession: navigationItem.title!) { snapshot in
                 guard !snapshot.isEmpty else {
                     self.casesLoaded = true
                     self.activityIndicator.stop()
                     self.casesCollectionView.refreshControl?.endRefreshing()
                     self.casesCollectionView.isHidden = false
                     self.casesCollectionView.reloadData()
                     return
                 }
                 
                 self.casesLastSnapshot = snapshot.documents.last
                 self.casesFirstSnapshot = snapshot.documents.first
                 self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                 CaseService.getCaseValuesFor(cases: self.cases) { cases in
                     self.cases = cases
                     let visibleUserUids = self.cases.filter({ $0.privacyOptions == .visible }).map({ $0.ownerUid })
                     UserService.fetchUsers(withUids: visibleUserUids) { users in
                         self.users = users
                         self.casesLoaded = true
                         self.activityIndicator.stop()
                         self.casesCollectionView.isHidden = false
                         self.casesCollectionView.reloadData()
                     }
                 }
             }
        }
    }
    
    private func createTwoColumnFlowCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            switch self.contentSource {
            case .home:
                if self.cases.isEmpty {
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
                    
                    /*
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(350))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
                    
                    group.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)
                    
                    let section = NSCollectionLayoutSection(group: group)
                    
                    section.interGroupSpacing = 10
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                    
                    return section
                     */
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
                if self.cases.isEmpty {
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
        
        casesCollectionView.register(CaseFeedTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        casesCollectionView.register(CaseFeedTextImageCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        casesCollectionView.register(MEPrimaryEmptyCell.self, forCellWithReuseIdentifier: primaryEmtpyCellReuseIdentifier)
        casesCollectionView.register(CategoriesExploreCasesCell.self, forCellWithReuseIdentifier: exploreCellReuseIdentifier)
        casesCollectionView.register(RegistrationInterestsCell.self, forCellWithReuseIdentifier: filterCellReuseIdentifier)
        casesCollectionView.register(SecondarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: exploreHeaderReuseIdentifier)
        casesCollectionView.register(ExploreCaseCell.self, forCellWithReuseIdentifier: exploreCaseCellReuseIdentifier)
        
        casesCollectionView.delegate = self
        casesCollectionView.dataSource = self
        
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }

        dataCategoryHeaders = Speciality.getSpecialitiesByProfession(profession: Profession.Professions(rawValue: user.profession!)!).map({ $0.name })

        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        casesCollectionView.refreshControl = contentSource == .home ? refresher : nil
        exploreCasesToolbar.selectFirstIndex()
    }
    
    @objc func handleRefresh() {
        HapticsManager.shared.vibrate(for: .success)
        guard casesCategorySelected == .recents else {
            self.casesCollectionView.refreshControl?.endRefreshing()
            return
        }
        checkIfUserHasNewCasesToDisplay()

    }
    
    private func checkIfUserHasNewCasesToDisplay() {
        CaseService.checkIfUserHasNewCasesToDisplay(category: casesCategorySelected, snapshot: casesFirstSnapshot) { snapshot in
            switch self.casesCategorySelected {
            case .explore:
                self.casesCollectionView.refreshControl?.endRefreshing()
                return
            case .all:
                self.casesCollectionView.refreshControl?.endRefreshing()
                return
            case .recents:
                guard !snapshot.isEmpty else {
                    self.casesCollectionView.refreshControl?.endRefreshing()
                    return
                }
                self.casesFirstSnapshot = snapshot.documents.last
                let newCases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                CaseService.getCaseValuesFor(cases: newCases) { casesWithValues in
                    let visibleUserUids = newCases.filter({ $0.privacyOptions == .visible }).map({ $0.ownerUid })
                    UserService.fetchUsers(withUids: visibleUserUids) { users in
                        self.cases.insert(contentsOf: casesWithValues, at: 0)
                        self.users.append(contentsOf: users)
                        
                        var newIndexPaths = [IndexPath]()
                        
                        casesWithValues.enumerated().forEach { index, clinicalCase in
                            newIndexPaths.append(IndexPath(item: index, section: 0))
                            if newIndexPaths.count == casesWithValues.count {
                                self.casesCollectionView.refreshControl?.endRefreshing()
                                self.casesCollectionView.isScrollEnabled = false
                                self.casesCollectionView.performBatchUpdates {
                                    self.casesCollectionView.isScrollEnabled = false
                                    self.casesCollectionView.insertItems(at: newIndexPaths)
                                    
                                }
                                
                                DispatchQueue.main.async {
                                    self.casesCollectionView.isScrollEnabled = true
                                }
                            }
                        }
                    }
                }
            case .solved:
                return
            case .unsolved:
                return
            case .diagnosis:
                return
            case .images:
                return
            }
        }
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
            return section == 0 ? Profession.Professions.allCases.count : dataCategoryHeaders.count
        case .filter:
            return casesLoaded ? cases.isEmpty ? 1 : cases.count : 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch contentSource {
        case .home:
            if cases.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: primaryEmtpyCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
                cell.set(withImage: UIImage(named: "onboarding.date")!, withTitle: "Nothing to see here —— yet.", withDescription: "It's empty now, but it won't be for long. Check back later for new clinical cases or share your own here.", withButtonText: "    Share a case    ")
                cell.delegate = self
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseFeedTextCell
                cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                guard cases[indexPath.row].privacyOptions == .visible else { return cell }
                
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
                
                /*
                switch cases[indexPath.row].type {
                case .text:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseFeedTextCell
                    cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                    guard cases[indexPath.row].privacyOptions == .visible else { return cell }
                    
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
                case .textWithImage:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CaseFeedTextImageCell
                    cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                    guard cases[indexPath.row].privacyOptions == .visible else { return cell }
                    
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
                 */
            }
        case .explore:
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: exploreCellReuseIdentifier, for: indexPath) as! CategoriesExploreCasesCell
                cell.set(category: Profession.Professions.allCases[indexPath.row].rawValue)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellReuseIdentifier, for: indexPath) as! RegistrationInterestsCell
                cell.setText(text: dataCategoryHeaders[indexPath.row])
                return cell
            }
        case .filter:
            if cases.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: primaryEmtpyCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
                cell.set(withImage: UIImage(named: "onboarding.date")!, withTitle: "Nothing to see here —— yet.", withDescription: "It's empty now, but it won't be for long. Check back later for new clinical cases or share your own here.", withButtonText: "    Share a case    ")
                cell.delegate = self
                return cell
            } else {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! CaseFeedTextCell
                cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
                guard cases[indexPath.row].privacyOptions == .visible else { return cell }
                
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
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: exploreHeaderReuseIdentifier, for: indexPath) as! SecondarySearchHeader
        if indexPath.section == 0 {
            header.configureWith(title: "Browse disciplines", linkText: "")
            header.separatorView.isHidden = true
        } else {
            header.configureWith(title: "For you", linkText: "")
            header.hideSeeAllButton()
            header.separatorView.isHidden = false
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch contentSource {
        case .home:
            return
        case .explore:
            self.navigationController?.delegate = self
            let controller = CasesViewController(contentSource: .filter)
            controller.controllerIsBeeingPushed = true
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            
            if indexPath.section == 0 {
                let profession = Profession.Professions.allCases[indexPath.row].rawValue
                controller.title = profession
            } else {
                controller.title = dataCategoryHeaders[indexPath.row]
            }

            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        case .filter:
            return
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

extension CasesViewController: ExploreCasesToolbarDelegate {
    func wantsToSeeCategory(category: Case.FilterCategories) {
        switch category {
        case .explore:
            self.navigationController?.delegate = self
            let controller = CasesViewController(contentSource: .explore)
            controller.controllerIsBeeingPushed = true
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            controller.title = category.rawValue
            
            navigationController?.pushViewController(controller, animated: true)
            
        case .all:
            casesCategorySelected = category
            casesLoaded = false
            casesCollectionView.isHidden = true
            cases.removeAll()
            users.removeAll()
            activityIndicator.start()
            fetchFirstGroupOfCases()

        case .recents:
            casesCategorySelected = category
            casesLoaded = false
            cases.removeAll()
            users.removeAll()
            casesCollectionView.isHidden = true
            activityIndicator.start()
            
            CaseService.fetchLastUploadedClinicalCases(lastSnapshot: nil) { snapshot in
                if snapshot.isEmpty {
                    self.casesLoaded = true
                    self.activityIndicator.stop()
                    self.casesCollectionView.reloadData()
                    self.casesCollectionView.isHidden = false
                } else {
                    self.casesFirstSnapshot = snapshot.documents.first
                    self.casesLastSnapshot = snapshot.documents.last
                    self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                    CaseService.getCaseValuesFor(cases: self.cases) { cases in
                        self.cases = cases

                        let visibleUserUids = cases.filter({ $0.privacyOptions == .visible }).map({ $0.ownerUid })
                        UserService.fetchUsers(withUids: visibleUserUids) { users in
                            self.users = users
                            self.casesLoaded = true
                            self.casesCollectionView.reloadData()
                            self.casesCollectionView.isHidden = false
                        }
                    }
                }
            }
        case .solved:
            return
        case .unsolved:
            return
        case .diagnosis:
            return
        case .images:
            return
        }
    }
}


extension CasesViewController: CaseCellDelegate {
    func clinicalCase(_ cell: UICollectionViewCell, didTapMenuOptionsFor clinicalCase: Case, option: Case.CaseMenuOptions) {
        switch option {
        case .delete:
            break
        case .update:
            let index = cases.firstIndex { homeCase in
                if homeCase.caseId == clinicalCase.caseId {
                    return true
                }
                return false
            }
            
            if let index = index {
                cases[index].caseUpdates = clinicalCase.caseUpdates
                casesCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        case .solved:
            let index = cases.firstIndex { homeCase in
                if homeCase.caseId == clinicalCase.caseId {
                    return true
                }
                return false
            }
            
            if let index = index {
                cases[index].stage = .resolved
                cases[index].diagnosis = clinicalCase.diagnosis
                casesCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        case .edit:
            let index = cases.firstIndex { homeCase in
                if homeCase.caseId == clinicalCase.caseId {
                    return true
                }
                return false
            }
            
            if let index = index {
                cases[index].stage = .resolved
                cases[index].diagnosis = clinicalCase.diagnosis
                casesCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        case .report:
            break
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeCase clinicalCase: Case, withAuthor user: User) {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: user, type: .regular, collectionViewFlowLayout: layout)
        controller.delegate = self
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didTapImage image: [UIImageView], index: Int) {
        guard image != [] else { return }
        self.navigationController?.delegate = zoomTransitioning
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
    
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) { return }
    func clinicalCase(_ cell: UICollectionViewCell, didPressThreeDotsFor clinicalCase: Case) { return }
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToShowProfileFor user: User) {
        let controller = UserProfileViewController(user: user)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }

    func clinicalCase(_ cell: UICollectionViewCell, didBookmark clinicalCase: Case) {
        guard let indexPath = casesCollectionView.indexPath(for: cell) else { return }
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
            return
        }
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didLike clinicalCase: Case) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        guard let indexPath = casesCollectionView.indexPath(for: cell) else { return }
        
        HapticsManager.shared.vibrate(for: .success)
        
        switch cell {
        case is CasesFeedCell:
            let currentCell = cell as! CasesFeedCell
            
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
                    NotificationService.uploadNotification(toUid: clinicalCase.ownerUid, fromUser: user, type: .likeCase, clinicalCase: clinicalCase)
                }
            }
            
        default:
            return
        }
    }
    
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
        switch contentSource {
        case .home:
            switch casesCategorySelected {
            case .explore:
                return
            case .all:
                CaseService.fetchClinicalCases(lastSnapshot: casesLastSnapshot) { snapshot in
                    if snapshot.isEmpty {
                        return
                    } else {
                        self.casesLastSnapshot = snapshot.documents.last
                        let newCases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                        CaseService.getCaseValuesFor(cases: newCases) { casesWithValues in
                            self.cases.append(contentsOf: casesWithValues)
                            let visibleUserUids = casesWithValues.filter({ $0.privacyOptions == .visible }).map({ $0.ownerUid })
                            UserService.fetchUsers(withUids: visibleUserUids) { newUsers in
                                self.users.append(contentsOf: newUsers)
                                self.casesCollectionView.reloadData()
                            }
                        }
                    }
                }
            case .recents:
                CaseService.fetchLastUploadedClinicalCases(lastSnapshot: casesLastSnapshot) { snapshot in
                    if snapshot.isEmpty {
                        return
                    } else {
                        self.casesLastSnapshot = snapshot.documents.last
                        let newCases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                        CaseService.getCaseValuesFor(cases: newCases) { casesWithValues in
                            self.cases.append(contentsOf: casesWithValues)
                            let visibleUserUids = casesWithValues.filter({ $0.privacyOptions == .visible }).map({ $0.ownerUid })
                            UserService.fetchUsers(withUids: visibleUserUids) { newUsers in
                                self.users.append(contentsOf: newUsers)
                                self.casesCollectionView.reloadData()
                            }
                        }
                    }
                }
            case .solved:
                return
            case .unsolved:
                return
            case .diagnosis:
                return
            case .images:
                return
            }
        case .explore:
            // No cases to append
            return
        case .filter:
            CaseService.fetchCasesWithProfession(lastSnapshot: casesLastSnapshot, profession: navigationItem.title!) { snapshot in
                self.casesLastSnapshot = snapshot.documents.last
                let newCases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                CaseService.getCaseValuesFor(cases: newCases) { newCasesValues in
                    self.cases.append(contentsOf: newCasesValues)
                    let newVisibleUids = newCases.filter({ $0.privacyOptions == .visible }).map({ $0.ownerUid })
                    UserService.fetchUsers(withUids: newVisibleUids) { users in
                        self.users.append(contentsOf: users)
                        self.casesCollectionView.reloadData()
                    }
                }
            }
        }
    }
}
        
extension CasesViewController: DetailsCaseViewControllerDelegate {
    func didDeleteComment(forCase clinicalCase: Case) {
        let index = cases.firstIndex { homeCase in
            if homeCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = index {
            if let _ = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
                
            }
        }
    }
    
    func didComment(forCase clinicalCase: Case) {
        let index = cases.firstIndex { homeCase in
            if homeCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = index {
            if let _ = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
                
            }
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
            if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
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
            if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
                self.clinicalCase(cell, didBookmark: clinicalCase)
            }
        }
    }
    
    func didAddUpdate(forCase clinicalCase: Case) {
        let index = cases.firstIndex { homeCase in
            if homeCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = index {
            cases[index].caseUpdates = clinicalCase.caseUpdates
            casesCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func didAddDiagnosis(forCase clinicalCase: Case) {
        let index = cases.firstIndex { homeCase in
            if homeCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = index {
            cases[index].stage = .resolved
            cases[index].diagnosis = clinicalCase.diagnosis
            casesCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
}

extension CasesViewController: UIToolbarDelegate {
   func position(for bar: UIBarPositioning) -> UIBarPosition {
       return .topAttached
    }
}

extension CasesViewController: EmptyGroupCellDelegate {
    func didTapDiscoverGroup() {
        guard let tab = tabBarController as? MainTabController else { return }
        tab.didTapUpload(content: .clinicalCase)
    }
}
