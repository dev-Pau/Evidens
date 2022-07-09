//
//  ClinicalTypeViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/7/22.
//

import UIKit

private let clinicalTypeCellReuseIdentifier = "ClinicalTypeCellReuseIdentifier"

protocol ClinicalTypeViewControllerDelegate: AnyObject {
    func didSelectCaseType(_ types: [String])
}

class ClinicalTypeViewController: UIViewController {
    
    weak var delegate: ClinicalTypeViewControllerDelegate?
    
    private var selectedTypes: [String] = []
    
    private var clinicalTypes = CaseType.allCaseTypes()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.register(ClinicalTypeCell.self, forCellWithReuseIdentifier: clinicalTypeCellReuseIdentifier)
        collectionView.allowsMultipleSelection = true
        return collectionView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
    }
    
    private func configureNavigationBar() {
        title = "Type details"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleDone))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        view.backgroundColor = .white
    }
    
    private func configureTableView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }
    
    @objc func handleDone() {
        delegate?.didSelectCaseType(selectedTypes)
        navigationController?.popViewController(animated: true) 
    }
}


extension ClinicalTypeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clinicalTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: clinicalTypeCellReuseIdentifier, for: indexPath) as! ClinicalTypeCell
        cell.set(title: clinicalTypes[indexPath.row].type)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ClinicalTypeCell else { return }
        if let text = cell.typeTitle.text {
            selectedTypes.append(text)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ClinicalTypeCell else { return }
        if let text = cell.typeTitle.text {
            if let index = selectedTypes.firstIndex(where: { $0 == text }) {
                selectedTypes.remove(at: index)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
