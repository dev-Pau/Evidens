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

        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .callout)
        let heavyFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold.rawValue
            ]
        ])
        
        label.font = UIFont(descriptor: heavyFontDescriptor, size: 0)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let settingsDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        let customFontSize: CGFloat = 14.0
        let fontMetrics = UIFontMetrics(forTextStyle: .subheadline)
        let scaledFontSize = fontMetrics.scaledValue(for: customFontSize)
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline)
        let heavyFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.regular.rawValue
            ]
        ])
        
        label.font = UIFont(descriptor: heavyFontDescriptor, size: scaledFontSize)

        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let chevron: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .center
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: AppStrings.Icons.rightChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = separatorColor
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
        addSubviews(settingsImage, settingsTitle, settingsDescription, chevron)
        NSLayoutConstraint.activate([
            
            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 20),
            chevron.heightAnchor.constraint(equalToConstant: 20),
            
            settingsTitle.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            settingsTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 47),
            settingsTitle.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -10),
            
            settingsDescription.topAnchor.constraint(equalTo: settingsTitle.bottomAnchor, constant: 3),
            settingsDescription.leadingAnchor.constraint(equalTo: settingsTitle.leadingAnchor),
            settingsDescription.trailingAnchor.constraint(equalTo: settingsTitle.trailingAnchor),
            settingsDescription.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            settingsImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            settingsImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            settingsImage.widthAnchor.constraint(equalToConstant: 25),
            settingsImage.heightAnchor.constraint(equalToConstant: 25)
        ])
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
