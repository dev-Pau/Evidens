//
//  ClinicalTypeViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/7/22.
//

import UIKit

private let clinicalTypeCellReuseIdentifier = "ClinicalTypeCellReuseIdentifier"

protocol ClinicalTypeViewControllerDelegate: AnyObject {
    func didSelectCaseType(_ types: [CaseItem])
    func didSelectCaseType(type: CaseItem)
}

class ClinicalTypeViewController: UIViewController {
    
    weak var delegate: ClinicalTypeViewControllerDelegate?
    
    private var selectedItems: [CaseItem]
    
    var controllerIsPresented: Bool = false
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.register(CaseKindCell.self, forCellWithReuseIdentifier: clinicalTypeCellReuseIdentifier)
        collectionView.allowsMultipleSelection = true
        return collectionView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
    }
    
    init(selectedItems: [CaseItem]) {
        self.selectedItems = selectedItems
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Content.Case.Share.details
        
        if controllerIsPresented {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.xmark)?.withConfiguration(UIImage.SymbolConfiguration(weight: .medium)).withRenderingMode(.alwaysOriginal).withTintColor(.label), style: .done, target: self, action: #selector(handleDismiss))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Global.done, style: .done, target: self, action: #selector(handleDone))
            navigationItem.rightBarButtonItem?.tintColor = primaryColor
            navigationItem.rightBarButtonItem?.isEnabled = selectedItems.count > 0 ? true : false
            
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.setBackIndicatorImage(UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), transitionMaskImage: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))
            navigationBarAppearance.configureWithOpaqueBackground()
            
            let barButtonItemAppearance = UIBarButtonItemAppearance()
            barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
            navigationBarAppearance.backButtonAppearance = barButtonItemAppearance
            
            navigationBarAppearance.shadowColor = separatorColor
            navigationBarAppearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 17, weight: .heavy)]
            
            navigationController?.navigationBar.standardAppearance = navigationBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        }
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        
        if controllerIsPresented {
            collectionView.allowsMultipleSelection = false
        }
    }
    
    @objc func handleDone() {
        delegate?.didSelectCaseType(selectedItems)
        navigationController?.popViewController(animated: true) 
    }
}


extension ClinicalTypeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CaseItem.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: clinicalTypeCellReuseIdentifier, for: indexPath) as! CaseKindCell
        cell.set(item: CaseItem.allCases[indexPath.row])
        //cell.set(title: clinicalTypes[indexPath.row].type)
        if selectedItems.contains(CaseItem.allCases[indexPath.row]) {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if controllerIsPresented {
            delegate?.didSelectCaseType(type: CaseItem.allCases[indexPath.row])
            dismiss(animated: true)
            return
        }
        
        selectedItems.append(CaseItem.allCases[indexPath.row])
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if controllerIsPresented {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
            dismiss(animated: true)
            return
        }
        
        if let index = selectedItems.firstIndex(of: CaseItem.allCases[indexPath.row]) {
            selectedItems.remove(at: index)
            navigationItem.rightBarButtonItem?.isEnabled = selectedItems.count > 0 ? true : false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return selectedItems.count > 3 ? false : true
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
