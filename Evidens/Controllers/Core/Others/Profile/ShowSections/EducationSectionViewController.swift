//
//  EducationSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/8/22.
//

import UIKit

private let educationCellReuseIdentifier = "EducationCellReuseIdentifier"

protocol EducationSectionViewControllerDelegate: AnyObject {
    func didUpdateEducation()
}

class EducationSectionViewController: UIViewController {
    
    weak var delegate: EducationSectionViewControllerDelegate?
    
    private var educations = [Education]()
    private var user: User
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configure()
    }
    
    init(user: User, educations: [Education]) {
        self.user = user
        self.educations = educations
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        let fullName = user.name()
        let view = CompoundNavigationBar(fullName: fullName, category: AppStrings.Sections.educationTitle)
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = view
   
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.leftChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.clear).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(ProfileEducationCell.self, forCellWithReuseIdentifier: educationCellReuseIdentifier)
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
                strongSelf.deleteEducation(at: indexPath)
                completion(true)
            }
            
            let editAction = UIContextualAction(style: .normal, title: nil ) {
                [weak self] action, view, completion in
                guard let strongSelf = self else { return }
                strongSelf.editEducation(at: indexPath)
                completion(true)
            }
            
            deleteAction.image = UIImage(systemName: AppStrings.Icons.fillTrash)
            editAction.image = UIImage(systemName: AppStrings.Icons.pencil, withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
            return UISwipeActionsConfiguration(actions: strongSelf.user.isCurrentUser ? [deleteAction, editAction] : [])
        }
        
        return configuration
    }
    
    private func deleteEducation(at indexPath: IndexPath) {
        displayAlert(withTitle: AppStrings.Alerts.Title.deleteEducation, withMessage: AppStrings.Alerts.Subtitle.deleteEducation, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.showProgressIndicator(in: strongSelf.view)
            var viewModel = EducationViewModel()
            viewModel.set(education: strongSelf.educations[indexPath.row])
            
            DatabaseManager.shared.deleteEducation(viewModel: viewModel) { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.dismissProgressIndicator()
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    strongSelf.educations.remove(at: indexPath.row)
                    strongSelf.collectionView.deleteItems(at: [indexPath])
                    strongSelf.delegate?.didUpdateEducation()
                }
            }
        }
    }
    
    private func editEducation(at indexPath: IndexPath) {
        let controller = AddEducationViewController(education: educations[indexPath.row])
        
        controller.delegate = self
        controller.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(controller, animated: true)
    }
}

extension EducationSectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return educations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: educationCellReuseIdentifier, for: indexPath) as! ProfileEducationCell
        cell.set(education: educations[indexPath.row])
        cell.separatorView.isHidden = indexPath.row == 0 ? true : false
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = AddEducationViewController(education: educations[indexPath.row])
        
        controller.delegate = self
        controller.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension EducationSectionViewController: AddEducationViewControllerDelegate {
    func didAddEducation(_ education: Education) {
        delegate?.didUpdateEducation()
        if let index = educations.firstIndex(where: { $0.id == education.id }) {
            educations[index] = education
            collectionView.reloadData()
        }
    }
    
    func didDeleteEducation(_ education: Education) {
        delegate?.didUpdateEducation()
        if let index = educations.firstIndex(where: { $0.id == education.id }) {
            educations.remove(at: index)
            collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }
    }
}
