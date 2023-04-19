//
//  JobApplicantsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/2/23.
//

import UIKit
import JGProgressHUD

private let emptyApplicantCellReuseIdentifier = "EmptyApplicantCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"
private let applicantCellReuseIdentifier = "ApplicantCellReuseIdentifier"

class JobApplicantsViewController: UIViewController {
    private var applicants = [JobUserApplicant]()
    private var users = [User]()
    private var usersLoaded: Bool = false
    private let progressIndicator = JGProgressHUD()
    
    private var job: Job
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    init(job: Job) {
        self.job = job
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
        fetchApplicants()
    }
    
    private func configureNavigationBar() {
        title = "Applicants"
    }
    
    
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        collectionView.frame = view.bounds
        view.addSubview(collectionView)
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyApplicantCellReuseIdentifier)
        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(JobUserApplicationCell.self, forCellWithReuseIdentifier: applicantCellReuseIdentifier)
    }
    
    private func fetchApplicants() {
        DatabaseManager.shared.fetchJobApplicationsForJob(withJobId: job.jobId) { applicants in
            self.applicants = applicants
            let applicantUids = applicants.map { $0.uid }
            UserService.fetchUsers(withUids: applicantUids) { users in
                self.users = users
                self.usersLoaded = true
                self.collectionView.reloadData()
            }
        }
    }
}

extension JobApplicantsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return usersLoaded ? users.isEmpty ? 1 : users.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return usersLoaded ? CGSize.zero : CGSize(width: view.frame.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if users.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyApplicantCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.delegate = self
            cell.configure(image: nil, title: "There's no applicants - yet.", description: "All your job aplicants will show up here.", buttonText: .dismiss)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: applicantCellReuseIdentifier, for: indexPath) as! JobUserApplicationCell
            cell.delegate = self
            if let index = applicants.firstIndex(where: { $0.uid == users[indexPath.row].uid! }) {
                cell.configureWith(user: users[indexPath.row], applicant: applicants[index])
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let index = applicants.firstIndex(where: { $0.uid == users[indexPath.row].uid! }) {
            let controller = ReviewApplicantViewController(user: users[indexPath.row], job: job, applicant: applicants[index])
            controller.delegate = self
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        }
    }
}

extension JobApplicantsViewController: MESecondaryEmptyCellDelegate {
    func didTapEmptyCellButton(option: EmptyCellButtonOptions) {
        navigationController?.popViewController(animated: true)
    }
}

extension JobApplicantsViewController: JobUserApplicationCellDelegate {
    func didTapOption(_ cell: UICollectionViewCell, _ option: Job.ApplicantJobOptions) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        switch option {
        case .review:
            if let index = applicants.firstIndex(where: { $0.uid == users[indexPath.row].uid! }) {
                let controller = ReviewApplicantViewController(user: users[indexPath.row], job: job, applicant: applicants[index])
                controller.delegate = self
                let navVC = UINavigationController(rootViewController: controller)
                navVC.modalPresentationStyle = .fullScreen
                present(navVC, animated: true)
            }

        case .reject:
            displayMEDestructiveAlert(withTitle: "Delete applicant", withMessage: "Are you sure you want to delete \(users[indexPath.row].firstName!)'s job request?", withCancelButtonText: "Cancel", withDoneButtonText: "Delete") {
                self.progressIndicator.show(in: self.view)
                DatabaseManager.shared.rejectJobApplication(withJobId: self.job.jobId, forUid: self.users[indexPath.row].uid!) { rejected in
                    if rejected {
                        self.collectionView.performBatchUpdates {
                            self.users.remove(at: indexPath.row)
                            self.collectionView.deleteItems(at: [indexPath])
                        }
                        let reportPopup = METopPopupView(title: "Job request rejected", image: "checkmark.circle.fill", popUpType: .regular)
                        reportPopup.showTopPopup(inView: self.view)
                    }
                }
            }
        }
    }
}

extension JobApplicantsViewController: ReviewApplicantViewControllerDelegate {
    func didRejectApplicant(user: User) {
        if let index = users.firstIndex(where: { $0.uid == user.uid! }) {
            collectionView.performBatchUpdates {
                self.users.remove(at: index)
                self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
            }
        }
    }
}
