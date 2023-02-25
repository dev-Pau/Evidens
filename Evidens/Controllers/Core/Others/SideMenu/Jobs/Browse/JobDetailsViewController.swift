//
//  JobDetailsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/2/23.
//

import UIKit

private let jobHeaderCellReuseIdentifier = "JobHeaderCellReuseIdentifier"
private let jobDescriptionCellReuseIdentifier = "JobDescriptionCellReuseIdentifier"
private let jobHiringTeamCellReuseIdentifier = "JobHiringTeamCellReuseIdentifier"

protocol JobDetailsViewControllerDelegate: AnyObject {

    func didBookmark(job: Job, company: Company)
}

class JobDetailsViewController: UIViewController {
    weak var delegate: JobDetailsViewControllerDelegate?
    
    private var collectionView: UICollectionView!
    
    private lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        button.isEnabled = false
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("  Apply  ", attributes: container)
        button.addTarget(self, action: #selector(handleApplyJob), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .systemBackground
        button.configuration?.baseForegroundColor = .secondaryLabel
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeColor = .secondaryLabel
        button.configuration?.background.strokeWidth = 1
        
        button.addTarget(self, action: #selector(handleSaveJob), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.borderColor = UIColor.quaternarySystemFill.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private var job: Job
    private var company: Company
    private var user: User
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNavigationBar()
    }
    
    
    init(job: Job, company: Company, user: User) {
        self.job = job
        self.company = company
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(JobHeaderCell.self, forCellWithReuseIdentifier: jobHeaderCellReuseIdentifier)
        collectionView.register(JobDescriptionCell.self, forCellWithReuseIdentifier: jobDescriptionCellReuseIdentifier)
        collectionView.register(JobHiringTeamCell.self, forCellWithReuseIdentifier: jobHiringTeamCellReuseIdentifier)
        
        view.addSubviews(collectionView, bottomView, saveButton, applyButton)
        NSLayoutConstraint.activate([
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 80),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            saveButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 5),
            
            applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            applyButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 5),
        ])
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        
        if user.uid! == job.ownerUid {
            applyButton.isEnabled = false
        } else {
            // Check if user did already applied
            DatabaseManager.shared.checkIfUserDidApplyForJob(jobId: job.jobId) { didApply in
                let text = didApply ? "  Applied  " : "  Apply  "
                self.applyButton.configuration?.attributedTitle = AttributedString(text, attributes: container)
                self.applyButton.isEnabled = didApply ? false : true
            }
        }
        
        JobService.checkIfUserBookmarkedJob(job: job) { bookmarked in
            self.job.didBookmark = bookmarked
            let text = self.job.didBookmark ? "  Saved  " : "  Save  "
            self.saveButton.configuration?.attributedTitle = AttributedString(text, attributes: container)
        }
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
      
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        config.scrollDirection = .horizontal
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureNavigationBar() {
        title = "Job"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleApplyJob() {
        let controller = ApplyJobViewController(job: job, company: company, user: user)

        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        
        self.navigationItem.backBarButtonItem = backItem
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleSaveJob() {
        saveButton.isUserInteractionEnabled = false
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        let text = job.didBookmark ? "  Save  " : "  Saved  "
        saveButton.configuration?.attributedTitle = AttributedString(text, attributes: container)
        
        if job.didBookmark {
            JobService.unbookmarkJob(job: job) { error in
                self.saveButton.isUserInteractionEnabled = true
                guard error == nil else { return }
                self.job.didBookmark = false
                self.delegate?.didBookmark(job: self.job, company: self.company)
            }
        } else {
            JobService.bookmarkJob(job: job) { error in
                self.saveButton.isUserInteractionEnabled = true
                guard error == nil else { return }
                self.job.didBookmark = true
                self.delegate?.didBookmark(job: self.job, company: self.company)
            }
        }
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}

extension JobDetailsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: jobHeaderCellReuseIdentifier, for: indexPath) as! JobHeaderCell
            cell.configure(withJob: JobViewModel(job: job), withCompany: company)
            return cell
        } else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: jobDescriptionCellReuseIdentifier, for: indexPath) as! JobDescriptionCell
            cell.viewModel = JobViewModel(job: job)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: jobHiringTeamCellReuseIdentifier, for: indexPath) as! JobHiringTeamCell
            cell.memberUid = job.ownerUid
            return cell
        }
    }
}

