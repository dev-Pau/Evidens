//
//  UserProfileLanguageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/8/22.
//

import UIKit

class UserProfileLanguageCell: UICollectionViewCell {
    
    private let languageTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let languageLevelLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var buttonImage: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))!.withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        button.configuration?.buttonSize = .mini
        button.isHidden = true
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        addSubviews(languageTitleLabel, languageLevelLabel)
        
        NSLayoutConstraint.activate([
            languageTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            languageTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            languageTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            languageLevelLabel.topAnchor.constraint(equalTo: languageTitleLabel.bottomAnchor, constant: 5),
            languageLevelLabel.leadingAnchor.constraint(equalTo: languageTitleLabel.leadingAnchor),
            languageLevelLabel.trailingAnchor.constraint(equalTo: languageTitleLabel.trailingAnchor),
            languageLevelLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }
    
    func set(language: Language) {
        languageTitleLabel.text = language.name
        languageLevelLabel.text = language.proficiency
    }
}
