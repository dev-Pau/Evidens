//
//  PublicationSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/8/22.
//

import UIKit

private let publicationCellReuseIdentifier = "PublicationCellReuseIdentifier"

class PublicationSectionViewController: UICollectionViewController {
    
    private let user: User
    
    weak var delegate: EditProfileViewControllerDelegate?
    
    private var publications = [[String: Any]]()
    private var isCurrentUser: Bool
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        title = "Publications"
    }
    
    init(user: User, publications: [[String: Any]], isCurrentUser: Bool) {
        self.user = user
        self.publications = publications
        self.isCurrentUser = isCurrentUser
        
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
            
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        layout.configuration = config
        
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCollectionView() {
        collectionView.register(UserProfilePublicationCell.self, forCellWithReuseIdentifier: publicationCellReuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        view.backgroundColor = .systemBackground
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: publicationCellReuseIdentifier, for: indexPath) as! UserProfilePublicationCell
        cell.set(publicationInfo: publications[indexPath.row])
        cell.delegate = self
        cell.separatorView.isHidden = indexPath.row == 0 ? true : false
        
        cell.buttonImage.isHidden = isCurrentUser ? false : true
        cell.buttonImage.isUserInteractionEnabled = isCurrentUser ? true : false
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return publications.count
    }
}

extension PublicationSectionViewController: UserProfilePublicationCellDelegate {
    func didTapShowContributors(users: [User]) {
        let controller = ContributorsViewController(users: users)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapEditPublication(_ cell: UICollectionViewCell, publicationTitle: String, publicationDate: String, publicationUrl: String) {
        let controller = AddPublicationViewController(user: user)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        controller.configureWithPublication(publicationTitle: publicationTitle, publicationUrl: publicationUrl, publicationDate: publicationDate)
        navigationController?.pushViewController(controller, animated: true)
        
    }
}

extension PublicationSectionViewController: AddPublicationViewControllerDelegate {
    func handleUpdatePublication() {
        delegate?.fetchNewPublicationValues()
    }
    
    
}
