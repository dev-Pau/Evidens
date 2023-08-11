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
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let settingsDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let chevronImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
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
        addSubviews(settingsImage, settingsTitle, settingsDescription, chevronImage)
        NSLayoutConstraint.activate([
            
            chevronImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            chevronImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronImage.widthAnchor.constraint(equalToConstant: 14),
            chevronImage.heightAnchor.constraint(equalToConstant: 17),
            
            settingsTitle.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            settingsTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 47),
            settingsTitle.trailingAnchor.constraint(equalTo: chevronImage.leadingAnchor, constant: -10),
            
            settingsDescription.topAnchor.constraint(equalTo: settingsTitle.bottomAnchor, constant: 1),
            settingsDescription.leadingAnchor.constraint(equalTo: settingsTitle.leadingAnchor),
            settingsDescription.trailingAnchor.constraint(equalTo: settingsTitle.trailingAnchor),
            settingsDescription.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            settingsImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            settingsImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            settingsImage.widthAnchor.constraint(equalToConstant: 20),
            settingsImage.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        chevronImage.image = UIImage(systemName: AppStrings.Icons.rightChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withRenderingMode(.alwaysOriginal).withTintColor(separatorColor!)
    }
    
    func set(kind settings: SettingKind) {
        settingsTitle.text = settings.title
        settingsDescription.text = settings.content
        settingsImage.image = settings.image
    }
    
    func set (subSetting setting: SubSetting) {
        settingsTitle.text = setting.title
        settingsDescription.text = setting.content
        settingsImage.image = setting.image
    }
}