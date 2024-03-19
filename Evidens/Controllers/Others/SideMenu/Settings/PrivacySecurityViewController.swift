//
//  PrivacySecurityViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/3/24.
//

import UIKit
import MessageUI

private let privacySecurityHeaderReuseIdentifier = "PrivacaySecurityHeaderReuseIdentifier"
private let settingsKindHeaderReuseIdentifier = "SettingsKindHeaderReuseIdentifier"
private let settingsCellReuseIdentifier = "SettingsCellReuseIdentifier"
private let privacyCellReuseIdentifier = "PrivacyCellReuseIdentifier"

class PrivacySecurityViewController: UIViewController {
    
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
        collectionView.register(NotificationHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: privacySecurityHeaderReuseIdentifier)
        collectionView.register(SettingsCell.self, forCellWithReuseIdentifier: settingsCellReuseIdentifier)
        collectionView.register(SettingsKindHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: settingsKindHeaderReuseIdentifier)
        collectionView.register(PrivacyCell.self, forCellWithReuseIdentifier: privacyCellReuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {

        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let _ = self else { return nil }
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            
            section.boundarySupplementaryItems = [header]
            
            if sectionNumber == 2 {
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
                item.contentInsets.leading = -10
                section.interGroupSpacing = 0
            } else {
                header.contentInsets.leading = 0
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
                section.interGroupSpacing = 20
            }
            
            
            return section
        }
       
        return layout
    }
}

extension PrivacySecurityViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else if section == 1 {
            return kind.subSetting.count
        } else {
            return PrivacyKind.allCases.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: ElementKind.sectionHeader, withReuseIdentifier: settingsKindHeaderReuseIdentifier, for: indexPath) as! SettingsKindHeader
            header.configure(with: self.kind.content)
            return header
        } else if indexPath.section == 1 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: privacySecurityHeaderReuseIdentifier, for: indexPath) as! NotificationHeader
            header.set(title: AppStrings.Legal.activity)
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: privacySecurityHeaderReuseIdentifier, for: indexPath) as! NotificationHeader
            header.set(title: AppStrings.Legal.contact)
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: settingsCellReuseIdentifier, for: indexPath) as! SettingsCell
            cell.set(subSetting: kind.subSetting[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: privacyCellReuseIdentifier, for: indexPath) as! PrivacyCell
            cell.set(option: PrivacyKind.allCases[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let _ = kind.subSetting[indexPath.row]
            let controller = UserBlockViewController()
            navigationController?.pushViewController(controller, animated: true) 
        } else if indexPath.section == 2 {
            let option = PrivacyKind.allCases[indexPath.row]
            switch option {
                
            case .center,.privacy:
                showLinks()
            case .contact:
                showMail()
            }
        }
    }
}

extension PrivacySecurityViewController {
    
    private func showLinks() {
        #if DEBUG
        if let privacyURL = URL(string: AppStrings.URL.draftPrivacy) {
            if UIApplication.shared.canOpenURL(privacyURL) {
                presentSafariViewController(withURL: privacyURL)
            } else {
                presentWebViewController(withURL: privacyURL)
            }
        }
        #else
        if let privacyURL = URL(string: AppStrings.URL.draftPrivacy) {
            if UIApplication.shared.canOpenURL(privacyURL) {
                presentSafariViewController(withURL: privacyURL)
            } else {
                presentWebViewController(withURL: privacyURL)
            }
        }
        #endif
    }
    
    private func showMail() {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            
        #if DEBUG
            controller.setToRecipients([AppStrings.App.personalMail])
        #else
            controller.setToRecipients([AppStrings.App.personalMail])
        #endif
            
            controller.mailComposeDelegate = self
            present(controller, animated: true)
        } else {
            return
        }
    }
}



extension PrivacySecurityViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        controller.dismiss(animated: true)
    }
}

