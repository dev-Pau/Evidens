//
//  SideMenuViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/9/22.
//

import UIKit

private let sideMenuCellReuseIdentifier = "SideMenuCellReuseIdentifier"
private let sideSubMenuCellReuseIdentifier = "SideSubMenuCellReuseIdentifier"
private let sideMenuFooterReuseIdentifier = "SideMenuFooterReuseIdentifier"
private let sideSubMenuKindCellReuseIdentifier = "SideSubMenuKindCellReuseIdentifier"

protocol SideMenuViewControllerDelegate: AnyObject {
    func didTapMenuHeader()
    func didSelectMenuOption(option: SideMenu)
    func didSelectSubMenuOption(option: SideSubMenuKind)
    func didTapAppearanceMenu()
}

class SideMenuViewController: UIViewController {
    
    weak var delegate: SideMenuViewControllerDelegate?
  
    private let appearanceMenuLauncher = AppearanceMenu()
    private let sideMenuView = SideMenuView()
    
    private let controllerSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.borderWidth = 0.5
        return view
    }()
    
    private var settingsCount = 1
    private var helpCount = 1
    
    private let sideMenuTabView = SideMenuToolbar(frame: .zero)
    
    private var menuWidth: CGFloat = UIScreen.main.bounds.width - 50
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange(notification:)), name: NSNotification.Name(AppPublishers.Names.refreshUser), object: nil)
    }
    
    @objc func userDidChange(notification: NSNotification) {
        updateUserData()
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        //collectionView.frame = view.bounds
        view.addSubviews(sideMenuView, collectionView, sideMenuTabView, controllerSeparatorView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SideMenuCell.self, forCellWithReuseIdentifier: sideMenuCellReuseIdentifier)
        collectionView.register(SideSubKindMenuCell.self, forCellWithReuseIdentifier: sideSubMenuKindCellReuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(SideSubMenuCell.self, forCellWithReuseIdentifier: sideSubMenuCellReuseIdentifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: sideMenuFooterReuseIdentifier)
        
        let tabControllerHeight = UITabBarController().tabBar.frame.height
        if let tabControllerShadowColor = UITabBarController().tabBar.standardAppearance.shadowColor {
            controllerSeparatorView.layer.borderColor = tabControllerShadowColor.cgColor
        }
        
        NSLayoutConstraint.activate([
            sideMenuView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sideMenuView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sideMenuView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sideMenuView.heightAnchor.constraint(equalToConstant: 80 + (view.frame.width - 40) / 3),
            
            sideMenuTabView.leadingAnchor.constraint(equalTo: sideMenuView.leadingAnchor),
            sideMenuTabView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sideMenuTabView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -tabControllerHeight),
            sideMenuTabView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            collectionView.topAnchor.constraint(equalTo: sideMenuView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: sideMenuView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: sideMenuView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: sideMenuTabView.topAnchor),

            controllerSeparatorView.topAnchor.constraint(equalTo: view.topAnchor),
            controllerSeparatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controllerSeparatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            controllerSeparatorView.widthAnchor.constraint(equalToConstant: 0.5)
        ])
        
        sideMenuView.delegate = self
        sideMenuTabView.toolbarDelegate = self
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 if let tabControllerShadowColor = UITabBarController().tabBar.standardAppearance.shadowColor {
                     controllerSeparatorView.layer.borderColor = tabControllerShadowColor.cgColor
                 }
             }
         }
    }
    
    func updateUserData(user: User) {
        sideMenuView.configure()
    }
    
    func updateUserData() {
        sideMenuView.configure()
    }
    
    func updateAppearanceSettings(_ sw: UISwitch, appearance: Appearance) {
        switch appearance {
        case .dark:
            if sw.isOn {
                sideMenuTabView.appearanceSettingsImageView.image = UIImage(systemName: AppStrings.Icons.moon, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            } else {
                sideMenuTabView.appearanceSettingsImageView.image = UIImage(systemName: AppStrings.Icons.sun, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            }
        case .system:
            let isSystemDark = UIScreen.main.traitCollection.userInterfaceStyle == .dark ? true : false
            if isSystemDark {
                sideMenuTabView.appearanceSettingsImageView.image = UIImage(systemName: AppStrings.Icons.moon, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            } else {
                sideMenuTabView.appearanceSettingsImageView.image = UIImage(systemName: AppStrings.Icons.sun, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            }
        case .light:
            break
        }
    }
}

extension SideMenuViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return SideMenu.allCases.count
        } else if section == 1 {
            return settingsCount
        } else {
            return helpCount
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 || section == 1 {
            return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sideMenuCellReuseIdentifier, for: indexPath) as! SideMenuCell
            cell.set(option: SideMenu.allCases[indexPath.row])
            return cell
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sideSubMenuCellReuseIdentifier, for: indexPath) as! SideSubMenuCell
                cell.set(option: SideSubMenu.settings)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sideSubMenuKindCellReuseIdentifier, for: indexPath) as! SideSubKindMenuCell
                cell.set(option: SideSubMenu.settings.kind[indexPath.row - 1])
                return cell
            }
        } else {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sideSubMenuCellReuseIdentifier, for: indexPath) as! SideSubMenuCell
                cell.set(option: SideSubMenu.help)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sideSubMenuKindCellReuseIdentifier, for: indexPath) as! SideSubKindMenuCell
                cell.set(option: SideSubMenu.help.kind[indexPath.row - 1])
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 1 || indexPath.section == 2 {
            return CGSize(width: menuWidth, height: 30)
        } else {
            return CGSize(width: menuWidth, height: 40)
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: sideMenuFooterReuseIdentifier, for: indexPath)
            
            let separatorLine = UIView()
            separatorLine.backgroundColor = separatorColor
            separatorLine.translatesAutoresizingMaskIntoConstraints = false
            footerView.addSubview(separatorLine)

            NSLayoutConstraint.activate([
                separatorLine.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20),
                separatorLine.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20),
                separatorLine.bottomAnchor.constraint(equalTo: footerView.bottomAnchor),
                separatorLine.heightAnchor.constraint(equalToConstant: 0.4)
            ])
            
            return footerView
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return section == 0 ? CGSize(width: collectionView.bounds.width, height: 20) : CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let selection = SideMenu.allCases[indexPath.row]
            delegate?.didSelectMenuOption(option: selection)
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = collectionView.cellForItem(at: indexPath) as! SideSubMenuCell
                cell.toggleChevron()
                if settingsCount == 1 {
                    settingsCount = SideSubMenu.settings.kind.count + 1
                    self.collectionView.performBatchUpdates {
                            collectionView.insertItems(at: [IndexPath(item: 1, section: 1), IndexPath(item: 2, section: 1)])
                    }
                } else {
                    settingsCount = 1
                    self.collectionView.performBatchUpdates {
                            collectionView.deleteItems(at: [IndexPath(item: 1, section: 1), IndexPath(item: 2, section: 1)])
                    }
                }
            } else {
                let kind = SideSubMenu.settings.kind[indexPath.row - 1]
                switch kind {
                case .settings, .legal: delegate?.didSelectSubMenuOption(option: kind)
                case .app, .contact: break
                }
            }
            
            
        } else {
            if indexPath.row == 0 {
                let cell = collectionView.cellForItem(at: indexPath) as! SideSubMenuCell
                cell.toggleChevron()
                if helpCount == 1 {
                    helpCount = SideSubMenu.help.kind.count + 1
                    self.collectionView.performBatchUpdates {
                            collectionView.insertItems(at: [IndexPath(item: 1, section: 2), IndexPath(item: 2, section: 2)])
                    }
                } else {
                    helpCount = 1
                    self.collectionView.performBatchUpdates {
                            collectionView.deleteItems(at: [IndexPath(item: 1, section: 2), IndexPath(item: 2, section: 2)])
                    }
                }
            } else {
                let kind = SideSubMenu.help.kind[indexPath.row - 1]
                switch kind {
                case .settings, .legal: break
                case .contact, .app:
                    delegate?.didSelectSubMenuOption(option: kind)
                }
            }
        }
    }
}

extension SideMenuViewController: SideMenuTabViewDelegate {
   
    func didTapConfigureAppearance() {
        delegate?.didTapAppearanceMenu()
    }
}

extension SideMenuViewController: SideMenuViewDelegate {
    func didTapProfile() {
        delegate?.didTapMenuHeader()
    }
}

protocol SideMenuTabViewDelegate: AnyObject {
    func didTapConfigureAppearance()
}
