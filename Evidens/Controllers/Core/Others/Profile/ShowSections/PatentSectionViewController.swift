//
//  PatentSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/8/22.
//

import UIKit
import JGProgressHUD

private let patentCellReuseIdentifier = "PatentCellReuseIdentifier"

protocol PatentSectionViewControllerDelegate: AnyObject {
    func didUpdatePatent()
}

class PatentSectionViewController: UIViewController {
    
    private let user: User
    
    weak var delegate: PatentSectionViewControllerDelegate?
    
    private var patents = [Patent]()
    private var isCurrentUser: Bool
    private var collectionView: UICollectionView!
    private var progressIndicator = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configure()
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
    
    private func configure() {
        let fullName = user.name()
        let view = CompoundNavigationBar(fullName: fullName, category: AppStrings.Sections.patentsTitle)
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = view
   
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.leftChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.clear).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(ProfilePatentCell.self, forCellWithReuseIdentifier: patentCellReuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        view.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
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
                strongSelf.deletePatent(at: indexPath)
                completion(true)
            }
            
            let editAction = UIContextualAction(style: .normal, title: nil ) {
                [weak self] action, view, completion in
                guard let strongSelf = self else { return }
                strongSelf.editPatent(at: indexPath)
                completion(true)
            }
            
            deleteAction.image = UIImage(systemName: AppStrings.Icons.fillTrash)
            editAction.image = UIImage(systemName: AppStrings.Icons.pencil, withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
            return UISwipeActionsConfiguration(actions: strongSelf.isCurrentUser ? [deleteAction, editAction] : [])
        }
        
        return configuration
    }
    
    private func deletePatent(at indexPath: IndexPath) {
        displayAlert(withTitle: AppStrings.Alerts.Title.deletePatent, withMessage: AppStrings.Alerts.Subtitle.deletePatent, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.progressIndicator.show(in: strongSelf.view)
            var viewModel = PatentViewModel()
            viewModel.set(patent: strongSelf.patents[indexPath.row])
            
            DatabaseManager.shared.deletePatent(viewModel: viewModel) { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.progressIndicator.dismiss(animated: true)
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    strongSelf.patents.remove(at: indexPath.row)
                    strongSelf.collectionView.deleteItems(at: [indexPath])
                    strongSelf.delegate?.didUpdatePatent()
                }
            }
        }
    }
    
    private func editPatent(at indexPath: IndexPath) {
        let controller = AddPatentViewController(user: user, patent: patents[indexPath.row])
        
        controller.delegate = self
        controller.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(controller, animated: true)
    }
}

extension PatentSectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return patents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: patentCellReuseIdentifier, for: indexPath) as! ProfilePatentCell
        cell.set(patent: patents[indexPath.row])
        cell.separatorView.isHidden = indexPath.row == 0 ? true : false
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = AddPatentViewController(user: user, patent: patents  [indexPath.row])
        
        controller.delegate = self
        controller.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(controller, animated: true)
    }
}

extension PatentSectionViewController: AddPatentViewControllerDelegate {
    func didDeletePatent(_ patent: Patent) {
        delegate?.didUpdatePatent()
        if let index = patents.firstIndex(where: { $0.id == patent.id }) {
            patents.remove(at: index)
            collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func didAddPatent(_ patent: Patent) {
        delegate?.didUpdatePatent()
        if let index = patents.firstIndex(where: { $0.id == patent.id }) {
            patents[index] = patent
            collectionView.reloadData()
        }
    }
}

