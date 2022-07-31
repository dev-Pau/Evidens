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
private let experienceCellReuseIdentifier = "ExperienceCellReuseIdentifier"
private let educationCellReuseIdentifier = "EducationCellReuseIdentifier"
private let test = "testIdentifier"

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
                item.contentInsets.bottom = 5
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
                item.contentInsets.bottom = 5
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
                item.contentInsets.bottom = 5
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
                item.contentInsets.bottom = 5
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
                item.contentInsets.bottom = 5
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
                item.contentInsets.leading = 10

                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.25), heightDimension: .absolute(100)), subitems: [item])
                
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
        collectionView.register(UserProfileExperienceCell.self, forCellWithReuseIdentifier: experienceCellReuseIdentifier)
        collectionView.register(UserProfileEducationCell.self, forCellWithReuseIdentifier: educationCellReuseIdentifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: test)

    }
    
    //MARK: - API
    
    
    //MARK: - Actions
    @objc func didTapSettings() {
        
    }
}

extension UserProfileViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 9
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Header
        if section == 0 {
            return 1
        }
        //About
        else if section == 1 {
            return 1
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
            return 3 // return 3 which is the max or return the minimum between posts and 3. if user has 0 posts, display cell with no activity data
        } else if section == 3 {
            // Cases
            return 3
        } else if section == 4 {
            // Comments
            return 3
        } else if section == 8 {
            return 20
        } else {
            return 3
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
            cell.set(body: "I have an extensive professional career of more than 30 years. I'm a speaker in various congresses of the speciality for my important research and education task. I'm currently 1st Vice-president of the Spanish Laser Medical-Surgery Society")
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: caseImageCellReuseIdentifier, for: indexPath)
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: test, for: indexPath)
            cell.backgroundColor = .systemPink
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: test, for: indexPath)
            cell.backgroundColor = .systemPink
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
            } else {
                footer.set(title: "Show all patents")
            }

            return footer
        default:
            print("No Kind registered")
            //assert(true)
            return UICollectionReusableView()
        }
    }
}



/*
 extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {
 
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: profileHeaderReuseIdentifier) as! UserProfileHeader
            header.viewModel = ProfileHeaderViewModel(user: user)
            header.delegate = self
            return header
        } else {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: profileHeaderReuseIdentifier) as! UserProfileHeader
            header.viewModel = ProfileHeaderViewModel(user: user)
            return header
        }


    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 410
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            return 5
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: test, for: indexPath)
        cell.backgroundColor = .white
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}
*/
//MARK: - UserProfileHeaderDelegate

extension UserProfileViewController: UserProfileHeaderCellDelegate {
    
    func headerCell(didTapEditProfileFor user: User) {
        let controller = EditProfileViewController(user: user)
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
    
    func headerCell(didTapProfilePictureFor user: User) {
        let controller = ProfileImageViewController(user: user)
        controller.hidesBottomBarWhenPushed = true
        if user.isCurrentUser {
            DispatchQueue.main.async {
                controller.profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
                controller.modalPresentationStyle = .overFullScreen
                self.present(controller, animated: true)
            }
        } else {
            print("Is not current user")
        }
    }
}
 
