//
//  ResourcesPopoverViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/3/24.
//

import UIKit

private let sideMenuHeaderReuseIdentifier = "SideMenuHeaderReuseIdentifier"
private let sideSubMenuCellReuseIdentifier = "SideSubMenuCellReuseIdentifier"
private let sideSubMenuKindCellReuseIdentifier = "SideSubMenuKindCellReuseIdentifier"

class ResourcesPopoverViewController: UIViewController {
    
    weak var delegate: SideMenuViewControllerDelegate?
    
    private var collectionView: UICollectionView!
    private var settingsCount = 1
    private var helpCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        view.backgroundColor = .systemBackground
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: addLayout())
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        view.addSubviews(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SideMenuHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: sideMenuHeaderReuseIdentifier)
        collectionView.register(SideSubKindMenuCell.self, forCellWithReuseIdentifier: sideSubMenuKindCellReuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(SideSubMenuCell.self, forCellWithReuseIdentifier: sideSubMenuCellReuseIdentifier)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func addLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let _ = self else { return nil }
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)

            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0)
            
            if sectionNumber == 0 {
                section.boundarySupplementaryItems = [header]
            }
            
            return section
        }

        return layout
    }
}

extension ResourcesPopoverViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return settingsCount
        } else  {
            return helpCount
        }
    }
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: sideMenuHeaderReuseIdentifier, for: indexPath) as! SideMenuHeader
        return header
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = collectionView.cellForItem(at: indexPath) as! SideSubMenuCell
                cell.toggleChevron()
                if settingsCount == 1 {
                    settingsCount = SideSubMenu.settings.kind.count + 1
                    self.collectionView.performBatchUpdates {
                        collectionView.insertItems(at: [IndexPath(item: 1, section: 0), IndexPath(item: 2, section: 0)])
                    }
                } else {
                    settingsCount = 1
                    self.collectionView.performBatchUpdates {
                        collectionView.deleteItems(at: [IndexPath(item: 1, section: 0), IndexPath(item: 2, section: 0)])
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
                        collectionView.insertItems(at: [IndexPath(item: 1, section: 1), IndexPath(item: 2, section: 1)])
                    }
                } else {
                    helpCount = 1
                    self.collectionView.performBatchUpdates {
                        collectionView.deleteItems(at: [IndexPath(item: 1, section: 1), IndexPath(item: 2, section: 1)])
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

