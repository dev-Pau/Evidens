//
//  AddUpdateCaseViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/8/22.
//

import UIKit

private let updateCaseCellReuseIdentifier = "UpdateCaseCellReuseIdentifier"
private let diagnosisCaseCellReuseIdentifier = "DiagnosisCaseCellReuseIdentifier"

protocol CaseUpdatesViewControllerDelegate: AnyObject {
    func didAddUpdateToCase(withUpdates updates: [String])
}

class CaseUpdatesViewController: UIViewController {
    
    weak var delegate: CaseUpdatesViewControllerDelegate?
    
    var controllerIsPushed: Bool = false
    
    var clinicalCaseData: [String] = []
    
    private var clinicalCase: Case
    private var user: User
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        //collectionView.bounces = true
        //collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isHidden = true
        return collectionView
    }()
    
    private let emptyUpdatesLabel: UILabel = {
        let label = UILabel()
        label.text = "This case doesn't have any updates"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
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
        title = "Updates"
        
        if !controllerIsPushed {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = .black
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddUpdate))
            navigationItem.rightBarButtonItem?.tintColor = .black
        }
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
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
        view.backgroundColor = .white
        view.addSubviews(emptyUpdatesLabel)
        NSLayoutConstraint.activate([
            emptyUpdatesLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyUpdatesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        if clinicalCase.caseUpdates.isEmpty {
            emptyUpdatesLabel.isHidden = false
            collectionView.isHidden = true
        } else {
            emptyUpdatesLabel.isHidden = true
            collectionView.isHidden = false
        }
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        navigationItem.rightBarButtonItem?.tintColor = clinicalCase.ownerUid == uid ? .black : .white
        navigationItem.rightBarButtonItem?.isEnabled = clinicalCase.ownerUid == uid ? true : false
    }
    
    @objc func handleAddUpdate() {
        let controller = AddCaseUpdateViewController()
        controller.delegate = self
        let navController = UINavigationController(rootViewController: controller)
        
        if let presentationController = navController.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium(), .large()]
        }
        present(navController, animated: true)
    }
    
    @objc func handleChangeState() {
        let controller = CaseDiagnosisViewController(diagnosisText: "")
        controller.stageIsUpdating = true
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
        return clinicalCase.caseUpdates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
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
            cell.topSeparatorView.backgroundColor = indexPath.row == 1 ? .white : primaryColor
            cell.bottomSeparatorView.backgroundColor = indexPath.row == clinicalCase.caseUpdates.count - 1 ? .white : primaryColor
        } else {
            cell.topSeparatorView.backgroundColor = indexPath.row == 0 ? .white : primaryColor
            cell.bottomSeparatorView.backgroundColor = indexPath.row == clinicalCase.caseUpdates.count - 1 || clinicalCase.caseUpdates.count == 1 ? .white : primaryColor
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
        showLoadingView()
        CaseService.uploadCaseUpdate(withCaseId: clinicalCase.caseId, withUpdate: text) { uploaded in
            self.dismissLoadingView()
            if uploaded {
                let positionToAdd = self.clinicalCase.diagnosis != "" ? 1 : 0
                self.clinicalCase.caseUpdates.insert(text, at: positionToAdd)
                self.collectionView.reloadData()
                self.delegate?.didAddUpdateToCase(withUpdates: self.clinicalCase.caseUpdates.reversed())
            }
        }
    }
}

