//
//  SettingsKindViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/6/23.
//

import UIKit

private let settingsKindHeaderReuseIdentifier = "SettingsKindHeaderReuseIdentifier"
private let settingsCellReuseIdentifier = "SettingsCellReuseIdentifier"

class SettingsKindViewController: UIViewController {
    
    let kind: SettingKind
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    init(kind: SettingKind) {
        self.kind = kind
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
        
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
        section.interGroupSpacing = 20
        section.boundarySupplementaryItems = [header]
        return UICollectionViewCompositionalLayout(section: section)
    }

    private func configureNavigationBar() {
        title = kind.title
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        view.addSubviews(collectionView)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .systemBackground
        collectionView.register(SettingsCell.self, forCellWithReuseIdentifier: settingsCellReuseIdentifier)
        collectionView.register(SettingsKindHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: settingsKindHeaderReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension SettingsKindViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kind.subSetting.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: ElementKind.sectionHeader, withReuseIdentifier: settingsKindHeaderReuseIdentifier, for: indexPath) as! SettingsKindHeader
        header.configure(with: self.kind.content)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: settingsCellReuseIdentifier, for: indexPath) as! SettingsCell
        cell.set(subSetting: kind.subSetting[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let subSetting = kind.subSetting[indexPath.row]
        switch subSetting {
        case .account:
            let controller = AccountInformationViewController()
            navigationController?.pushViewController(controller, animated: true)
        case .password:
            let controller = ChangePasswordViewController()
            navigationController?.pushViewController(controller, animated: true)
        case .deactivate:
            let controller = DeactivateAccountViewController()
            navigationController?.pushViewController(controller, animated: true)
        default:
            fatalError()
        }
    }
}
