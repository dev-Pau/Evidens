//
//  PublicationSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/8/22.
//

import UIKit
import JGProgressHUD

private let publicationCellReuseIdentifier = "PublicationCellReuseIdentifier"

protocol PublicationSectionViewControllerDelegate: AnyObject {
    func didUpdatePublication()
}

class PublicationSectionViewController: UIViewController {
    
    private let user: User
    
    weak var delegate: PublicationSectionViewControllerDelegate?
    
    private var publications = [Publication]()
    private var isCurrentUser: Bool
    private var collectionView: UICollectionView!
    private var progressIndicator = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureCollectionView()
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
    
    private func configure() {
        let fullName = user.name()
        let view = CompoundNavigationBar(fullName: fullName, category: AppStrings.Sections.publicationsTitle)
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = view
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.leftChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.clear).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(ProfilePublicationCell.self, forCellWithReuseIdentifier: publicationCellReuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            let section = NSCollectionLayoutSection.list(using: strongSelf.createListConfiguration(), layoutEnvironment: env)
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        layout.configuration = config
        return layout
    }
    
    private func createListConfiguration() -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let strongSelf = self else { return nil }
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] action, view, completion in
                guard let strongSelf = self else { return }
                strongSelf.deletePublication(at: indexPath)
                completion(true)
            }
            
            let editAction = UIContextualAction(style: .normal, title: nil ) {
                [weak self] action, view, completion in
                guard let strongSelf = self else { return }
                strongSelf.editPublication(at: indexPath)
                completion(true)
            }
            
            deleteAction.image = UIImage(systemName: AppStrings.Icons.fillTrash)
            editAction.image = UIImage(systemName: AppStrings.Icons.pencil, withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
            return UISwipeActionsConfiguration(actions: strongSelf.isCurrentUser ? [deleteAction, editAction] : [])
        }
        
        return configuration
    }
    
    private func deletePublication(at indexPath: IndexPath) {
         displayAlert(withTitle: AppStrings.Alerts.Title.deletePublication, withMessage: AppStrings.Alerts.Subtitle.deletePublication, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
             guard let strongSelf = self else { return }
             strongSelf.progressIndicator.show(in: strongSelf.view)
             var viewModel = PublicationViewModel()
             viewModel.set(publication: strongSelf.publications[indexPath.row])
             
             DatabaseManager.shared.deletePublication(viewModel: viewModel) { [weak self] error in
                 guard let strongSelf = self else { return }
                 strongSelf.progressIndicator.dismiss(animated: true)
                 if let error {
                     strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                 } else {
                     strongSelf.publications.remove(at: indexPath.row)
                     strongSelf.collectionView.deleteItems(at: [indexPath])
                     strongSelf.delegate?.didUpdatePublication()
                 }
             }
         }
    }
    
    private func editPublication(at indexPath: IndexPath) {
        let controller = AddPublicationViewController(user: user, publication: publications[indexPath.row])
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }

}

extension PublicationSectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return publications.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: publicationCellReuseIdentifier, for: indexPath) as! ProfilePublicationCell
        cell.set(publication: publications[indexPath.row])
        cell.delegate = self
        cell.separatorView.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = AddPublicationViewController(user: user, publication: publications[indexPath.row])
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension PublicationSectionViewController: ProfilePublicationCellDelegate {
    func didTapURL(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            presentSafariViewController(withURL: url)
        } else {
            presentWebViewController(withURL: url)
        }
    }
}

extension PublicationSectionViewController: AddPublicationViewControllerDelegate {
    func didDeletePublication(_ publication: Publication) {
        delegate?.didUpdatePublication()
        if let index = publications.firstIndex(where: { $0.id == publication.id }) {
            publications.remove(at: index)
            collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func didAddPublication(_ publication: Publication) {
        delegate?.didUpdatePublication()
        if let index = publications.firstIndex(where: { $0.id == publication.id }) {
            publications[index] = publication
            collectionView.reloadData()
        }
    }
}
