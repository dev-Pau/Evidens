//
//  CaseStageViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 18/7/22.
//

import UIKit

private let clinicalTypeCellReuseIdentifier = "ClinicalTypeCellReuseIdentifier"

protocol CaseStageViewControllerDelegate: AnyObject {
    func didSelectStage(_ stage: String)
}

class CaseStageViewController: UIViewController {
    
    weak var delegate: CaseStageViewControllerDelegate?
    
    private var selectedType: String
    
    private var stageTypes = ["Resolved", "Unresolved"]
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.register(ClinicalTypeCell.self, forCellWithReuseIdentifier: clinicalTypeCellReuseIdentifier)
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        print(selectedType)
    }
    
    init(selectedType: String) {
        self.selectedType = selectedType
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Type details"
    }
    
    private func configureTableView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }
}


extension CaseStageViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stageTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: clinicalTypeCellReuseIdentifier, for: indexPath) as! ClinicalTypeCell
        cell.set(title: stageTypes[indexPath.row])
        if let text = cell.typeTitle.text {
            if selectedType == text {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ClinicalTypeCell else { return }
        if let text = cell.typeTitle.text {
            selectedType = text
            navigationController?.popViewController(animated: true)
            delegate?.didSelectStage(selectedType)

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

