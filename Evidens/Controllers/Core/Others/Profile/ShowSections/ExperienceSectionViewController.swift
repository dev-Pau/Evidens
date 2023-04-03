//
//  ExperienceSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/8/22.
//

import UIKit
import JGProgressHUD

private let experienceCellReuseIdentifier = "ExperienceCellReuseIdentifier"

class ExperienceSectionViewController: UIViewController {
    weak var delegate: EditProfileViewControllerDelegate?
    
    private var experiences = [Experience]()
    private var isCurrentUser: Bool
    private var collectionView: UICollectionView!
    private var progressIndicator = JGProgressHUD()
    private var indexPathSelected = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        title = "Experience"
    }
    
    init(experiences: [Experience], isCurrentUser: Bool) {
        self.experiences = experiences
        self.isCurrentUser = isCurrentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(UserProfileExperienceCell.self, forCellWithReuseIdentifier: experienceCellReuseIdentifier)
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
                self?.deleteExperience(at: indexPath)
                completion(true)
            }
            
            let editAction = UIContextualAction(style: .normal, title: nil ) {
                [weak self] action, view, completion in
                self?.editExperience(at: indexPath)
                completion(true)
            }
            
            deleteAction.image = UIImage(systemName: "trash.fill")
            editAction.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
            return UISwipeActionsConfiguration(actions: self.isCurrentUser ? [deleteAction, editAction] : [])
        }
        return configuration
    }
    
    private func deleteExperience(at indexPath: IndexPath) {
        displayMEDestructiveAlert(withTitle: "Delete Experience", withMessage: "Are you sure you want to delete this experience from your profile?", withCancelButtonText: "Cancel", withDoneButtonText: "Delete") {
            self.progressIndicator.show(in: self.view)
            DatabaseManager.shared.deleteExperience(experience: self.experiences[indexPath.row]) { deleted in
                self.progressIndicator.dismiss(animated: true)
                if deleted {
                    self.experiences.remove(at: indexPath.row)
                    self.collectionView.deleteItems(at: [indexPath])
                    self.delegate?.fetchNewExperienceValues()
                }
            }
        }
    }
    
    private func editExperience(at indexPath: IndexPath) {
        let controller = AddExperienceViewController(previousExperience: experiences[indexPath.row])
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

extension ExperienceSectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return experiences.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: experienceCellReuseIdentifier, for: indexPath) as! UserProfileExperienceCell
        cell.set(experience: experiences[indexPath.row])
        cell.separatorView.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = AddExperienceViewController(previousExperience: experiences[indexPath.row])
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

extension ExperienceSectionViewController: AddExperienceViewControllerDelegate {
    func handleUpdateExperience(experience: Experience) {
        experiences[indexPathSelected.row] = experience
        collectionView.reloadData()
        delegate?.fetchNewExperienceValues()
    }
    
    func handleDeleteExperience(experience: Experience) {
        if let experienceIndex = experiences.firstIndex(where: { $0.role == experience.role && $0.company == experience.company }) {
            delegate?.fetchNewExperienceValues()
            experiences.remove(at: experienceIndex)
            collectionView.deleteItems(at: [IndexPath(item: experienceIndex, section: 0)])
        }
    }
}


