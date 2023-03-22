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
private let caseTextImageCellReuseIdentifier = "CaseTextImageCellReuseIdentifier"
private let primaryEmtpyCellReuseIdentifier = "PrimaryEmptyCellReuseIdentifier"
private let exploreCaseCellReuseIdentifier = "ExploreCaseCellReuseIdentifier"

class CasesViewController: NavigationBarViewController, UINavigationControllerDelegate {
    var users = [User]()
    private var cases = [Case]()
    
    private var casesLoaded = false
    
    var displaysExploringWindow = false
    var displaysFilteredWindow = false
    
    private var displayState: DisplayState = .none
    
    var casesLastSnapshot: QueryDocumentSnapshot?
    
    private var zoomTransitioning = ZoomTransitioning()
    var selectedImage: UIImageView!
    
    private var casesCollectionView: UICollectionView!
    
    private var magicalValue: CGFloat = 0
    
    private let activityIndicator = MEProgressHUD(frame: .zero)
    
    private let exploreCasesToolbar: ExploreCasesToolbar = {
        let toolbar = ExploreCasesToolbar(frame: .zero)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.isHidden = true
        return toolbar
    }()
    
    private lazy var lockView = MEPrimaryBlurLockView(frame: view.bounds)
    
    private var indexSelected: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFirstGroupOfCases()
        configureCollectionView()
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        casesCollectionView.refreshControl = refresher
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self

        if !casesLoaded {
            casesCollectionView.reloadData()
        }
    }
    
    private func fetchFirstGroupOfCases() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        if displaysFilteredWindow {
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
                self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                self.checkIfUserLikedCase()
                self.checkIfUserBookmarkedCase()
                self.casesCollectionView.refreshControl?.endRefreshing()
                self.cases.forEach { clinicalCase in
                    UserService.fetchUser(withUid: clinicalCase.ownerUid) { user in
                        self.users.append(user)
                        self.casesLoaded = true
                        self.activityIndicator.stop()
                        self.casesCollectionView.isHidden = false
                        self.casesCollectionView.reloadData()
                    }
                }
            }
        } else if displaysExploringWindow {
            #warning("Need to find a way to get the trending, etc")
            CaseService.fetchClinicalCases(lastSnapshot: nil) { snapshot in
                if snapshot.isEmpty {
                    self.casesLoaded = true
                    self.casesCollectionView.refreshControl?.endRefreshing()
                    self.activityIndicator.stop()
                    self.casesCollectionView.isHidden = false
                    self.casesCollectionView.reloadData()
                }
                
                self.casesLastSnapshot = snapshot.documents.last
                self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                self.checkIfUserLikedCase()
                self.checkIfUserBookmarkedCase()
                self.casesCollectionView.refreshControl?.endRefreshing()
                self.cases.forEach { clinicalCase in
                    UserService.fetchUser(withUid: clinicalCase.ownerUid) { user in
                        self.users.append(user)
                        self.casesLoaded = true
                        self.activityIndicator.stop()
                        self.casesCollectionView.isHidden = false
                        self.casesCollectionView.reloadData()
                    }
                }
            }
        } else {
            // Main cases view
            CaseService.fetchClinicalCases(lastSnapshot: nil) { snapshot in
                if snapshot.isEmpty {
                    self.casesLoaded = true
                    self.activityIndicator.stop()
                    self.casesCollectionView.refreshControl?.endRefreshing()
                    if user.phase != .verified {
                        self.view.addSubview(self.lockView)
                    }
                    
                    self.casesCollectionView.reloadData()
                    self.casesCollectionView.isHidden = false
                    self.exploreCasesToolbar.isHidden = false
                } else {
                    self.casesLastSnapshot = snapshot.documents.last
                    self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                    self.checkIfUserLikedCase()
                    self.checkIfUserBookmarkedCase()
                    self.casesCollectionView.refreshControl?.endRefreshing()
                    
                    #warning("Check if this works")
                    let visibleUserUids = self.cases.filter({ $0.privacyOptions == .visible }).map({ $0.ownerUid })
                    
                    UserService.fetchUsers(withUids: visibleUserUids) { users in
                        self.users = users
                        self.casesLoaded = true
                        self.activityIndicator.stop()
                        self.casesCollectionView.reloadData()
                        self.casesCollectionView.isHidden = false
                        self.exploreCasesToolbar.isHidden = false
                    }
                }
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
                    CaseService.fetchLikesForCase(caseId: clinicalCase.caseId) { likes in
                        self.cases[index].likes = likes
                        CaseService.fetchCommentsForCase(caseId: clinicalCase.caseId) { comments in
                            self.cases[index].numberOfComments = comments
                            self.casesCollectionView.reloadData()
                            //print(self.cases[index].likes)
                            //print(self.cases[index].numberOfComments)
                        }
                    }
                }
            }
        }
    }
    
    func checkIfUserBookmarkedCase() {
        self.cases.forEach { clinicalCase in
            CaseService.checkIfUserBookmarkedCase(clinicalCase: clinicalCase) { didBookmark in
                if let index = self.cases.firstIndex(where: { $0.caseId == clinicalCase.caseId}) {
                    self.cases[index].didBookmark = didBookmark
                    self.casesCollectionView.reloadData()

                }
            }
        }
    }
    /*
    private func createTwoColumnFlowLayout() -> UICollectionViewFlowLayout {
        /*
        if cases.isEmpty {
            let flowLayout = UICollectionViewFlowLayout()
            //flowLayout.sectionInset = UIEdgeInsets(top: 10, left: padding, bottom: padding, right: padding)
            flowLayout.itemSize = CGSize(width: view.frame.width, height: UIScreen.main.bounds.height * 0.6)
            
            return flowLayout
        } else {
         */
            let width = view.bounds.width
            let padding: CGFloat = 10
            let minimumItemSpacing: CGFloat = 10
            let availableWidth = width - (padding * 2) - minimumItemSpacing
            let itemWidth = availableWidth / 2
            
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.sectionInset = UIEdgeInsets(top: 10, left: padding, bottom: padding, right: padding)
            flowLayout.itemSize = CGSize(width: itemWidth, height: 350)
            
            return flowLayout
        //}
    }
    */
    private func createTwoColumnFlowCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            
            if self.displaysFilteredWindow {
                
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(UIScreen.main.bounds.height * 0.6)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(UIScreen.main.bounds.height * 0.6)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                return section
                
            } else if self.displaysExploringWindow {
                // Explore Clincal Cases view
                if sectionNumber == 0 {
                    let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
                    let tripleVerticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.35),
                                                                                                                  heightDimension: .absolute(280)), subitem: item, count: 3)
                    
                    tripleVerticalGroup.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)
                    
                    let section = NSCollectionLayoutSection(group: tripleVerticalGroup)
                    section.interGroupSpacing = 10
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)
                    section.orthogonalScrollingBehavior = .continuous
                    return section
                } else {
                    if self.cases.isEmpty {
                        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(UIScreen.main.bounds.height * 0.6)))
                        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(UIScreen.main.bounds.height * 0.6)), subitems: [item])
                        let section = NSCollectionLayoutSection(group: group)
                        return section
                    } else {
                        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
                        
                        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                              heightDimension: .fractionalHeight(1.0))
                        let item = NSCollectionLayoutItem(layoutSize: itemSize)
                        
                        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4),
                                                               heightDimension: .fractionalWidth(0.55))
                        
                        
                        
                        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                        let section = NSCollectionLayoutSection(group: group)
                        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                        section.interGroupSpacing = 10
                        
                        //if !self.cases.isEmpty {
                          //  section.boundarySupplementaryItems = [header]
                        //} else {
                            section.boundarySupplementaryItems = [header]
                        //}
                        
                        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)

                        return section
                    }
                }
                
            } else {
                if self.cases.isEmpty {
                    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(UIScreen.main.bounds.height * 0.6)))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(UIScreen.main.bounds.height * 0.6)), subitems: [item])
                    let section = NSCollectionLayoutSection(group: group)
                    return section
                } else {
                    print("main cases view")
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(350))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
                    
                    group.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)
                    
                    let section = NSCollectionLayoutSection(group: group)
                    
                    section.interGroupSpacing = 10
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                    
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

        if displaysExploringWindow || displaysFilteredWindow {
            view.addSubviews(casesCollectionView)
            casesCollectionView.frame = view.bounds
            
        } else {
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
        }
        
        casesCollectionView.register(CasesFeedCell.self, forCellWithReuseIdentifier: caseTextImageCellReuseIdentifier)
        casesCollectionView.register(MEPrimaryEmptyCell.self, forCellWithReuseIdentifier: primaryEmtpyCellReuseIdentifier)
        casesCollectionView.register(CategoriesExploreCasesCell.self, forCellWithReuseIdentifier: exploreCellReuseIdentifier)
        
        casesCollectionView.register(SecondarySearchHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: exploreHeaderReuseIdentifier)
        casesCollectionView.register(ExploreCaseCell.self, forCellWithReuseIdentifier: exploreCaseCellReuseIdentifier)

        casesCollectionView.delegate = self
        casesCollectionView.dataSource = self
        
    }
    
    @objc func handleRefresh() {
        HapticsManager.shared.vibrate(for: .success)
        fetchFirstGroupOfCases()
    }
}

extension CasesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
#warning("when developing showing more sections, need to segment this in if we are in displays exploring, normal displaying or the other with category")
        return displaysExploringWindow ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if displaysExploringWindow {
            if section == 0 {
                return Profession.Professions.allCases.count
            } else {
                #warning("when developing showing more sections, need to segment this in sections 1, 2, 3, etc and not just 1 sentence")
                return casesLoaded ? cases.isEmpty ? 1 : cases.count : 0
            }
        } else {
            return casesLoaded ? cases.isEmpty ? 1 : cases.count : 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if displaysExploringWindow {
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: exploreCellReuseIdentifier, for: indexPath) as! CategoriesExploreCasesCell
                cell.set(category: Profession.Professions.allCases[indexPath.row].rawValue)
                return cell
            } else {
                if cases.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: primaryEmtpyCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
                    cell.set(withImage: UIImage(named: "onboarding.date")!, withTitle: "Nothing to see here —— yet.", withDescription: "It's empty now, but it won't be for long. Check back later for new clinical cases or share your own here.", withButtonText: "    Share a case    ")
                    cell.delegate = self
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: exploreCaseCellReuseIdentifier, for: indexPath) as! ExploreCaseCell
                    //cell.backgroundColor = .systemPink
                    return cell
                    
                    /*
                     let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CasesFeedCell
                     cell.viewModel = CaseViewModel(clinicalCase: cases[indexPath.row])
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
            }
        }
        
        if cases.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: primaryEmtpyCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
            cell.set(withImage: UIImage(named: "onboarding.date")!, withTitle: "Nothing to see here —— yet.", withDescription: "It's empty now, but it won't be for long. Check back later for new clinical cases or share your own here.", withButtonText: "    Share a case    ")
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextImageCellReuseIdentifier, for: indexPath) as! CasesFeedCell
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: exploreHeaderReuseIdentifier, for: indexPath) as! SecondarySearchHeader
        if indexPath.section == 1 {
            header.configureWith(title: "For you", linkText: "See All")
        } else {
            header.configureWith(title: "Most Recent", linkText: "See All")
        }

        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("tap")
        if displaysExploringWindow && indexPath.section == 0 {
            let profession = Profession.Professions.allCases[indexPath.row].rawValue
            
            self.navigationController?.delegate = self
            let controller = CasesViewController()
            controller.controllerIsBeeingPushed = true
            controller.displaysFilteredWindow = true
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            controller.title = profession
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
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
            let controller = CasesViewController()
            controller.controllerIsBeeingPushed = true
            controller.displaysExploringWindow = true
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            controller.title = category.rawValue
            
            navigationController?.pushViewController(controller, animated: true)
            
        case .all:
            indexSelected = 1
            self.casesLoaded = false
            self.casesCollectionView.isHidden = true
            self.cases.removeAll()
            self.users.removeAll()
            self.activityIndicator.start()
            
            CaseService.fetchClinicalCases(lastSnapshot: nil) { snapshot in
                if snapshot.isEmpty {
                    self.casesLoaded = true
                    self.activityIndicator.stop()
                    
                    self.casesCollectionView.reloadData()
                    self.casesCollectionView.isHidden = false
                } else {
                    self.casesLastSnapshot = snapshot.documents.last
                    self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                    self.checkIfUserLikedCase()
                    self.checkIfUserBookmarkedCase()
                    self.casesCollectionView.refreshControl?.endRefreshing()
                    self.cases.forEach { clinicalCase in
                        UserService.fetchUser(withUid: clinicalCase.ownerUid) { user in
                            self.users.append(user)
                            self.casesLoaded = true
                            self.casesCollectionView.reloadData()
                            self.casesCollectionView.isHidden = false
                        }
                    }
                }
            }

        case .recents:
            indexSelected = 2
            self.casesLoaded = false
            self.cases.removeAll()
            self.users.removeAll()
            self.casesCollectionView.isHidden = true
            self.activityIndicator.start()
            
            CaseService.fetchLastUploadedClinicalCases(lastSnapshot: nil) { snapshot in
                if snapshot.isEmpty {
                    self.casesLoaded = true
                    self.activityIndicator.stop()
                    self.casesCollectionView.reloadData()
                    self.casesCollectionView.isHidden = false
                } else {
                    self.casesLastSnapshot = snapshot.documents.last
                    self.cases = snapshot.documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                    self.checkIfUserLikedCase()
                    self.checkIfUserBookmarkedCase()
                    self.casesCollectionView.refreshControl?.endRefreshing()
                    self.cases.forEach { clinicalCase in
                        UserService.fetchUser(withUid: clinicalCase.ownerUid) { user in
                            self.users.append(user)
                            self.casesLoaded = true
                            self.casesCollectionView.reloadData()
                            self.casesCollectionView.isHidden = false
                        }
                    }
                }
            }
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
    
    
    func clinicalCase(_ cell: UICollectionViewCell, wantsToSeeUpdatesForCase clinicalCase: Case) {
        return
    }
    
    func clinicalCase(_ cell: UICollectionViewCell, didPressThreeDotsFor clinicalCase: Case) {
        return
    }
    
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
            break
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
            break
        }
    }
    
    func scrollCollectionViewToTop() {
        casesCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    func clinicalCase(wantsToSeeLikesFor clinicalCase: Case) {
        return
    }
    
    func clinicalCase(wantsToShowCommentsFor clinicalCase: Case, forAuthor user: User) {
        return
    }
}

extension CasesViewController: ZoomTransitioningDelegate {
    func zoomingImageView(for transition: ZoomTransitioning) -> UIImageView? {
        return selectedImage
    }
}

extension CasesViewController {
    func getMoreCases() {
        if displaysFilteredWindow {
            CaseService.fetchCasesWithProfession(lastSnapshot: casesLastSnapshot, profession: navigationItem.title!) { snapshot in
                self.casesLastSnapshot = snapshot.documents.last
                let documents = snapshot.documents
                let newCases = documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                self.cases.append(contentsOf: newCases)
                self.checkIfUserLikedCase()
                self.checkIfUserBookmarkedCase()
                
                newCases.forEach { clinicalCase in
                    UserService.fetchUser(withUid: clinicalCase.ownerUid) { user in
                        self.users.append(user)
                        self.casesCollectionView.reloadData()
                    }
                }
            }
            #warning("Need to put an else if with DisplaysExploreWidnow to show trending")
        } else {
            
            if indexSelected == 1 {
                CaseService.fetchClinicalCases(lastSnapshot: casesLastSnapshot) { snapshot in
                    self.casesLastSnapshot = snapshot.documents.last
                    let documents = snapshot.documents
                    let newCases = documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                    self.cases.append(contentsOf: newCases)
                    self.checkIfUserLikedCase()
                    self.checkIfUserBookmarkedCase()
                    
                    newCases.forEach { clinicalCase in
                        UserService.fetchUser(withUid: clinicalCase.ownerUid) { user in
                            self.users.append(user)
                            self.casesCollectionView.reloadData()
                        }
                    }
                }
            }
            
            if indexSelected == 2 {
                // Recently uploaded
                CaseService.fetchLastUploadedClinicalCases(lastSnapshot: casesLastSnapshot) { snapshot in
                    self.casesLastSnapshot = snapshot.documents.last
                    let documents = snapshot.documents
                    let newCases = documents.map({ Case(caseId: $0.documentID, dictionary: $0.data()) })
                    self.cases.append(contentsOf: newCases)
                    self.checkIfUserLikedCase()
                    self.checkIfUserBookmarkedCase()
                    
                    newCases.forEach { clinicalCase in
                        UserService.fetchUser(withUid: clinicalCase.ownerUid) { user in
                            self.users.append(user)
                            self.casesCollectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
        
}

extension CasesViewController: DetailsCaseViewControllerDelegate {
    func didComment(forCase clinicalCase: Case) {
        let index = cases.firstIndex { homeCase in
            if homeCase.caseId == clinicalCase.caseId {
                return true
            }
            return false
        }
        
        if let index = index {
            if let cell = casesCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
                
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
