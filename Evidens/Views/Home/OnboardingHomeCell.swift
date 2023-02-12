//
//  OnboardingHomeCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/2/23.
//

import UIKit

class OnboardingHomeCell: UICollectionViewCell {
    
    private let gradientView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let onboardingMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .label
        label.text = "Complete your profile"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        return button
    }()
    
    private let hintImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
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
        backgroundColor = .clear
        addSubviews(gradientView, onboardingMessageLabel, hintImageView)
        NSLayoutConstraint.activate([
            onboardingMessageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            onboardingMessageLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            onboardingMessageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            gradientView.topAnchor.constraint(equalTo: topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: onboardingMessageLabel.topAnchor, constant: -10),
            
            hintImageView.centerXAnchor.constraint(equalTo: gradientView.centerXAnchor),
            hintImageView.centerYAnchor.constraint(equalTo: gradientView.centerYAnchor),
            hintImageView.heightAnchor.constraint(equalToConstant: 30),
            hintImageView.widthAnchor.constraint(equalToConstant: 30)
        ])
        gradientView.layer.cornerRadius = 10
    }
    
    func configure(onboardingOption: OnboardingMessage.HomeHelper) {
        onboardingMessageLabel.text = onboardingOption.rawValue
        gradientView.image = onboardingOption.homeHelperImage.scalePreservingAspectRatio(targetSize: CGSize(width: gradientView.frame.width, height: gradientView.frame.height))
        hintImageView.image = onboardingOption.homeHelperHintImage
    }
}
