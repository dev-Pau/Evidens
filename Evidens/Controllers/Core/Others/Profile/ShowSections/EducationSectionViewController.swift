//
//  EducationSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/8/22.
//

import UIKit
import JGProgressHUD

private let educationCellReuseIdentifier = "EducationCellReuseIdentifier"

class EducationSectionViewController: UIViewController {
    
    weak var delegate: EditProfileViewControllerDelegate?
    
    private var educations = [Education]()
    private var isCurrentUser: Bool
    private var collectionView: UICollectionView!
    private var progressIndicator = JGProgressHUD()
    private var indexPathSelected = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        title = "Education"
    }
    
    init(educations: [Education], isCurrentUser: Bool) {
        self.educations = educations
        self.isCurrentUser = isCurrentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(UserProfileEducationCell.self, forCellWithReuseIdentifier: educationCellReuseIdentifier)
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
                self?.deleteEducation(at: indexPath)
                completion(true)
            }
            
            let editAction = UIContextualAction(style: .normal, title: nil ) {
                [weak self] action, view, completion in
                self?.editEducation(at: indexPath)
                completion(true)
            }
            
            deleteAction.image = UIImage(systemName: "trash.fill")
            editAction.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
            return UISwipeActionsConfiguration(actions: self.isCurrentUser ? [deleteAction, editAction] : [])
        }
        
        return configuration
    }
    
    private func deleteEducation(at indexPath: IndexPath) {
        displayMEDestructiveAlert(withTitle: "Delete Education", withMessage: "Are you sure you want to delete this education from your profile?", withCancelButtonText: "Cancel", withDoneButtonText: "Delete") {
            self.progressIndicator.show(in: self.view)
            DatabaseManager.shared.deleteEducation(education: self.educations[indexPath.row]) { deleted in
                self.progressIndicator.dismiss(animated: true)
                if deleted {
                    self.educations.remove(at: indexPath.row)
                    self.collectionView.deleteItems(at: [indexPath])
                    self.delegate?.fetchNewEducationValues()
                }
            }
        }
    }
    
    private func editEducation(at indexPath: IndexPath) {
        let controller = AddEducationViewController(previousEducation: educations[indexPath.row])
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

extension EducationSectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return educations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: educationCellReuseIdentifier, for: indexPath) as! UserProfileEducationCell
        cell.set(education: educations[indexPath.row])
        cell.separatorView.isHidden = indexPath.row == 0 ? true : false
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = AddEducationViewController(previousEducation: educations[indexPath.row])
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

extension EducationSectionViewController: AddEducationViewControllerDelegate {
    func handleUpdateEducation(education: Education) {
        educations[indexPathSelected.row] = education
        collectionView.reloadData()
        delegate?.fetchNewEducationValues()
    }
    
    func handleDeleteEducation(education: Education) {
        if let educationIndex = educations.firstIndex(where: { $0.degree == education.degree && $0.school == education.school && $0.fieldOfStudy == education.fieldOfStudy }) {
            delegate?.fetchNewEducationValues()
            educations.remove(at: educationIndex)
            collectionView.deleteItems(at: [IndexPath(item: educationIndex, section: 0)])
        }
    }
}

