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

class MyJobsViewController: UIViewController {
    
    private var jobsLoaded: Bool = false
    private var jobs = [Job]()
    private var companies = [Company]()
    
    var jobsLastSnapshot: QueryDocumentSnapshot?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        configureUI()
        fetchJobs()
    }
    
    private func configureNavigationBar() {
        title = "My jobs"
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(jobsCollectionView)
        jobsCollectionView.frame = view.bounds
    }
    
    private func configureCollectionView() {
        jobsCollectionView.delegate = self
        jobsCollectionView.dataSource = self
        jobsCollectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        jobsCollectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyCellReuseIdentifier)
        jobsCollectionView.register(BrowseJobCell.self, forCellWithReuseIdentifier: jobCellReuseIdentifier)
    }
    
    private func fetchJobs() {
        JobService.fetchBookmarkedJobsDocuments(lastSnapshot: nil) { snapshot in
            if snapshot.count == 0 {
                self.jobsLoaded = true
                self.jobsCollectionView.reloadData()
            } else {
                JobService.fetchBookmarkedJobs(snapshot: snapshot) { jobs in
                    self.jobsLastSnapshot = snapshot.documents.last
                    self.jobs = jobs
                    let companyIds = jobs.map { $0.companyId }
                    CompanyService.fetchCompanies(withIds: companyIds) { companies in
                        self.jobsLoaded = true
                        self.companies = companies
                        self.jobsCollectionView.reloadData()
                    }
                }
            }
        }
    }
}

extension MyJobsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
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
        if jobs.isEmpty  {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.configure(image: nil, title: "Save jobs you are interested in.", description: "Jobs you save will show up here.", buttonText: .dismiss)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: jobCellReuseIdentifier, for: indexPath) as! BrowseJobCell
            cell.viewModel = JobViewModel(job: jobs[indexPath.row])
            
            if let companyIndex = companies.firstIndex(where: { $0.id == jobs[indexPath.row].companyId }) {
                cell.configureWithCompany(company: companies[companyIndex])
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard jobs.count > 0 else { return }
        if let companyIndex = companies.firstIndex(where: { $0.id == jobs[indexPath.row].companyId }) {
            let controller = JobDetailsViewController(job: jobs[indexPath.row], company: companies[companyIndex])
            let navController = UINavigationController(rootViewController: controller)
            navController.setNavigationBarHidden(true, animated: true)
            
            if let presentationController = navController.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium()]
            }
            
            present(navController, animated: true)
        }
    }
}
