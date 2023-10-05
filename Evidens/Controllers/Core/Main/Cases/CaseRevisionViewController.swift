//
//  AddUpdateCaseViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/8/22.
//

import UIKit

private let emptyRevisionCellReuseIdentifier = "EmptyUpdatesCellReuseIdentifier"
private let revisionCaseCellReuseIdentifier = "RevisionCaseCellReuseIdentifier"
private let diagnosisCaseCellReuseIdentifier = "DiagnosisCaseCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"

protocol CaseUpdatesViewControllerDelegate: AnyObject {
    func didAddRevision(to clinicalCase: Case, _ revision: CaseRevision)
}

class CaseRevisionViewController: UIViewController {
    
    private var viewModel: CaseRevisionViewModel
    
    weak var delegate: CaseUpdatesViewControllerDelegate?

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
        configureNotificationObservers()
    }
    
    init(clinicalCase: Case, user: User? = nil) {
        self.viewModel = CaseRevisionViewModel(clinicalCase: clinicalCase, user: user)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Title.revision
        guard viewModel.clinicalCase.revision != .diagnosis else { return }
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), style: .done, target: self, action: #selector(handleAddUpdate))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
    }
    
    private func configureNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange(_:)), name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseRevisionChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseRevision), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(caseSolveChange(_:)), name: NSNotification.Name(AppPublishers.Names.caseSolve), object: nil)
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
        navigationItem.rightBarButtonItem?.tintColor = viewModel.clinicalCase.uid == uid ? .label : .clear
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.clinicalCase.uid == uid ? true : false
    }
    
    private func fetchRevisions() {
        viewModel.fetchRevisions { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.reloadData()
            
            if let error, error == .network {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
    
    @objc func handleAddUpdate() {
        let controller = AddCaseRevisionViewController(clinicalCase: viewModel.clinicalCase)

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
        return viewModel.loaded ? viewModel.revisions.isEmpty ? 1 : viewModel.revisions.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! MELoadingHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return viewModel.loaded ? CGSize.zero : CGSize(width: view.frame.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.revisions.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyRevisionCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.delegate = self
            
            cell.configure(image: UIImage(named: AppStrings.Assets.emptyContent), title: AppStrings.Content.Case.Empty.emptyRevisionTitle, description: AppStrings.Content.Case.Empty.emptyRevisionContent, content: .dismiss)
            
            return cell
        } else {
            let revision = viewModel.revisions[indexPath.row].kind
            
            switch revision {
            case .clear: fatalError()
            case .update:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: revisionCaseCellReuseIdentifier, for: indexPath) as! RevisionCaseCell
                cell.viewModel = RevisionKindViewModel(revision: viewModel.revisions[indexPath.row])
                if viewModel.clinicalCase.privacy == .regular, let user = viewModel.user { cell.set(user: user) }
                cell.set(date: viewModel.clinicalCase.timestamp.dateValue())
                return cell
            case .diagnosis:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: diagnosisCaseCellReuseIdentifier, for: indexPath) as! DiagnosisCaseCell
                cell.viewModel = RevisionKindViewModel(revision: viewModel.revisions[indexPath.row])
                if viewModel.clinicalCase.privacy == .regular, let user = viewModel.user { cell.set(user: user) }
                cell.set(date: viewModel.clinicalCase.timestamp.dateValue())
                return cell
            }
        }
    }
}

extension CaseRevisionViewController: MESecondaryEmptyCellDelegate {
    func didTapContent(_ content: EmptyContent) {
        navigationController?.popViewController(animated: true)
    }
}

extension CaseRevisionViewController {
    
    @objc func caseRevisionChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseRevisionChange {
            if change.caseId == viewModel.clinicalCase.caseId {
                viewModel.loaded = false
                viewModel.revisions.removeAll()
                collectionView.reloadData()
                fetchRevisions()
            }
        }
    }
    
    @objc func caseSolveChange(_ notification: NSNotification) {
        if let change = notification.object as? CaseSolveChange {
            if change.caseId == viewModel.clinicalCase.caseId {
                navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension CaseRevisionViewController {
    
    @objc func userDidChange(_ notification: NSNotification) {
        if let user = notification.userInfo!["user"] as? User {
            if let currentUser = viewModel.user, currentUser.isCurrentUser {
                viewModel.user = user
                collectionView.reloadData()
            }
        }
    }
}

