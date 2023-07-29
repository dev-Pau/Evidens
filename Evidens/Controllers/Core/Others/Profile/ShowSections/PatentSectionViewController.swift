//
//  PatentSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/8/22.
//

import UIKit
import JGProgressHUD

private let patentCellReuseIdentifier = "PatentCellReuseIdentifier"

class PatentSectionViewController: UIViewController {
    
    private let user: User
    
    weak var delegate: EditProfileViewControllerDelegate?
    
    private var patents = [Patent]()
    private var isCurrentUser: Bool
    private var collectionView: UICollectionView!
    private var progressIndicator = JGProgressHUD()
    private var indexPathSelected = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        title = "Patents"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(user: User, patents: [Patent], isCurrentUser: Bool) {
        self.user = user
        self.patents = patents
        self.isCurrentUser = isCurrentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(UserProfilePatentCell.self, forCellWithReuseIdentifier: patentCellReuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        view.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
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
                self?.deletePatent(at: indexPath)
                completion(true)
            }
            
            let editAction = UIContextualAction(style: .normal, title: nil ) {
                [weak self] action, view, completion in
                self?.editPatent(at: indexPath)
                completion(true)
            }
            
            deleteAction.image = UIImage(systemName: "trash.fill")
            editAction.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
            return UISwipeActionsConfiguration(actions: self.isCurrentUser ? [deleteAction, editAction] : [])
        }
        
        return configuration
    }
    
    private func deletePatent(at indexPath: IndexPath) {
        displayAlert(withTitle: AppStrings.Alerts.Title.deletePatent, withMessage: AppStrings.Alerts.Subtitle.deletePatent, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) {
            [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.progressIndicator.show(in: strongSelf.view)
            DatabaseManager.shared.deletePatent(patent: strongSelf.patents[indexPath.row]) { deleted in
                strongSelf.progressIndicator.dismiss(animated: true)
                if deleted {
                    strongSelf.patents.remove(at: indexPath.row)
                    strongSelf.collectionView.deleteItems(at: [indexPath])
                    strongSelf.delegate?.fetchNewPatentValues()
                }
            }
        }
    }
    
    private func editPatent(at indexPath: IndexPath) {
        let controller = AddPatentViewController(user: user, previousPatent: patents[indexPath.row])
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

extension PatentSectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return patents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: patentCellReuseIdentifier, for: indexPath) as! UserProfilePatentCell
        cell.set(patent: patents[indexPath.row])
        cell.delegate = self
        cell.separatorView.isHidden = indexPath.row == 0 ? true : false
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = AddPatentViewController(user: user, previousPatent: patents  [indexPath.row])
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


extension PatentSectionViewController: UserProfilePatentCellDelegate {
    func didTapShowContributors(users: [User]) {
        let controller = ContributorsViewController(users: users)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension PatentSectionViewController: AddPatentViewControllerDelegate {
    func handleUpdatePatent(patent: Patent) {
        patents[indexPathSelected.row] = patent
        collectionView.reloadData()
        delegate?.fetchNewPatentValues()
    }
    
    func handleDeletePatent(patent: Patent) {
        if let patentIndex = patents.firstIndex(where: { $0.title == patent.title }) {
            delegate?.fetchNewPatentValues()
            patents.remove(at: patentIndex)
            collectionView.deleteItems(at: [IndexPath(item: patentIndex, section: 0)])
        }
    }
}

