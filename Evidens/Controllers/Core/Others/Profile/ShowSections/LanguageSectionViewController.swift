//
//  LanguageSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/8/22.
//

import UIKit

private let languageCellReuseIdentifier = "LanguageCellReuseIdentifier"

protocol LanguageSectionViewControllerDelegate: AnyObject {
    func didUpdateLanguage()
}

class LanguageSectionViewController: UIViewController {
    
    weak var delegate: LanguageSectionViewControllerDelegate?
    
    private var languages: [Language]
    private let user: User
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
    }
    
    init(languages: [Language], user: User) {
        self.languages = languages
        self.user = user
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        let fullName = user.name()
        let view = CompoundNavigationBar(fullName: fullName, category: AppStrings.Sections.languagesTitle)
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = view
        view.backgroundColor = .systemBackground
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: AppStrings.Icons.leftChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withTintColor(.clear).withRenderingMode(.alwaysOriginal), style: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ProfileLanguageCell.self, forCellWithReuseIdentifier: languageCellReuseIdentifier)
        view.addSubview(collectionView)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            let _ = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100)))
            let section = NSCollectionLayoutSection.list(using: strongSelf.createListConfiguration(), layoutEnvironment: env)
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        layout.configuration = config
        return layout
    }
    
    private func createListConfiguration() -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let strongSelf = self else { return nil }
            
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] action, view, completion in
                guard let strongSelf = self else { return}
                strongSelf.deleteLanguage(at: indexPath)
                completion(true)
            }

            let editAction = UIContextualAction(style: .normal, title: nil ) { [weak self] action, view, completion in
                guard let strongSelf = self else { return }
                strongSelf.editLangauge(at: indexPath)
                completion(true)
            }
            
            deleteAction.image = UIImage(systemName: AppStrings.Icons.fillTrash)
            editAction.image = UIImage(systemName: AppStrings.Icons.pencil, withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
            return UISwipeActionsConfiguration(actions: strongSelf.user.isCurrentUser ? [deleteAction, editAction] : [])
        }
        
        return configuration
    }
    
    private func deleteLanguage(at indexPath: IndexPath) {
        displayAlert(withTitle: AppStrings.Alerts.Title.deleteLanguage, withMessage: AppStrings.Alerts.Subtitle.deleteLanguage, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.delete, style: .destructive) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.showProgressIndicator(in: strongSelf.view)
            
            DatabaseManager.shared.deleteLanguage(strongSelf.languages[indexPath.row]) { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.dismissProgressIndicator()
                if let error {
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    strongSelf.languages.remove(at: indexPath.row)
                    strongSelf.collectionView.deleteItems(at: [indexPath])
                    strongSelf.delegate?.didUpdateLanguage()
                }
            }
        }
    }
    
    private func editLangauge(at indexPath: IndexPath) {
        let controller = AddLanguageViewController(language: languages[indexPath.row])
        controller.delegate = self
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension LanguageSectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return languages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: languageCellReuseIdentifier, for: indexPath) as! ProfileLanguageCell
        cell.set(language: languages[indexPath.row])
        cell.separatorView.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = AddLanguageViewController(language: languages[indexPath.row])
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension LanguageSectionViewController: AddLanguageViewControllerDelegate {
    func didDeleteLanguage(_ language: Language) {
        delegate?.didUpdateLanguage()
        if let index = languages.firstIndex(where: { $0.kind == language.kind }) {
            languages.remove(at: index)
            collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func didAddLanguage(_ language: Language) {
        delegate?.didUpdateLanguage()
        if let index = languages.firstIndex(where: { $0.kind == language.kind }) {
            languages[index] = language
            collectionView.reloadData()
        }
    }
}
