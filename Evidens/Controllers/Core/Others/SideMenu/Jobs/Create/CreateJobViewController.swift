//
//  CreateJobViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/2/23.
//

import UIKit
import JGProgressHUD

private let jobHeaderReuseIdentifier = "JobHeaderReuseIdentifier"
private let createJobNameCellReuseIdentifier = "CreateJobNameReuseIdentifier"
private let createJobDescriptionCellReuseIdentifier = "CreateJobDescriptionReuseIdentifier"
private let createJobProfessionCellReuseIdentifier = "CreateJobProfessionCellReuseIdentifier"

protocol CreateJobViewControllerDelegate: AnyObject {
    func didUpdateJob(job: Job)
}

class CreateJobViewController: UIViewController {
    weak var delegate: CreateJobViewControllerDelegate?
    
    private var viewModel = CreateJobViewModel()
    
    private let user: User
    private var job: Job?
    private var company: Company?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var createGroupButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(handleCreateJob), for: .touchUpInside)
        return button
    }()
    
    private let progressIndicator = JGProgressHUD()
    
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
        title = job != nil ? "Edit Job" : "Post a Job"
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 17, weight: .bold)
        let text = job != nil ? "Edit" : "Post"
        createGroupButton.configuration?.attributedTitle = AttributedString(text, attributes: container)
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }
    
    init(user: User, job: Job? = nil, company: Company? = nil) {
        self.user = user
        viewModel.profession = user.profession!
        self.job = job
        self.company = company
        
        if let job = job {
            viewModel.title = job.title
            viewModel.location = job.location
            viewModel.description = job.description
            viewModel.workplaceType = job.workplaceType
            viewModel.jobType = job.jobType
            viewModel.profession = job.profession
            viewModel.companyId = job.companyId
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCollectionView() {
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
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String, let title = viewModel.title, let description = viewModel.description, let worksplaceType = viewModel.workplaceType, let jobType = viewModel.jobType, let location = viewModel.location, let profession = viewModel.profession, let companyId = viewModel.companyId else { return }
        
        var jobToUpload = Job(jobId: "", dictionary: [:])
        
        jobToUpload.jobId = COLLECTION_JOBS.document().documentID
        jobToUpload.ownerUid = uid
        jobToUpload.title = title
        jobToUpload.location = location
        jobToUpload.description = description
        jobToUpload.workplaceType = worksplaceType
        jobToUpload.jobType = jobType
        jobToUpload.profession = profession
        jobToUpload.companyId = companyId
        
        if let job = job, let _ = company {
            progressIndicator.show(in: view)
            JobService.updateGroup(from: job, to: jobToUpload) { job in
                self.delegate?.didUpdateJob(job: job)
                self.progressIndicator.dismiss(animated: true)
                let reportPopup = METopPopupView(title: "Job succesfully updated", image: "checkmark.circle.fill", popUpType: .regular)
                reportPopup.showTopPopup(inView: self.view)
                self.dismiss(animated: true)
            }
        } else {
            progressIndicator.show(in: view)
            JobService.uploadJob(job: jobToUpload) { error in
                self.progressIndicator.dismiss(animated: true)
                guard error == nil else { return }
                let reportPopup = METopPopupView(title: "Job succesfully uploaded", image: "checkmark.circle.fill", popUpType: .regular)
                reportPopup.showTopPopup(inView: self.view)
                self.dismiss(animated: true)
                //self.pushGroupViewController(withGroup: groupToUpload)
            }
        }

    }
}

extension CreateJobViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: jobHeaderReuseIdentifier, for: indexPath) as! CreateJobHeader
        if let company = company {
            header.setWithCompany(company: company)
        } else {
            header.delegate = self
        }

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
            if let job = job { cell.set(text: job.title)}
            return cell
        } else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createJobDescriptionCellReuseIdentifier, for: indexPath) as! GroupDescriptionCell
            cell.set(title: Job.JobSections.description.rawValue)
            cell.set(placeholder: "Add skills and requirements")
            if let job = job { cell.set(description: job.description) }
            cell.delegate = self
            return cell
        } else if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createJobNameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.set(title: Job.JobSections.workplace.rawValue, placeholder: "Workplace", name: "")
            cell.disableTextField()
            if let job = job { cell.set(text: job.workplaceType) }
            return cell
        } else if indexPath.row == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createJobNameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.set(title: Job.JobSections.location.rawValue, placeholder: "Location", name: "")
            cell.disableTextField()
            if let job = job { cell.set(text: job.location) }
            return cell
            
        } else if indexPath.row == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createJobNameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.set(title: Job.JobSections.type.rawValue, placeholder: "Type", name: "")
            if let job = job { cell.set(text: job.jobType) }
            cell.disableTextField()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createJobNameCellReuseIdentifier, for: indexPath) as! EditNameCell
            cell.set(title: Job.JobSections.professions.rawValue, placeholder: "Profession", name: "")
            cell.disableTextField()
            cell.set(text: viewModel.profession!)
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
            let controller = JobAssistantViewController(jobSection: .workplace)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 3 {
            let controller = JobAssistantViewController(jobSection: .location)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 4 {
            let controller = JobAssistantViewController(jobSection: .type)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 5 {
            let controller = JobAssistantViewController(jobSection: .professions)
            if let profession = viewModel.profession {
                controller.selectedProfessions = [profession]
            }

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
        
        case .workplace:
            let cell = collectionView.cellForItem(at: IndexPath(item: 2, section: 0)) as! EditNameCell
            cell.set(text: text)
            viewModel.workplaceType = text
        case .location:
            let cell = collectionView.cellForItem(at: IndexPath(item: 3, section: 0)) as! EditNameCell
            cell.set(text: text)
            viewModel.location = text
        case .type:
            let cell = collectionView.cellForItem(at: IndexPath(item: 4, section: 0)) as! EditNameCell
            cell.set(text: text)
            viewModel.jobType = text
        case .professions:
            let cell = collectionView.cellForItem(at: IndexPath(item: 5, section: 0)) as! EditNameCell
            cell.set(text: text)
            viewModel.profession = text
        }
    }
}

extension CreateJobViewController: CreateJobHeaderDelegate {
    func didTapAddExistingCompany() {
        let controller = CompanyBrowserViewController()
        controller.delegate = self
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTappCreateNewCompany() {
        let controller = CreateCompanyViewController(user: user)
        controller.delegate = self
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension CreateJobViewController: CreateCompanyViewControllerDelegate {
    func didCreateCompany(company: Company) {
     
        if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? CreateJobHeader {
            header.setWithCompany(company: company)
            viewModel.companyId = company.id
            jobIsValid()
            //collectionView.reloadData()
        }
    }
}

extension CreateJobViewController: CompanyBrowserViewControllerDelegate {
    func didSelectCompany(company: Company) {
        if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? CreateJobHeader {
            header.setWithCompany(company: company)
            viewModel.companyId = company.id
            jobIsValid()
        }
    }
}
