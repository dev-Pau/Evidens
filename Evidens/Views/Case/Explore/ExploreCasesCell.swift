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
        iv.image = UIImage(systemName: "safari", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .quaternarySystemFill
        layer.cornerRadius = 3
        
        addSubviews(exploreImageView)
        
        NSLayoutConstraint.activate([
            exploreImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            exploreImageView.heightAnchor.constraint(equalToConstant: 25),
            exploreImageView.widthAnchor.constraint(equalToConstant: 25),
            exploreImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
        ])
    }
}
