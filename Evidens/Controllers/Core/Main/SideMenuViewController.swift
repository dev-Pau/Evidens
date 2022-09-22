//
//  SideMenuViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/9/22.
//

import UIKit

private let sideMenuCellReuseIdentifier = "SideMenuCellReuseIdentifier"
private let sideMenuHeaderReuseIdentifier = "SideMenuHeaderReuseIdentifier"

protocol SideMenuViewControllerDelegate: AnyObject {
    func didTapMenuHeader()
    func didTapSettings()
    func didSelectMenuOption(option: SideMenuViewController.MenuOptions)
}

class SideMenuViewController: UIViewController {
    
    weak var delegate: SideMenuViewControllerDelegate?
    
    enum MenuOptions: String, CaseIterable {
        case bookmarks = "Bookmarks"

        var imageName: String {
            switch self {
            case .bookmarks:
                return "bookmark"
            }
        }
    }
    
    private var menuWidth: CGFloat = UIScreen.main.bounds.width - 50
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var settingsImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "gearshape.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(grayColor)
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSettingsTap)))
        return iv
    }()
    
    private lazy var settingsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Settings"
        label.textAlignment = .left
        label.textColor = grayColor
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSettingsTap)))
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 70)
        view.addSubviews(collectionView, separatorView, settingsImageView, settingsLabel)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SideMenuCell.self, forCellWithReuseIdentifier: sideMenuCellReuseIdentifier)
        collectionView.register(SideMenuHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: sideMenuHeaderReuseIdentifier)
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: 20),
            separatorView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -70),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            settingsImageView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            settingsImageView.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor),
            settingsImageView.heightAnchor.constraint(equalToConstant: 30),
            settingsImageView.widthAnchor.constraint(equalToConstant: 30),
            
            settingsLabel.centerYAnchor.constraint(equalTo: settingsImageView.centerYAnchor),
            settingsLabel.leadingAnchor.constraint(equalTo: settingsImageView.trailingAnchor, constant: 10),
            settingsLabel.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor)
        ])
    }
    
    @objc func handleSettingsTap() {
        delegate?.didTapSettings()
    }
}

extension SideMenuViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: sideMenuHeaderReuseIdentifier, for: indexPath) as! SideMenuHeader
        header.delegate = self
        return header
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MenuOptions.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sideMenuCellReuseIdentifier, for: indexPath) as! SideMenuCell
        cell.set(title: MenuOptions.allCases[indexPath.row].rawValue, image: MenuOptions.allCases[indexPath.row].imageName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selection = MenuOptions.allCases[indexPath.row]
        delegate?.didSelectMenuOption(option: selection)
    }
}

extension SideMenuViewController: SideMenuHeaderDelegate {
    func didTapHeader() {
        delegate?.didTapMenuHeader()
    }
}
