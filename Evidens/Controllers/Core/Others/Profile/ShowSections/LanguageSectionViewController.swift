//
//  LanguageSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/8/22.
//

import UIKit

private let languageCellReuseIdentifier = "LanguageCellReuseIdentifier"

class LanguageSectionViewController: UICollectionViewController {
    
    private var languages = [[String: String]]()
    private var isCurrentUser: Bool
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        title = "Languages"
    }
    
    init(languages: [[String: String]], isCurrentUser: Bool) {
        self.languages = languages
        self.isCurrentUser = isCurrentUser
        
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
            
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        layout.configuration = config
        
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCollectionView() {
        collectionView.register(UserProfileLanguageCell.self, forCellWithReuseIdentifier: languageCellReuseIdentifier)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: languageCellReuseIdentifier, for: indexPath) as! UserProfileLanguageCell
        cell.set(languageInfo: languages[indexPath.row])
        cell.delegate = self
        cell.separatorView.isHidden = indexPath.row == 0 ? true : false
        
        cell.buttonImage.isHidden = isCurrentUser ? false : true
        cell.buttonImage.isUserInteractionEnabled = isCurrentUser ? true : false
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return languages.count
    }
}

extension LanguageSectionViewController: UserProfileLanguageCellDelegate {
    func didTapEditLanguage(_ cell: UICollectionViewCell, languageName: String, languageProficiency: String) {
        
        let controller = AddLanguageViewController()
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .black
        navigationItem.backBarButtonItem = backItem
        
        controller.configureWithLanguage(languageName: languageName, languageProficiency: languageProficiency)
        navigationController?.pushViewController(controller, animated: true)
        
    }
}