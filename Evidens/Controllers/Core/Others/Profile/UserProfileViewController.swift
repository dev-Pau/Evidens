//
//  UserProfileViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/5/22.
//

import UIKit
import GoogleSignIn

private let stretchyReuseIdentifier = "StretchyReuseIdentifier"
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
    private var standardAppearance = UINavigationBarAppearance()
    
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
    
    var relatedUsers = [User]() {
        didSet {
            print(relatedUsers)
            collectionView.reloadData()
        }
    }
        
    //About
    private var hasAbout: Bool = false
    private var aboutText: String = ""
    
    //Languages
    private var hasLanguages: Bool = false
    private var languages = [[String: String]]()
    
    //Patents
    private var hasPatents: Bool = false
    private var patents = [[String: String]]()
    
    //Publications
    private var publications = [[String: String]]()
    
    //Education
    private var hasEducation: Bool = false
    private var education = [[String: String]]()
    
    //Profession
    private var experience = [[String: String]]()
    
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
    }()
    
    private var collectionView: UICollectionView!
  
    private lazy var customRightButton: UIButton = {
        let button = UIButton()

        button.configuration = .filled()

        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground

        button.configuration?.cornerStyle = .capsule
        //button.becomeFirstResponder()
        button.addTarget(self, action: #selector(handleUserButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var ellipsisRightButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .mini
        button.configuration?.baseBackgroundColor = .label.withAlphaComponent(0.7)
        button.configuration?.image = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.systemBackground)
        //button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .mini
        button.configuration?.baseBackgroundColor = .label.withAlphaComponent(0.7)
        button.configuration?.image = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.systemBackground)
        button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.backgroundColor = .quaternarySystemFill
        return iv
    }()
        
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        ellipsisRightButton.menu = addEllipsisMenuItems()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        
        
        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = .systemBackground
        navigationController?.navigationBar.standardAppearance = standardAppearance
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .bold)
        
        let viewModel = ProfileHeaderViewModel(user: user)
        customRightButton.configuration?.baseBackgroundColor = viewModel.followButtonBackgroundColor
        customRightButton.configuration?.baseForegroundColor = viewModel.followButtonTextColor
        customRightButton.configuration?.background.strokeColor = viewModel.followButtonBorderColor
        customRightButton.configuration?.attributedTitle = AttributedString(viewModel.customFollowButtonText, attributes: container)
        
        if !user.isCurrentUser {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: ellipsisRightButton)

        }
       
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30 / 2
        imageView.sd_setImage(with: URL(string: user.profileImageUrl!))
        
        let imageViewContainer = LogoContainerView(imageView: imageView)
        imageViewContainer.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        
        navigationItem.titleView = imageViewContainer
        navigationItem.titleView?.isHidden = true
    }
    
    private func addEllipsisMenuItems() -> UIMenu? {
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title: "Report " + user.firstName!, image: UIImage(systemName: "flag", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!, handler: { _ in
                print("did report user")
            })
        ])
        ellipsisRightButton.showsMenuAsPrimaryAction = true
        return menuItems
    }
    
    private func addUnfollowMenu() -> UIMenu? {
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title: "Unfollow " + user.firstName!, image: UIImage(systemName: "person.fill.xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!, attributes: .destructive, handler: { _ in
                print("did unfollow user")
            })
        ])
        customRightButton.showsMenuAsPrimaryAction = true
        return menuItems
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxVerticalOffset = (view.frame.width / 3) / 2
        let currentVeritcalOffset = scrollView.contentOffset.y
        let percentageOffset = currentVeritcalOffset / maxVerticalOffset
        standardAppearance.backgroundColor = .systemBackground.withAlphaComponent(percentageOffset)
        navigationController?.navigationBar.standardAppearance = standardAppearance
        
        if currentVeritcalOffset > (view.frame.width / 3 + 10 + 30 - topbarHeight) {
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.label).withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(handleBack))

            var container = AttributeContainer()
            container.font = .systemFont(ofSize: 14, weight: .bold)
            
            if self.user.isFollowed {
                //navigationItem.rightBarButtonItem = UIBarB
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis")?.withTintColor(.label).withRenderingMode(.alwaysOriginal), menu: addEllipsisMenuItems())
                return
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customRightButton)
        } else {
            if !user.isCurrentUser {
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: ellipsisRightButton)
            }

            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
            navigationItem.setRightBarButton(nil, animated: true)
        }
        
        if currentVeritcalOffset > (view.frame.width / 3 + 90 - topbarHeight) {
            navigationItem.titleView?.isHidden = false
        } else {
            navigationItem.titleView?.isHidden = true
        }
    }
    
    func configureCollectionView() {
       
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
       
        collectionView.translatesAutoresizingMaskIntoConstraints = false
      
        view.addSubview(collectionView)
       
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MEStretchyHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: stretchyReuseIdentifier)
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
        let layout = StretchyHeaderLayout { sectionNumber, env in
            if sectionNumber == 0 {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(self.view.frame.width / 3)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
                // Profile Header
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(350)))
                //item.contentInsets.bottom = 16
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(350)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header]
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
                if self.user.stats.posts > 3 {
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
            } else if sectionNumber == 3 {
                if self.user.stats.cases > 3 {
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
                
            } else if sectionNumber == 4 {
                if self.recentComments.count == 3 {
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
                
            } else if sectionNumber == 5 {
                // Experience
                
                if self.experience.count == 0 {
                    
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
                    
                    if self.experience.count < 4 {
                        
                        let section = NSCollectionLayoutSection(group: group)
                        section.boundarySupplementaryItems = [header]
                        return section
                        
                    } else {
                        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                                 elementKind: ElementKind.sectionFooter,
                                                                                 alignment: .bottom)
                        
                        let section = NSCollectionLayoutSection(group: group)
                        section.boundarySupplementaryItems = [header, footer]
                        return section
                    }
                }
 
                
            } else if sectionNumber == 6 {
                // Education
                if self.education.count == 0 {
                    
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
                    
                    if self.education.count < 4 {
                        
                        let section = NSCollectionLayoutSection(group: group)
                        section.boundarySupplementaryItems = [header]
                        return section
                        
                    } else {
                        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                                 elementKind: ElementKind.sectionFooter,
                                                                                 alignment: .bottom)
                        
                        let section = NSCollectionLayoutSection(group: group)
                        section.boundarySupplementaryItems = [header, footer]
                        return section
                    }
                }
 
            } else if sectionNumber == 7 {
                // Patents
                if self.patents.count == 0 {
                    
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
                    
                    if self.patents.count < 4 {
                        
                        let section = NSCollectionLayoutSection(group: group)
                        section.boundarySupplementaryItems = [header]
                        return section
                        
                    } else {
                        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                                 elementKind: ElementKind.sectionFooter,
                                                                                 alignment: .bottom)
                        
                        let section = NSCollectionLayoutSection(group: group)
                        section.boundarySupplementaryItems = [header, footer]
                        return section
                    }
                }
                
            } else if sectionNumber == 8 {
                if self.publications.count == 0 {
                    
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
                    
                    if self.publications.count < 4 {
                        
                        let section = NSCollectionLayoutSection(group: group)
                        section.boundarySupplementaryItems = [header]
                        return section
                        
                    } else {
                        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                                 elementKind: ElementKind.sectionFooter,
                                                                                 alignment: .bottom)
                        
                        let section = NSCollectionLayoutSection(group: group)
                        section.boundarySupplementaryItems = [header, footer]
                        return section
                    }
                }
               
            } else if sectionNumber == 9 {
                if self.languages.count == 0 {
                    
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
                    
                    if self.languages.count < 4 {
                        
                        let section = NSCollectionLayoutSection(group: group)
                        section.boundarySupplementaryItems = [header]
                        return section
                        
                    } else {
                        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
                                                                                 elementKind: ElementKind.sectionFooter,
                                                                                 alignment: .bottom)
                        
                        let section = NSCollectionLayoutSection(group: group)
                        section.boundarySupplementaryItems = [header, footer]
                        return section
                    }
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
    
    @objc func handleBack() {
        print("dismiss")
        navigationController?.popViewController(animated: true)
    }
    
    
    @objc func handleUserButton() {
        //button.becomeFirstResponder()
        if user.isCurrentUser {
            let controller = EditProfileViewController(user: user)
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        } else {
            collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            /*
            if user.isFollowed {
                print("follow user and update UI")
                //customRightButton.menu = nil
            } else {
                customRightButton.menu = nil
                
            }
             */
        }
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
                
                self.hasLanguages = true
                self.languages = languages
                //self.collectionView.reloadData()
                break
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
                self.experience = experiences
                self.collectionView.reloadData()
            case .failure(_):
                print("No languages ")
            }
        }
    }
    
    func fetchRelated() {
        guard let profession = user.profession else { return }
        UserService.fetchRelatedUsers(withProfession: profession) { relatedUsers in
            self.relatedUsers = relatedUsers

        }
        /*
        DatabaseManager.shared.getAllUsers { result in
            switch result {
                
            case .success(let users):
                self.relatedUsers = users
            case .failure(_):
                print("Failed to fetch users")
            }
        }
         */
    }
    
    func fetchPatents() {
        guard let uid = user.uid else { return }
        DatabaseManager.shared.fetchPatents(forUid: uid) { result in
            switch result {
            case .success(let patents):
                //self.aboutText = sectionText
                //self.collectionView.reloadSections(IndexSet(integer: 1))
                self.hasPatents = true
                self.patents = patents
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
            //if !isFollowed { self.customRightButton.menu = self.addUnfollowMenu()}
            self.collectionView.reloadData()
        }
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
            if recentComments.count != 0 {
                return min(recentComments.count, 3)
            } else {
                return 1
            }
        } else if section == 5 {
            if experience.count != 0 {
                return min(experience.count, 3)
            } else {
                return 0
            }
            
        } else if section == 6 {
            if education.count != 0 {
                return min(education.count, 3)
            } else {
                return 0
            }
            
        } else if section == 7 {
            if patents.count != 0 {
                return min(patents.count, 3)
            } else {
                return 0
            }
            
        } else if section == 8 {
            if publications.count != 0 {
                return min(publications.count, 3)
            } else {
                return 0
            }

        } else if section == 9 {
            if languages.count != 0 {
                return min(languages.count, 3)
            } else {
                return 0
            }
            
        } else {
            return relatedUsers.count
        }
    }
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == 0 {
            return -30
        } else {
            return 0
        }
    }
     */
    
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
            if recentComments.count != 0 {
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
            if indexPath.row == experience.count - 1 {
                cell.separatorView.isHidden = true
            }
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
            
            cell.set(user: relatedUsers[indexPath.row])
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case ElementKind.sectionHeader:
            
            if indexPath.section == 0 {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: stretchyReuseIdentifier, for: indexPath) as! MEStretchyHeader
                header.setImageWithStringUrl(imageUrl: user.bannerImageUrl!)
                return header
            }
            
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: profileHeaderTitleReuseIdentifier, for: indexPath) as! UserProfileTitleHeader
            header.delegate = self
            
            header.buttonImage.isHidden = user.isCurrentUser ? false : true
            header.buttonImage.isEnabled = user.isCurrentUser ? true : false
            
            if indexPath.section == 1 {
                header.set(title: "About")
            }else if indexPath.section == 2 {
                header.buttonImage.isHidden = true
                header.set(title: "Posts")
            } else if indexPath.section == 3 {
                header.buttonImage.isHidden = true
                header.set(title: "Cases")
            } else if indexPath.section == 4 {
                header.buttonImage.isHidden = true
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
                header.buttonImage.isHidden = true
                header.set(title: "Related")
            }
            return header
            
        case ElementKind.sectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: profileFooterTitleReuseIdentifier, for: indexPath) as! UserProfileTitleFooter
            footer.delegate = self
            
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            // About
            let controller = AboutSectionViewController(section: aboutText)
            controller.title = "About"
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.section == 2 {
            // Posts
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            
            let controller = DetailsPostViewController(post: recentPosts[indexPath.row], user: user, collectionViewLayout: layout)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
            
        } else if indexPath.section == 3 {
            guard !recentCases.isEmpty else { return }
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: view.frame.width, height: 300)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            
            let controller = DetailsCaseViewController(clinicalCase: recentCases[indexPath.row], user: user, collectionViewFlowLayout: layout)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            navigationController?.pushViewController(controller, animated: true)
            
        } else if indexPath.section == 4 {
            // Comments
            let comment = recentComments[indexPath.row]
            guard let type = comment["type"] as? Int else { return }
            
            if type == 0 {
                // Post
                if let postUid = comment["refUid"] as? String {
                    showLoadingView()
                    PostService.fetchPost(withPostId: postUid) { post in
                        self.dismissLoadingView()
                        let layout = UICollectionViewFlowLayout()
                        layout.scrollDirection = .vertical
                        layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 300)
                        layout.minimumLineSpacing = 0
                        layout.minimumInteritemSpacing = 0
                        
                        let controller = DetailsPostViewController(post: post, user: self.user, collectionViewLayout: layout)
                        
                        let backItem = UIBarButtonItem()
                        backItem.title = ""
                        backItem.tintColor = .label
                        self.navigationItem.backBarButtonItem = backItem
                        
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            } else {
                // Case
                if let caseUid = comment["refUid"] as? String {
                    showLoadingView()
                    CaseService.fetchCase(withCaseId: caseUid) { clinicalCase in
                        self.dismissLoadingView()
                        let layout = UICollectionViewFlowLayout()
                        layout.scrollDirection = .vertical
                        layout.estimatedItemSize = CGSize(width: self.view.frame.width, height: 300)
                        layout.minimumLineSpacing = 0
                        layout.minimumInteritemSpacing = 0
                        
                        let controller = DetailsCaseViewController(clinicalCase: clinicalCase, user: self.user, collectionViewFlowLayout: layout)
                        
                        let backItem = UIBarButtonItem()
                        backItem.tintColor = .label
                        backItem.title = ""
                        self.navigationItem.backBarButtonItem = backItem
                        
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }
        }
    }
}


//MARK: - UserProfileHeaderDelegate

extension UserProfileViewController: UserProfileHeaderCellDelegate {
    
    func headerCell(didTapFollowingFollowersFor user: User) {
        let controller = FollowersFollowingViewController(user: user)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func headerCell(_ cell: UICollectionViewCell, didTapEditProfileFor user: User) {

        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        guard let currentCell = cell as? UserProfileHeaderCell else { return }
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        
        if user.uid == uid {
            let controller = EditProfileViewController(user: user)
            controller.delegate = self
            
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
                    currentCell.isUpdatingFollowState = false
                    // Delete user feed posts related to the unfollowed user
                    PostService.updateUserFeedAfterFollowing(userUid: uid, didFollow: false)
                }
            } else {
                // Handle follow user
                UserService.follow(uid: uid) { error in
                    self.user.isFollowed = true
                    self.fetchUserStats()
                    currentCell.isUpdatingFollowState = false
                    NotificationService.uploadNotification(toUid: uid, fromUser: currentUser, type: .follow)
                    //Update user feed posts related to the followed user
                    PostService.updateUserFeedAfterFollowing(userUid: uid, didFollow: true)
                }
            }
        }
    }
    
    func headerCell(didTapBannerPictureFor user: User) {
        let controller = ProfileImageViewController(isBanner: true)
        controller.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async {
            controller.profileImageView.sd_setImage(with: URL(string: user.bannerImageUrl!))
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true)
        }
    }
    
    func headerCell(didTapProfilePictureFor user: User) {
        let controller = ProfileImageViewController(isBanner: false)
        controller.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async {
            controller.profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true)
        }
    }
}

extension UserProfileViewController: UserProfileSeeOthersCellDelegate {
    func didTapProfile(forUser user: User) {
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        backItem.tintColor = .label
        
        let controller = UserProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
        
        DatabaseManager.shared.uploadRecentUserSearches(withUid: user.uid!) { _ in }
    }
    
    
}

extension UserProfileViewController: UserProfileTitleHeaderDelegate {
    func didTapEditSection(sectionTitle: String) {
        switch sectionTitle {
        case "About":
            let controller = AddAboutViewController()
            controller.title = "About"
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
            
        case "Patents":
            let controller = PatentSectionViewController(user: user, patents: patents, isCurrentUser: user.isCurrentUser)
            controller.title = "Patents"
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
            
        case "Education":
            let controller = EducationSectionViewController(education: education, isCurrentUser: user.isCurrentUser)
            controller.title = "Education"
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
            
        case "Languages":
            let controller = LanguageSectionViewController(languages: languages, isCurrentUser: user.isCurrentUser)
            controller.title = "Languages"
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
            
        case "Publications":
            let controller = PublicationSectionViewController(publications: publications, isCurrentUser: user.isCurrentUser)
            controller.title = "Publications"
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
            
        case "Experience":
            let controller = ExperienceSectionViewController(experience: experience, isCurrentUser: user.isCurrentUser)
            controller.title = "Experience"
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)

        default:
            print("No cell registered")
        }
    }
}

extension UserProfileViewController: UserProfileTitleFooterDelegate {
    func didTapFooter(section: String) {
        switch section {
        case "Show posts":

            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 300)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            let controller = HomeViewController()
            controller.controllerIsBeeingPushed = true
            controller.displaysSinglePost = true
            controller.user = user
            
            controller.hidesBottomBarWhenPushed = true
            
            navigationController?.pushViewController(controller, animated: true)
            
        case "Show cases":
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 300)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            let controller = CaseViewController(user: user)
            //controller.controllerIsBeeingPushed = true
            //controller.displaysSinglePost = true
            navigationController?.pushViewController(controller, animated: true)
            
        case "Show comments":
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .zero)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            let controller = UserCommentsViewController(user: user, collectionViewFlowLayout: layout)
       
            navigationController?.pushViewController(controller, animated: true)
        
   
    case "Show experiences":
        let controller = ExperienceSectionViewController(experience: experience, isCurrentUser: user.isCurrentUser)
        controller.delegate = self
        let backItem = UIBarButtonItem()
        backItem.title = ""
            backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
            navigationController?.pushViewController(controller, animated: true)

         
        case "Show education":
            let controller = EducationSectionViewController(education: education, isCurrentUser: user.isCurrentUser)
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
            
            
        case "Show patents":
            let controller = PatentSectionViewController(user: user, patents: patents, isCurrentUser: user.isCurrentUser)
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)

            
        case "Show publications":
            let controller = PublicationSectionViewController(publications: publications, isCurrentUser: user.isCurrentUser)
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
            
        case "Show languages":
            let controller = LanguageSectionViewController(languages: languages, isCurrentUser: user.isCurrentUser)
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            navigationItem.backBarButtonItem = backItem


            navigationController?.pushViewController(controller, animated: true)
            //co
        default:
            print("no footer registered")
        }
    }
}

extension UserProfileViewController: EditProfileViewControllerDelegate, AddAboutViewControllerDelegate, LanguageSectionViewControllerDelegate {
    func didUpdateProfile(user: User) {
        self.user = user
        UserDefaults.standard.set(user.profileImageUrl, forKey: "userProfileImageUrl")
        UserDefaults.standard.set(user.firstName! + " " + user.lastName!, forKey: "name")
        
        UserService.fetchUserStats(uid: user.uid!) { stats in
            self.user.stats = stats
            self.collectionView.reloadSections(IndexSet(integer: 0))
 
            //guard let tab = self.tabBarController as? MainTabController else { return }
            //tab.updateUser(user: user)
        }
    }
    
    func updateLanguageValues() {
        fetchUserStats()
        fetchLanguages()
    }
    
    
    func fetchNewLanguageValues() {
        fetchUserStats()
        fetchLanguages()
    }
    
    func fetchNewPublicationValues() {
        fetchUserStats()
        fetchPublications()
    }
    
    func fetchNewPatentValues() {
        fetchUserStats()
        fetchPatents()
    }
    
    func fetchNewEducationValues() {
        fetchUserStats()
        fetchEducation()
    }
    
    func fetchNewExperienceValues(withUid uid: String) {
        fetchUserStats()
        fetchExperience()
    }
    
    func handleUpdateAbout() {
        fetchUserStats()
        fetchSections()
    }
    
    func fetchNewAboutValues(withUid uid: String) {
        fetchUserStats()
        fetchSections()
    }
    
    func fetchNewUserValues(withUid uid: String) {
        UserService.fetchUser(withUid: uid) { user in
    
            #warning("Asignar al user al main tab controllerl també perquè sinó es perd la info nova")
            self.user = user
            self.collectionView.reloadData()
        }
    }
    
    
}

class StretchyHeaderLayout: UICollectionViewCompositionalLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        layoutAttributes?.forEach { attribute in
            if attribute.representedElementKind == ElementKind.sectionHeader && attribute.indexPath.section == 0 {
                guard let collectionView = collectionView else { return }
               
                let contentOffsetY = collectionView.contentOffset.y
                if contentOffsetY < 0 {
                    let width = UIScreen.main.bounds.width
                    let height = width / 3 - contentOffsetY
                    attribute.frame = CGRect(x: 0, y: contentOffsetY, width: width, height: height)
                }
            }
        }
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}


class LogoContainerView: UIView {
    let imageView: UIImageView
    init(imageView: UIImageView) {
        self.imageView = imageView
        super.init(frame: CGRect.zero)
        
        addSubview(imageView)
    }
    
    override convenience init(frame: CGRect) {
        self.init(imageView: UIImageView())
        self.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
}
