//
//  OnboardingHomeCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/2/23.
//

import UIKit

class OnboardingHomeCell: UICollectionViewCell {
    
    private let gradientView: UIView = {
        let view = UIView()
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //gradientView.image = UIImage(named: "profileGradient")?.scalePreservingAspectRatio(targetSize: CGSize(width: gradientView.frame.width, height: gradientView.frame.height))
        let gradient = CAGradientLayer(start: .bottomLeft, end: .centerRight, colors: [UIColor.systemOrange.cgColor, UIColor.systemCyan.cgColor], type: .axial)
        gradient.frame = gradientView.bounds
        gradient.cornerRadius = 10
        gradientView.layer.addSublayer(gradient)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .clear
        addSubviews(gradientView, onboardingMessageLabel)
        NSLayoutConstraint.activate([
            onboardingMessageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            onboardingMessageLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            onboardingMessageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            gradientView.topAnchor.constraint(equalTo: topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: onboardingMessageLabel.topAnchor, constant: -10)
        ])

        gradientView.layer.cornerRadius = 10

    }
}
