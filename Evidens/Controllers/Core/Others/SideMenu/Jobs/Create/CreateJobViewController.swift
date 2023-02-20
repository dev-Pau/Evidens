//
//  CreateJobViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/2/23.
//

import UIKit

private let jobHeaderReuseIdentifier = "JobHeaderReuseIdentifier"
private let createJobNameCellReuseIdentifier = "CreateJobNameReuseIdentifier"
private let createJobDescriptionCellReuseIdentifier = "CreateJobDescriptionReuseIdentifier"
private let createJobProfessionCellReuseIdentifier = "CreateJobProfessionCellReuseIdentifier"

class CreateJobViewController: UIViewController {
    
    private var viewModel = CreateJobViewModel()
    
    private let user: User
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var createGroupButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 17, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Post", attributes: container)
        button.addTarget(self, action: #selector(handleCreateJob), for: .touchUpInside)
        return button
    }()
    
    private var sectionSelected: Job.JobSections = .title

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        configureUI()
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: createGroupButton)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = .label
        title = "Post a job"
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }
    
    init(user: User) {
        self.user = user
        viewModel.professions = [Profession(profession: user.profession!)]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCollectionView() {

        //viewModel.professions = [Profession(profession: user.profession!)]
        
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(CreateJobHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: jobHeaderReuseIdentifier)
        collectionView.register(EditNameCell.self, forCellWithReuseIdentifier: createJobNameCellReuseIdentifier)
        collectionView.register(GroupDescriptionCell.self, forCellWithReuseIdentifier: createJobDescriptionCellReuseIdentifier)
        collectionView.register(GroupCategoriesCell.self, forCellWithReuseIdentifier: createJobProfessionCellReuseIdentifier)
    }
    
    private func jobIsValid() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.jobIsValid
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    @objc func handleCreateJob() {
        print("Create job")
    }
}

extension CreateJobViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: jobHeaderReuseIdentifier, for: indexPath) as! CreateJobHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 135)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Job.JobSections.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createJobNameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.set(title: Job.JobSections.title.rawValue, placeholder: "Job title", name: "")
            cell.delegate = self
            return cell
        } else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createJobDescriptionCellReuseIdentifier, for: indexPath) as! GroupDescriptionCell
            cell.set(title: Job.JobSections.description.rawValue)
            cell.set(placeholder: "Add skills and requirements")
            //if let group = group { cell.set(description: group.description) }
            cell.delegate = self
            return cell
        } else if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createJobNameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.set(title: Job.JobSections.role.rawValue, placeholder: "Role", name: "")
            cell.disableTextField()
            //cell.delegate = self
            return cell
        } else if indexPath.row == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createJobNameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.set(title: Job.JobSections.workplace.rawValue, placeholder: "Workplace", name: "")
            cell.disableTextField()
            //cell.delegate = self
            return cell
            
        } else if indexPath.row == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createJobNameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.set(title: Job.JobSections.location.rawValue, placeholder: "Location", name: "")
            cell.disableTextField()
            return cell
        } else if indexPath.row == 5 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createJobNameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.set(title: Job.JobSections.type.rawValue, placeholder: "Type", name: "")
            cell.disableTextField()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createJobProfessionCellReuseIdentifier, for: indexPath) as! GroupCategoriesCell
            let category = user.category
            cell.updateCategories(categories: [Category(name: user.profession!)])
            //if let group = group { cell.updateCategories(categories: group.categories) }
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        sectionSelected = Job.JobSections.allCases[indexPath.row]
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        if indexPath.row == 2 {
            let controller = JobAssistantViewController(jobSection: .role)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 3 {
            let controller = JobAssistantViewController(jobSection: .workplace)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 4 {
            let controller = JobAssistantViewController(jobSection: .location)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 5 {
            let controller = JobAssistantViewController(jobSection: .type)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension CreateJobViewController: EditNameCellDelegate {
    func textDidChange(_ cell: UICollectionViewCell, text: String) {
        viewModel.title = text
        jobIsValid()
    }
}

extension CreateJobViewController: GroupDescriptionCellDelegate {
    func descriptionDidChange(text: String) {
        viewModel.description = text
        jobIsValid()
    }
}

extension CreateJobViewController: JobAssistantViewControllerDelegate {
    func didSelectItem(_ text: String) {
        switch sectionSelected {
            
        case .title:
            break
        case .description:
            break
        case .professions:
            break
        case .role:
            let cell = collectionView.cellForItem(at: IndexPath(item: 2, section: 0)) as! EditNameCell
            cell.set(text: text)
            viewModel.role = text
        case .workplace:
            let cell = collectionView.cellForItem(at: IndexPath(item: 3, section: 0)) as! EditNameCell
            cell.set(text: text)
            viewModel.workplaceType = text
        case .location:
            let cell = collectionView.cellForItem(at: IndexPath(item: 4, section: 0)) as! EditNameCell
            cell.set(text: text)
            viewModel.location = text
        case .type:
            let cell = collectionView.cellForItem(at: IndexPath(item: 5, section: 0)) as! EditNameCell
            cell.set(text: text)
            viewModel.jobType = text

        }
    }
}

extension CreateJobViewController: GroupCategoriesCellDelegate {
    func didSelectAddCategory(withSelectedCategories categories: [Category]) {
        let controller = CategoryListViewController(selectedCategories: categories.reversed())
        controller.delegate = self
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""  
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension CreateJobViewController: CategoryListViewControllerDelegate {
    func didTapAddCategories(categories: [Category]) {
        if let cell = collectionView.cellForItem(at: IndexPath(item: 2, section: 0)) as? GroupCategoriesCell {
            cell.updateCategories(categories: categories)
            viewModel.professions = categories.map({ Profession(profession: $0.name) })
            collectionView.reloadData()
            jobIsValid()
        }
    }
}
