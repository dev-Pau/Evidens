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
    func didSelectCaseType(type: String)
}

class ClinicalTypeViewController: UIViewController {
    
    weak var delegate: ClinicalTypeViewControllerDelegate?
    
    private var selectedTypes: [String]
    
    var controllerIsPresented: Bool = false
    
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
    
    init(selectedTypes: [String]) {
        self.selectedTypes = selectedTypes
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Type Details"
        
        if controllerIsPresented {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark")?.withConfiguration(UIImage.SymbolConfiguration(weight: .medium)).withRenderingMode(.alwaysOriginal).withTintColor(.label), style: .done, target: self, action: #selector(handleDismiss))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleDone))
            navigationItem.rightBarButtonItem?.tintColor = primaryColor
            navigationItem.rightBarButtonItem?.isEnabled = selectedTypes.count > 0 ? true : false
        }
    }
    
    private func configureTableView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        
        if controllerIsPresented {
            collectionView.allowsMultipleSelection = false
        }
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
        if let text = cell.typeTitle.text {
            if selectedTypes.contains(text) {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if controllerIsPresented {
            delegate?.didSelectCaseType(type: clinicalTypes[indexPath.row].type)
            dismiss(animated: true)
            return
        }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? ClinicalTypeCell else { return }
        if let text = cell.typeTitle.text {
            selectedTypes.append(text)
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if controllerIsPresented {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
            dismiss(animated: true)
            return
        }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? ClinicalTypeCell else { return }

        if let text = cell.typeTitle.text {
            if let index = selectedTypes.firstIndex(where: { $0 == text }) {
                selectedTypes.remove(at: index)
                navigationItem.rightBarButtonItem?.isEnabled = selectedTypes.count > 0 ? true : false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}
