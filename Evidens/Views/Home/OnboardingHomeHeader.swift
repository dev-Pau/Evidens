//
//  OnboardingHomeHeader.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/2/23.
//

import UIKit

protocol OnboardingHomeHeaderDelegate: AnyObject {
    func didTapConfigureProfile()
}

class OnboardingHomeHeader: UICollectionReusableView {
    
    weak var delegate: OnboardingHomeHeaderDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = AppStrings.Sections.setUp
        label.textColor = .label
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let blackFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.heavy.rawValue
            ]
        ])
        
        label.font = UIFont(descriptor: blackFontDescriptor, size: 0)
        return label
    }()
    
    private lazy var configureProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.buttonSize = .small
        button.configuration?.cornerStyle = .capsule
        button.tintAdjustmentMode = .normal
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString(AppStrings.SideMenu.profile, attributes: container)
        button.addTarget(self, action: #selector(handleConfigureTap), for: .touchUpInside)
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = AppStrings.Sections.know
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .subheadline)
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
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
        addSubviews(titleLabel, contentLabel, configureProfileButton, separatorView)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            //contentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60),
            
            configureProfileButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 10),
            configureProfileButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            configureProfileButton.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            configureProfileButton.heightAnchor.constraint(equalToConstant: 40),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    @objc func handleConfigureTap() {
        delegate?.didTapConfigureProfile()
    }
}
