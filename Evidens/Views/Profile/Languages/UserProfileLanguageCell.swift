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
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
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
        addSubviews(languageTitleLabel, languageLevelLabel, separatorView)
        
        NSLayoutConstraint.activate([
            languageTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            languageTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            languageTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            languageLevelLabel.topAnchor.constraint(equalTo: languageTitleLabel.bottomAnchor, constant: 5),
            languageLevelLabel.leadingAnchor.constraint(equalTo: languageTitleLabel.leadingAnchor),
            languageLevelLabel.trailingAnchor.constraint(equalTo: languageTitleLabel.trailingAnchor),
            languageLevelLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
        ])
    }
    
    func set(language: Language) {
        languageTitleLabel.text = language.name
        languageLevelLabel.text = language.proficiency
    }
}
