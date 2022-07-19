//
//  RegistrationListView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/7/22.
//

import UIKit

class RegistrationListView: UIView {
    
    private var category: String
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.baseBackgroundColor = lightColor
        button.configuration?.image = UIImage(named: "checkmark")?.scalePreservingAspectRatio(targetSize: CGSize(width: 18, height: 18)).withTintColor(primaryColor)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(category: String) {
        self.category = category
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(categoryButton, categoryLabel)
        categoryLabel.text = category
    
        
        NSLayoutConstraint.activate([
            categoryButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            categoryButton.widthAnchor.constraint(equalToConstant: 30),
            categoryButton.heightAnchor.constraint(equalToConstant: 30),
            categoryButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            categoryLabel.leadingAnchor.constraint(equalTo: categoryButton.trailingAnchor, constant: 10),
            categoryLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            categoryLabel.heightAnchor.constraint(equalToConstant: 20),
            categoryLabel.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor)
        ])
        
    }
    
}
