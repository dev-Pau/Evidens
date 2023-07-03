//
//  AddUpdateCaseViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/8/22.
//

import UIKit
import JGProgressHUD

private let emptyRevisionCellReuseIdentifier = "EmptyUpdatesCellReuseIdentifier"
private let revisionCaseCellReuseIdentifier = "RevisionCaseCellReuseIdentifier"
private let diagnosisCaseCellReuseIdentifier = "DiagnosisCaseCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"

protocol CaseUpdatesViewControllerDelegate: AnyObject {
    func didAddRevision(to clinicalCase: Case, _ revision: CaseRevision)
}

class CaseRevisionViewController: UIViewController {
    
    weak var delegate: CaseUpdatesViewControllerDelegate?

    var groupId: String?
    
    private var clinicalCase: Case
    private var user: User
    private var loaded: Bool = false
    
    private var revisions = [CaseRevision]()

    private let progressIndicator = JGProgressHUD()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: .leastNonzeroMagnitude)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        configureUI()
        fetchRevisions()
    }
    
    init(clinicalCase: Case, user: User) {
        self.clinicalCase = clinicalCase
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Case Revision"
        guard clinicalCase.revision != .diagnosis else { return }
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), style: .done, target: self, action: #selector(handleAddUpdate))
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        view.backgroundColor = .systemBackground
        collectionView.frame = view.bounds
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(MELoadingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyRevisionCellReuseIdentifier)
        collectionView.register(RevisionCaseCell.self, forCellWithReuseIdentifier: revisionCaseCellReuseIdentifier)
        collectionView.register(DiagnosisCaseCell.self, forCellWithReuseIdentifier: diagnosisCaseCellReuseIdentifier)
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        navigationItem.rightBarButtonItem?.tintColor = clinicalCase.ownerUid == uid ? .label : .clear
        navigationItem.rightBarButtonItem?.isEnabled = clinicalCase.ownerUid == uid ? true : false
    }
    
    private func fetchRevisions() {
        CaseService.fetchCaseRevisions(withCaseId: clinicalCase.caseId) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let revisions):
                strongSelf.revisions = revisions.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
                strongSelf.loaded = true
                strongSelf.collectionView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func handleAddUpdate() {
        let controller = AddCaseRevisionViewController(clinicalCase: clinicalCase)
        controller.delegate = self
        controller.groupId = groupId
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}

extension CaseRevisionViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loaded ? revisions.isEmpty ? 1 : revisions.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return loaded ? CGSize.zero : CGSize(width: view.frame.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if revisions.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyRevisionCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.delegate = self
            cell.configure(image: UIImage(named: "content.empty"), title: "This case does not have any revisions —— yet.", description: "Would you like to share more information or any new findings? Add a revision to keep others informed about your progress.", buttonText: .dismiss)
            return cell
        } else {
            let revision = revisions[indexPath.row].kind
            
            switch revision {
            case .clear: fatalError()
            case .update:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: revisionCaseCellReuseIdentifier, for: indexPath) as! RevisionCaseCell
                cell.viewModel = RevisionKindViewModel(revision: revisions[indexPath.row])
                if clinicalCase.privacyOptions == .visible { cell.set(user: user) }
                cell.set(date: clinicalCase.timestamp.dateValue())
                return cell
            case .diagnosis:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: diagnosisCaseCellReuseIdentifier, for: indexPath) as! DiagnosisCaseCell
                cell.viewModel = RevisionKindViewModel(revision: revisions[indexPath.row])
                if clinicalCase.privacyOptions == .visible { cell.set(user: user) }
                cell.set(date: clinicalCase.timestamp.dateValue())
                return cell
            }
        }
    }
}

extension CaseRevisionViewController: AddCaseUpdateViewControllerDelegate {
    func didAddRevision(revision: CaseRevision, for clinicalCase: Case) {
        self.clinicalCase.revision = revision.kind
        revisions.insert(revision, at: 0)
        collectionView.reloadData()
        delegate?.didAddRevision(to: clinicalCase, revision)
    }
}

extension CaseRevisionViewController: MESecondaryEmptyCellDelegate {
    func didTapEmptyCellButton(option: EmptyCellButtonOptions) {
        navigationController?.popViewController(animated: true)
    }
}

