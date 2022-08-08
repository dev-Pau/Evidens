//
//  UserProfileViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/5/22.
//

import UIKit

private let profileHeaderReuseIdentifier = "ProfileHeaderReuseIdentifier"
private let profileAboutCellReuseIdentifier = "ProfileAboutCellReuseIdentifier"
private let profileHeaderTitleReuseIdentifier = "ProfileHeaderTitleReuseIdentifier"
private let profileFooterTitleReuseIdentifier = "ProfileFooterTitleReuseIdentifier"
private let noRecentPostsCellReuseIdentifier = "NoRecentPostsCellReuseIdentifier"
private let postImageCellReuseIdentifier = "ProfileImageCellReuseIdentifier"
private let postTextCellReuseIdentifier = "PostTextCellReuseIdentifier"
private let noRecentCasesCellReuseIdentifier = "NoRecentCasesCellReuseIdentifier"
private let caseTextCellReuseIdentifier = "CaseTextCellReuseIdentifier"
private let caseImageCellReuseIdentifier = "CaseImageCellReuseIdentifier"
private let noCommentsCellReuseIdentifier = "NoCommentsCellReuseIdentifier"
private let commentsCellReuseIdentifier = "CommentsCellReuseIdentifier"
private let experienceCellReuseIdentifier = "ExperienceCellReuseIdentifier"
private let educationCellReuseIdentifier = "EducationCellReuseIdentifier"
private let patentCellReuseIdentifier = "PatentCellReuseIdentifier"
private let publicationsCellReuseIdentifier = "PublicationCellReuseIdentifier"
private let languageCellReuseIdentifier = "LanguageCellReuseIdentifier"
private let seeOthersCellReuseIdentifier = "SeeOthersCellReuseIdentifier"

struct ElementKind {
    //static let badge = "badge-element-kind"
    //static let background = "background-element-kind"
    static let sectionHeader = "section-header-element-kind"
    static let sectionFooter = "section-footer-element-kind"
    //static let layoutHeader = "layout-header-element-kind"
    //static let layoutFooter = "layout-footer-element-kind"
}

class UserProfileViewController: UIViewController {
    

    //MARK: - Properties
    private var user: User
    
    var recentPosts = [Post]() {
        didSet {
            collectionView.reloadData()
            //collectionView.reloadSections(IndexSet(integer: 2))
        }
    }
    
    var recentCases = [Case]() {
        didSet {
            collectionView.reloadData()
            //collectionView.reloadSections(IndexSet(integer: 3))
        }
    }
    
    var recentComments = [[String: Any]]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var relatedUsers = [[String: String]]() {
        didSet {
            collectionView.reloadData()
        }
    }
        
    // Sections
    private var hasComments: Bool = false
    
    //About
    private var hasAbout: Bool = false
    private var aboutText: String = ""
    
    //Languages
    private var hasLanguages: Bool = false
    private var languages = [[String: String]]()
    
    //Patents
    private var hasPatents: Bool = false
    private var patents = [[String: Any]]()
    
    //Publications
    private var hasPublications: Bool = false
    private var publications = [[String: String]]()
    
    //Education
    private var hasEducation: Bool = false
    private var education = [[String: String]]()
    
    //Profession
    private var hasExperiences: Bool = false
    private var experience = [[String: String]]()
    
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchTextField.backgroundColor = lightColor
        return searchBar
    }()
    
    private var collectionView: UICollectionView!
        
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserStats()
        fetchRecentPosts()
        fetchRecentCases()
        fetchLanguages()
        fetchPatents()
        fetchPublications()
        fetchRecentComments()
        fetchEducation()
        fetchExperience()
        fetchSections()
        fetchRelated()
        checkIfUserIsFollowed()
        configureNavigationItemButton()
        configureCollectionView()

    }
        
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    func configureNavigationItemButton() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                                            style: .plain,
                                                            target: self, action: #selector(didTapSettings))
        
        navigationItem.rightBarButtonItem?.tintColor = .black
        
        navigationItem.titleView = searchBar
        
        guard let firstName = user.firstName, let lastName = user.lastName else { return }
        
        searchBar.text = ("\(firstName ) \(lastName)")
        searchBar.searchTextField.clearButtonMode = .never
    }
    
    func configureCollectionView() {
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = .white
        collectionView.register(UserProfileHeaderCell.self, forCellWithReuseIdentifier: profileHeaderReuseIdentifier)
        collectionView.register(UserProfileTitleHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: profileHeaderTitleReuseIdentifier)
        collectionView.register(UserProfileTitleFooter.self, forSupplementaryViewOfKind: ElementKind.sectionFooter, withReuseIdentifier: profileFooterTitleReuseIdentifier)
        collectionView.register(UserProfileAboutCell.self, forCellWithReuseIdentifier: profileAboutCellReuseIdentifier)
        collectionView.register(UserProfileNoPostCell.self, forCellWithReuseIdentifier: noRecentPostsCellReuseIdentifier)
        collectionView.register(UserProfilePostImageCell.self, forCellWithReuseIdentifier: postImageCellReuseIdentifier)
        collectionView.register(UserProfilePostCell.self, forCellWithReuseIdentifier: postTextCellReuseIdentifier)
        collectionView.register(UserProfileNoCaseCell.self, forCellWithReuseIdentifier: noRecentCasesCellReuseIdentifier)
        collectionView.register(UserProfileCaseTextCell.self, forCellWithReuseIdentifier: caseTextCellReuseIdentifier)
        collectionView.register(UserProfileCaseImageCell.self, forCellWithReuseIdentifier: caseImageCellReuseIdentifier)
        collectionView.register(UserProfileNoCommentsCell.self, forCellWithReuseIdentifier: noCommentsCellReuseIdentifier)
        collectionView.register(UserProfileCommentCell.self, forCellWithReuseIdentifier: commentsCellReuseIdentifier)
        collectionView.register(UserProfileExperienceCell.self, forCellWithReuseIdentifier: experienceCellReuseIdentifier)
        collectionView.register(UserProfileEducationCell.self, forCellWithReuseIdentifier: educationCellReuseIdentifier)
        collectionView.register(UserProfilePatentCell.self, forCellWithReuseIdentifier: patentCellReuseIdentifier)
        collectionView.register(UserProfilePublicationCell.self, forCellWithReuseIdentifier: publicationsCellReuseIdentifier)
        collectionView.register(UserProfileLanguageCell.self, forCellWithReuseIdentifier: languageCellReuseIdentifier)
        collectionView.register(UserProfileSeeOthersCell.self, forCellWithReuseIdentifier: seeOthersCellReuseIdentifier)
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            if sectionNumber == 0 {

                // Profile Header
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(350)))
                //item.contentInsets.bottom = 16
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(350)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                return section
            } else if sectionNumber == 1 {
                // About section
                if self.hasAbout == false {
                    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)))
                    //item.contentInsets.bottom = 16
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
                    let section = NSCollectionLayoutSection(group: group)
                    //section.orthogonalScrollingBehavior = .continuous
                    return section
                } else {
                    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                             elementKind: ElementKind.sectionHeader,
                                                                             alignment: .top)
        
                    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                
                    let section = NSCollectionLayoutSection(group: group)
                    section.boundarySupplementaryItems = [header]
                    return section
                }
            } else if sectionNumber == 2 {
                // Posts
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
    
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                
                let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                         elementKind: ElementKind.sectionFooter,
                                                                         alignment: .bottom)
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header, footer]
                return section
                
            } else if sectionNumber == 3 {
            // Cases
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
    
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                
                let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                         elementKind: ElementKind.sectionFooter,
                                                                         alignment: .bottom)
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header, footer]
                    
                return section
            } else if sectionNumber == 4 {
                // Comments
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
    
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                
                let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                         elementKind: ElementKind.sectionFooter,
                                                                         alignment: .bottom)
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header, footer]
                    
                return section
            } else if sectionNumber == 5 {
                // Experience
                
                if self.hasExperiences == false {
                    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                    let section = NSCollectionLayoutSection(group: group)

                        
                    return section
                    
                } else {
                    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                             elementKind: ElementKind.sectionHeader,
                                                                             alignment: .top)
        
                    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                    
                    let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                             elementKind: ElementKind.sectionFooter,
                                                                             alignment: .bottom)
                    let section = NSCollectionLayoutSection(group: group)
                    section.boundarySupplementaryItems = [header, footer]
                    return section
                }
                
            } else if sectionNumber == 6 {
                // Education
                if self.hasEducation == false {
                   
                    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                    
                    
                    let section = NSCollectionLayoutSection(group: group)
                    
                    return section
                } else {
                    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                             elementKind: ElementKind.sectionHeader,
                                                                             alignment: .top)
        
                    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                    
                    let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                             elementKind: ElementKind.sectionFooter,
                                                                             alignment: .bottom)
                    
                    let section = NSCollectionLayoutSection(group: group)
                    section.boundarySupplementaryItems = [header, footer]
                        
                    return section
                }
 
            } else if sectionNumber == 7 {
                // Patents
                if self.hasPatents == false {
                    
                    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                   
                    let section = NSCollectionLayoutSection(group: group)
                  
                    return section
                        
                } else {
                    
                    
                    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                             elementKind: ElementKind.sectionHeader,
                                                                             alignment: .top)
        
                    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                    
                    let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                             elementKind: ElementKind.sectionFooter,
                                                                             alignment: .bottom)
                    
                    let section = NSCollectionLayoutSection(group: group)
                    section.boundarySupplementaryItems = [header, footer]
                    
                    return section
                        
                }
                
            } else if sectionNumber == 8 {
                if self.hasPublications == false {
                    
                    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                    
                    
                    let section = NSCollectionLayoutSection(group: group)
                  
                        
                    return section
                } else {
                    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                             elementKind: ElementKind.sectionHeader,
                                                                             alignment: .top)
        
                    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                    
                    let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                             elementKind: ElementKind.sectionFooter,
                                                                             alignment: .bottom)
                    
                    let section = NSCollectionLayoutSection(group: group)
                    section.boundarySupplementaryItems = [header, footer]
                        
                    return section
                }
               
            } else if sectionNumber == 9 {
                if self.hasLanguages == false {
                    
                    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                    
                   
                    let section = NSCollectionLayoutSection(group: group)
                    
                    return section
                        
                } else {
                    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                             elementKind: ElementKind.sectionHeader,
                                                                             alignment: .top)
        
                    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                    
                    let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                             elementKind: ElementKind.sectionFooter,
                                                                             alignment: .bottom)
                    
                    let section = NSCollectionLayoutSection(group: group)
                    section.boundarySupplementaryItems = [header, footer]
                    
                    return section
                        
                }
                
            } else {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
    
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                item.contentInsets.leading = 10
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.30), heightDimension: .absolute(120)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header]
                section.orthogonalScrollingBehavior = .continuous
                
                
                return section
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()

        config.interSectionSpacing = 0
        layout.configuration = config
        return layout
    }
    
    //MARK: - API
    
    func fetchRecentPosts() {
        guard let uid = user.uid else { return }
        DatabaseManager.shared.fetchRecentPosts(forUid: uid) { result in
            switch result {
            case .success(let postIDs):
                PostService.fetchRecentPosts(withPostId: postIDs) { recentPosts in
                    self.recentPosts = recentPosts
                }
            case .failure(_):
                print("Failure fetching posts")
            }
        }
    }
    
    func fetchRecentCases() {
        guard let uid = user.uid else { return }
        DatabaseManager.shared.fetchRecentCases(forUid: uid) { result in
            switch result {
            case .success(let caseIDs):
                CaseService.fetchRecentCases(withCaseId: caseIDs) { recentCases in
                    self.recentCases = recentCases
                    
                }
            case .failure(_):
                print("Failure fetching posts")
            }
        }
    }
    
    func fetchRecentComments() {
        guard let uid = user.uid else { return }
        print("starting fetching comments")
        DatabaseManager.shared.fetchRecentComments(forUid: uid) { result in
            switch result {
            case .success(let recentComments):
                self.hasComments = true
                self.recentComments = recentComments
            case .failure(_):
                print("Failure fetching recent comments")
            }
        }
    }
    
    func fetchEducation() {
        guard let uid = user.uid else { return }
        DatabaseManager.shared.fetchEducation(forUid: uid) { result in
            switch result {
            case .success(let education):
                self.education = education
                self.hasEducation = true
                //self.collectionView.reloadSections(IndexSet(integer: 1))
                self.collectionView.reloadData()
            case .failure(_):
                print("No section")
            }
        }
    }
    
    func fetchSections() {
        // About Section
        guard let uid = user.uid else { return }
        DatabaseManager.shared.fetchAboutSection(forUid: uid) { result in
            switch result {
            case .success(let sectionText):
                self.aboutText = sectionText
                self.hasAbout = true
                //self.collectionView.reloadSections(IndexSet(integer: 1))
                self.collectionView.reloadData()
            case .failure(_):
                print("No section")
            }
        }
    }
    
    func fetchLanguages() {
        guard let uid = user.uid else { return }
        DatabaseManager.shared.fetchLanguages(forUid: uid) { result in
            switch result {
            case .success(let languages):
                //self.aboutText = sectionText
                //self.collectionView.reloadSections(IndexSet(integer: 1))
                self.hasLanguages = true
                self.languages = languages
                self.collectionView.reloadData()
            case .failure(_):
                print("No languages ")
            }
        }
    }
    
    func fetchExperience() {
        guard let uid = user.uid else { return }
        DatabaseManager.shared.fetchExperience(forUid: uid) { result in
            switch result {
            case .success(let experiences):
                //self.aboutText = sectionText
                //self.collectionView.reloadSections(IndexSet(integer: 1))
                self.hasExperiences = true
                self.experience = experiences
                self.collectionView.reloadData()
            case .failure(_):
                print("No languages ")
            }
        }
    }
    
    func fetchRelated() {
        DatabaseManager.shared.getAllUsers { result in
            switch result {
                
            case .success(let users):
                self.relatedUsers = users
            case .failure(_):
                print("Failed to fetch users")
            }
        }
    }
    
    func fetchPatents() {
        guard let uid = user.uid else { return }
        DatabaseManager.shared.fetchPatents(forUid: uid) { result in
            switch result {
            case .success(let languages):
                //self.aboutText = sectionText
                //self.collectionView.reloadSections(IndexSet(integer: 1))
                self.hasPatents = true
                self.patents = languages
                self.collectionView.reloadData()
            case .failure(_):
                print("No Patents")
            }
        }
    }
    
    func fetchPublications() {
        guard let uid = user.uid else { return }
        DatabaseManager.shared.fetchPublications(forUid: uid) { result in
            switch result {
            case .success(let publications):
                //self.aboutText = sectionText
                //self.collectionView.reloadSections(IndexSet(integer: 1))
                self.hasPublications = true
                self.publications = publications
                self.collectionView.reloadData()
            case .failure(_):
                print("No publications")
            }
        }
    }
    
    func fetchUserStats() {
        UserService.fetchUserStats(uid: user.uid!) { stats in
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }
    
    func checkIfUserIsFollowed() {
        UserService.checkIfUserIsFollowed(uid: user.uid!) { isFollowed in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    
    //MARK: - Actions
    @objc func didTapSettings() {
        AuthService.logout()
        AuthService.googleLogout()
        let controller = WelcomeViewController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}

extension UserProfileViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 11
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Header
        if section == 0 {
            return 1
        }
        //About
        else if section == 1 {
            if hasAbout {
                return 1
            } else {
                return 0
            }
        } else if section == 2 {
            // Posts
            if user.stats.posts == 0 {
                return 1
            } else {
                return min(recentPosts.count, 3)
            }
        } else if section == 3 {
            // Cases
            if user.stats.cases == 0 {
                return 1
            } else {
                return min(recentCases.count, 3)
            }
        } else if section == 4 {
            if hasComments {
                return min(recentComments.count, 3)
            } else {
                return 1
            }
        } else if section == 5 {
            if hasExperiences {
                return min(experience.count, 3)
            } else {
                return 0
            }
            
        } else if section == 6 {
            if hasEducation {
                return min(education.count, 3)
            } else {
                return 0
            }
            
        } else if section == 7 {
            if hasPatents {
                return min(patents.count, 3)
            } else {
                return 0
            }
            
        } else if section == 8 {
            if hasPublications {
                return min(publications.count, 3)
            } else {
                return 0
            }

        } else if section == 9 {
            if hasLanguages {
                return min(languages.count, 3)
            } else {
                return 0
            }
            
        } else {
            return relatedUsers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileHeaderReuseIdentifier, for: indexPath) as! UserProfileHeaderCell
            cell.viewModel = ProfileHeaderViewModel(user: user)
            cell.delegate = self
            return cell
            
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileAboutCellReuseIdentifier, for: indexPath) as! UserProfileAboutCell
            cell.set(body: aboutText)
            return cell
            
        } else if indexPath.section == 2 {
            // Post
            if user.stats.posts == 0 {
                // User has no recent posts, display no activity
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: noRecentPostsCellReuseIdentifier, for: indexPath) as! UserProfileNoPostCell
                cell.configure(user: user)
                return cell
                
            } else {
                
                if recentPosts[indexPath.row].type.postType == 0 {
                    // Text Post
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postTextCellReuseIdentifier, for: indexPath) as! UserProfilePostCell
                    cell.viewModel = PostViewModel(post: recentPosts[indexPath.row])
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postImageCellReuseIdentifier, for: indexPath) as! UserProfilePostImageCell
                    cell.viewModel = PostViewModel(post: recentPosts[indexPath.row])
                    return cell
                }
            }
            
        } else if indexPath.section == 3 {
            // Cases
            if user.stats.cases == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: noRecentCasesCellReuseIdentifier, for: indexPath) as! UserProfileNoCaseCell
                cell.configure(user: user)
                return cell
            } else {
                
                if recentCases[indexPath.row].type.caseType == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseTextCellReuseIdentifier, for: indexPath) as! UserProfileCaseTextCell
                    cell.viewModel = CaseViewModel(clinicalCase: recentCases[indexPath.row])
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseImageCellReuseIdentifier, for: indexPath) as! UserProfileCaseImageCell
                    cell.viewModel = CaseViewModel(clinicalCase: recentCases[indexPath.row])
                    return cell
                }
            }
            
        } else if indexPath.section == 4 {
            // Comments
            if hasComments {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentsCellReuseIdentifier, for: indexPath) as! UserProfileCommentCell
                cell.configure(commentInfo: recentComments[indexPath.row], user: user)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: noCommentsCellReuseIdentifier, for: indexPath) as! UserProfileNoCommentsCell
                cell.configure(user: user)
                return cell
            }

            
        } else if indexPath.section == 5 {
            // Experience
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: experienceCellReuseIdentifier, for: indexPath) as! UserProfileExperienceCell
            cell.set(experienceInfo: experience[indexPath.row])
            return cell
            
        } else if indexPath.section == 6 {
            // Education
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: educationCellReuseIdentifier, for: indexPath) as! UserProfileEducationCell
            cell.set(educationInfo: education[indexPath.row])
            return cell
            
        } else if indexPath.section == 7 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: patentCellReuseIdentifier, for: indexPath) as! UserProfilePatentCell
            cell.set(patentInfo: patents[indexPath.row])
            return cell
            
        } else if indexPath.section == 8 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: publicationsCellReuseIdentifier, for: indexPath) as! UserProfilePublicationCell
            cell.set(publicationInfo: publications[indexPath.row])
            return cell
            
        } else if indexPath.section == 9 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: languageCellReuseIdentifier, for: indexPath) as! UserProfileLanguageCell
            cell.set(languageInfo: languages[indexPath.row])
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: seeOthersCellReuseIdentifier, for: indexPath) as! UserProfileSeeOthersCell
            cell.set(userInfo: relatedUsers[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case ElementKind.sectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: profileHeaderTitleReuseIdentifier, for: indexPath) as! UserProfileTitleHeader
            if indexPath.section == 1 {
                header.set(title: "About")
            }else if indexPath.section == 2 {
                header.set(title: "Posts")
            } else if indexPath.section == 3 {
                header.set(title: "Cases")
            } else if indexPath.section == 4 {
                header.set(title: "Comments")
            } else if indexPath.section == 5 {
                header.set(title: "Experience")
            } else if indexPath.section == 6 {
                header.set(title: "Education")
            } else if indexPath.section == 7 {
                header.set(title: "Patents")
            } else if indexPath.section == 8 {
                header.set(title: "Publications")
            } else if indexPath.section == 9 {
                header.set(title: "Languages")
            } else {
                header.set(title: "Related")
            }
            return header
            
        case ElementKind.sectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: profileFooterTitleReuseIdentifier, for: indexPath) as! UserProfileTitleFooter
            if indexPath.section == 2 {
                footer.set(title: "Show posts")
            } else if indexPath.section == 3 {
                footer.set(title: "Show cases")
            } else if indexPath.section == 4 {
                footer.set(title: "Show comments")
            } else if indexPath.section == 5 {
                footer.set(title: "Show experiences")
            } else if indexPath.section == 6 {
                footer.set(title: "Show education")
            } else if indexPath.section == 7 {
                footer.set(title: "Show patents")
            } else if indexPath.section == 8 {
                footer.set(title: "Show publications")
            } else if indexPath.section == 9 {
                footer.set(title: "Show languages")
            }
            return footer
        default:
            print("No Kind registered")
            //assert(true)
            return UICollectionReusableView()
        }
    }
}


//MARK: - UserProfileHeaderDelegate

extension UserProfileViewController: UserProfileHeaderCellDelegate {
    
    func headerCell(didTapEditProfileFor user: User) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        if user.isCurrentUser {
            let controller = EditProfileViewController(user: user)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        } else {
            guard let uid = user.uid else { return }
            if user.isFollowed {
                // Handle unfollow user
                UserService.unfollow(uid: uid) { error in
                    self.user.isFollowed = false
                    self.fetchUserStats()
                    // Delete user feed posts related to the unfollowed user
                    PostService.updateUserFeedAfterFollowing(user: user, didFollow: false)
                }
            } else {
                // Handle follow user
                UserService.follow(uid: uid) { error in
                    self.user.isFollowed = true
                    self.fetchUserStats()
                    NotificationService.uploadNotification(toUid: uid, fromUser: currentUser, type: .follow)
                    //Update user feed posts related to the followed user
                    PostService.updateUserFeedAfterFollowing(user: user, didFollow: true)
                }
            }
        }
    }
    
    func headerCell(didTapBannerPictureFor user: User) {
        let controller = ProfileImageViewController(user: user, isBanner: true)
        controller.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async {
            controller.profileImageView.sd_setImage(with: URL(string: user.bannerImageUrl!))
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true)
        }
    }
    
    func headerCell(didTapProfilePictureFor user: User) {
        let controller = ProfileImageViewController(user: user, isBanner: false)
        controller.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async {
            controller.profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true)
        }
    }
}

