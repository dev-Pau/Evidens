//
//  DisabledNotificationsCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/6/23.
//

import UIKit

class DisabledNotificationsCell: UICollectionViewCell {
    
    private let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .center

        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
        let heavyFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.heavy.rawValue
            ]
        ])
        
        label.font = UIFont(descriptor: heavyFontDescriptor, size: 0)

        return label
    }()
    
    private let content: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label

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

        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        return button
    }()
    
    let tapView = NotificationStepView(notificationFlow: .tap)
    let turnView = NotificationStepView(notificationFlow: .turn)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {

        addSubviews(title, content, tapView, turnView, settingsButton)
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            
            content.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
            content.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            
            tapView.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            tapView.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20),
            tapView.topAnchor.constraint(equalTo: content.bottomAnchor, constant: 10),
            tapView.heightAnchor.constraint(equalToConstant: 40),

            turnView.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            turnView.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20),
            turnView.topAnchor.constraint(equalTo: tapView.bottomAnchor, constant: 10),
            turnView.heightAnchor.constraint(equalToConstant: 40),

            settingsButton.topAnchor.constraint(equalTo: turnView.bottomAnchor, constant: 10),
            settingsButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            settingsButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        title.text = AppStrings.Settings.turnNotificationsTitle
        content.text = AppStrings.Settings.turnNotificationsContent
        
        var container = AttributeContainer()
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline)
        let heavyFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold.rawValue
            ]
        ])
        
        container.font = UIFont(descriptor: heavyFontDescriptor, size: 0)
        
        
        settingsButton.configuration?.attributedTitle = AttributedString(AppStrings.Settings.openSettings, attributes: container)
    }
    
    @objc func handleSettings() {
        if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(appSettingsURL) {
                UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
            }
        }
    }
}
