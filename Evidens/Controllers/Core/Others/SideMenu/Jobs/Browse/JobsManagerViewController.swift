//
//  JobsManagerViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/2/23.
//

import UIKit

private let emptyCellReuseIdentifier = "EmptyCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let manageJobCellReuseIdentifier = "ManageJobCellReuseIdentifier"

class JobsManagerViewController: UIViewController {
    
    private var jobs = [Job]()
    private var companies = [Company]()
    private var jobsLoaded: Bool = false
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 200)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .large
        button.addTarget(self, action: #selector(handleCreateJob), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
        fetchJobs()
    }
    
    private func configureNavigationBar() {
        title = "Manage jobs"
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        collectionView.frame = view.bounds
        view.addSubviews(collectionView, plusButton)
        
        NSLayoutConstraint.activate([
            plusButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            plusButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func configureCollectionView() {
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(ManageJobCell.self, forCellWithReuseIdentifier: manageJobCellReuseIdentifier)
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func fetchJobs() {
        DatabaseManager.shared.fetchManagingJobIds { jobIds in
            if jobIds.isEmpty {
                self.jobsLoaded = true
                self.collectionView.reloadData()
                return
            }
            
            JobService.fetchJobs(withJobIds: jobIds) { jobs in
                self.jobs = jobs
                let companyIds = jobs.map { $0.companyId }
                let companyIdsUnique = Array(Set(companyIds))
                CompanyService.fetchCompanies(withIds: companyIdsUnique) { companies in
                    self.companies = companies
                    self.jobsLoaded = true
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    @objc func handleCreateJob() {
        guard let tab = self.tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        let controller = CreateJobViewController(user: user)
        
        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen

        self.present(navVC, animated: true)
    }
}

extension JobsManagerViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jobsLoaded ? jobs.isEmpty ? 1 : jobs.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return jobsLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if jobs.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: nil, title: "No jobs posted yet.", description: "Job you post will show up here.", buttonText: .dismiss)
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: manageJobCellReuseIdentifier, for: indexPath) as! ManageJobCell
            cell.delegate = self
            if let index = companies.firstIndex(where: { $0.id == jobs[indexPath.row].companyId }) {
                cell.configure(withJob: JobViewModel(job: jobs[indexPath.row]), withCompany: companies[index])
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !jobs.isEmpty else { return }
        if let index = companies.firstIndex(where: { $0.id == jobs[indexPath.row].companyId }) {
            let controller = JobManagerViewController(job: jobs[indexPath.row], company: companies[index])
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            
            navigationItem.backBarButtonItem = backItem
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension JobsManagerViewController: MESecondaryEmptyCellDelegate {
    func didTapEmptyCellButton(option: EmptyCellButtonOptions) {
        navigationController?.popViewController(animated: true)
    }
}

extension JobsManagerViewController: JobManagerViewControllerDelegate, CreateJobViewControllerDelegate {
    func didUpdateJob(job: Job) {
        if let jobIndex = jobs.firstIndex(where: { $0.jobId == job.jobId }) {
            jobs[jobIndex] = job
            collectionView.reloadItems(at: [IndexPath(item: jobIndex, section: 0)])
        }
    }
}

extension JobsManagerViewController: ManageJobCellDelegate {
    func didTapManageOption(_ cell: UICollectionViewCell, _ option: Job.ManageJobOptions) {
        guard let tab = self.tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        if let companyIndex = companies.firstIndex(where:  { $0.id == jobs[indexPath.row].companyId }) {
            switch option {
            case .edit:
                let controller = CreateJobViewController(user:user, job: jobs[indexPath.row] , company: companies[companyIndex])
                controller.delegate = self
                
                let navVC = UINavigationController(rootViewController: controller)
                navVC.modalPresentationStyle = .fullScreen
                present(navVC, animated: true)
                
            case .applicants:
                // Cretate applicant controller
                let controller = JobApplicantsViewController(job: jobs[indexPath.row])
                let backItem = UIBarButtonItem()
                backItem.tintColor = .label
                backItem.title = ""
                navigationItem.backBarButtonItem = backItem
                navigationController?.pushViewController(controller, animated: true)
            case .delete:
                displayMEDestructiveAlert(withTitle: "Delete job", withMessage: "Are you sure you want to delete this job?", withCancelButtonText: "Cancel", withDoneButtonText: "Delete") {
                    let reportPopup = METopPopupView(title: "Job successfully deleted", image: "checkmark.circle.fill", popUpType: .regular)
                    reportPopup.showTopPopup(inView: self.view)
                }
            }
        }
    }
}
