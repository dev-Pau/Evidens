//
//  SettingsCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/6/23.
//

import UIKit

class SettingsCell: UICollectionViewCell {
    
    private let settingsImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    private let settingsTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 14, scaleStyle: .title3, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let settingsDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.font = UIFont.addFont(size: 13, scaleStyle: .title1, weight: .regular)
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 0
        return label
    }()
    
    private let chevron: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .center
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: AppStrings.Icons.rightChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = K.Colors.separatorColor
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
        let chevronSize: CGFloat = UIDevice.isPad ? 25 : 20
        let settingsSize: CGFloat = UIDevice.isPad ? 30 : 25
        
        addSubviews(settingsImage, settingsTitle, settingsDescription, chevron)
        NSLayoutConstraint.activate([
            
            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -K.Paddings.Settings.horizontalPadding),
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: chevronSize),
            chevron.heightAnchor.constraint(equalToConstant: chevronSize),
            
            settingsTitle.topAnchor.constraint(equalTo: topAnchor, constant: K.Paddings.Settings.verticalPadding),
            settingsTitle.leadingAnchor.constraint(equalTo: settingsImage.trailingAnchor, constant: 15),
            settingsTitle.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -10),
            
            settingsDescription.topAnchor.constraint(equalTo: settingsTitle.bottomAnchor),
            settingsDescription.leadingAnchor.constraint(equalTo: settingsTitle.leadingAnchor),
            settingsDescription.trailingAnchor.constraint(equalTo: settingsTitle.trailingAnchor),
            settingsDescription.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -K.Paddings.Settings.verticalPadding),
            
            settingsImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: K.Paddings.Settings.horizontalPadding),
            settingsImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            settingsImage.widthAnchor.constraint(equalToConstant: settingsSize),
            settingsImage.heightAnchor.constraint(equalToConstant: settingsSize)
        ])
    }
    
    func set(kind settings: SettingKind) {
        settingsTitle.text = settings.title
        settingsDescription.text = settings.content
        settingsImage.image = settings.image
    }
    
    func set (subSetting setting: SubSettingKind) {
        settingsTitle.text = setting.title
        settingsDescription.text = setting.content
        settingsImage.image = setting.image
    }
}
