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

class LanguageListViewController: UICollectionViewController {
    
    enum LanguageSource {
        case kind, proficiency
    }
    
    private let source: LanguageSource
    
    private var kind: LanguageKind?
    private var proficiency: LanguageProficiency?
    
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
        
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
        layout.scrollDirection = .vertical
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        super.init(collectionViewLayout: layout)
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
        collectionView.bounces = true
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        collectionView.register(LanguageCell.self, forCellWithReuseIdentifier: supportSectionCellReuseIdentifier)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch source {
        case .kind: return LanguageKind.allCases.count
        case .proficiency: return LanguageProficiency.allCases.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch source {
        case .kind: delegate?.didAddKind(LanguageKind.allCases[indexPath.row])
        case .proficiency: delegate?.didAddProficiency(LanguageProficiency.allCases[indexPath.row])
        }
    
        navigationController?.popViewController(animated: true)
        
    }
}
