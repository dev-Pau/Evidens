//
//  CaseFiltersViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/11/23.
//

import UIKit

private let filterHeaderReuseIdentifier = "FilterHeaderReuseIdentifier"
private let filterCellReuseIdentifier = "FilterCellReuseIdentifier"

protocol CaseFiltersViewControllerDelegate: AnyObject {
    func didTapFilter(_ filter: CaseFilter)
}

class CaseFiltersViewController: UIViewController {
    
    private var viewModel: CaseFiltersViewModel
    
    weak var delegate: CaseFiltersViewControllerDelegate?
    
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    init(filter: CaseFilter) {
        self.viewModel = CaseFiltersViewModel(filter: filter)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Title.sort
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppStrings.Global.cancel, style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Global.apply, style: .done, target: self, action: #selector(handleApply))
        navigationItem.rightBarButtonItem?.tintColor = K.Colors.primaryColor
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        navigationItem.leftBarButtonItem?.tintColor = .label
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        
        collectionView.register(NotificationHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: filterHeaderReuseIdentifier)
        collectionView.register(FilterCaseCell.self, forCellWithReuseIdentifier: filterCellReuseIdentifier)
    }

    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    @objc func handleApply() {
        delegate?.didTapFilter(viewModel.filter)
        dismiss(animated: true)
    }
}

extension CaseFiltersViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CaseFilter.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellReuseIdentifier, for: indexPath) as! FilterCaseCell
        cell.set(isOn: viewModel.filter == CaseFilter.allCases[indexPath.row])
        cell.set(filter: CaseFilter.allCases[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: filterHeaderReuseIdentifier, for: indexPath) as! NotificationHeader
        header.set(title: AppStrings.Content.Case.Sort.sort)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filter = CaseFilter.allCases[indexPath.row]
        guard filter != viewModel.filter else { return }
        viewModel.set(filter: filter)
        navigationItem.rightBarButtonItem?.isEnabled = true
        collectionView.reloadData()
    }
}
