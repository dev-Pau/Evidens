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
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
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
            contentImage.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            contentImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentImage.heightAnchor.constraint(equalToConstant: frame.width / 4),
            contentImage.widthAnchor.constraint(equalToConstant: frame.width / 4),
            
            titleLabel.topAnchor.constraint(equalTo: contentImage.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
        
        contentImage.layer.cornerRadius = (frame.width / 4) / 2
        
    }
    
    private func configure() {
        addSubviews(contentImage, titleLabel, descriptionLabel)
        titleLabel.text = "Title should go here"
        descriptionLabel.text = "Description should go here. Description should go here. Description should go here. Description should go here."
    }
}
