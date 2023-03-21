//
//  JobManagerViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/2/23.
//

import UIKit

private let manageJobHeaderReuseIdentifier = "ManageJobHeaderCellReuseIdentifier"
private let jobDescriptionCellReuseIdentifier = "JobDescriptionCellReuseIdentifier"

protocol JobManagerViewControllerDelegate: AnyObject {
    func didUpdateJob(job: Job)
}

class JobManagerViewController: UIViewController {
    weak var delegate: JobManagerViewControllerDelegate?
    
    private var job: Job
    private var company: Company
    
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
        configureUI()
        configureCollectionView()
    }
    
    init(job: Job, company: Company) {
        self.company = company
        self.job = job
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Manage Job"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(handleEditJob))
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        collectionView.frame = view.bounds
        view.addSubviews(collectionView)
    }
    
    private func configureCollectionView() {
        
        collectionView.register(ManageJobHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: manageJobHeaderReuseIdentifier)
        collectionView.register(JobDescriptionCell.self, forCellWithReuseIdentifier: jobDescriptionCellReuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @objc func handleEditJob() {
        guard let tab = self.tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        let controller = CreateJobViewController(user: user, job: job, company: company)
        controller.delegate = self
        let navVC = UINavigationController(rootViewController: controller)
        
        navVC.modalPresentationStyle = .fullScreen
        
        present(navVC, animated: true)
    }
}

extension JobManagerViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: manageJobHeaderReuseIdentifier, for: indexPath) as! ManageJobHeaderCell
        header.delegate = self
        header.configure(withJob: JobViewModel(job: job), withCompany: company)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 123)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: jobDescriptionCellReuseIdentifier, for: indexPath) as! JobDescriptionCell
        cell.viewModel = JobViewModel(job: job)
        return cell
    }
}

extension JobManagerViewController: CreateJobViewControllerDelegate {
    func didUpdateJob(job: Job) {
        self.job = job
        collectionView.reloadData()
        delegate?.didUpdateJob(job: job)
    }
}

extension JobManagerViewController: ManageJobHeaderCellDelegate {
    func didTapShowParticipants() {
        let controller = JobApplicantsViewController(job: job)
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(controller, animated: true)
    }
}
