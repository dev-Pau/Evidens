//
//  ApplyJobViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/2/23.
//

import UIKit
import UniformTypeIdentifiers
import JGProgressHUD

private let applyJobHeaderReuseIdentifier = "ApplyJobHeaderReuseIdentifier"
private let jobAttachementsCellReuseIdentifier = "JobAttachementsCellReuseIdentifier"

class ApplyJobViewController: UIViewController {

    private var job: Job
    private var company: Company
    private var user: User
    private var privacyJobMenuLauncher = MEContextMenuLauncher(menuLauncherData: Display(content: .jobPrivacy))
    
    private var viewModel = ApplyJobViewModel()
    
    private var collectionView: UICollectionView!
    
    private lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("  Apply  ", attributes: container)
        button.addTarget(self, action: #selector(handleApplyJob), for: .touchUpInside)
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
    
    private let progressIndicator = JGProgressHUD()
    
    private var userDocUrl: URL?
    private var userDocName: String?
    
    init(job: Job, company: Company, user: User) {
        self.user = user
        self.job = job
        self.company = company
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNavigationBar()
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ApplyJobHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: applyJobHeaderReuseIdentifier)
        collectionView.register(JobAttachementsCell.self, forCellWithReuseIdentifier: jobAttachementsCellReuseIdentifier)
        
        view.addSubviews(collectionView, bottomView, applyButton)
        NSLayoutConstraint.activate([
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 80),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            
            applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            applyButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 5),
        ])
        
        applyButton.isEnabled = false
        //privacyJobMenuLauncher.delega
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        section.boundarySupplementaryItems = [header]
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        config.scrollDirection = .horizontal
        return UICollectionViewCompositionalLayout(section: section)
    }

    private func configureNavigationBar() {
        title = "Apply"
    }
    
    @objc func handleApplyJob() {
        let fileName = user.uid!
        guard let userDocUrl = userDocUrl else { return }
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(userDocUrl.lastPathComponent, isDirectory: false)
        
        progressIndicator.show(in: view)

        StorageManager.uploadJobDocument(jobId: job.jobId, fileName: fileName, url: temporaryFileURL) { url in
            DatabaseManager.shared.sendJobApplication(jobId: self.job.jobId, documentURL: url, phoneNumber: self.viewModel.phoneNumber!) { sent in
                JobService.applyForJob(job: self.job) { error in
                    self.progressIndicator.dismiss(animated: true)
                    guard error == nil else { return }
                    if sent {
                        let reportPopup = METopPopupView(title: "Job application sent", image: "checkmark.circle.fill", popUpType: .regular)
                        reportPopup.showTopPopup(inView: self.view)
                        self.dismiss(animated: true)
                        let fileManager = FileManager.default
                        //NotificationService.uploadNotification(toUid: self.job.ownerUid, fromUser: self.user, type: .jobApplicant, job: self.job)
                        do {
                            try fileManager.removeItem(at: temporaryFileURL)
                            print("Temporary file deleted successfully")
                        } catch {
                            print("Error deleting temporary file: \(error.localizedDescription)")
                        }
                    }
                }
                
            }
        }
    }
}

extension ApplyJobViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: applyJobHeaderReuseIdentifier, for: indexPath) as! ApplyJobHeader
        header.user = user
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: jobAttachementsCellReuseIdentifier, for: indexPath) as! JobAttachementsCell
        cell.delegate = self
        return cell
    }
}

extension ApplyJobViewController: JobAttachementsCellDelegate {
    func didSelectAddFile() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.shouldShowFileExtensions = true
        present(documentPicker, animated: true)
    }
    
    func didSelectReviewFile() {
        guard let userDocUrl = userDocUrl else { return }
        
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(userDocUrl.lastPathComponent, isDirectory: false)

        let controller = ReviewDocumentViewController(url: temporaryFileURL)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func applicationIsValid() {
        applyButton.isEnabled = viewModel.jobIsValid
    }
}

extension ApplyJobViewController: ApplyJobHeaderDelegate {
    func phoneNumberIsValid(number: String?) {
        viewModel.phoneNumber = number
        applicationIsValid()
    }
    
    func didTapShowPrivacyRules() {
        privacyJobMenuLauncher.showImageSettings(in: view)
    }
}

extension ApplyJobViewController: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) { }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let url = urls.first else { return }
        guard url.startAccessingSecurityScopedResource() else {
            print("Can't access")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
    
        userDocUrl = url
        viewModel.documentUrl = userDocUrl
        updateButtonAfterSelectingDocument()
        
        
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(url.lastPathComponent, isDirectory: false)
        do {
            let fileManager = FileManager.default
            try fileManager.copyItem(at: url, to: temporaryFileURL)
            print("file has been successfully copied to temp directory")
            // The file has been successfully copied to the temporary directory
        } catch {
            print("Error copying file to temporary directory: \(error.localizedDescription)")
        }
    }
    
    func updateButtonAfterSelectingDocument() {
        if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? JobAttachementsCell, let userDocUrl = userDocUrl {
            cell.updateButtonWithDocument(fileName: userDocUrl.lastPathComponent)
            applicationIsValid()
        }
    }
}
