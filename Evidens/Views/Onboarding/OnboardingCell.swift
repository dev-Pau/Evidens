//
//  OnboardingCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/9/22.
//

import UIKit

class OnboardingCell: UICollectionViewCell {
    
    private var onboardingTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    private var onboardingDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = grayColor
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubviews(onboardingTitleLabel, onboardingDescriptionLabel)
        NSLayoutConstraint.activate([
            onboardingTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            onboardingTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            onboardingTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            onboardingDescriptionLabel.topAnchor.constraint(equalTo: onboardingTitleLabel.bottomAnchor, constant: 10),
            onboardingDescriptionLabel.leadingAnchor.constraint(equalTo: onboardingTitleLabel.leadingAnchor),
            onboardingDescriptionLabel.trailingAnchor.constraint(equalTo: onboardingTitleLabel.trailingAnchor, constant: -10)
        ])
    }
    
    func set(message: OnboardingMessage) {
        onboardingTitleLabel.text = message.title
        onboardingDescriptionLabel.text = message.description
    }
}
