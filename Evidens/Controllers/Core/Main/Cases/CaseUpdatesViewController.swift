//
//  AddUpdateCaseViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/8/22.
//

import UIKit

private let updateCaseCellReuseIdentifier = "UpdateCaseCellReuseIdentifier"

class CaseUpdatesViewController: UIViewController {
    
    private var clinicalCase: Case
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 200)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
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
    
    private lazy var addUpdateButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .medium
        button.configuration?.baseBackgroundColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAddUpdate), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        configureUI()
    }
    

    init(clinicalCase: Case) {
        self.clinicalCase = clinicalCase
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Case updates"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UpdateCaseCell.self, forCellWithReuseIdentifier: updateCaseCellReuseIdentifier)
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubviews(emptyUpdatesLabel, addUpdateButton)
        NSLayoutConstraint.activate([
            emptyUpdatesLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyUpdatesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            
            addUpdateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addUpdateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        
        if clinicalCase.caseUpdates.isEmpty {
            emptyUpdatesLabel.isHidden = false
            collectionView.isHidden = true
        } else {
            emptyUpdatesLabel.isHidden = true
            collectionView.isHidden = false
        }
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
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}

extension CaseUpdatesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clinicalCase.caseUpdates.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: updateCaseCellReuseIdentifier, for: indexPath) as! UpdateCaseCell
        cell.updateNumberLabel.text = "Update \(indexPath.row + 1)"
        cell.updateTextLabel.text = clinicalCase.caseUpdates[indexPath.row]
        return cell
    }
}

extension CaseUpdatesViewController: AddCaseUpdateViewControllerDelegate {
    func didTapUploadCaseUpdate(withText text: String) {
        CaseService.uploadCaseUpdate(withCaseId: clinicalCase.caseId, withUpdate: text) { uploaded in
            if uploaded {
                print("uploaded")
            }
        }
    }
}

