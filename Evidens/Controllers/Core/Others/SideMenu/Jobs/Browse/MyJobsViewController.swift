//
//  MyJobsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/2/23.
//

import UIKit
import Firebase

private let jobCellReuseIdentifier = "JobCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let emptyCellReuseIdentifier = "EmptyCellReuseIdentifier"
private let categoriesCellReuseIdentifier = "CategoriesCellReuseIdentifier"
private let applicantsCellReuseIdentifier = "ApplicantsCellReuseIdentifier"

protocol MyJobsViewControllerDelegate: AnyObject {
    func didUnsaveJob(job: Job)
}

class MyJobsViewController: UIViewController {
    weak var delegate: MyJobsViewControllerDelegate?
    
    private var savedLoaded: Bool = false
    private var applicationsLoaded: Bool = false
    private var savedJobs = [Job]()
    private var applicationJobs = [Job]()
    private var savedCompanies = [Company]()
    private var applicationCompanies = [Company]()
    
    var savedJobLastSnapshot: QueryDocumentSnapshot?
    var applicationJobLastSnapshot: QueryDocumentSnapshot?
    
    private let categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 100, height: 30)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.bounces = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    private let jobsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 200)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternarySystemFill
        return view
    }()
    
    enum CategoriesType: String, CaseIterable {
        case saved = "Saved"
        case applications = "Applications"
        
        var index: Int {
            switch self {
            case .saved:
                return 0
            case .applications:
                return 1
            }
        }
    }
    
    private var selectedIndex = CategoriesType.saved
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        configureUI()
        fetchJobs()
    }
    
    private func configureNavigationBar() {
        title = "My Jobs"
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubviews(categoriesCollectionView, separatorView, jobsCollectionView)
        
        NSLayoutConstraint.activate([
            categoriesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: 40),
            
            separatorView.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
        
            jobsCollectionView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            jobsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            jobsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            jobsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func configureCollectionView() {
        categoriesCollectionView.register(BookmarkCategoriesCell.self, forCellWithReuseIdentifier: categoriesCellReuseIdentifier)
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
        
        jobsCollectionView.delegate = self
        jobsCollectionView.dataSource = self
        jobsCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        jobsCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        jobsCollectionView.register(BrowseJobCell.self, forCellWithReuseIdentifier: jobCellReuseIdentifier)
        jobsCollectionView.register(ApplicantsJobCell.self, forCellWithReuseIdentifier: applicantsCellReuseIdentifier)
        
        categoriesCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)
    }
    
    private func fetchJobs() {
        JobService.fetchBookmarkedJobsDocuments(lastSnapshot: nil) { snapshot in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                self.savedLoaded = true
                self.jobsCollectionView.reloadData()
                return
            }
            JobService.fetchBookmarkedJobs(snapshot: snapshot) { jobs in
                self.savedJobLastSnapshot = snapshot.documents.last
                self.savedJobs = jobs
                let companyIds = jobs.map { $0.companyId }
                CompanyService.fetchCompanies(withIds: companyIds) { companies in
                    self.savedLoaded = true
                    self.savedCompanies = companies
                    self.jobsCollectionView.reloadData()
                    
                }
            }
        }
    }
    
    private func fetchApplications() {
        DatabaseManager.shared.fetchJobApplicationsForUser { applicants in
            if applicants.isEmpty {
                self.applicationsLoaded = true
                self.jobsCollectionView.reloadData()
            } else {
                let jobIds = applicants.map { $0.jobId }
                JobService.fetchJobs(withJobIds: jobIds) { jobs in
                    self.applicationJobs = jobs
                    let companyIds = jobs.map { $0.companyId }
                    CompanyService.fetchCompanies(withIds: companyIds) { companies in
                        self.applicationCompanies = companies
                        self.applicationsLoaded = true
                        self.jobsCollectionView.reloadData()
                    }
                }
            }
        }
    }
}

extension MyJobsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoriesCollectionView {
            return CategoriesType.allCases.count
        } else {
            switch selectedIndex {
            case .saved:
                return savedLoaded ? savedJobs.isEmpty ? 1 : savedJobs.count : 0
            case .applications:
                return applicationsLoaded ? applicationJobs.isEmpty ? 1 : applicationJobs.count : 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == categoriesCollectionView {
            return CGSize.zero
        } else {
            switch selectedIndex {
            case .saved:
                return savedLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
            case .applications:
                return applicationsLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoriesCollectionView {
            let cell = categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: categoriesCellReuseIdentifier, for: indexPath) as! BookmarkCategoriesCell
            cell.set(category: CategoriesType.allCases[indexPath.row].rawValue)
            return cell
        } else {
            switch selectedIndex {
            case .saved:
                if savedJobs.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                    cell.configure(image: UIImage(named: "content.empty"), title: "Save jobs you are interested in.", description: "Jobs you save will show up here.", buttonText: .dismiss)
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: jobCellReuseIdentifier, for: indexPath) as! BrowseJobCell
                    cell.viewModel = JobViewModel(job: savedJobs[indexPath.row])
                    cell.configureWithBookmarkOptions()
                    cell.savedDelegate = self
                    if let companyIndex = savedCompanies.firstIndex(where: { $0.id == savedJobs[indexPath.row].companyId }) {
                        cell.configureWithCompany(company: savedCompanies[companyIndex])
                    }
                    return cell
                }
            case .applications:
                if applicationJobs.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
                    cell.configure(image: UIImage(named: "content.empty"), title: "Apply jobs you are interested in.", description: "Your applications will show up here.", buttonText: .dismiss)
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: applicantsCellReuseIdentifier, for: indexPath) as! ApplicantsJobCell
                    cell.viewModel = JobViewModel(job: applicationJobs[indexPath.row])
                    cell.delegate = self
                    if let companyIndex = applicationCompanies.firstIndex(where: { $0.id == applicationJobs[indexPath.row].companyId }) {
                        cell.configureWithCompany(company: applicationCompanies[companyIndex])
                    }
                    return cell
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tab = self.tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        if collectionView == categoriesCollectionView {
            collectionView.cellForItem(at: indexPath)?.isSelected = true
            guard selectedIndex != CategoriesType.allCases[indexPath.row] else { return }
            selectedIndex = CategoriesType.allCases[indexPath.row]
            if selectedIndex == .applications && applicationJobs.isEmpty {
                // Fetch applications
                fetchApplications()
                return
            }
            jobsCollectionView.reloadData()
        } else {
            
            switch selectedIndex {
            case .saved:
                if let companyIndex = savedCompanies.firstIndex(where: { $0.id == savedJobs[indexPath.row].companyId }) {
                    savedJobs[indexPath.row].didBookmark = true
                    let controller = JobDetailsViewController(job: savedJobs[indexPath.row] , company: savedCompanies[companyIndex], user: user)
                    controller.delegate = self
                    let navVC = UINavigationController(rootViewController: controller)
                    navVC.modalPresentationStyle = .fullScreen
                    present(navVC, animated: true)
                }
            case .applications:
                if let companyIndex = applicationCompanies.firstIndex(where: { $0.id == applicationJobs[indexPath.row].companyId }) {
                    let controller = JobDetailsViewController(job: applicationJobs[indexPath.row] , company: applicationCompanies[companyIndex], user: user)
                    controller.delegate = self
                    let navVC = UINavigationController(rootViewController: controller)
                    navVC.modalPresentationStyle = .fullScreen
                    present(navVC, animated: true)
                }
            }
        }
    }
}

extension MyJobsViewController: BrowseSavedJobCellDelegate {
    func didUnsaveJob(_ cell: UICollectionViewCell, job: Job) {
        JobService.unbookmarkJob(job: job) { error in
            guard error == nil else { return }
            if let indexPath = self.jobsCollectionView.indexPath(for: cell) {
                self.jobsCollectionView.performBatchUpdates {
                    self.savedJobs.remove(at: indexPath.row)
                    self.jobsCollectionView.deleteItems(at: [indexPath])
                    self.delegate?.didUnsaveJob(job: job)
                }
            }
        }
    }
}

extension MyJobsViewController: JobDetailsViewControllerDelegate {
    func didBookmark(job: Job, company: Company) {
        let jobIsBookmarked = job.didBookmark
        if jobIsBookmarked {
            savedJobs.insert(job, at: 0)
            savedCompanies.append(company)
        } else {
            if let jobIndex = savedJobs.firstIndex(where: { $0.jobId == job.jobId }) {
                self.jobsCollectionView.performBatchUpdates {
                    self.savedJobs.remove(at: jobIndex)
                    self.jobsCollectionView.deleteItems(at: [IndexPath(item: jobIndex, section: 0)])
                }
            }
        }
    }
}

extension MyJobsViewController: ApplicantsJobCellDelegate {
    func didTapRemoveApplicant(job: Job) {
        displayMEDestructiveAlert(withTitle: "Remove request", withMessage: "Are you sure you want to delete this job request?", withCancelButtonText: "Cancel", withDoneButtonText: "Remove") {
            DatabaseManager.shared.removeJobApplication(jobId: job.jobId) { removed in
                if removed {
                    if let jobIndex = self.applicationJobs.firstIndex(where: { $0.jobId == job.jobId }) {
                        self.jobsCollectionView.performBatchUpdates {
                            self.applicationJobs.remove(at: jobIndex)
                            self.jobsCollectionView.deleteItems(at: [IndexPath(item: jobIndex, section: 0)])
                        }
                    }
                    
                    let reportPopup = METopPopupView(title: "Request removed", image: "checkmark.circle.fill", popUpType: .regular)
                    reportPopup.showTopPopup(inView: self.view)
                }
            }
        }
    }
}
