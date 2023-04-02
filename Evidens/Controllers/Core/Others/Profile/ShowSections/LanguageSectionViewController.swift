//
//  LanguageSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/8/22.
//

import UIKit
import JGProgressHUD

private let languageCellReuseIdentifier = "LanguageCellReuseIdentifier"

protocol LanguageSectionViewControllerDelegate: AnyObject {
    func updateLanguageValues()
}

class LanguageSectionViewController: UIViewController {
    
    weak var delegate: LanguageSectionViewControllerDelegate?
    
    private var languages: [Language]
    private var isCurrentUser: Bool
    private var collectionView: UICollectionView!
    private var progressIndicator = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
    }
    
    init(languages: [Language], isCurrentUser: Bool) {
        self.languages = languages
        self.isCurrentUser = isCurrentUser
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        title = "Languages"
        view.backgroundColor = .systemBackground
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UserProfileLanguageCell.self, forCellWithReuseIdentifier: languageCellReuseIdentifier)
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            
            let _ = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100)))
            let section = NSCollectionLayoutSection.list(using: self.createListConfiguration(), layoutEnvironment: env)
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        layout.configuration = config
        return layout
    }
    
    private func createListConfiguration() -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.trailingSwipeActionsConfigurationProvider = { indexPath in
         
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] action, view, completion in
                self?.deleteLanguage(at: indexPath)
                completion(true)
            }

            let editAction = UIContextualAction(style: .normal, title: nil ) {
                [weak self] action, view, completion in
                self?.editLangauge(at: indexPath)
                completion(true)
            }
            
            deleteAction.image = UIImage(systemName: "trash.fill")
            editAction.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
            return UISwipeActionsConfiguration(actions: self.isCurrentUser ? [deleteAction, editAction] : [])
        }
        
        return configuration
    }
    
    private func deleteLanguage(at indexPath: IndexPath) {
        displayMEDestructiveAlert(withTitle: "Delete Language", withMessage: "Are you sure you want to delete \(languages[indexPath.row].name) from your profile?", withCancelButtonText: "Cancel", withDoneButtonText: "Delete") {
            self.progressIndicator.show(in: self.view)
            DatabaseManager.shared.deleteLanguage(language: self.languages[indexPath.row]) { deleted in
                self.progressIndicator.dismiss(animated: true)
                if deleted {
                    self.languages.remove(at: indexPath.row)
                    self.collectionView.deleteItems(at: [indexPath])
                    self.delegate?.updateLanguageValues()
                }
            }
        }
    }
    
    private func editLangauge(at indexPath: IndexPath) {
        let controller = AddLanguageViewController()
        controller.userIsEditing = true
        controller.delegate = self
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        controller.hidesBottomBarWhenPushed = true
        controller.configureWithLanguage(language: languages[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension LanguageSectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return languages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: languageCellReuseIdentifier, for: indexPath) as! UserProfileLanguageCell
        cell.set(language: languages[indexPath.row])
        cell.buttonImage.isHidden = isCurrentUser ? false : true
        cell.buttonImage.isUserInteractionEnabled = isCurrentUser ? true : false
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = AddLanguageViewController()
        controller.userIsEditing = true
        controller.delegate = self
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        controller.hidesBottomBarWhenPushed = true
        navigationItem.backBarButtonItem = backItem
        
        controller.configureWithLanguage(language: languages[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension LanguageSectionViewController: AddLanguageViewControllerDelegate {
    func handleLanguageUpdate(language: Language) {
        delegate?.updateLanguageValues()
        if let languageIndex = languages.firstIndex(where: { $0.name == language.name }) {
            languages[languageIndex] = language
            collectionView.reloadData()
        }

    }
    
    func deleteLanguage(language: Language) {
        if let languageIndex = languages.firstIndex(where: { $0.name == language.name }) {
            languages.remove(at: languageIndex)
            collectionView.deleteItems(at: [IndexPath(item: languageIndex, section: 0)])
        }
    }
}
