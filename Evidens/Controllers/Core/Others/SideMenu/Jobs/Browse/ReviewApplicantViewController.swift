//
//  ReviewApplicantViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/2/23.
//

import UIKit
import JGProgressHUD

private let applicationUserCellReuseIdentifier = "ApplicationUserCellReuseIdentifier"
private let applicationUserDocumentReuseIdentifier = "ApplicationUserDocumentReuseIdentifier"

protocol ReviewApplicantViewControllerDelegate: AnyObject {
    func didRejectApplicant(user: User)
}

class ReviewApplicantViewController: UIViewController {
    weak var delegate: ReviewApplicantViewControllerDelegate?
    private var job: Job
    private var user: User
    private var applicant: JobUserApplicant
    
    private var collectionView: UICollectionView!
    
    private let progressIndicator = JGProgressHUD()
    
    private lazy var rejectButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .systemRed
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("  Reject  ", attributes: container)
        
        button.addTarget(self, action: #selector(handleRejectApplicant), for: .touchUpInside)
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
    }
    
    private func configureUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        view.backgroundColor = .systemBackground
        title = user.firstName!
    }
    
    init(user: User, job: Job, applicant: JobUserApplicant) {
        self.user = user
        self.job = job
        self.applicant = applicant
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ApplicantHeaderCell.self, forCellWithReuseIdentifier: applicationUserCellReuseIdentifier)
        collectionView.register(ApplicantDocumentCell.self, forCellWithReuseIdentifier: applicationUserDocumentReuseIdentifier)
        //collectionView.register(JobDescriptionCell.self, forCellWithReuseIdentifier: jobDescriptionCellReuseIdentifier)
        //collectionView.register(JobHiringTeamCell.self, forCellWithReuseIdentifier: jobHiringTeamCellReuseIdentifier)
        
        view.addSubviews(collectionView, bottomView, rejectButton)
        NSLayoutConstraint.activate([
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 80),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            
            rejectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            rejectButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 5),
        ])
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    @objc func handleRejectApplicant() {
        displayMEDestructiveAlert(withTitle: "Delete applicant", withMessage: "Are you sure you want to delete \(user.firstName!)'s job request?", withCancelButtonText: "Cancel", withDoneButtonText: "Delete") {
            self.progressIndicator.show(in: self.view)
            DatabaseManager.shared.rejectJobApplication(withJobId: self.job.jobId, forUid: self.user.uid!) { rejected in
                if rejected {
                    self.delegate?.didRejectApplicant(user: self.user)
                    let reportPopup = METopPopupView(title: "Job request rejected", image: "checkmark.circle.fill", popUpType: .regular)
                    reportPopup.showTopPopup(inView: self.view)
                    self.dismiss(animated: true)
                }
            }
        }
    }
}


extension ReviewApplicantViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: applicationUserCellReuseIdentifier, for: indexPath) as! ApplicantHeaderCell
            cell.configureWithUser(user: user, applicant: applicant)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: applicationUserDocumentReuseIdentifier, for: indexPath) as! ApplicantDocumentCell
            cell.delegate = self
            return cell
        }
    }
}

extension ReviewApplicantViewController: ApplicantDocumentCellDelegate {
    func didTapAttachementsButton() {
        guard let userDocUrl = URL(string: applicant.documentUrl) else { return }
        let controller = ReviewDocumentViewController(url: userDocUrl)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
}




