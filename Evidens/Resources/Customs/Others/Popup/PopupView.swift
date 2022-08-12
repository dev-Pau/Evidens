//
//  PopupView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/8/22.
//

import UIKit

class PopupView: UIView {
    
    private let image: String
    private let title: String
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "xmark.circle.fill")
        button.configuration?.buttonSize = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(title: String, image: String) {
        self.title = title
        self.image = image
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        titleLabel.text = title
        infoButton.configuration?.image = UIImage(systemName: image, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(primaryColor)
        
        addSubviews(infoButton, titleLabel)
        NSLayoutConstraint.activate([
            infoButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            infoButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            infoButton.heightAnchor.constraint(equalToConstant: 25),
            infoButton.widthAnchor.constraint(equalToConstant: 25),
            
            titleLabel.centerYAnchor.constraint(equalTo: infoButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: infoButton.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
    
    
    
    
}
