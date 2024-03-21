//
//  EmtpyGroupCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/1/23.
//

import UIKit

protocol PrimaryEmptyCellDelegate: AnyObject {
    func didTapEmptyAction()
}

class PrimaryEmptyCell: UICollectionViewCell {
    
    weak var delegate: PrimaryEmptyCellDelegate?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 28, scaleStyle: .title1, weight: .heavy)
        
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.numberOfLines = 0
        label.textColor = K.Colors.primaryGray
        return label
    }()
    
    private lazy var discoverButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintAdjustmentMode = .normal
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 25, bottom: 20, trailing: 25)
        button.addTarget(self, action: #selector(handleDiscoverGroups), for: .touchUpInside)
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

        addSubviews(titleLabel, descriptionLabel, discoverButton)
       
        NSLayoutConstraint.activate([
           
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
           
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        
            discoverButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            discoverButton.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            discoverButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func set(withTitle title: String, withDescription description: String, withButtonText buttonText: String? = nil) {
        
        descriptionLabel.text = description
        titleLabel.text = title
        
        if let buttonText = buttonText {
            var container = AttributeContainer()
            container.font = UIFont.addFont(size: 16, scaleStyle: .body, weight: .bold, scales: false)
            discoverButton.configuration?.attributedTitle = AttributedString(buttonText, attributes: container)
        } else {
            discoverButton.isHidden = true
        }
    }
    
    @objc func handleDiscoverGroups() {
        delegate?.didTapEmptyAction()
    }
}
