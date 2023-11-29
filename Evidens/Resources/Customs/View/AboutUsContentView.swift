//
//  AboutUsContentView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/6/23.
//

import UIKit

class AboutUsContentView: UIView {
    
    private let contentImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .white
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
        let heavyFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold.rawValue
            ]
        ])
        
        label.font = UIFont(descriptor: heavyFontDescriptor, size: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()

        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .callout)
        let heavyFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold.rawValue
            ]
        ])
        
        label.font = UIFont(descriptor: heavyFontDescriptor, size: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
    }
    
    func configure() {
        addSubviews(titleLabel)
    }
    
    func configure(with kind: AboutKind) {
        titleLabel.text = kind.title
    }
}
