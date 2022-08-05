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
private let postImageCellReuseIdentifier = "ProfileImageCellReuseIdentifier"
private let postTextCellReuseIdentifier = "PostTextCellReuseIdentifier"
private let caseImageCellReuseIdentifier = "CaseImageCellReuseIdentifier"
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

class UserProfileViewController: UICollectionViewController {
    

    //MARK: - Properties
    private var user: User
    
    // Sections
    private var hasAbout: Bool = false
    private var aboutText: String = ""
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchTextField.backgroundColor = lightColor
        return searchBar
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItemButton()
        //PostService.fetchPosts(forUser: <#T##String#>, completion: <#T##([Post]) -> Void#>)
        //CaseService fetch 3 last psts
        configureCollectionView()
        fetchRecentPosts()
        fetchSections()
        checkIfUserIsFollowed()
        fetchUserStats()
    }
        
    init(user: User) {
        self.user = user
        
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
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)))
                //item.contentInsets.bottom = 16
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                //section.orthogonalScrollingBehavior = .continuous
                return section
            } else if sectionNumber == 2 {
                // Posts
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
    
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                
                let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)),
                                                                         elementKind: ElementKind.sectionFooter,
                                                                         alignment: .bottom)
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header, footer]
                return section
                
            } else if sectionNumber == 3 {
            // Cases
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
    
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                
                let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)),
                                                                         elementKind: ElementKind.sectionFooter,
                                                                         alignment: .bottom)
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header, footer]
                    
                return section
            } else if sectionNumber == 4 {
                // Comments
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
    
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                
                let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)),
                                                                         elementKind: ElementKind.sectionFooter,
                                                                         alignment: .bottom)
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header, footer]
                    
                return section
            } else if sectionNumber == 5 {
                // Experience
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
    
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                
                let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)),
                                                                         elementKind: ElementKind.sectionFooter,
                                                                         alignment: .bottom)
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header, footer]
                    
                return section
            } else if sectionNumber == 6 {
                // Education
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
    
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                
                let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)),
                                                                         elementKind: ElementKind.sectionFooter,
                                                                         alignment: .bottom)
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header, footer]
                    
                return section
            } else if sectionNumber == 7 {
                // Patents
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
    
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                
                let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)),
                                                                         elementKind: ElementKind.sectionFooter,
                                                                         alignment: .bottom)
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header, footer]
                
                return section
                    
            } else if sectionNumber == 8 {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
    
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                
                let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)),
                                                                         elementKind: ElementKind.sectionFooter,
                                                                         alignment: .bottom)
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header, footer]
                    
                return section
            } else if sectionNumber == 9 {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
    
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                
                let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)),
                                                                         elementKind: ElementKind.sectionFooter,
                                                                         alignment: .bottom)
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header, footer]
                
                return section
                    
            } else {
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
    
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))

                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.30), heightDimension: .absolute(120)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header]
                section.orthogonalScrollingBehavior = .continuous
                
                
                return section
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 10
        layout.configuration = config

        super.init(collectionViewLayout: layout)
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
        collectionView.backgroundColor = lightGrayColor
        collectionView.register(UserProfileHeaderCell.self, forCellWithReuseIdentifier: profileHeaderReuseIdentifier)
        collectionView.register(UserProfileTitleHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: profileHeaderTitleReuseIdentifier)
        collectionView.register(UserProfileTitleFooter.self, forSupplementaryViewOfKind: ElementKind.sectionFooter, withReuseIdentifier: profileFooterTitleReuseIdentifier)
        collectionView.register(UserProfileAboutCell.self, forCellWithReuseIdentifier: profileAboutCellReuseIdentifier)
        collectionView.register(UserProfilePostImageCell.self, forCellWithReuseIdentifier: postImageCellReuseIdentifier)
        collectionView.register(UserProfilePostCell.self, forCellWithReuseIdentifier: postTextCellReuseIdentifier)
        collectionView.register(UserProfileCaseImageCell.self, forCellWithReuseIdentifier: caseImageCellReuseIdentifier)
        collectionView.register(UserProfileCommentCell.self, forCellWithReuseIdentifier: commentsCellReuseIdentifier)
        collectionView.register(UserProfileExperienceCell.self, forCellWithReuseIdentifier: experienceCellReuseIdentifier)
        collectionView.register(UserProfileEducationCell.self, forCellWithReuseIdentifier: educationCellReuseIdentifier)
        collectionView.register(UserProfilePatentCell.self, forCellWithReuseIdentifier: patentCellReuseIdentifier)
        collectionView.register(UserProfilePublicationCell.self, forCellWithReuseIdentifier: publicationsCellReuseIdentifier)
        collectionView.register(UserProfileLanguageCell.self, forCellWithReuseIdentifier: languageCellReuseIdentifier)
        collectionView.register(UserProfileSeeOthersCell.self, forCellWithReuseIdentifier: seeOthersCellReuseIdentifier)
    }
    
    //MARK: - API
    
    func fetchRecentPosts() {
        
    }
    
    func fetchSections() {
        // About Section
        guard let uid = user.uid else { return }
        DatabaseManager.shared.fetchAboutSection(forUid: uid) { result in
            switch result {
            case .success(let sectionText):
                self.aboutText = sectionText
                self.hasAbout = true
                self.collectionView.reloadSections(IndexSet(integer: 1))
            case .failure(_):
                print("No section")
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
        
    }
}

extension UserProfileViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 11
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
            /*
            if user.firstName == "Pau" { if user has no about information return 0 (hide) if not return 1 and you can see about
                print("user has no about")
                return 0
             } else {
             return 1
             }
             */
        } else if section == 2 {
            // Posts
            
            return min(user.stats.posts, 3)
            
            //return 3 // return 3 which is the max or return the minimum between posts and 3. if user has 0 posts, display cell with no activity data
        } else if section == 3 {
            // Cases
            return 3
        } else if section == 4 {
            // Comments
            return 3
        } else if section == 5 {
            // Comments
            return 3
        } else if section == 6 {
            // Comments
            return 3
        } else if section == 7 {
            // Comments
            return 3
        } else if section == 8 {
            // Comments
            return 3
        } else if section == 9 {
            return 3
            
        } else {
            return 20
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileHeaderReuseIdentifier, for: indexPath) as! UserProfileHeaderCell
            cell.viewModel = ProfileHeaderViewModel(user: user)
            cell.delegate = self
            return cell
            
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileAboutCellReuseIdentifier, for: indexPath) as! UserProfileAboutCell
            // change for viewModel, fetch the information in the viewModel
            cell.set(body: aboutText)
            return cell
            
        } else if indexPath.section == 2 {
            // Post
            // posar un if en funció de si té imatge o no per presentar una cel·la o una altre.
            // ja hi ha creada la UserProfilePostCell.self que només té text
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postImageCellReuseIdentifier, for: indexPath) as! UserProfilePostImageCell
            return cell
            
        } else if indexPath.section == 3 {
            // Cases
            // posar un if en funció de si té imatge o no per presentar una cel·la o una altre.
            // ja hi ha creada la UserProfilePostCell.self que només té text
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseImageCellReuseIdentifier, for: indexPath) as! UserProfileCaseImageCell
            return cell
            
        } else if indexPath.section == 4 {
            // Comments
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentsCellReuseIdentifier, for: indexPath) as! UserProfileCommentCell
            return cell
            
        } else if indexPath.section == 5 {
            // Experience
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: experienceCellReuseIdentifier, for: indexPath) as! UserProfileExperienceCell
            return cell
            
        } else if indexPath.section == 6 {
            // Education
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: educationCellReuseIdentifier, for: indexPath) as! UserProfileEducationCell
            return cell
            
        } else if indexPath.section == 7 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: patentCellReuseIdentifier, for: indexPath) as! UserProfilePatentCell
            return cell
            
        } else if indexPath.section == 8 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: publicationsCellReuseIdentifier, for: indexPath) as! UserProfilePublicationCell
            return cell
            
        } else if indexPath.section == 9 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: languageCellReuseIdentifier, for: indexPath) as! UserProfileLanguageCell
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: seeOthersCellReuseIdentifier, for: indexPath)
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case ElementKind.sectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: profileHeaderTitleReuseIdentifier, for: indexPath) as! UserProfileTitleHeader
            if indexPath.section == 2 {
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
                header.set(title: "See Others")
            }
            return header
            
        case ElementKind.sectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: profileFooterTitleReuseIdentifier, for: indexPath) as! UserProfileTitleFooter
            if indexPath.section == 2 {
                footer.set(title: "Show all posts")
            } else if indexPath.section == 3 {
                footer.set(title: "Show all cases")
            } else if indexPath.section == 4 {
                footer.set(title: "Show all comments")
            } else if indexPath.section == 5 {
                footer.set(title: "Show all experience")
            } else if indexPath.section == 6 {
                footer.set(title: "Show all education")
            } else if indexPath.section == 7 {
                footer.set(title: "Show all patents")
            } else if indexPath.section == 8 {
                footer.set(title: "Show all publications")
            } else if indexPath.section == 9 {
                footer.set(title: "Show all languages")
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

