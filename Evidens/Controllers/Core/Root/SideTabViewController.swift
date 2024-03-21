//
//  SideTabViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/3/24.
//

import UIKit

private let tabBarIconCellReuseIdentifier = "TabBarIconCellReuseIdentifier"

class SideTabViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var addButton: UIButton!
    
    weak var tabDelegate: SideTabViewControllerDelegate?
    weak var popoverDelegate: SideMenuViewControllerDelegate?
    
    private var selectedIcon: TabIcon = .cases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {

        view.backgroundColor = .systemBackground
        
        let buttonSize = UIWindow.visibleScreenWidth * 0.13 / 1.7
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: addLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TabBarIconCell.self, forCellWithReuseIdentifier: tabBarIconCellReuseIdentifier)
        collectionView.bounces = false
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = K.Colors.separatorColor
        
        addButton = UIButton(type: .custom)
        addButton.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = K.Colors.primaryColor
        configuration.cornerStyle = .capsule
        configuration.image = UIImage(systemName: AppStrings.Icons.plus, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withTintColor(.white).scalePreservingAspectRatio(targetSize: CGSize(width: buttonSize / 2, height: buttonSize / 2))
        
        addButton.configuration = configuration
        addButton.tintAdjustmentMode = .normal
        addButton.layer.shadowColor = UIColor.secondaryLabel.cgColor
        addButton.layer.shadowOpacity = 0.5
        addButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        addButton.layer.shadowRadius = 4
        
        view.addSubview(collectionView)
        view.addSubview(separator)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            separator.topAnchor.constraint(equalTo: view.topAnchor),
            separator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            separator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separator.widthAnchor.constraint(equalToConstant: 0.4),
            
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            addButton.heightAnchor.constraint(equalToConstant: buttonSize),
            addButton.widthAnchor.constraint(equalToConstant: buttonSize)
        ])
    }
    
    private func addLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(250))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.top = -10
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func presentPopoverController(for cell: UICollectionViewCell, at indexPath: IndexPath) {
        
        let popoverContentController = ResourcesPopoverViewController()
        popoverContentController.delegate = self
        popoverContentController.modalPresentationStyle = .popover
        
        if let popoverPresentationController = popoverContentController.popoverPresentationController, let cell = collectionView.cellForItem(at: indexPath) {
            popoverPresentationController.permittedArrowDirections = [.down]
            popoverPresentationController.sourceView = cell
            popoverPresentationController.delegate = self
            present(popoverContentController, animated: true)
        }
    }
    
    @objc func handleAdd() {
        tabDelegate?.didTapAdd()
    }
}

extension SideTabViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TabIcon.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tabBarIconCellReuseIdentifier, for: indexPath) as! TabBarIconCell
        cell.tabIcon = TabIcon.allCases[indexPath.row]
        
        if indexPath.row == 1 {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        } else if indexPath.row == 8 {
            if let cell = collectionView.cellForItem(at:  indexPath) as? TabBarIconCell {
                cell.animateBounce(scale: 0.8)
                presentPopoverController(for: cell, at: indexPath)
            }
            return false
        } else {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tabSelected = TabIcon.allCases[indexPath.row]
        
        switch tabSelected {
            
        case .icon, .resources:
            break
        case .cases, .network, .notifications, .search, .bookmark, .drafts, .profile:
            tabDelegate?.didTapTabIcon(tabSelected)
        }
    }
}

extension SideTabViewController: SideMenuViewControllerDelegate {
    func didTapMenuHeader() {
        
        let indexPath = IndexPath(item: 7, section: 0)
        collectionView(collectionView, didSelectItemAt: indexPath)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
    }
    
    func didSelectMenuOption(option: SideMenu) {
        popoverDelegate?.didSelectMenuOption(option: option)
    }
    
    func didSelectSubMenuOption(option: SideSubMenuKind) {
        popoverDelegate?.didSelectSubMenuOption(option: option)
    }
}

extension SideTabViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {

    }

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

