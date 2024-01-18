//
//  SupportSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/8/22.
//

private let supportSectionCellReuseIdentifier = "SupportSectionCellReuseIdentifier"

import UIKit

protocol SupportSectionViewControllerDelegate: AnyObject {
    func didAddKind(_ kind: LanguageKind)
    func didAddProficiency(_ proficiency: LanguageProficiency)
}

class LanguageListViewController: UIViewController {
    
    enum LanguageSource {
        case kind, proficiency
    }
    
    private let source: LanguageSource
    
    private var kind: LanguageKind?
    private var proficiency: LanguageProficiency?
    
    private var collectionView: UICollectionView!
    
    weak var delegate: SupportSectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
    }
    
    init(source: LanguageSource, kind: LanguageKind? = nil, proficiency: LanguageProficiency? = nil) {
        self.source = source
        
        if let kind {
            self.kind = kind
        }
        
        if let proficiency {
            self.proficiency = proficiency
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        switch source {
            
        case .kind:
            title = AppStrings.Sections.languageTitle
        case .proficiency:
            title = AppStrings.Sections.Language.proficiency
        }
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: addLayout())
        collectionView.bounces = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        collectionView.register(LanguageCell.self, forCellWithReuseIdentifier: supportSectionCellReuseIdentifier)
        view.addSubviews(collectionView)
    }
    
    private func addLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension LanguageListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch source {
        case .kind: return LanguageKind.allCases.count
        case .proficiency: return LanguageProficiency.allCases.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: supportSectionCellReuseIdentifier, for: indexPath) as! LanguageCell
        switch source {
            
        case .kind:
            cell.set(kind: LanguageKind.allCases[indexPath.row])
            if let kind, kind == LanguageKind.allCases[indexPath.row] {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
            }
        case .proficiency:
            cell.set(proficiency: LanguageProficiency.allCases[indexPath.row])
            if let proficiency, proficiency == LanguageProficiency.allCases[indexPath.row] {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch source {
        case .kind: delegate?.didAddKind(LanguageKind.allCases[indexPath.row])
        case .proficiency: delegate?.didAddProficiency(LanguageProficiency.allCases[indexPath.row])
        }
    
        navigationController?.popViewController(animated: true)
        
    }
}
