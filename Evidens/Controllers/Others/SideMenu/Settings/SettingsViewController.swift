//
//  SettingsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/6/23.
//

import UIKit

private let settingsCellReuseIdentifier = "SettingsCellReuseIdentifier"

class SettingsViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    private func configureNavigationBar() {
        title = AppStrings.SideMenu.settings
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
        section.interGroupSpacing = 20
        return UICollectionViewCompositionalLayout(section: section)
    }

    private func configure() {
        view.backgroundColor = .systemBackground
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .systemBackground
        collectionView.register(SettingsCell.self, forCellWithReuseIdentifier: settingsCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubviews(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: UIDevice.isPad ? view.bottomAnchor : view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension SettingsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SettingKind.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: settingsCellReuseIdentifier, for: indexPath) as! SettingsCell
        cell.set(kind: SettingKind.allCases[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let kind = SettingKind.allCases[indexPath.row]
        switch kind {
        case .account:
            let controller = SettingsKindViewController(kind: kind)
            navigationController?.pushViewController(controller, animated: true)
        case .privacy:
            let controller = PrivacySecurityViewController(kind: kind)
            navigationController?.pushViewController(controller, animated: true)
        case .notifications:
            let controller = NotificationKindViewController()
            navigationController?.pushViewController(controller, animated: true)
        case .resources:
            let controller = ResourcesViewController()
            navigationController?.pushViewController(controller, animated: true)
        case .language:
            if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(appSettingsURL) {
                    UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
                }
            }
        }
    }
}
