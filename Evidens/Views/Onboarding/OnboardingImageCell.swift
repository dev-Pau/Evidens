//
//  OnboardingImageCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/3/23.
//

import UIKit

class OnboardingImageCell: UICollectionViewCell {
    
    private let onboardingImageCell: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
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
        addSubviews(onboardingImageCell)
        NSLayoutConstraint.activate([
            onboardingImageCell.topAnchor.constraint(equalTo: topAnchor),
            onboardingImageCell.leadingAnchor.constraint(equalTo: leadingAnchor),
            onboardingImageCell.trailingAnchor.constraint(equalTo: trailingAnchor),
            onboardingImageCell.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func set(image: UIImage) {
        onboardingImageCell.image = image
    }
    
    /*
    func set(message: OnboardingMessage) {
        onboardingTitleLabel.text = message.title
        onboardingDescriptionLabel.text = message.description
    }
     */
}

