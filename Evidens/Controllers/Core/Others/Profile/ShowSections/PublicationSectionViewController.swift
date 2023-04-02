//
//  PublicationSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/8/22.
//

import UIKit
import JGProgressHUD

private let publicationCellReuseIdentifier = "PublicationCellReuseIdentifier"

class PublicationSectionViewController: UIViewController {
    
    private let user: User
    
    weak var delegate: EditProfileViewControllerDelegate?
    
    private var publications = [Publication]()
    private var isCurrentUser: Bool
    private var collectionView: UICollectionView!
    private var progressIndicator = JGProgressHUD()
    private var indexPathSelected = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        title = "Publications"
    }
    
    init(user: User, publications: [Publication], isCurrentUser: Bool) {
        self.user = user
        self.publications = publications
        self.isCurrentUser = isCurrentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(UserProfilePublicationCell.self, forCellWithReuseIdentifier: publicationCellReuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            
            let _ = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(200)))
            let section = NSCollectionLayoutSection.list(using: self.createListConfiguration(), layoutEnvironment: env)
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        layout.configuration = config
        return layout
    }
    
    private func createListConfiguration() -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.trailingSwipeActionsConfigurationProvider = { indexPath in
            
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] action, view, completion in
                self?.deletePublication(at: indexPath)
                completion(true)
            }
            
            let editAction = UIContextualAction(style: .normal, title: nil ) {
                [weak self] action, view, completion in
                self?.editPublication(at: indexPath)
                completion(true)
            }
            
            deleteAction.image = UIImage(systemName: "trash.fill")
            editAction.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
            return UISwipeActionsConfiguration(actions: self.isCurrentUser ? [deleteAction, editAction] : [])
        }
        
        return configuration
    }
    
    private func deletePublication(at indexPath: IndexPath) {
        displayMEDestructiveAlert(withTitle: "Delete Publication", withMessage: "Are you sure you want to delete this publication from your profile?", withCancelButtonText: "Cancel", withDoneButtonText: "Delete") {
            self.progressIndicator.show(in: self.view)
            DatabaseManager.shared.deletePublication(publication: self.publications[indexPath.row]) { deleted in
                self.progressIndicator.dismiss(animated: true)
                if deleted {
                    self.publications.remove(at: indexPath.row)
                    self.collectionView.deleteItems(at: [indexPath])
                    self.delegate?.fetchNewPublicationValues()
                }
            }
        }
    }
    
    private func editPublication(at indexPath: IndexPath) {
        let controller = AddPublicationViewController(user: user, previousPublication: publications[indexPath.row])
        controller.delegate = self
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        controller.hidesBottomBarWhenPushed = true
        indexPathSelected = indexPath
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension PublicationSectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return publications.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: publicationCellReuseIdentifier, for: indexPath) as! UserProfilePublicationCell
        cell.set(publication: publications[indexPath.row])
        cell.delegate = self
        cell.separatorView.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = AddPublicationViewController(user: user, previousPublication: publications[indexPath.row])
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        controller.hidesBottomBarWhenPushed = true
        indexPathSelected = indexPath
        navigationController?.pushViewController(controller, animated: true)
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
}

extension PublicationSectionViewController: AddPublicationViewControllerDelegate {
    func handleDeletePublication(publication: Publication) {
        if let publicationIndex = publications.firstIndex(where: { $0.title == publication.title }) {
            publications.remove(at: publicationIndex)
            collectionView.deleteItems(at: [IndexPath(item: publicationIndex, section: 0)])
        }
    }
    
    func handleUpdatePublication(publication: Publication) {
        
        publications[indexPathSelected.row] = publication
        collectionView.reloadData()
        delegate?.fetchNewPublicationValues()
    }
}
