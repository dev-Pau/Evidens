//
//  PopupView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/8/22.
//

import UIKit

class PopUpView: UIView {
    
    private let image: String
    private let title: String
    private let popUpKind: PopUpKind
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 14, scaleStyle: .largeTitle, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private let popUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.xmarkCircleFill)
        button.configuration?.buttonSize = .small
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(title: String, image: String, popUpKind: PopUpKind) {
        self.title = title
        self.image = image
        self.popUpKind = popUpKind
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        titleLabel.text = title
        let color = popUpKind == .regular ? primaryColor : .systemRed
        popUpButton.configuration?.image = UIImage(systemName: image, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(color)
        
        addSubviews(popUpButton, titleLabel)
        NSLayoutConstraint.activate([
            popUpButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            popUpButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            popUpButton.heightAnchor.constraint(equalToConstant: 25),
            popUpButton.widthAnchor.constraint(equalToConstant: 25),
            
            titleLabel.centerYAnchor.constraint(equalTo: popUpButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: popUpButton.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
}
