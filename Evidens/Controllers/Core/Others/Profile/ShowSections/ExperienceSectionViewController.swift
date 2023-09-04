//
//  ExperienceSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/8/22.
//

import UIKit

private let experienceCellReuseIdentifier = "ExperienceCellReuseIdentifier"

protocol ExperienceSectionViewControllerDelegate: AnyObject {
    func didUpdateExperience()
}

class ExperienceSectionViewController: UIViewController {
    weak var delegate: ExperienceSectionViewControllerDelegate?
    
    private var experiences = [Experience]()
    private let user: User
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configure()
    }
    
    init(user: User, experiences: [Experience]) {
        self.user = user
        self.experiences = experiences
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(ProfileExperienceCell.self, forCellWithReuseIdentifier: experienceCellReuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }
    
    private func configure() {
        title = AppStrings.Sections.experiencesTitle
    
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.leftChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.clear).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItem = rightBarButtonItem
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
                strongSelf.deleteExperience(at: indexPath)
                completion(true)
            }
            
            let editAction = UIContextualAction(style: .normal, title: nil ) {
                [weak self] action, view, completion in
                guard let strongSelf = self else { return }
                strongSelf.editExperience(at: indexPath)
                completion(true)
            }
            
            deleteAction.image = UIImage(systemName: AppStrings.Icons.fillTrash)
            editAction.image = UIImage(systemName: AppStrings.Icons.pencil, withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
            return UISwipeActionsConfiguration(actions: strongSelf.user.isCurrentUser ? [deleteAction, editAction] : [])
        }
        
        return configuration
    }
    
    private func deleteExperience(at indexPath: IndexPath) {
        displayAlert(withTitle: AppStrings.Alerts.Title.deleteExperience, withMessage: AppStrings.Alerts.Subtitle.deleteExperience, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.showProgressIndicator(in: strongSelf.view)
            var viewModel = ExperienceViewModel()
            viewModel.set(experience: strongSelf.experiences[indexPath.row])
            
            DatabaseManager.shared.deleteExperience(viewModel: viewModel) { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.dismissProgressIndicator()
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    strongSelf.experiences.remove(at: indexPath.row)
                    strongSelf.collectionView.deleteItems(at: [indexPath])
                    strongSelf.delegate?.didUpdateExperience()
                }
            }
        }
    }
        
    private func editExperience(at indexPath: IndexPath) {
        let controller = AddExperienceViewController(experience: experiences[indexPath.row])
        controller.delegate = self
        
        controller.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ExperienceSectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return experiences.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: experienceCellReuseIdentifier, for: indexPath) as! ProfileExperienceCell
        cell.set(experience: experiences[indexPath.row])
        cell.separatorView.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = AddExperienceViewController(experience: experiences[indexPath.row])
        
        controller.delegate = self
        controller.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ExperienceSectionViewController: AddExperienceViewControllerDelegate {
    func didAddExperience(_ experience: Experience) {
        delegate?.didUpdateExperience()
        if let index = experiences.firstIndex(where: { $0.id == experience.id }) {
            experiences[index] = experience
            collectionView.reloadData()
        }
    }
    
    func didDeleteExperience(_ experience: Experience) {
        delegate?.didUpdateExperience()
        if let index = experiences.firstIndex(where: { $0.id == experience.id }) {
            experiences.remove(at: index)
            collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }
    }
}
