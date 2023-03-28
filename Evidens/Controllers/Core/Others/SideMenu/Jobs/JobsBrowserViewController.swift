//
//  JobsBrowserViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/2/23.
//

import UIKit
import Firebase

private let emptyCellReuseIdentifier = "EmptyCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let jobCellReuseIdentifier = "JobCellReuseIdentifier"
private let searchHeaderReuseIdentifier = "SearchHeaderReuseIdentifier"

class JobsBrowserViewController: UIViewController {
    
    private var jobsLoaded: Bool = false
    private var jobs = [Job]()
    private var companies = [Company]()
    
    var jobsLastSnapshot: QueryDocumentSnapshot?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .leastNonzeroMagnitude)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        configureUI()
        fetchJobs()
    }
    
    private func configureNavigationBar() {
        title = "Jobs"
        
        guard let tab = self.tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        let jobAction = UIAction(title: "Post a Job", image: UIImage(systemName: "case", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)) { action in
            
            let controller = CreateJobViewController(user: user)
            
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen

            self.present(navVC, animated: true)
        }
        
        let companyAction = UIAction(title: "Create a Company", image: UIImage(systemName: "building", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)) { action in
            let controller = CreateCompanyViewController(user: user)
            controller.isControllerPresented = true
            
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen

            self.present(navVC, animated: true)
        }
        
        let manageJobs = UIAction(title: "Manage Job Posts", image: UIImage(systemName: "tray.and.arrow.down", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)) { action in
            let controller = JobsManagerViewController()
            //controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            
            self.navigationItem.backBarButtonItem = backItem
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
        let myJobs = UIAction(title: "My Jobs", image: UIImage(systemName: "list.bullet.rectangle", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)) { action in
            let controller = MyJobsViewController()
            controller.delegate = self
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.tintColor = .label
            
            self.navigationItem.backBarButtonItem = backItem
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
        let menuBarButton = UIBarButtonItem(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), primaryAction: nil, menu: UIMenu(title: "", children: [jobAction, companyAction]))
        let ellipsisButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), primaryAction: nil, menu: UIMenu(title: "", children: [manageJobs, myJobs]))
        navigationItem.rightBarButtonItems = [ellipsisButton, menuBarButton]
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BrowseJobCell.self, forCellWithReuseIdentifier: jobCellReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(MEPrimaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
    }
    
    private func fetchJobs() {
        JobService.fetchJobs(lastSnapshot: nil) { snapshot in
            if snapshot.isEmpty {
                self.jobsLoaded = true
                self.collectionView.reloadData()
                return
            } else {
                self.jobsLastSnapshot = snapshot.documents.last
                self.jobs = snapshot.documents.map({ Job(jobId: $0.documentID, dictionary: $0.data()) })
                JobService.fetchJobValuesFor(jobs: self.jobs) { jobsWithValues in
                    self.jobs = jobsWithValues
                    let companyIds = self.jobs.map { $0.companyId }
                    CompanyService.fetchCompanies(withIds: companyIds) { companies in
                        self.companies = companies
                        self.jobsLoaded = true
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            getMoreJobs()
        }
    }
    
    private func getMoreJobs() {
        JobService.fetchJobs(lastSnapshot: jobsLastSnapshot) { snapshot in
            guard !snapshot.isEmpty else { return }
            self.jobsLastSnapshot = snapshot.documents.last
            let newJobs = snapshot.documents.map({ Job(jobId: $0.documentID, dictionary: $0.data()) })
            JobService.fetchJobValuesFor(jobs: newJobs) { newJobsWithValues in
                self.jobs.append(contentsOf: newJobsWithValues)
                let companyIds = self.jobs.map { $0.companyId }
                CompanyService.fetchCompanies(withIds: companyIds) { companies in
                    self.companies.append(contentsOf: companies)
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

extension JobsBrowserViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jobsLoaded ? jobs.isEmpty ? 1 : jobs.count : 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return jobsLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if jobs.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! MEPrimaryEmptyCell
            cell.set(withImage: UIImage(named: "jobs.empty")!, withTitle: "We could not find any job offer —— yet.", withDescription: "Check back later for new job updates or share your own.", withButtonText: "   Post a job   ")
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: jobCellReuseIdentifier, for: indexPath) as! BrowseJobCell
            cell.viewModel = JobViewModel(job: jobs[indexPath.row])
            cell.delegate = self
            if let companyIndex = companies.firstIndex(where: { $0.id == jobs[indexPath.row].companyId }) {
                cell.configureWithCompany(company: companies[companyIndex])
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard jobs.count > 0 else { return }
        guard let tab = self.tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        if let companyIndex = companies.firstIndex(where: { $0.id == jobs[indexPath.row].companyId }) {
            let controller = JobDetailsViewController(job: jobs[indexPath.row], company: companies[companyIndex], user: user)
            controller.delegate = self
            let navController = UINavigationController(rootViewController: controller)
            
            navController.modalPresentationStyle = .fullScreen
            
            present(navController, animated: true)
        }
    }
}

extension JobsBrowserViewController: BrowseJobCellDelegate {
    func didBookmarkJob(_ cell: UICollectionViewCell, job: Job) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        HapticsManager.shared.vibrate(for: .success)
        switch cell {
        case is BrowseJobCell:
            let currentCell = cell as! BrowseJobCell
            currentCell.viewModel?.job.didBookmark.toggle()
            
            if job.didBookmark {
                JobService.unbookmarkJob(job: job) { _ in
                    self.jobs[indexPath.row].didBookmark = false
                    currentCell.isUpdatingJoiningState = false
                }
            } else {
                JobService.bookmarkJob(job: job) { _ in
                    self.jobs[indexPath.row].didBookmark = true
                    currentCell.isUpdatingJoiningState = false
                }
            }
            
        default:
            print("No cell registered for this type")
        }
    }
}

extension JobsBrowserViewController: EmptyGroupCellDelegate {
    func didTapDiscoverGroup() {
        guard let tab = self.tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        let controller = CreateJobViewController(user: user)

        let navVC = UINavigationController(rootViewController: controller)
        navVC.modalPresentationStyle = .fullScreen

        self.present(navVC, animated: true)
    }
}

extension JobsBrowserViewController: MyJobsViewControllerDelegate {
    func didUnsaveJob(job: Job) {
        if let jobIndex = jobs.firstIndex(where: { $0.jobId == job.jobId }) {
            jobs[jobIndex].didBookmark = false
            collectionView.reloadItems(at: [IndexPath(item: jobIndex, section: 0)])
        }
    }
}

extension JobsBrowserViewController: JobDetailsViewControllerDelegate {
    func didBookmark(job: Job, company: Company) {
        if let jobIndex = jobs.firstIndex(where: { $0.jobId == job.jobId }) {
            jobs[jobIndex].didBookmark.toggle()
            collectionView.reloadItems(at: [IndexPath(item: jobIndex, section: 0)])
        }
    }
}
