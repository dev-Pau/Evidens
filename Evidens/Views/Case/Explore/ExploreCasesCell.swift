//
//  ExploreCasesCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/10/22.
//

import UIKit

class ExploreCasesCell: UICollectionViewCell {
    
    private let exploreImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(systemName: "safari", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withRenderingMode(.alwaysOriginal).withTintColor(.black)
        return iv
    }()
    
    private let exploreLabel: UILabel = {
        let label = UILabel()
        label.text = "Explore"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = lightColor
        layer.cornerRadius = 2
        
        addSubviews(exploreImageView, exploreLabel)
        
        NSLayoutConstraint.activate([
            exploreImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            exploreImageView.heightAnchor.constraint(equalToConstant: 25),
            exploreImageView.widthAnchor.constraint(equalToConstant: 25),
            exploreImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            exploreLabel.centerYAnchor.constraint(equalTo: exploreImageView.centerYAnchor),
            exploreLabel.leadingAnchor.constraint(equalTo: exploreImageView.trailingAnchor, constant: 10),
            exploreLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])
    }
}
