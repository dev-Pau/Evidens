//
//  AddUpdateCaseViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/8/22.
//

import UIKit
import JGProgressHUD

private let emptyUpdatesCellReuseIdentifier = "EmptyUpdatesCellReuseIdentifier"
private let updateCaseCellReuseIdentifier = "UpdateCaseCellReuseIdentifier"
private let diagnosisCaseCellReuseIdentifier = "DiagnosisCaseCellReuseIdentifier"

protocol CaseUpdatesViewControllerDelegate: AnyObject {
    func didAddUpdateToCase(withUpdates updates: [String], caseId: String)
}

class CaseUpdatesViewController: UIViewController {
    
    weak var delegate: CaseUpdatesViewControllerDelegate?
    
    var controllerIsPushed: Bool = false
    var groupId: String?
    
    private var clinicalCase: Case
    private var user: User

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
        title = "Case Updates"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddUpdate))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        view.backgroundColor = .systemBackground
        collectionView.frame = view.bounds
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(MESecondaryEmptyCell.self, forCellWithReuseIdentifier: emptyUpdatesCellReuseIdentifier)
        collectionView.register(UpdateCaseCell.self, forCellWithReuseIdentifier: updateCaseCellReuseIdentifier)
        collectionView.register(DiagnosisCaseCell.self, forCellWithReuseIdentifier: diagnosisCaseCellReuseIdentifier)
        
        if clinicalCase.diagnosis != "" {
            clinicalCase.caseUpdates.append(clinicalCase.diagnosis)
            clinicalCase.caseUpdates.reverse()
        } else {
            clinicalCase.caseUpdates.reverse()
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        navigationItem.rightBarButtonItem?.tintColor = clinicalCase.ownerUid == uid ? .label : .clear
        navigationItem.rightBarButtonItem?.isEnabled = clinicalCase.ownerUid == uid ? true : false
    }
    
    @objc func handleAddUpdate() {
        let controller = AddCaseUpdateViewController()
        controller.delegate = self
        controller.groupId = groupId
        let navController = UINavigationController(rootViewController: controller)
        
        if let presentationController = navController.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium(), .large()]
        }
        present(navController, animated: true)
    }
    
    @objc func handleChangeState() {
        let controller = CaseDiagnosisViewController(diagnosisText: "")
        controller.stageIsUpdating = true
        controller.groupId = groupId
        controller.caseId = clinicalCase.caseId
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}

extension CaseUpdatesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clinicalCase.caseUpdates.isEmpty ? 1 : clinicalCase.caseUpdates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if clinicalCase.caseUpdates.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyUpdatesCellReuseIdentifier, for: indexPath) as! MESecondaryEmptyCell
            cell.delegate = self
            cell.configure(image: UIImage(named: "content.empty"), title: "This case does not have any updates —— yet.", description: "Check back for all the new updates that might get posted.", buttonText: .dismiss)
            return cell
        }
        
        if clinicalCase.diagnosis != "" && indexPath.row == 0 {
            // Diagnosis added by the user
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: diagnosisCaseCellReuseIdentifier, for: indexPath) as! DiagnosisCaseCell
            cell.updateNumberLabel.text = "Diagnosis result"
            cell.updateTextLabel.text = clinicalCase.caseUpdates[indexPath.row]
            if clinicalCase.privacyOptions == .visible {
                cell.set(user: user)
            }
            return cell
        }
        
        let hasDiagnosis = clinicalCase.diagnosis != "" ? true : false
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: updateCaseCellReuseIdentifier, for: indexPath) as! UpdateCaseCell
        
        if hasDiagnosis {
            cell.topSeparatorView.backgroundColor = indexPath.row == 1 ? .systemBackground : primaryColor
            cell.bottomSeparatorView.backgroundColor = indexPath.row == clinicalCase.caseUpdates.count - 1 ? .white : primaryColor
        } else {
            cell.topSeparatorView.backgroundColor = indexPath.row == 0 ? .systemBackground : primaryColor
            cell.bottomSeparatorView.backgroundColor = indexPath.row == clinicalCase.caseUpdates.count - 1 || clinicalCase.caseUpdates.count == 1 ? .systemBackground : primaryColor
        }
        
        cell.updateNumberLabel.text = clinicalCase.privacyOptions == .nonVisible ? "Update \(clinicalCase.caseUpdates.count - indexPath.row) by author" : "Update \(clinicalCase.caseUpdates.count - indexPath.row) by \(user.firstName!)"
        cell.updateTextLabel.text = clinicalCase.caseUpdates[indexPath.row]
        if clinicalCase.privacyOptions == .visible {
            cell.set(user: user)
        }
        return cell
    }
}

extension CaseUpdatesViewController: AddCaseUpdateViewControllerDelegate {
    func didTapUploadCaseUpdate(withText text: String) {
        progressIndicator.show(in: view)
        CaseService.uploadCaseUpdate(withCaseId: clinicalCase.caseId, withUpdate: text, withGroupId: groupId) { uploaded in
            self.progressIndicator.dismiss(animated: true)
            if uploaded {
                let positionToAdd = self.clinicalCase.diagnosis != "" ? 1 : 0
                self.clinicalCase.caseUpdates.insert(text, at: positionToAdd)
                self.collectionView.reloadData()
                self.delegate?.didAddUpdateToCase(withUpdates: self.clinicalCase.caseUpdates.reversed(), caseId: self.clinicalCase.caseId)
            }
        }
    }
}

extension CaseUpdatesViewController: MESecondaryEmptyCellDelegate {
    func didTapEmptyCellButton(option: EmptyCellButtonOptions) {
        navigationController?.popViewController(animated: true)
    }
}

