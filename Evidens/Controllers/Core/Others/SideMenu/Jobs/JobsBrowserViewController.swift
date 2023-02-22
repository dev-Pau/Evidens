//
//  JobsBrowserViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/2/23.
//

import UIKit
import Firebase

private let jobCellReuseIdentifier = "JobCellReuseIdentifier"

class JobsBrowserViewController: UIViewController {
    
    private var jobsLoaded: Bool = false
    private var jobs = [Job]()
    private var companies = [Company]()
    
    var jobsLastSnapshot: QueryDocumentSnapshot?
    
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
        
        let jobAction = UIAction(title: "Post a job", image: UIImage(systemName: "bag", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)) { action in
            
            let controller = CreateJobViewController(user: user)
            
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen

            self.present(navVC, animated: true)
        }
        
        let companyAction = UIAction(title: "Add your company", image: UIImage(systemName: "building", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)) { action in
            let controller = CreateCompanyViewController(user: user)
            controller.isControllerPresented = true
            
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen

            self.present(navVC, animated: true)
        }
        
        let manageJobs = UIAction(title: "Manage job posts", image: UIImage(systemName: "tray.and.arrow.down", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)) { action in

        }
        
        let myJobs = UIAction(title: "My jobs", image: UIImage(systemName: "book", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)) { action in
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
    }
    
    private func fetchJobs() {
        JobService.fetchJobs(lastSnapshot: nil) { snapshot in
            self.jobsLastSnapshot = snapshot.documents.last
            self.jobs = snapshot.documents.map({ Job(jobId: $0.documentID, dictionary: $0.data()) })
            self.checkIfUserBookmarkedJob()
            let companyIds = self.jobs.map { $0.companyId }
            CompanyService.fetchCompanies(withIds: companyIds) { companies in
                self.companies = companies
                self.jobsLoaded = true
                self.collectionView.reloadData()
            }
        }
    }
    
    private func checkIfUserBookmarkedJob() {
        self.jobs.forEach { job in
            JobService.checkIfUserBookmarkedJob(job: job) { didBookmark in
                if let index = self.jobs.firstIndex(where: {$0.jobId == job.jobId}) {
                    self.jobs[index].didBookmark = didBookmark
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
        return jobsLoaded ? jobs.count : 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: jobCellReuseIdentifier, for: indexPath) as! BrowseJobCell
        cell.viewModel = JobViewModel(job: jobs[indexPath.row])
        cell.delegate = self
        if let companyIndex = companies.firstIndex(where: { $0.id == jobs[indexPath.row].companyId }) {
            cell.configureWithCompany(company: companies[companyIndex])
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard jobs.count > 0 else { return }
        if let companyIndex = companies.firstIndex(where: { $0.id == jobs[indexPath.row].companyId }) {
            let controller = JobDetailsViewController(job: jobs[indexPath.row], company: companies[companyIndex])
            controller.delegate = self
            let navController = UINavigationController(rootViewController: controller)
            
            //let scrollAppearance = UINavigationBarAppearance().configureWithTransparentBackground()
            
            //navController.navigationBar.scrollEdgeAppearance = UINavigationBarAppearance.configure
            
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

extension JobsBrowserViewController: MyJobsViewControllerDelegate {
    func didUnsaveJob(job: Job) {
        if let jobIndex = jobs.firstIndex(where: { $0.jobId == job.jobId }) {
            jobs[jobIndex].didBookmark = false
            collectionView.reloadItems(at: [IndexPath(item: jobIndex, section: 0)])
        }
    }
}

extension JobsBrowserViewController: JobDetailsViewControllerDelegate {
    func didBookmark(job: Job) {
        if let jobIndex = jobs.firstIndex(where: { $0.jobId == job.jobId }) {
            jobs[jobIndex].didBookmark.toggle()
            collectionView.reloadItems(at: [IndexPath(item: jobIndex, section: 0)])
        }
    }
}
