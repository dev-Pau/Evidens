//
//  MERegistrationDocumentView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/8/22.
//

import UIKit

class MERegistrationDocumentView: UIView {
    
    private var title: String
    private var image: String
    
    private let identityImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let identityLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
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
        translatesAutoresizingMaskIntoConstraints = false
        layer.borderWidth = 1
        layer.borderColor = lightGrayColor.cgColor
        layer.cornerRadius = 5
        
        addSubviews(identityImageView, identityLabel)
        
        NSLayoutConstraint.activate([
            identityImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            identityImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            identityImageView.widthAnchor.constraint(equalToConstant: 30),
            identityImageView.heightAnchor.constraint(equalToConstant: 30),
            
            identityLabel.centerYAnchor.constraint(equalTo: identityImageView.centerYAnchor),
            identityLabel.leadingAnchor.constraint(equalTo: identityImageView.trailingAnchor, constant: 10),
            identityLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
        
        identityImageView.image = UIImage(systemName: image)?.withRenderingMode(.alwaysOriginal).withTintColor(primaryColor)
        identityLabel.text = title
        
    }
    
}
