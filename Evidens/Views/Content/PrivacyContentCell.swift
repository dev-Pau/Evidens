//
//  PostPrivacyMenu.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/6/22.
//

import UIKit


class PrivacyContentCell: UICollectionViewCell {

    private let padding: CGFloat = 10

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .largeTitle, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 12, scaleStyle: .largeTitle, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let selectorButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.baseForegroundColor = primaryColor
        button.configuration?.cornerStyle = .capsule
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
        let stack = UIStackView(arrangedSubviews: [titleLabel, contentLabel])
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubviews(button, selectorButton, stack)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            button.widthAnchor.constraint(equalToConstant: 30),
            button.heightAnchor.constraint(equalToConstant: 30),
            
            selectorButton.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            selectorButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            selectorButton.heightAnchor.constraint(equalToConstant: 15),
            selectorButton.widthAnchor.constraint(equalToConstant: 15),
            
            stack.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: padding),
            stack.trailingAnchor.constraint(equalTo: selectorButton.leadingAnchor, constant: -padding),
            stack.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    func set(postPrivacy: PostPrivacy) {
        button.configuration?.image = postPrivacy.image.scalePreservingAspectRatio(targetSize: CGSize(width: 27, height: 27)).withRenderingMode(.alwaysOriginal).withTintColor(primaryColor)
        contentLabel.text = postPrivacy.content
        titleLabel.text = postPrivacy.title
    }
    
    func set(casePrivacy: CasePrivacy) {
        button.configuration?.image = casePrivacy.image.scalePreservingAspectRatio(targetSize: CGSize(width: 27, height: 27)).withRenderingMode(.alwaysOriginal).withTintColor(primaryColor)
        titleLabel.text = casePrivacy.title
        contentLabel.text = casePrivacy.content
    }
}
