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
    func didTapAppearanceMenu()
}

class SideMenuViewController: UIViewController {
    
    weak var delegate: SideMenuViewControllerDelegate?
    private lazy var lockView = MEPrimaryBlurLockView(frame: view.bounds)
    private let appearanceMenuLauncher = AppearanceMenuLauncher()
    
    enum MenuOptions: String, CaseIterable {
        case bookmarks = "Bookmarks"
        case groups = "Groups"
        case jobs = "Jobs"

        var imageName: String {
            switch self {
            case .bookmarks:
                return "bookmark.fill"
            case .groups:
                return "groups.selected"
            case .jobs:
                return "case.fill"
            }
        }
    }
    
    private let controllerSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.borderWidth = 0.5
        return view
    }()
    
    private let sideMenuTabView = SideMenuTabView(frame: .zero)
    
    private var menuWidth: CGFloat = UIScreen.main.bounds.width - 50
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var settingsImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "gearshape.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
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
        label.textColor = .label
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSettingsTap)))
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        //NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name("ProfileImageUpdateIdentifier"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: NSNotification.Name("UserUpdateIdentifier"), object: nil)
    }
    
    @objc func didReceiveNotification(notification: NSNotification) {
        updateUserData()
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.frame = view.bounds
        view.addSubviews(collectionView, sideMenuTabView, controllerSeparatorView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SideMenuCell.self, forCellWithReuseIdentifier: sideMenuCellReuseIdentifier)
        collectionView.register(SideMenuHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: sideMenuHeaderReuseIdentifier)

        let tabControllerHeight = UITabBarController().tabBar.frame.height
        if let tabControllerShadowColor = UITabBarController().tabBar.standardAppearance.shadowColor {
            controllerSeparatorView.layer.borderColor = tabControllerShadowColor.cgColor
        }
        
        
        NSLayoutConstraint.activate([
            sideMenuTabView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            sideMenuTabView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            sideMenuTabView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            sideMenuTabView.heightAnchor.constraint(equalToConstant: tabControllerHeight),
            
            controllerSeparatorView.topAnchor.constraint(equalTo: view.topAnchor),
            controllerSeparatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controllerSeparatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            controllerSeparatorView.widthAnchor.constraint(equalToConstant: 0.5)
            /*
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
            settingsLabel.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor),
                                      */
            /*
            tabBarView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBarView.heightAnchor.constraint(equalToConstant: tabControllerHeight)
            */
        ])
        
        sideMenuTabView.delegate = self
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
    
    @objc func handleSettingsTap() {
        delegate?.didTapSettings()
    }
    
    func updateUserData(user: User) {
        let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as! SideMenuHeader
        header.configure()
        
        if user.phase != .verified {
            view.addSubview(lockView)
        }
    }
    
    func updateUserData() {
        let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as! SideMenuHeader
        header.configure()
    }
    
    func updateAppearanceSettings(_ sw: UISwitch, appearance: Appearance.Theme) {
        switch appearance {
        case .dark:
            if sw.isOn {
                sideMenuTabView.appearanceSettingsImageView.image = UIImage(systemName: "moon.stars", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            } else {
                sideMenuTabView.appearanceSettingsImageView.image = UIImage(systemName: "sun.max", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            }
        case .system:
            let isSystemDark = UIScreen.main.traitCollection.userInterfaceStyle == .dark ? true : false
            if isSystemDark {
                sideMenuTabView.appearanceSettingsImageView.image = UIImage(systemName: "moon.stars", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            } else {
                sideMenuTabView.appearanceSettingsImageView.image = UIImage(systemName: "sun.max", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            }
        case .light:
            break
        }
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

extension SideMenuViewController: SideMenuTabViewDelegate {
    func didTapConfigureAppearance() {
        //appearanceMenuLauncher.showPostSettings(in: view)
        delegate?.didTapAppearanceMenu()
    }
}

extension SideMenuViewController: SideMenuHeaderDelegate {
    func didTapHeader() {
        delegate?.didTapMenuHeader()
    }
}










protocol SideMenuTabViewDelegate: AnyObject {
    func didTapConfigureAppearance()
}

class SideMenuTabView: UIView {
    weak var delegate: SideMenuTabViewDelegate?
    
    lazy var appearanceSettingsImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAppearanceTap)))
        return iv
    }()
    
    private let tabBarSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 0
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(tabBarSeparatorView, appearanceSettingsImageView)
        NSLayoutConstraint.activate([
            tabBarSeparatorView.topAnchor.constraint(equalTo: topAnchor),
            tabBarSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabBarSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabBarSeparatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            appearanceSettingsImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            appearanceSettingsImageView.topAnchor.constraint(equalTo: tabBarSeparatorView.bottomAnchor, constant: 6),
            appearanceSettingsImageView.heightAnchor.constraint(equalToConstant: 27),
            appearanceSettingsImageView.widthAnchor.constraint(equalToConstant: 27)
        ])
        
        if let tabControllerShadowColor = UITabBarController().tabBar.standardAppearance.shadowColor {
            tabBarSeparatorView.backgroundColor = tabControllerShadowColor
        }
        
        guard let defaultsAppearance = UserDefaults.standard.value(forKey: "themeStateEnum") as? String else { return }
        let defaultsTheme = Appearance.Theme(rawValue: defaultsAppearance) ?? .system
        switch defaultsTheme {
        case .dark:
            appearanceSettingsImageView.image = UIImage(systemName: "moon.stars", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        case .system:
            let isSystemDark = UIScreen.main.traitCollection.userInterfaceStyle == .dark ? true : false
            if isSystemDark {
                appearanceSettingsImageView.image = UIImage(systemName: "moon.stars", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            } else {
                appearanceSettingsImageView.image = UIImage(systemName: "sun.max", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            }
        case .light:
            appearanceSettingsImageView.image = UIImage(systemName: "sun.max", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        }
    }
    
    @objc func handleAppearanceTap() {
        delegate?.didTapConfigureAppearance()
    }
}
