//
//  SideMenuToolbar.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/7/23.
//

import UIKit


class SideMenuToolbar: UIToolbar {
    weak var toolbarDelegate: SideMenuTabViewDelegate?
    
    lazy var appearanceSettingsImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAppearanceTap)))
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        let appearance = UIToolbarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = separatorColor
        
        standardAppearance = appearance
        scrollEdgeAppearance = appearance
        
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(appearanceSettingsImageView)
        NSLayoutConstraint.activate([
            appearanceSettingsImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            appearanceSettingsImageView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            appearanceSettingsImageView.heightAnchor.constraint(equalToConstant: 27),
            appearanceSettingsImageView.widthAnchor.constraint(equalToConstant: 27),
        ])
        
        var defaultAppearance: Appearance!
        
        if let appearance = UserDefaults.standard.value(forKey: "themeStateEnum") as? Int {
            defaultAppearance = Appearance(rawValue: appearance)
        } else {
            defaultAppearance = Appearance.system
        }
       
        switch defaultAppearance {
        case .dark:
            appearanceSettingsImageView.image = UIImage(systemName: AppStrings.Icons.moon, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        case .system:
            let isSystemDark = UIScreen.main.traitCollection.userInterfaceStyle == .dark ? true : false
            if isSystemDark {
                appearanceSettingsImageView.image = UIImage(systemName: AppStrings.Icons.moon, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            } else {
                appearanceSettingsImageView.image = UIImage(systemName: AppStrings.Icons.sun, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            }
        case .light:
            appearanceSettingsImageView.image = UIImage(systemName: AppStrings.Icons.sun, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        case .none:
            break
        }
    }
    
    @objc func handleAppearanceTap() {
        toolbarDelegate?.didTapConfigureAppearance()
    }
}

